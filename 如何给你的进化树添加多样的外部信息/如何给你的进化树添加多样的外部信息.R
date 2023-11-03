if (!requireNamespace("BiocManager"))
  install.packages("BiocManager")
if (!requireNamespace("treeio"))
  BiocManager::install("treeio")
if (!requireNamespace("tidytree"))
  install.packages("tidytree")

library(treeio)
library(ggtree)
library(tidytree)
library(tidyverse)
#载入树文件
tree<-read.tree("test_name.nwk")
#检查树文件类型，可以看出是phylo类
class(tree)
####[1] "phylo"

##载入外部数据
cafe<-read.table("cafe.txt",header = F)%>%
  rename_with(~c("label","info"),c(1,2))%>%  ##重命名
  mutate(label=gsub("_"," ",label))  ##将物种拉丁文间的下斜杠替换成空格
specific<-read.table("speciesSpecific.txt",header = F)%>%
  rename_with(~c("label","geneNum"),c(1,2))%>%
  mutate(label=gsub("_"," ",label))

##tidytree包的核心函数as_tibble()，将phylo类转化成tbl_tree类，这是一个tibble数据框，便于我们修改数据
tibbletree<-as_tibble(tree)%>%
  mutate(label=gsub("_"," ",label))%>%   ##物种拉丁文间的下斜杠替换成空格
  mutate(label=case_when(label=="" ~ NA,
                         TRUE ~ label))     ##label列中有空值""的话替换成NA值



##merge外部数据
tibbletree<-left_join(tibbletree,cafe)   
tibbletree<-left_join(tibbletree,specific)

class(tibbletree)
##[1] "tbl_tree"   "tbl_df"     "tbl"        "data.frame"
tibbletree

##我们给树添加了新的两列：info  geneNum


##使用treeio包函数as.treedata()把tbl_tree类转化成treedata类
#treedata类可以直接用ggtree可视化
tree<-as.treedata(tibbletree)
class(tree)

ggtree(tree,layout = "roundrect")+
  geom_tiplab(align = T, fontface="italic")+
  #theme_tree2()+
  geom_text(aes(label=tibbletree$info),vjust=-.3,hjust=1)+
  geom_tippoint(aes(color=log2(geneNum)),size=1.2)+
  xlim(c(0,460))
