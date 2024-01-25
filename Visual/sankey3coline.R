#!/usr/bin/Rscript
########用处：用于绘制3个基因组的共线性的桑吉图。

library("tidyverse")
library("ggplot2")
if(!require("ggalluvial")){install.packages("ggalluvial")}
library("ggalluvial")

#配置读取参数
args<-commandArgs(T) #收集参数给args变量，则args[1]=1，args[2]=2

#测试示例
#args <- c("Aip.coline.gff","Dcu.coline.gff","Adu.coline.gff","Aip.Dcu.bar.coline","Adu.Dcu.bar.coline","A.ipaensis", "D.cultrata", "A.duranensis","E:/bioinformation_center/huangtan/coline/Adu_Dcu_Aip")

if (length(args) < 9){
  message("Rscript bar_coline.R gff3file1 gff3file2 gff3file3 colinefile1 colinefile2 Species1 Species2 Species3 workpath") 
  if (TRUE) {stop("please input 9 parameters")}
}
#要求输入的gff3文件格式如下：(不要有行头)
#chr       chrom start   end
#Ath1 AT1G01010.1  3630  5899
#Ath1 AT1G01020.1  6787  9130

#要求输入的共线性文件格式如下：（(不要有行头)）
#species1 species2
#rna-NM_001247827.2 Cs01G006040.1
#rna-XM_010317976.3 Cs01G005970.1
#rna-XM_004228567.4 Cs01G006000.1
#要求输入的gff3的顺序和最后面的拉丁名的顺序一样，而且共线性文件列的顺序也应该是coline1:物种1，物种2 coline2:物种3,物种2
gff3file1 <- args[1] #物种1的gff3文件
gff3file2 <- args[2] #物种2的gff3文件
gff3file3 <- args[3] #物种3的gff3文件
colinefile1 <- args[4] #两列基因ID的共线性文件
colinefile2 <- args[5] #两列基因ID的共线性文件
latin_label <- c(args[6],args[7],args[8]) #物种的拉丁名
workpath <- args[9]
setwd(workpath)
gff3_1 <- read.delim(gff3file1,header = F,col.names = c("ChrID1","geneID1","geneID1_start","geneID1_end")) %>%　
  mutate(geneID1_len=(geneID1_start+geneID1_end)/2) %>% select(-c(geneID1_start,geneID1_end))
gff3_2 <- read.delim(gff3file2,header = F,col.names = c("ChrID2","geneID2","geneID2_start","geneID2_end")) %>%　
  mutate(geneID2_len=(geneID2_start+geneID2_end)/2) %>% select(-c(geneID2_start,geneID2_end))
gff3_3 <- read.delim(gff3file3,header = F,col.names = c("ChrID3","geneID3","geneID3_start","geneID3_end")) %>%　
  mutate(geneID3_len=(geneID3_start+geneID3_end)/2) %>% select(-c(geneID3_start,geneID3_end))
coline1 <- read.delim(colinefile1,header = F)
coline2 <- read.delim(colinefile2,header = F)
coline_gene <- full_join(coline1,coline2,by="V2")
colnames(coline_gene) <- c("geneID1","geneID2","geneID3")
data_all <- inner_join(inner_join(inner_join(coline_gene,gff3_1,by="geneID1"),gff3_2,by="geneID2"),gff3_3,by="geneID3")
dat_all <- gather(data_all,key="geneID",value="GeneID",c(geneID1,geneID2,geneID3)) %>% 
  gather(key="geneID_len",value="GeneID_len",c(geneID1_len,geneID2_len,geneID3_len)) %>% select(-c(geneID,geneID_len))

#随机选取总数的比例，
dat1 <- sample_frac(dat_all,0.01)
#dat1 <- dat_all
p1 <- ggplot(dat1,
             aes(y = GeneID_len,
                 axis1 = ChrID1, axis2 = ChrID2, axis3 = ChrID3)) +
  geom_alluvium(aes(fill = ChrID2),width = 0, 
                 reverse = FALSE) + #knot.pos是控制曲线的弯曲程度的，0-1越大越弯
  theme_classic()+
  geom_stratum(width = 1/10, reverse = FALSE,alpha=0.5) + #设置三根柱子的宽度、透明度
  geom_text(stat = "stratum", aes(label = after_stat(stratum)),
            reverse = FALSE) +
  scale_x_continuous(breaks = 1:3, labels = latin_label) +
  coord_flip()+
  labs(x="",y="")+
  theme(legend.position = "none",axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),axis.line = element_blank(),axis.text.x = element_blank())+
  scale_y_continuous(expand = c(0, 0))

p2 <- ggplot(dat1,
             aes(y = GeneID_len,
                 axis1 = ChrID1, axis2 = ChrID2, axis3 = ChrID3)) +
  geom_alluvium(aes(fill = ChrID2),
                width = 0, knot.pos = 0.35, reverse = FALSE) +#knot.pos是控制曲线的弯曲程度的，0-1越大越弯
  theme_classic()+
  geom_stratum(width = 1/10, reverse = FALSE,alpha=0.8) + #设置三根柱子的宽度、透明度
  geom_text(angle=0,stat = "stratum", aes(label = after_stat(stratum)),reverse = FALSE) +
  scale_x_continuous(breaks = 1:3, labels = latin_label) +
  labs(x="",y="")+
  theme(legend.position = "none",axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),axis.line = element_blank(),axis.text.y = element_blank())+
  scale_y_continuous(expand = c(0, 0))

if(! require("patchwork")){install.packages("patchwork")}
library("patchwork")

ggsave(paste0(latin_label[1],".",latin_label[2],".",latin_label[3],".sankey.p1.pdf"),p1,width = 170,units = "mm",dpi=400)
ggsave(paste0(latin_label[1],".",latin_label[2],".",latin_label[3],".sankey.p2.pdf"),p2,width = 170,units = "mm",dpi=400)
message("Output image in ",getwd(),"/",latin_label[1],".",latin_label[2],".",latin_label[3],".sankey.p1.pdf")

ggsave(paste0(latin_label[1],".",latin_label[2],".",latin_label[3],".sankey.pdf"),p1/p2)
ggsave(paste0(latin_label[1],".",latin_label[2],".",latin_label[3],".sankey.png"),p1/p2)
message("Output image in ",getwd(),"/",latin_label[1],".",latin_label[2],".",latin_label[3],".sankey.pdf")