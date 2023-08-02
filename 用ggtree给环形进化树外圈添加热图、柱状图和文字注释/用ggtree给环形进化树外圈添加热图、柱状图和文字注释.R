
library(ggtree)
library(ggnewscale)
library(ggplot2)
library(ggtreeExtra)

tree<-read.tree("trans-IQ.contree")
tpm<-read.csv("TPMmatrix.CSV",header = T,row.names = 1)
tpm<-log2(tpm+1)
fc<-read.csv("logFC.CSV",header = T)
fc$group<-ifelse(fc$logFC>0,"up","down")
annotation<-read.table("annotation.txt",header = T,sep = "\t")




p<-ggtree(tree,layout = "circular",size=0.1)

p1<-p+
  geom_tiplab(align = T,size=2)

p2<-gheatmap(p1,tpm,
             offset=6, #设置外圈图到树的偏移距离，这个值需要不断调试 
             width=.8, #热图宽度
             colnames_angle=95, #列名角度
             legend_title = "log2(TPM)",  #图例名称
             high="#D32F2F",low = "#FFF7F3",
             font.size = 2)  #列名大小




p3 <- p2 + 
  new_scale_fill() +  ##ggplot2只允许设置一个scale，这个函数可以添加新的scale
  geom_fruit(
    data=fc,
    geom=geom_bar,  #这里很重要，包含树tip标签的列在映射中应为 Y
    mapping=aes(y=ID, x=logFC, fill=group),  
    pwidth=0.6,
    stat="identity",
    offset = 2
    
  ) + 
  scale_fill_manual(
    values=c("#8BC34A", "#A58AFF")
  )


#最外圈添加注释文字
p4<-p3+
  geom_fruit(
    data=annotation,
    geom=geom_text,
    mapping=aes(y=ID, x=annotation,label=annotation), 

    size=1.5,  ##文字注释大小
    pwidth=0.02,
    offset = 0.3
    
  )