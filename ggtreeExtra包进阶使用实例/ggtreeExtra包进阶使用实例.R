if (!require("BiocManager"))
  install.packages("BiocManager")
if (!require("ggtree"))
  BiocManager::install("ggtree")
if (!require("ggnewscale"))
  install.packages("ggnewscale")
if (!require("ggtreeExtra"))
  BiocManager::install("ggtreeExtra")
if (!require("tidyverse"))
  install.packages("tidyverse")


library(ggtree)
library(ggtreeExtra)
library(tidyverse)
library(ggplot2)
library(ggnewscale)

#读取树文件
tree<-read.tree("trans-IQ.contree")
#读取不同时期表达量的矩阵文件，并标准化; 用ggplot2语法画热图，让宽表变长表
tpm<-read.csv("TPMmatrix.CSV",header = T,row.names = 1)
tpm<-log2(tpm+1)#标准化
tpm_long<-tpm%>%mutate(ID=rownames(tpm))%>%pivot_longer(cols =-ID)#宽表变长表
#读取差异表达倍数，并分组为上调和下调基因
fc<-read.csv("logFC.CSV",header = T)
fc$group<-ifelse(fc$logFC>0,"up","down")


p1<-ggtree(tree,layout = "fan",size=0.1,open.angle = 60)

#p1<-ggtree(tree,layout='rectangular'，size=0.1)  非环形进化树

col_fun<-colorRampPalette(c("#2574AA","white","#ED7B79"))(50) #设置渐变色
p2 <- p1 + 
  geom_fruit(
    data=tpm_long,
    geom=geom_tile,  
    #这里很重要，包含树tip标签的列在映射中应为 Y
    mapping=aes(y=ID, x=name, fill=value),  
    color="lightgrey",
    pwidth=0.6,
    stat="identity",
    offset = 0.15,
    #给热图标注行名
    axis.params = list(
      axis="x",
      line.color="white",
      text.size = 2,
      nbreak = 2, 
      text.angle = -40, 
      vjust = 1, 
      hjust = 0
    )
    
  ) + 
  scale_fill_gradientn(
    colours=col_fun
  )



fc<-mutate(fc,pvalue=runif(nrow(fc),min = 0,max=0.05))
col_fun2<-colorRampPalette(c("skyblue","#FC5C7D"))(50) #设置渐变色
p3 <- p2 + 
  geom_fruit(
    data=fc,
    geom=geom_point, 
    mapping=aes(y=ID, x=logFC,color=-log10(pvalue)), 
    size=0.5,
    pwidth=0.6,
    offset = 0.8,
    axis.params=list(
      axis="x"  #添加x轴
    ),
    grid.params=list(
      vline=T
    )
    
  )+
  scale_color_gradientn(colours = col_fun2)

#可以在同一圈叠加两种图形，我们用上一圈的数据尝试画一个散点和柱状图叠加的图
p4<-p3+
  ##这个函数可以初始化scale
  new_scale_fill()+
  geom_fruit_list(
    geom_fruit(
      data=fc,
      geom=geom_col,  
      mapping=aes(y=ID, x=logFC, fill=group),  
      pwidth=0.6,
      offset = 0.8
    ),
    scale_fill_manual(values=c("#8BC34A", "#A58AFF")),
    geom_fruit(
      data=fc,
      geom=geom_point,
      mapping=aes(y=ID, x=logFC,shape=group),  
      pwidth=0.6,
      size=1.2,
      offset = 0.8
    )
  )
  