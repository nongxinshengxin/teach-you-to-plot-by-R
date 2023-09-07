library(igraph)
library(ggraph)
library(tidyverse)
library(ggnewscale)

ppidf<-read.table("string_interactions_short.tsv",header = F)
nodes<-read.csv("geneInfo.CSV",header = T)

nodelink<-ppidf[,c(1,2,10)]%>%rename_with(~c("from","to","experimentally_determined_interaction"),c(1,2,3))
nodelink$experimentally_group<-ifelse(nodelink$experimentally_determined_interaction>0.5,"validation","no validation")

mygraph<-graph_from_data_frame(nodelink,vertices = nodes)

plot(mygraph)

ggraph(mygraph,layout = "linear",circular=T)+
  geom_edge_bend(aes(edge_width=experimentally_determined_interaction,edge_colour=experimentally_group),
                 strength = 0.02, #strength参数后接数值，在0-1之间，越大，代表曲线的弯曲程度越大
                 alpha=0.6)+ 
  scale_edge_width_continuous(range = c(0.5,1.2))+ #设置连线的粗细范围
  scale_edge_color_manual(values = c("skyblue","#fe817d"))+ #设置连线的颜色
  geom_node_point(aes(colour=Sample,size=logFC))+ #添加第一层散点，映射样本信息和logFC
  scale_size_continuous(range =c(3,10))+ #设置散点大小范围
  scale_colour_manual(values = c("#264653","#2a9d8e","#e9c46b","#f3a261","#e66f51"))+ #设置散点颜色
  new_scale_colour()+ #添加新的scale
  geom_node_point(aes(colour=DEG),alpha=0.8,size=2)+ #添加第二层散点，映射差异表达基因信息
  scale_colour_manual(values = c("black","#FFEB3B"))+ #设置散点颜色
  theme_void()
