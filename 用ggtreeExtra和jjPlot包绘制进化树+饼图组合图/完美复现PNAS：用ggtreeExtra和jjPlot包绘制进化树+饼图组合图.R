if (!require("BiocManager"))
  install.packages("BiocManager")
if (!require("ggtree"))
  BiocManager::install("ggtree")
if (!require("ggnewscale"))
  install.packages("ggnewscale")
if (!require("tidyverse"))
  install.packages("tidyverse")
if (!require("ggtreeExtra"))
  BiocManager::install("ggtreeExtra")
if (!require("devtools"))
  install.packages('devtools')
if (!require("jjPlot"))
  devtools::install_github('junjunlab/jjPlot')


library(ggtree)
library(ggnewscale)
library(tidyverse)
library(ggtreeExtra)
library(jjPlot)

#读取树文件，并根据内节点名称分组
tree<-read.tree("species.tree")
tree <- groupClade(tree, .node = c("Ascomycota","Basidiomycota"))

#读取物种数目文件
annotation<-read.csv("num.CSV",header = T)

#读取矩阵并处理
mat<-read.csv("pie.CSV",header = T)
matdf<-pivot_longer(mat,cols = c(-1,-ncol(mat),-(ncol(mat)-1)),names_to = "type")



p<-ggtree(tree, aes(color=group), branch.length = 'none', 
          layout = "ellipse",
          ladderize=F,size=0.1) + 
  geom_tiplab(fontface = "bold.italic",size=3.5) + 
  scale_color_manual(values=c("black","orange","darkgreen")) + 
  xlim(c(0, 35))

p1<-p+
  geom_fruit(
    data=annotation,
    geom=geom_text,
    mapping=aes(y=name, x=num,label=num), 
    angle=0.1,
    size=3,  ##文字注释大小
    pwidth=0.02,
    offset = 1
    
  )

p2 <- p1 + 
  new_scale_fill() +  #添加新的scale
  geom_fruit(
    data=matdf,
    geom=geom_jjPointPie,  
    mapping=aes(y=name, x=gene, group=seq, fill=type,pievar=value),  
    color="white",
    line.size=0.01,
    width=0.5,
    pwidth=0.08,
    offset = 4
    
  ) + 
  scale_fill_manual(
    values=c(R="#E64A19",G="yellow",other="#8BC34A", P="#03A9F4",NA.="grey"),  #设置扇形颜色
    limits=c("R","G","other","P","NA."), #设置图例顺序
    name="" #隐藏图例名称
  )+
  guides(color="none")+ #隐藏进化树分组图例
  theme(
    legend.justification = c("right", "top")  #调整图例位置到右上角
  )

