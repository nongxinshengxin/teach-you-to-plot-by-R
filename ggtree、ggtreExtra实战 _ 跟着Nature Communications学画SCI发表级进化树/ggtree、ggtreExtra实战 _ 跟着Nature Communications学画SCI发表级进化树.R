library(ggtree)
library(tidytree)
library(tidyverse)
library(ggtreeExtra)

tree<-read.tree("Fig_3a.18Species_2329LCN.newick")
genomeInfo<-read.csv("genomeInfo.CSV",header = T)
#宽表变长表
genomeInfo<-pivot_longer(genomeInfo,cols =-1 )
#固定x轴顺序
namefac<-factor(genomeInfo$name,levels = c("GenomeSize","GeneSize","IntroSize"))


p0<-ggtree(tree)+ geom_tiplab(align = T)+geom_text2(aes(label=node),hjust=-.3,color="red")
##groupClade()函数接受一个内部节点或内部节点的向量，这个节点下的所有子节点自动分为一组。但注意，groupClade()不解释末端节点
tree <- groupClade(tree, c(23,27,33))

tree_tibble<-as_tibble(tree)
tree_tibble<-tree_tibble%>%mutate(group=as.character(tree_tibble$group))


tree_tibble[which(tree_tibble$node==5),5]<-"5"
groupinfo<-split(tree_tibble$node, tree_tibble$group)
tree<-as.phylo(tree_tibble)
###groupOTU()函数需要接受分组下所有节点，相应的，也能接受末端节点
tree <- groupOTU(tree, groupinfo)

p1<-ggtree(tree,aes(colour=group),size=2)+
  geom_tiplab(align = T,fontface = "bold.italic",size=3.5,color="black")+
  geom_treescale(x=0, y=15, width=0.1, color='black')+
  scale_color_manual(values = c("black","#800080","#008000","#FFD700","#0000FF"))+
  guides(color="none")
p2<-ggtree::rotate(p1,22)




p3<-p2+
  geom_fruit(
  data = genomeInfo,
  geom = geom_point,
  shape=21,
  mapping = aes(y=species,x=namefac,size=value,fill=name),
  offset = 0.6,
  pwidth = 0.8,
  color="#FFC0CB"
  )+
  scale_fill_manual(values = c("#028482","#7ABA7A","#00FF00"),
                    limits=c("GenomeSize","GeneSize","IntroSize"),
                    name="Genome characteristic")

