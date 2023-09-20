> “如果不是从进化的角度看问题，生物学的一切都将无法理解。”
>                                        ———— 杜布赞斯基


<a name="Jt2ag"></a>
## 写在前面
进化是生物学的统一理论。绘制进化树（系统发生树），则探究生物进化过程的最直观体现。我们已经连续推出多期关于如何使用ggtree、ggtreExtra包绘制进化树的教程。今天，我们将再次实践，通过复现2021年发表在**Nature Communications**上_Chloranthus genome provides insights into the early diversification of angiosperms_一文的fig2a，进一步学习理解掌握如何用ggtree、ggtreExtra包绘制美观的进化树。话不多说先上原图：


<a name="we5fz"></a>
## 源码获取
源码和示例数据已上传GitHub仓库，可以在以下链接获取：<br />[https://github.com/nongxinshengxin/teach-you-to-plot-by-R](https://github.com/nongxinshengxin/teach-you-to-plot-by-R)

<a name="P4YZv"></a>
## R包加载
```r
if (!require("BiocManager"))
  install.packages("BiocManager")
if (!require("ggtree"))
  BiocManager::install("ggtree")
if (!require("tidytree"))
  install.packages("tidytree")
if (!require("tidyverse"))
  install.packages("tidyverse")
if (!require("ggtreeExtra"))
  BiocManager::install("ggtreeExtra")

library(ggtree)
library(tidytree)
library(tidyverse)
library(ggtreeExtra)
```

<a name="vLxEB"></a>
## 代码解析
<a name="wYXLT"></a>
### 读取数据
文章附件提供了newick文件可以绘制进化树，原图右边的散点图数据未提供，我们手动编辑文件genomeInfo.CSV用于绘制。

```r
tree<-read.tree("Fig_3a.18Species_2329LCN.newick")
genomeInfo<-read.csv("genomeInfo.CSV",header = T)
#宽表变长表
genomeInfo<-pivot_longer(genomeInfo,cols =-1 )
#固定x轴顺序
namefac<-factor(genomeInfo$name,levels = c("GenomeSize","GeneSize","IntroSize"))
```

<a name="cgsRz"></a>
### 绘图过程
原图涉及根据不同进化支进行分组上色，因此我们需要先看每一个节点（包括内节点和末端节点）编号。
```r
p0<-ggtree(tree)+ geom_tiplab(align = T)+geom_text2(aes(label=node),hjust=-.3,color="red")
```

接下来需要对不同进化支进行分组。groupClade()函数接受一个内部节点或内部节点的向量，这个节点下的所有子节点自动分为一组。但注意，**groupClade()不接受末端节点**。本图中，有一条分支分组是基于末端节点分组的（原图蓝色）。为解决这个问题，需要用到groupOTU()函数，该函数接受分组下所有节点，相应的，也能接受末端节点。

```r
tree <- groupClade(tree, c(23,27,33))
tree_tibble<-as_tibble(tree)
tree_tibble<-tree_tibble%>%mutate(group=as.character(tree_tibble$group))
tree_tibble[which(tree_tibble$node==5),5]<-"5"
groupinfo<-split(tree_tibble$node, tree_tibble$group)
tree<-as.phylo(tree_tibble)
tree <- groupOTU(tree, groupinfo)
```

分组完成后，开始绘制进化树并美化：

```r
p1<-ggtree(tree,aes(colour=group),size=2)+
  geom_tiplab(align = T,fontface = "bold.italic",size=3.5,color="black")+
  geom_treescale(x=0, y=15, width=0.1, color='black')+ ##添加进化距离标尺
  scale_color_manual(values = c("black","#800080","#008000","#FFD700","#0000FF"))+
  guides(color="none")
```

绘制出来的进化树末端节点顺序和原图不一致，可以根据内部节点调整，这里只调整一个，作为例子：
```r
p2<-ggtree::rotate(p1,22)
```

用ggtreeExtra添加进化树右边的气泡图：
```r
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
                    limits=c("GenomeSize","GeneSize","IntroSize"))
```

<a name="kxvnY"></a>
## 完整代码
```r
if (!require("BiocManager"))
  install.packages("BiocManager")
if (!require("ggtree"))
  BiocManager::install("ggtree")
if (!require("tidytree"))
  install.packages("tidytree")
if (!require("tidyverse"))
  install.packages("tidyverse")
if (!require("ggtreeExtra"))
  BiocManager::install("ggtreeExtra")

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

tree <- groupClade(tree, c(23,27,33))
tree_tibble<-as_tibble(tree)
tree_tibble<-tree_tibble%>%mutate(group=as.character(tree_tibble$group))
tree_tibble[which(tree_tibble$node==5),5]<-"5"
groupinfo<-split(tree_tibble$node, tree_tibble$group)
tree<-as.phylo(tree_tibble)
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
                    limits=c("GenomeSize","GeneSize","IntroSize"))
```


<a name="az5j6"></a>
## 写在最后
每天


