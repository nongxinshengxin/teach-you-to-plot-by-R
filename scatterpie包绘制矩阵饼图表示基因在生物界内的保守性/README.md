近期我们收到了读者的私信提问，他说最近正在分析一些基因在整个真菌界的保守性，已经鉴定到这些基因在整个真菌界中所有物种里的直系同源基因数量，现在想将结果可视化。他发来一篇文献，是2019年发表在environmental microbiology 上的《Independent losses and duplications of autophagy-related genes in fungal tree of life》。他想复现Fig 1C中的矩阵饼状图。






由原图可知，矩阵饼图顶部的行表示41个ATG基因，从1-41进行编号；每个纲或门的物种数在括号中标出；矩阵中的单个饼图显示了每个真菌类群中具有(蓝色)和不具有(灰色)单个ATG基因的真菌物种的比例。

我们推测该图应该是用R的基础绘图包完成（例如igraph），今天在这里，我们尝试基于ggplot2包进行复现。

scatterpie包是基于ggplot2构建的包，可以把散点图的点换成饼图，接下来，我们将通过这个包，来对原图进行复现。



1. 安装并载入所需R包：‍

```{}
if (!require("scatterpie"))
  install.packages("scatterpie")
if (!require("tidyr"))
  install.packages("tidyr")
# 加载包
library(scatterpie)
library(tidyr)
```



2. 生成测试数据。使用scatterpie包，输入的数据是关键，由于该包可以将散点图中的点换成饼图，实际上它的使用方法与绘制散点图相似，需要将数据映射到x轴和y轴。但该包不支持映射字符型数据，只能映射数值型数据，因此对输入的数据要进行预先处理：

```{}
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
```

3. 图形绘制，代码非常简洁：

```{}
ggplot()+
  geom_scatterpie(aes(x=geneNum, y=order), data=df, cols=c("Presence","Absence"))
```



4. 在此基础上，美化图片：

```{}
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
```



5. 用AI美化调整。





完整代码如下：

```{}
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
这里多说一句，复现图相比原图，虽然接近，但仍不够美观，可能在绘制这类矩阵饼图时使用基础绘图函数会更加灵活，原图作者的代码应该更加巧妙。之后会尝试用基础绘图函数来复现该图。

最后，感谢这位热心读者的提问，如果大家在阅读推文的过程中有任何问题，欢迎在后台留言，或加入 农心生信工作室学习交流群 提问，我们会努力为大家答疑解惑。
```
