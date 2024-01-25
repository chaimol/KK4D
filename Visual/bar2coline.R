#!/usr/bin/Rscript
#绘制基因组共线性的上下染色体分布的线段堆叠图，如果是1个基因组内部的分析，则不会进行绘图。
if(! require("tidyverse")){install.packages("tidyverse")}
if(! require("ggplot2")){install.packages("ggplot2")}
if(! require("patchwork")){install.packages("patchwork")}
if(! require("RColorBrewer")){install.packages("RColorBrewer")}
library("tidyverse")
library("patchwork") #拼图
library("ggplot2")
library("RColorBrewer")#用于生成颜色向量

args<-commandArgs(T) #收集参数给args变量，则args[1]=1，args[2]=2
#args <- c("Ath.Osa.gff","Ath.Osa.bar.coline","Osa","Ath","E:/Github/KK4D/Visual/Ath_Osa")
#args <- c("Ath.Osa.gff","Ath.Osa.bar.coline","Ath","Osa","E:/Github/KK4D/Visual/Ath_Osa")
if (length(args) < 5){
  print("Rscript bar_coline.R gff3file colinefile figset_up figset_down PWD") 
  {
    if (TRUE) {stop("please input 5 parameters")}
    print("Script is running !")
  }
}
gff3file <- args[1] #gff3文件,两个基因组的gff3的合并文件
colinefile <- args[2] #两列基因ID的共线性文件
figset_up <- args[3] #上面的图的染色体的前面的三字符
figset_down <- args[4] #下面的图的染色体的前面的三字符
wd_path <- args[5] #工作路径
setwd(wd_path)

#如果上面和下面的字符串一致，说明是一个基因组内的比较，此类比较不绘图。
if(figset_up== figset_down){stop("Analysis within a genome will not plot")}
#cat Ath_Csp.collinearity|grep -v ^#|cut -f2,3 >Ath_Csp.colline

#检测输入文件是否存在
if(! file.exists(gff3file)){stop(paste0("input file not exist ",getwd(),"/",gff3file))}
if(! file.exists(colinefile)){stop(paste0("input file not exist ",getwd(),"/",colinefile))}
#需要修改的参数的三行命令
coline <- read.delim(colinefile,header = F) 
gff3 <- read.delim(gff3file,header = F)
figset <- c(figset_up,figset_down) #用于控制画图的上下的物种的名称的缩写（第一个是上），需要与gff里的第一列的染色体的字符一致
#head(coline)  #共线性文件的格式就两列基因ID,不需要有文件头
#V1          V2
#AT1G20780.1 AT1G76390.2
#AT1G20816.1 AT1G76405.2
#head(gff3)  #gff3文件的格式是两个基因组的 染色体名称,基因ID,基因起始位置,基因终止位置，不需要有文件头
#chr       chrom start   end
#Ath1 AT1G01010.1  3630  5899
#Ath1 AT1G01020.1  6787  9130


#color_pool 一共有52种颜色，如果你的染色体数量大于这个值，则需要手动增加新的颜色到color_pool
color_pool <- c(brewer.pal(n= 9,name ="Set1"),brewer.pal(n= 8,name ="Set2"),brewer.pal(n= 11,name ="Set3"),brewer.pal(n=8,name ="Dark2"),brewer.pal(n=8,name ="Accent"),brewer.pal(n=8,name ="Pastel2"))
del_repeat_coline <- coline %>% mutate(str_V1=str_sub(V1, 1, 2),str_V2=str_sub(V2, 1, 2)) %>% filter(str_V1 != str_V2)

###################################
#del_repeat_coline <- sample_n(del_repeat_coline,1000) #随机选择1000行测试
del_repeat_coline <- sample_frac(del_repeat_coline,0.1) #选择总量的10%
##################

colnames(gff3) <- c("chr","chrom","start","end")
upchr <- gff3 %>% group_by(chr) %>% summarise(maxchr=max(end)) %>% 
        filter(stringr::str_detect(chr,figset[1])) %>% 
        mutate(up_color=sample(color_pool,length(chr))) #随机从颜色库中抽取颜色，每次的结果都不一样
colnames(upchr) <- c("up_chr","up_maxchr","up_color")
#上面的染色体的图
p1 <- ggplot(upchr,aes(x=up_chr,y=up_maxchr,fill=up_color))+
  geom_bar(stat = "identity",width=0.2)+
  theme_classic()+labs(x="",y="")+
  theme(legend.position = "none",axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),axis.line = element_blank(),
        axis.text.y = element_blank())+
  scale_y_continuous(expand = c(0, 0))
#print(p1)

