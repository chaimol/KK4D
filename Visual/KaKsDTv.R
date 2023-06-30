#############
#脚本用于获取输出的KaKs4DTv的峰值，并可视化.可用于1到多个基因组之间的结果的分析
#仅适用于KK4D的输出的下游分析可视化，注意输出的峰值可能比真实的值多，需要自行选择合适的位置

##用于kaks4DTv的下游输出的结果的可视化和峰值的计算
#####输入参数有3个：ref_genome_abbr config.txt workpath
###获取脚本的输入的参数
args<-commandArgs(T) #收集参数给args变量
#Usage:Rscript KaKs4DTv.R ref_genome_abbr config.txt workpath
#第1个参数是用于输出的文件名的前缀
#第2个参数是输入配置文件conifg.txt格式如下：
## 分别是3字符缩写 拉丁学名 是否包含自身比对
#Ath A.thaliana TRUE
#Tca T.cacao TRUE
#Tha T.hassleriana FALSE
#Vvi V.vinifera TRUE

#第3个参数是工作路径
# 输入文件是config.txt
#第4个参数是KaKs|4DTv|both,三选一，决定分析的是哪一种输入文件
args <- c("Csp","config.txt","E:/bioinformation_center/laoshugua/KaKs/V2","both")

if ( length(args)==0 | args[1] == "-h" | args[1] == "--help" | length(args)<4){
  stop("\n Usage: 
       KaKs4DTv.R ref_genome_abbr config.txt workpath both 
       KaKs4DTv.R ref_genome_abbr config.txt workpath KaKs
       KaKs4DTv.R ref_genome_abbr config.txt workpath 4DTv")
}


if(! require("ggplot2")){install.packages("ggplot2")}
library("ggplot2")
if(! require("patchwork")){install.packages("patchwork")}
library("patchwork")
if(! require("ggprism")){install.packages("ggprism")}
library("ggprism") #可以完善ggplot2的图使之达到发表级别
library("tidyverse")
library("ggrepel")

##读取多组Ka,Ks,4DTV
workdir <- args[3]
setwd(workdir)

##定义模式比较的物种的名称
control_species <- args[1]
##定义需要研究的物种的缩写，后续据此自动分析并出图。（3字符和拉丁学名的顺序必须对应）
all_species <- read.delim(args[2],header = F)
all_abbr_species <- all_species$V1 #3字符缩写
all_latin_species <- all_species$V2 #完整拉丁学名
all_control_species <- all_species$V3 #用于控制是否包含该物种的自我比对的结果
##获取比较的模式物种的拉丁名
control_latin <- all_latin_species[which(all_species==control_species)]
#读取文件
read_data <- function(in_file_str){
  #in_file_str <- ".kaks4DTv.csv" #test
  #定义读取文件的函数
  get_data <- function(speciesA,speciesB,latin_nameA,latin_nameB){
    in_file <- paste0(speciesA,"_",speciesB,in_file_str)
    if (! file.exists(in_file)){stop(paste0("Error: the file not exist of ",getwd(),"/",in_file))}
    data1 <- read.csv(in_file,header = T)
    data1 <- data.frame(data1)
    data1$Type <- paste0(latin_nameA,"_",latin_nameB)
    return(data1)
  } 
  #获取所有的物种的输出结果
  all_data <- data.frame()
  for (i in 1:length(all_abbr_species)){
    #如果是true,则需要读取自身的，否，则只用读取比较物种和该物种.注意需要过滤掉模式物种自身，否则会自身比对会读取2次
    
    #i=6 ##test
    if (all_control_species[i] && all_abbr_species[i] != control_species){
      #读取自身比对
      assign(paste0(all_abbr_species[i],"_",all_abbr_species[i]),get_data(all_abbr_species[i],all_abbr_species[i],all_latin_species[i],all_latin_species[i])) #给动态变量赋值
      all_data <- rbind(all_data,get(paste0(all_abbr_species[i],"_",all_abbr_species[i]))) #逐次合并新生成的自身比较变量的值到all_data
      #读取和模式物种的比对
      assign(paste0(control_species,"_",all_abbr_species[i]),get_data(all_abbr_species[i],control_species,all_latin_species[i],control_latin)) #给动态变量赋值
      all_data <- rbind(all_data,get(paste0(control_species,"_",all_abbr_species[i]))) #逐次合并新生成的和模式物种比较变量的值到all_data
      }else{
      #读取和模式物种的比对
      assign(paste0(control_species,"_",all_abbr_species[i]),get_data(all_abbr_species[i],control_species,all_latin_species[i],control_latin)) #给动态变量赋值
      all_data <- rbind(all_data,get(paste0(control_species,"_",all_abbr_species[i]))) #逐次合并新生成的和模式物种比较变量的值到all_data
      }
    
  }
  return(all_data)
}

draw_peak <- function(key_str){
  P_Ks <- ggplot(all_data,aes(x=get(key_str),group=Type))+geom_density(alpha=0.4,aes(color=Type))+theme_classic()+
    #theme_prism(base_size = 14)+
    scale_y_continuous(guide = "prism_offset_minor")+scale_x_continuous(guide = "prism_offset_minor")+xlab(key_str)
  print(P_Ks)
  ggsave(paste0(key_str,"_new.pdf"),dpi = 400)
  ggsave(paste0(key_str,"_new.png"),dpi = 400)
  print(paste0("output image to ",getwd(),"/",key_str,"_new.pdf"))
  ##############计算ks的时间################
  get_ks_time <- function(x_peak){
    lamda <- 8.83E-9 #3.48E-9
    Ks_time <- x_peak/(2*lamda)
    time <- Ks_time/1E6
    return(time)
  }
  
  ######################获取峰值
  #获取每一个峰值,输入参数dat,只能有1列
  get_peak <- function(dat,type_name){
    d <- density(dat[,1])
    modes <- function(d){
      i <- which(diff(sign(diff(d$y))) < 0) + 1
      peak_time <- get_ks_time(d$x[i])
      data.frame(x = d$x[i], y = d$y[i],peak_time=peak_time,type=type_name,peak_type=key_str)
    }
    return(modes(d))
  }
  
  all_Kspeak <- data.frame()
  all_species_type <- all_data$Type %>% unique()
  for (i in 1:length(all_species_type)){
    species_peak <- paste0(all_latin_species[i],"_Ks_peak")
    Ks_dataframe <- all_data %>% dplyr::filter(Type %in% all_species_type[i]) %>% select(factor(key_str)) %>% na.omit()
    assign(species_peak,get_peak(Ks_dataframe,all_species_type[i])) #给动态变量赋值
    all_Kspeak <- rbind(all_Kspeak,get(species_peak)) #逐次合并新生成的变量的值到all_data
  }
  #print(all_Kspeak)
  write.csv(all_Kspeak,paste0("All.",key_str,"_peak.csv"),quote = F,row.names = F)
  print(paste0("output all the peak to ",getwd(),"/All.",key_str,"_peak.csv"))
  
  #绘制峰值的分布图
  ##绘制主图
  ggplot()+geom_density(data=all_data,aes(x=get(key_str),group=Type,color=Type),alpha=0.4)+theme_classic()+
    #theme_prism(base_size = 14)+
    scale_y_continuous(guide = "prism_offset_minor")+scale_x_continuous(guide = "prism_offset_minor")+xlab(key_str)+
  #绘制点的标签
    geom_text(data=all_Kspeak,aes(x=x,y=y,label = round(x,3),color=type),position=position_dodge(width=0.5),vjust='inward',hjust='inward')+
  #绘制峰值点  
    geom_point(data=all_Kspeak, aes(x=x, y=y,color=type))
  ggsave(paste0(key_str,"_new.peak.png"),dpi=300)
  ggsave(paste0(key_str,"_new.peak.pdf"),dpi=300)
  print(paste0("output the peak iamge in ",getwd(),"/",key_str,"_new.peak.png"))
  
  
  data1 <- all_Kspeak %>% group_by(type)
  y_max <- summarise(data1,max_y=max(y))
  y_max$max_x <- data1$x[which(data1$y %in% y_max$max_y)]
  
  #返回PKs是加标签的图
  PKs <- 
  ##绘制主图
  ggplot()+geom_density(data=all_data,aes(x=get(key_str),group=Type,color=Type),alpha=0.4)+theme_classic()+
    #theme_prism(base_size = 14)+
    scale_y_continuous(guide = "prism_offset_minor")+scale_x_continuous(guide = "prism_offset_minor")+xlab(key_str)+
    theme(legend.position = "none")+ #隐藏图例
    geom_label_repel(data =y_max,aes(x=max_x,y=max_y,color=type,label=type))
  return(P_Ks) #决定返回哪个图
}

if (args[4] == "both"){
  all_data <- read_data(".kaks4DTv.csv")
  P_Ks <- draw_peak("Ks")
  P_4DTv <- draw_peak("X4dtv_corrected")
  (P_Ks+xlim(0,5))/P_4DTv+xlim(0,0.9)
  ggsave("ks_4DTv.bold.pdf",dpi=400)
} else if (args[4]=="KaKs"){
  all_data <- read_data(".all-kaks.csv")
  draw_peak("Ks")
} else if(args[4]=="4DTv"){
  all_data <- read_data(".all-4dtv.csv")
  draw_peak("X4dtv_corrected")
} else{
  stop("参数4错误！请重新输入")
}

