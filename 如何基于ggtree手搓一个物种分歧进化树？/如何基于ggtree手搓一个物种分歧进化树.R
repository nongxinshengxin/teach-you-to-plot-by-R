library(ggtree)
library(tidytree)
library(tidyverse)

tree<-read.tree("r8s_ultrametric.txt")

tibbletree<-as_tibble(tree)

calculate_divergence_time<-function(treesdata){
  dftip <- data.frame(node = numeric(), divergence_time = numeric())
  internode<-data.frame(parent=numeric(),node = numeric(), divergence_time = numeric())
  for (i in 1:nrow(treesdata)) {
    if (isTip(treesdata,treesdata$node[i])){
      newtip<-data.frame(node = treesdata$parent[i],divergence_time =treesdata$branch.length[i])
      dftip<-rbind(dftip,newtip)
    }
    else{
      if (treesdata$node[i] != treesdata$parent[i]){
        newdata<-data.frame(parent=treesdata$parent[i],node = treesdata$node[i],divergence_time =treesdata$branch.length[i])
        internode<-rbind(internode,newdata)
        
      }
    }
  }
  unfindnode<-data.frame(parent=numeric(),node = numeric(), divergence_time = numeric())
  for (j in 1:nrow(internode)) {
    if (internode$node[j] %in% dftip$node){
      newtip<-data.frame(node = internode$parent[j],divergence_time =internode$divergence_time[j]+dftip[which(dftip$node==internode$node[j]),2])
      dftip<-rbind(dftip,newtip)
    }else{
      newnode<-data.frame(parent=internode$parent[j],node = internode$node[j],divergence_time =internode$divergence_time[j])
      unfindnode<-rbind(unfindnode,newnode)
    }
  }
  for (s in 1:nrow(unfindnode)){
    if (unfindnode$node[s] %in% dftip$node){
      newtip<-data.frame(node = unfindnode$parent[s],divergence_time =unfindnode$divergence_time[s]+dftip[which(dftip$node==unfindnode$node[s]),2])
      dftip<-rbind(dftip,newtip)
    }
  }
  dftip$divergence_time<-round(dftip$divergence_time, digits = 1)
  dftip<-dftip%>% distinct()
  return(dftip)
}

myainfo<-calculate_divergence_time(tibbletree)

tibbletree<-left_join(tibbletree,myainfo,by="node")

tree<-as.treedata(tibbletree)

p<-ggtree(tree,layout = "ellipse")+
  geom_tiplab(align = T, fontface="italic")+
  geom_point(aes(shape=isTip, color=isTip))+
  geom_text2(aes(label=divergence_time),vjust=-.3,hjust=1)+
  geom_treescale()+
  guides(shape="none",color="none")



# 计算 x 轴的范围（从右开始）
start <- max(tibbletree$branch.length,na.rm = T)
end <- 0

###看一下整个进化树的极限进化时间是多久，根据时间设置步长
print(start)

break_seq <- seq(from = start, to = end, by = -10)
label_seq<-seq(from = end, to = start, by = 10)


####写一个函数帮助我们完成次要刻度的生成
minor_ticks<-function(seq,step){
  min_value<-min(seq)
  max_value<-max(seq)
  for (i in 1:length(seq)){
    if (seq[i]==min_value){
      min_value<-min_value+step
    }else{
      seq[i]=" "
    }
  }
  return(seq)
}

p1<-p +
  scale_x_continuous(breaks = break_seq,
                     labels = minor_ticks(label_seq,30), ###使用minor_ticks函数生成次要刻度，注意，这里参数step必须是label_seq的step的整数倍
                     expand = expansion(mult=c(0.15,0.2)))+  ###将x轴向左右延长，以确保图中标注的信息能显示出来
  labs(x="Divergence time (MYA)")+  ###给x轴命名
  theme(axis.line.x = element_line(colour = "black"), # 添加 x 轴线
        axis.ticks.x = element_line(colour = "black"), # 添加 x 轴刻度线
        axis.text.x = element_text(colour = "black")) # 添加 x 轴刻度文本