#下面的染色体的图
downchr <- gff3 %>% group_by(chr) %>% summarise(maxchr=max(end)) %>% filter(stringr::str_detect(chr,figset[2])) %>% 
  mutate(down_color=sample(color_pool,length(chr)))
colnames(downchr) <- c("down_chr","down_maxchr","down_color")
p2 <- ggplot(downchr,aes(x=down_chr,y=down_maxchr,fill=down_color))+
  geom_bar(stat = "identity",width=0.3)+
  theme_classic()+labs(x="",y="")+
  theme(legend.position = "none",axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),axis.line = element_blank(),
        axis.text.y = element_blank())+
  scale_y_continuous(expand = c(0, 0))
#print(p2)
#合并gff3里面的物种1的基因的位置到共线性文件中
data1 <- select(merge(del_repeat_coline,gff3,by.x="V1",by.y="chrom"),-c(str_V1,str_V2))
colnames(data1) <- c("Species1","Species2","up_chr","S1_start","S1_end")
#合并gff3里面的物种2的基因的位置到共线性文件中
data_all <- merge(data1,gff3,by.x="Species2",by.y="chrom")
colnames(data_all) <- c("Species1","Species2","S1_chr","S1_start","S1_end","S2_chr","S2_start","S2_end")
#使用基因的前后坐标的中间值作为基因的位置坐标
All_data1 <-  mutate(data_all,S1_len=abs(S1_end + S1_start)/2,S2_len=(S2_end + S2_start)/2) %>% select(-c(S1_start,S1_end,S2_start,S2_end))


#获取geom_bar的柱子的宽度，用于传递给上层的散点线。输入参数是一个ggplot2绘图的对象
getbarwidth <- function(p){
  # 获取 ggplot2 绘图对象的信息
  p_build <- ggplot_build(p)
  # 提取柱状图的绘图信息
  bar_data <- p_build$data[[1]]
  # 计算柱状图的宽度
  bar_width <- max(bar_data$xmax)
  return(bar_width)  
}

#获取染色体的数量
upchrnum<- length(upchr$up_chr)
downchrnum<- length(downchr$down_chr)

#控制上下图的染色体的位置，根据输入的最后figset_up和figset_down的位置来判断上下
if ( all(is.element(upchr$up_chr[1],All_data1$S2_chr))){
  All_data2 <- merge(All_data1,upchr,by.x = "S2_chr",by.y = "up_chr")
  All_data <- merge(All_data2,downchr,by.x = "S1_chr",by.y = "down_chr")
  p3_1<- 
    ggplot() + 
    geom_bar(data=downchr,aes(x=down_chr,y=down_maxchr),fill="white",colour="grey",stat = "identity",width=0.2*downchrnum/upchrnum)#底层的柱状图
    linesize <- getbarwidth(p3_1)
    p3 <- p3_1 +geom_point(data=All_data,aes(x= S1_chr,y=S1_len,colour=up_color),shape = 95, size = linesize, alpha = 1) + #上层的点图（点形状是线）
    theme_classic() + 
    labs(x="",y="")+
    theme(legend.position = "none",axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),axis.line = element_blank(),
          axis.text.y = element_blank())+
    scale_y_continuous(expand = c(0, 0))
  }else{
  All_data2 <- merge(All_data1,upchr,by.x = "S1_chr",by.y = "up_chr")
  All_data <- merge(All_data2,downchr,by.x = "S2_chr",by.y = "down_chr")
  p3_1 <- 
    ggplot() + 
    geom_bar(data=downchr,aes(x=down_chr,y=down_maxchr),fill="white",colour="grey",stat = "identity",width=0.2*downchrnum/upchrnum) #底层的柱状图
    linesize <- getbarwidth(p3_1)
    p3 <- p3_1+geom_point(data=All_data,aes(x= S2_chr,y=S2_len,colour=up_color),shape = 95, size = linesize, alpha = 0.8) + #上层的点图（点形状是线）
    theme_classic() + 
    labs(x="",y="")+
    theme(legend.position = "none",axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),axis.line = element_blank(),
          axis.text.y = element_blank())+
    scale_y_continuous(expand = c(0, 0))
}
rm(All_data1,All_data2,data_all,data1,coline,del_repeat_coline,gff3) #删除所有中间变量
#染色体的分布图
print(p1/p3)
ggsave(paste0(figset[1],"_",figset[2],".bar.plot.pdf"))
ggsave(paste0(figset[1],"_",figset[2],".bar.plot.png"))
message(paste0("Output the coline barplot in ",wd_path,"/",figset[1],"_",figset[2],".bar.plot.png"))
