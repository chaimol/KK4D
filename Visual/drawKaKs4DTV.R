#############
#脚本用于获取输出的KaKs4DTv的峰值，并可视化.可用于1到多个基因组之间的结果的分析
#仅适用于KK4D的输出的下游分析可视化，注意输出的峰值可能比真实的值多，需要自行选择合适的位置

##用于kaks4DTv的下游输出的结果的可视化和峰值的计算
#####输入参数有3个：ref_genome_abbr config.tsv workpath
###获取脚本的输入的参数
args<-commandArgs(T) #收集参数给args变量
#Usage:Rscript KaKs4DTv.R ref_genome_abbr config.tsv workpath
#第1个参数是用于输出的文件名的前缀
#第2个参数是输入配置文件config.tsv格式如下：要求使用的是tab分割符
#Ath  A.thaliana
#Tca  T.cacao
#Tha  T.hassleriana
#Vvi  V.vinifera
#第3个参数是工作路径
# 输入文件是config.tsv
#第4个参数是KaKs|4DTv|both,三选一，决定分析的是哪一种输入文件
#第5个参数是碱基的突变率，默认值是7E-9,可以不提供此参数。用于计算Ks的插入时间时使用。
#args <- c("Osa","Ath.Osa.config.tsv","E:/Github/KK4D/Visual/Ath_Osa","both","7E-9")
#args <- c("Ghi","Ghi.Ghi.config.tsv","E:/Github/KK4D论文/AD1","both","7E-9")
if ( length(args)==0 | args[1] == "-h" | args[1] == "--help" | length(args)<4){
  stop("
       Usage:
       KaKs4DTv.R ref_genome_abbr config.tsv workpath both
       KaKs4DTv.R ref_genome_abbr config.tsv workpath KaKs
       KaKs4DTv.R ref_genome_abbr config.tsv workpath 4DTv
       KaKs4DTv.R ref_genome_abbr config.tsv workpath KaKs 3.85E-9
       KaKs4DTv.R ref_genome_abbr config.tsv workpath both 7.8E-9

       Default param5 lamda:7E-9
       Note:config.tsv Separator must be tab.

       Example config.tsv:
       Ath  A.thaliana
       Tca  T.cacao
       Tha  T.hassleriana")
}


if(! require("ggplot2")){install.packages("ggplot2")}
if(! require("patchwork")){install.packages("patchwork")}
if(! require("ggprism")){install.packages("ggprism")}
if(! require("tidyverse")){install.packages("tidyverse")}
library("ggplot2")
library("patchwork")
library("ggprism") #可以完善ggplot2的图使之达到发表级别
library("tidyverse") #数据处理
##读取多组Ka,Ks,4DTV
workdir <- args[3]
setwd(workdir)

##定义模式比较的物种的名称
control_species <- args[1]
##定义需要研究的物种的缩写，后续据此自动分析并出图。（3字符和拉丁学名的顺序必须对应）
all_species <- read.delim(args[2],header = F)
all_abbr_species <- all_species$V1 #3字符缩写
all_latin_species <- all_species$V2 #完整拉丁学名

#处理control的拉丁名,删除control的拉丁学名
control_index <- which(all_abbr_species %in% control_species)
if (length(control_index)==2){control_index <- control_index[-1]} #当物种内部比较的时候，只删除其中一个，保留一个。
control_latin_species <- all_latin_species[control_index]
all_abbr_species <- all_abbr_species[-control_index]
all_latin_species <- all_latin_species[-control_index]

#设置全局变量lamda,如果用户不提供，则使用默认值7E-9
if (!is.na(args[5])) {
  lamda <- args[5]
} else {
  lamda <- 7E-9
}

#读取和目标物种比较的结果
read_data <- function(in_file_str){
  #定义读取文件的函数
  get_data <- function(species,latin_name){
    in_file <- paste0(species,"_",control_species,in_file_str)
    if (! file.exists(in_file)){stop(paste0("Error: the file not exist of ",getwd(),"/",in_file))}
    data1 <- read.csv(in_file,header = T)
    data1 <- data.frame(data1)
    data1$Type <- latin_name
    return(data1)
  }
  #获取所有的物种的输出结果
  all_data <- data.frame()
  for (i in 1:length(all_abbr_species)){
    assign(all_abbr_species[i],get_data(all_abbr_species[i],all_latin_species[i])) #给动态变量赋值
    all_data <- rbind(all_data,get(all_abbr_species[i])) #逐次合并新生成的变量的值到all_data
  }
  return(all_data) #返回最终的读取的结果的数据框
}


draw_peak <- function(key_str,adjust=1){#adjust可以控制曲线的平滑度，值越大越平滑
  P_Ks <- ggplot(all_data,aes(x=get(key_str),group=Type))+geom_density(alpha=0.4,aes(color=Type),adjust=adjust,trim=TRUE)+theme_classic()+
    #theme_prism(base_size = 14)+
    scale_y_continuous(guide = "prism_offset_minor")+scale_x_continuous(guide = "prism_offset_minor")+xlab(key_str)
  print(P_Ks)
  ggsave(paste0(key_str,"_new.pdf"),dpi = 400)
  ggsave(paste0(key_str,"_new.png"),dpi = 400)
  print(paste0("output image to ",getwd(),"/",key_str,"_new.pdf"))
  ##############计算ks的时间################
  get_ks_time <- function(x_peak){
    lamda_value <- as.numeric(lamda) #这是全局变量，默认是：7E-9
    Ks_time <- x_peak/(2*lamda_value)
    time <- Ks_time/1E6
    return(time)
  }
  ######################获取峰值
  #获取每一个峰值,输入参数dat,只能有1列
  get_peak <- function(dat,type_name){
    d <- density(dat[,1])
    modes <- function(d){
      max_i <- which(diff(sign(diff(d$y))) < 0) + 1#求出连续三个数变化率最高的极大值
      #slp <- diff(d$y) / diff(d$x) #求出每个位置的数据点的斜率
      #j <- which(abs(slp)>0.05)+1 #过滤获取斜率的绝对值>0.1的位置
      i <- max_i[which(d$y[max_i]>0.05)] #控制y轴坐标要大于0.05的点
      #i <- intersect(i,j) #求交集，极大值和斜率绝对值大于0.1的点，通过斜率来过滤一部分点
      peak_time <- get_ks_time(d$x[i])
      data.frame(x = d$x[i], y = d$y[i],peak_time=peak_time,type=type_name,peak_type=key_str)
    }
    return(modes(d))
  }
  all_Kspeak <- data.frame()
  for (i in 1:length(all_latin_species)){
    species_peak <- paste0(all_latin_species[i],"_Ks_peak")
    Ks_dataframe <- all_data %>% dplyr::filter(Type %in% all_latin_species[i]) %>% select(factor(key_str)) %>% na.omit()
    assign(species_peak,get_peak(Ks_dataframe,all_latin_species[i])) #给动态变量赋值
    all_Kspeak <- rbind(all_Kspeak,get(species_peak)) #逐次合并新生成的变量的值到all_data
  }
  #print(all_Kspeak)
  write.csv(all_Kspeak,paste0("All.",key_str,"_peak.csv"),quote = F,row.names = F)
  print(paste0("output all the peak to ",getwd(),"/All.",key_str,"_peak.csv"))

  #绘制峰值的分布图
  ##绘制主图
  ggplot()+geom_density(data=all_data,aes(x=get(key_str),group=Type,color=Type,trim=TRUE),alpha=0.4)+theme_classic()+
    #theme_prism(base_size = 14)+
    scale_y_continuous(guide = "prism_offset_minor")+scale_x_continuous(guide = "prism_offset_minor")+xlab(key_str)+
  #绘制点的标签
    geom_text(data=all_Kspeak,aes(x=x,y=y,label = round(x,3),color=type),position=position_dodge(width=0.5),vjust='inward',hjust='inward')+
  #绘制峰值点
    geom_point(data=all_Kspeak, aes(x=x, y=y,color=type))
  ggsave(paste0(key_str,"_new.peak.png"),dpi=300)
  ggsave(paste0(key_str,"_new.peak.pdf"),dpi=300)
  print(paste0("output the peak iamge in ",getwd(),"/",key_str,"_new.peak.png"))
  return(P_Ks) #返回第一步的绘图，用于后续拼图
}

if (args[4] == "both"){
  all_data <- read_data(".kaks4DTv.csv")
  P_Ks <- draw_peak("Ks")
  P_4DTv <- draw_peak("X4dtv_corrected")
  P_Ks/P_4DTv
  ggsave("ks_4DTv.bold.pdf",dpi=400)
} else if (args[4]=="KaKs"){
  all_data <- read_data(".all-kaks.csv")
  P_Ks <- draw_peak("Ks")
} else if(args[4]=="4DTv"){
  all_data <- read_data(".all-4dtv.csv")
  P_4DTV <- draw_peak("X4dtv_corrected")
} else{
  stop("参数4错误！请重新输入")
}

