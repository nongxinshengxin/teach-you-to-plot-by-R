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
