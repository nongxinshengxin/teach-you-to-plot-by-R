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
