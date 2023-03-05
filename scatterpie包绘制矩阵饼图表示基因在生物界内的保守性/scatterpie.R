if (!require("scatterpie"))
  install.packages("scatterpie")
if (!require("tidyr"))
  install.packages("tidyr")
# 加载包
library(scatterpie)
library(tidyr)

#生成50行21列的矩阵，前二十列均为0-15之间的随机整数，表示每个真菌类群中具有单个目的基因的真菌物种数，最后一列是15-60之间的随机整数，表示每个纲或门的物种数
mat<-cbind(matrix(sample(c(0:15),100,replace = T),50,20),sample(c(15:60),50,replace = T))
#计算每个真菌类群中具有单个目的基因的真菌物种比例
mat[,1:ncol(mat)-1]<-mat[,1:ncol(mat)-1]/mat[,ncol(mat)]
#将矩阵转化为数据框
mat<-as.data.frame(mat)
#添加列order列，即需要映射到y轴的数据
mat$order<-seq(nrow(mat),1)
#利用tidyr包中的pivot_longer()函数将矩阵转化为长表，参数cols决定哪些列进行转化
df<-pivot_longer(mat,cols=c(-ncol(mat),-(ncol(mat)-1)))
#添加Absence列，计算每个真菌类群中不具有单个目的基因的真菌物种比例
df$Absence<-1-df$value
#添加geneNum列，即需要映射到x轴的数据
df$geneNum<-substr(df$name,2,3)
#重命名
colnames(df)<-c("speciesNum","order","geneID","Presence","Absence","geneNum")
#scatterpie只能映射数值型数据，因此将"order","Presence","Absence","geneNum"四列的数据类型转化为数值型
df[c(2,4,5,6)] = lapply(df[c(2,4,5,6)], FUN = function(y){as.numeric(y)})

ggplot()+
  geom_scatterpie(aes(x=geneNum, y=order), data=df, cols=c("Presence","Absence"))+
  scale_x_continuous(breaks=c(1:20),labels=seq(1:20))+ #设置x轴刻度标签
  scale_y_continuous(breaks = c(1:50),labels =paste(paste("(",rev(mat$V21 ),sep = ""),")",sep=""))+ #设置y轴刻度标签
  scale_fill_manual(values = c("blue","grey"))+ #设置颜色
  theme(panel.grid=element_blank(),
        panel.background = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_blank())+  #设置主题，去除背景，x轴和y轴以及刻度线
  labs(y="",x="")+
  coord_fixed(ratio =1 ) #ratio表示纵轴1单位显示的长度，是横轴1单位显示的长度的几倍
