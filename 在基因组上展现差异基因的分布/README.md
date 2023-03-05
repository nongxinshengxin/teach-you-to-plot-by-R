最近发现一幅有趣的图，是2022年1月17日刊登在Stress Biology上《Deletion of all three MAP kinase genes results in severe defects in stress responses and pathogenesis in Fusarium graminearum 》的Fig5 A 。该图描绘了禾谷镰刀菌中一些差异表达基因在双速基因组上的分布，展现了基因在基因组上的可视化方法。



接下来，我们将通过详尽的代码逐步拆解原图，最终实现对原图的复现。



1. 安装核心R包RIdeogram以及karyoploteR，并载入所有R包。

```{}
if (!require("RIdeogram"))
  install.packages('RIdeogram')
if (!require("karyoploteR"))
  install.packages('karyoploteR') 
# 加载包
library(RIdeogram)
library(karyoploteR)
```

2. 生成测试数据。要复现原图，需要将过程拆解为三步，首先绘制染色体示意图，其次绘制双速基因组区域，最后绘制差异基因在基因组上的位置。由于缺少原始数据，因此本例使用RIdeogram包自带的数据集进行测试。

```{}
setwd("f:/plot/") #设置工作目录，这里的目录需要提前创建好
data(human_karyotype, package="RIdeogram")
data(gene_density, package="RIdeogram")
data(Random_RNAs_500, package="RIdeogram")
#基于载入的数据进行改造，获得本例中需要使用的数据
#基因组信息
genome<-human_karyotype[c(1,2,3)]



#双速基因组分布数据
two_speed_g<-gene_density
#添加一列value，value值为0意为低速区域，为1意为高速区域
two_speed_g$Value<-sample(c(0:1),size = 3102,replace = T)




#上调表达的差异基因分布数据
up_gene<-Random_RNAs_500
up_gene$Type<-"up"
up_gene$Shape<-"circle"
up_gene$color<-"blue"
```



3.先使用RIdeogram进行绘图：

```{}
ideogram(karyotype = genome,  #基因组（染色体）信息
         overlaid = two_speed_g, #双速基因组信息。这里只能展示热图，因此双速基因组中高速区域值均为1，低速区域均为0，这样展示出的热图不是渐变色，而是分区域呈现两种颜色
         label = up_gene, #差异表达基因信息
         label_type = "marker",
         colorset1 = c("#F0F4C3", "#B3E5FC")) #双速基因组颜色设置
convertSVG("chromosome.svg",device="png") #保存图片
```



最后的成品图还不错，但与原图的相似度不够。



4.再使用karyoploteR进行绘图。先将双速基因组数据按高速区和低速区拆分，差异表达基因数据也仅取3,4,5列：



```{}
slow<-two_speed_g[two_speed_g$Value=="0",][-ncol(two_speed_g)]
fast<-two_speed_g[two_speed_g$Value=="1",][-ncol(two_speed_g)]
up_gene2<-up_gene[c(3,4,5)]
```

5.创建染色体示意图和染色体名称：

```{}
kp <- plotKaryotype(genome, plot.type=1, cex=0.6) #参数plot.type后接数字1-7，即示意图的7种不同形式
```



6.我们不需要染色体示意图有高度，可以通过getDefaultPlotParams()函数设置示意图参数，在这里我们设置示意图高度为0再进行绘图：

```{}
pp<-getDefaultPlotParams(plot.type = 1)
pp$ideogramheight<-0
kp <- plotKaryotype(genome, plot.type=1,plot.params = pp, cex=0.6)
```




7.绘制双速基因组区域：

```{}
kp<-kpPlotRegions(kp, slow, col="#F0F4C3")
kp<-kpPlotRegions(kp, fast, col="#B3E5FC")
```



8.绘制差异表达基因在基因组上的分布情况：

```{}
kp<-kpPlotRegions(kp, up_gene2, col="red")
```



### 附.完整代码



```{}
if (!require("RIdeogram"))
  install.packages('RIdeogram')
if (!require("karyoploteR"))
  install.packages('karyoploteR') 
# 加载包
library(RIdeogram)
library(karyoploteR)

setwd("f:/plot/") #设置工作目录，这里的目录需要提前创建好
data(human_karyotype, package="RIdeogram")
data(gene_density, package="RIdeogram")
data(Random_RNAs_500, package="RIdeogram")
#基于载入的数据进行改造，获得本例中需要使用的数据
#基因组信息
genome<-human_karyotype[c(1,2,3)]
#双速基因组分布数据
two_speed_g<-gene_density
#添加一列value，value值为0意为低速区域，为1意为高速区域
two_speed_g$Value<-sample(c(0:1),size = 3102,replace = T)
#上调表达的差异基因分布数据
up_gene<-Random_RNAs_500
up_gene$Type<-"up"
up_gene$Shape<-"circle"
up_gene$color<-"blue"
#plot 1
ideogram(karyotype = genome,  #基因组（染色体）信息
         overlaid = two_speed_g, #双速基因组信息。这里只能展示热图，因此双速基因组中高速区域值均为1，低速区域均为0，这样展示出的热图不是渐变色，而是分区域呈现两种颜色
         label = up_gene, #差异表达基因信息
         label_type = "marker",
         colorset1 = c("#F0F4C3", "#B3E5FC")) #双速基因组颜色设置
convertSVG("chromosome.svg",device="png") #保存图片
#plot2
slow<-two_speed_g[two_speed_g$Value=="0",][-ncol(two_speed_g)]
fast<-two_speed_g[two_speed_g$Value=="1",][-ncol(two_speed_g)]
up_gene2<-up_gene[c(3,4,5)]
#绘制染色体示意图
pp<-getDefaultPlotParams(plot.type = 1)
pp$ideogramheight<-0
kp <- plotKaryotype(genome, plot.type=1,plot.params = pp, cex=0.6)
#绘制双速基因组区域
kp<-kpPlotRegions(kp, slow, col="#F0F4C3")
kp<-kpPlotRegions(kp, fast, col="#B3E5FC")
#绘制差异表达基因在基因组上的分布情况
kp<-kpPlotRegions(kp, up_gene2, col="red")
```
