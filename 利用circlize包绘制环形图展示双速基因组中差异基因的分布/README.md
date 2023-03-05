之前的推文中，我们介绍了如何绘制一个好看的染色体示意图来表示双速基因组中差异基因的分布，今天我们将进一步延申拓展这个主题，利用顾祖光博士开发的circlize包来绘制环形图展示双速基因组中差异基因的分布。话不多说，接下来我们将逐步拆解代码，完成绘图。



R包检测和安装

1. 安装核心R包circlize以及一些功能辅助性R包，并载入所有R包。

```{}
# 检查开发者工具devtools，如没有则安装
if (!require("devtools"))
  install.packages("devtools")
# 加载开发者工具devtools
library(devtools)
# 检查circlize包，没有则通过github安装最新版
if (!require("circlize"))
  install_github("jokergoo/circlize")
# 加载包
library(circlize)
```

生成测试数据



2. 读取数据。这里准备了4个示例数据集。示例数据与源代码的获取方式已在文末标注。

```{}
#读取数据
genome<-read.csv("genome.csv",header = T)
two_speed_g<-read.csv("two_speed.csv",header = T)
DEgene<-read.csv("DEgene.csv",header = T)
GCcontent<-read.csv("gc_content.csv",header = T)
```





图形预览



3. 开始作图，最外圈首先绘制染色体的示意图，仅保留染色体长度刻度和标签。

```{}
circos.clear()
circos.par(start.degree = 85, track.height = 0.02, cell.padding = c(0,0,0,0), gap.degree=c(rep(1,23), 5))
circos.initializeWithIdeogram(genome,plotType = c("axis", "labels"))
```



4. 第二圈，绘制双速基因组区域，fast和slow分别由不同颜色表示。

```{}
two_speed_g_list<-list(two_speed_g[two_speed_g$group=="fast",],
                       two_speed_g[two_speed_g$group=="slow",])

circos.genomicTrackPlotRegion(two_speed_g_list, track.height = 0.08,ylim = c(0,1), bg.border="lightgray",
                              panel.fun = function(region, value, ...){
                                i=getI(...)
                                if(i == 1){
                                  circos.genomicRect(region, value, col = "#B3E5FC", border = NA, lwd=1)}
                                else{
                                  circos.genomicRect(region, value, col = "#F0F4C3", border = NA, lwd=1)
                                }
                              })

```


5. 第三圈，绘制差异表达基因位置。差异表达基因里有上调和下调的基因，分别用橙色和紫色标注。

```{}
#绘制差异表达基因位置
DEgene.list<-list(DEgene[DEgene$group=="up",],
                  DEgene[DEgene$group=="down",])

circos.genomicTrackPlotRegion(DEgene.list, track.height = 0.05,ylim = c(0,1), bg.border="lightgray",
                              panel.fun = function(region, value, ...){
                                i=getI(...)
                                if(i == 1){
                                  circos.genomicRect(region, value, col = "orange", border ="orange", lwd=0.1)}
                                else{
                                  circos.genomicRect(region, value, col = "purple", border = "purple", lwd=0.1)
                                }
                                })

```


6. 第四圈，我们再多增加一圈来展示基因组GC含量的分布。假设基因组平均GC含量为0.56，绿色表示该区域GC含量高于平均GC含量，红色相反。

```{}
#绘制基因组的GC含量
GCcontent$value<-GCcontent$value-0.56 
#排除数据中可能存在的异常值，将所有异常值更改为平均值
outlier <- GCcontent$value
outlier[which(outlier %in% boxplot.stats(outlier)$out)] <- mean(outlier)
GCcontent$value<-outlier
gc.list <- list(GCcontent[GCcontent$value>0, ], 
                GCcontent[GCcontent$value<0, ])
                
circos.genomicTrackPlotRegion(gc.list, track.height = 0.08, bg.border = NA, ylim = c(min(vv),max(vv)),
                              # ylim=c(min(bed.gc$value), max(bed.gc$value)),
                              panel.fun = function(region, value, ...){
                                i=getI(...)
                                if(i == 1){
                                  circos.genomicRect(region, value, col = "forestgreen", border = NA,
                                                     ybottom = 0, ytop.column = 1)
                                }else{
                                  circos.genomicRect(region, value, col = "firebrick1", border = NA,
                                                     ybottom = 0, ytop.column = 1)
                                }})


```






完整代码

```{}
#R包检测和安装
# 检查开发者工具devtools，如没有则安装
if (!require("devtools"))
  install.packages("devtools")
# 加载开发者工具devtools
library(devtools)
# 检查circlize包，没有则通过github安装最新版
if (!require("circlize"))
  install_github("jokergoo/circlize")
# 加载包
library(circlize)

#读取数据
genome<-read.csv("genome.csv",header = T)
two_speed_g<-read.csv("two_speed.csv",header = T)
DEgene<-read.csv("DEgene.csv",header = T)
GCcontent<-read.csv("gc_content.csv",header = T)

circos.clear()
circos.par(start.degree = 85, track.height = 0.02, cell.padding = c(0,0,0,0), gap.degree=c(rep(1,23), 5))
circos.initializeWithIdeogram(genome,plotType = c("axis", "labels"))

###绘制双速基因组区域

two_speed_g_list<-list(two_speed_g[two_speed_g$group=="fast",],
                       two_speed_g[two_speed_g$group=="slow",])

circos.genomicTrackPlotRegion(two_speed_g_list, track.height = 0.08,ylim = c(0,1), bg.border="lightgray",
                              panel.fun = function(region, value, ...){
                                i=getI(...)
                                if(i == 1){
                                  circos.genomicRect(region, value, col = "#B3E5FC", border = NA, lwd=1)}
                                else{
                                  circos.genomicRect(region, value, col = "#F0F4C3", border = NA, lwd=1)
                                }
                              })

#绘制差异表达基因位置
DEgene.list<-list(DEgene[DEgene$group=="up",],
                  DEgene[DEgene$group=="down",])

circos.genomicTrackPlotRegion(DEgene.list, track.height = 0.05,ylim = c(0,1), bg.border="lightgray",
                              panel.fun = function(region, value, ...){
                                i=getI(...)
                                if(i == 1){
                                  circos.genomicRect(region, value, col = "orange", border ="orange", lwd=0.1)}
                                else{
                                  circos.genomicRect(region, value, col = "purple", border = "purple", lwd=0.1)
                                }
                                })

#绘制基因组的GC含量
GCcontent$value<-GCcontent$value-0.56

#排除数据中可能存在的异常值，将所有异常值更改为平均值
outlier <- GCcontent$value
outlier[which(outlier %in% boxplot.stats(outlier)$out)] <- mean(outlier)

GCcontent$value<-outlier

gc.list <- list(GCcontent[GCcontent$value>0, ], 
                GCcontent[GCcontent$value<0, ])
circos.genomicTrackPlotRegion(gc.list, track.height = 0.08, bg.border = NA, ylim = c(min(vv),max(vv)),
                              # ylim=c(min(bed.gc$value), max(bed.gc$value)),
                              panel.fun = function(region, value, ...){
                                i=getI(...)
                                if(i == 1){
                                  circos.genomicRect(region, value, col = "forestgreen", border = NA,
                                                     ybottom = 0, ytop.column = 1)
                                }else{
                                  circos.genomicRect(region, value, col = "firebrick1", border = NA,
                                                     ybottom = 0, ytop.column = 1)
                                }})
```
