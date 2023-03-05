通常在完成基因组组装后，我们需要根据基因组序列以及转录组证据的支持，对基因进行预测，常用的流程有maker、braker等，也存在很多从头预测的软件比如Augustus、gene-mark等，它们的使用流程教程很多这里不再过多赘述。今天我们想要实现的是，在完成基因预测获得基因注释的gff文件后，如何对基因特征，如外显子数量以及基因长度分布进行统计并可视化？R语言可以帮助我们轻松解决这一问题。


### R包检测和安装
1. 安装核心R包GenomicFeatures以及一些功能辅助性R包，并载入所有R包。
```{r}
if (!require("BiocManager"))
  install.packages('BiocManager') 
if (!require("GenomicFeatures"))
  BiocManager::install('GenomicFeatures')
if (!require("ggplot2"))
  install.packages("ggplot2")
if (!require("cowplot"))
  install.packages("cowplot") 
# 加载包
library(GenomicFeatures)
library(ggplot2)
library(cowplot)
```

### 生成测试数据
2. 测试数据为模式真菌粗糙脉胞菌的基因注释gtf文件。示例数据与源代码的获取方式已在文末标注。
```{r}
#根据gff文件获得基因信息
txdb <- makeTxDbFromGFF("Neurospora_crassa.NC12.52.gtf", format = "gtf")
```


### 作图预览
3. 计算基因中外显子数量。最终获得一个数据框exonNum.df，表示包含1个外显子到10个以上外显子的基因数量。
```{r}
exon.gr.list <- exonsBy(txdb, by = "tx")#读取exon外显子信息
exon.num <- unlist(lapply(exon.gr.list, FUN = function(x) {NROW(x)}))#统计每个基因中外显子数量
exon.tbl <- table(exon.num)#table函数计算包含不同数量外显子的基因频数
exonMoreThan10 <- sum(exon.tbl[11:length(exon.tbl)])#将外显子数量大于10的基因数统计在一起
exonNum.df <- data.frame(cc = c(as.vector(exon.tbl[1:10]), exonMoreThan10))
positions1 = rownames(exonNum.df)
```


4. 将统计后的外显子数量进行可视化。
```{r}
#设置颜色
cc1 = c(colorRampPalette(c("#00b4d8", "#ade8f4"))(10), "#fb8500") 
p1 <- ggplot(data = exonNum.df, aes(x=rownames(exonNum.df),y=cc))+ 
  geom_bar(stat = "identity",fill=cc1) + 
  geom_text(label = exonNum.df$cc, nudge_y = 60) +
  scale_x_discrete(limits=positions1, labels=c("1","2","3","4","5","6","7","8","9","10", ">10")) +
  scale_y_continuous(expand =expansion(mult=c(0,0.05))) + 
  theme_classic() + 
  xlab("Exon number") + 
  ylab("Number of genes")
```

5. 计算基因长度分布数量。最终获得一个数据框geLen.df，表示以500bp作为滑窗，基因长度的最终分布。
```{r}
ge.length <- width(genes(txdb)) #读取基因的长度
aa = table(cut(ge.length, breaks=seq(0,4000, 500))) 
morethan4000 <- length(ge.length[ge.length > 4000])
geLen.df <- data.frame(cc = c(as.vector(aa), morethan4000))
x.lab = c("1-500", "501-1000", "1001-1500", "1501-2000", "2001-2500", "2501-3000", "3001-3500","3501-4000", ">4000")
positions2 = x.lab
```

6. 将基因长度分布进行可视化。
```{r}
cc2 = c(colorRampPalette(c("#7b2cbf", "#e0aaff"))(8), "#538d22")
p2 <- ggplot(data = geLen.df, aes(x = x.lab, y = cc)) + 
  geom_bar(stat = "identity", fill=cc2) + 
  geom_text(label = geLen.df$cc, nudge_y = 60) + 
  scale_x_discrete(limits = positions2, labels = positions2)  + 
  scale_y_continuous(expand =expansion(mult=c(0,0.05))) + 
  theme_classic() + 
  xlab("Gene length distribution") + 
  ylab("Number of genes")+
  theme(axis.text.x = element_text(angle = 270, hjust = 0, vjust = 0))
```
7. 最终，用cowplot包将两幅图组合输出。成品图如下。
```{r}
pdf("plot.pdf", width = 10, height = 6)
plot_grid(plotlist = list(p1,p2), align = "h", nrow = 1)
dev.off()
```


### 附.完整代码
```{r}
if (!require("BiocManager"))
  install.packages('BiocManager') 
if (!require("GenomicFeatures"))
  BiocManager::install('GenomicFeatures')
if (!require("ggplot2"))
  install.packages("ggplot2")
if (!require("cowplot"))
  install.packages("cowplot") 
# 加载包
library(GenomicFeatures)
library(ggplot2)
library(cowplot)
txdb <- makeTxDbFromGFF("Neurospora_crassa.NC12.52.gtf", format = "gtf")
####### exon num
exon.gr.list <- exonsBy(txdb, by = "tx")#读取exon外显子信息
exon.num <- unlist(lapply(exon.gr.list, FUN = function(x) {NROW(x)}))#统计每个基因中外显子数量
exon.tbl <- table(exon.num)#table函数计算包含不同数量外显子的基因频数
exonMoreThan10 <- sum(exon.tbl[11:length(exon.tbl)])#将外显子数量大于10的基因数统计在一起
exonNum.df <- data.frame(cc = c(as.vector(exon.tbl[1:10]), exonMoreThan10))
positions1 = rownames(exonNum.df)
cc1 = c(colorRampPalette(c("#00b4d8", "#ade8f4"))(10), "#fb8500") #设置颜色 
p1 <- ggplot(data = exonNum.df, aes(x=rownames(exonNum.df),y=cc))+ 
  geom_bar(stat = "identity",fill=cc1) + 
  geom_text(label = exonNum.df$cc, nudge_y = 60) +
  scale_x_discrete(limits=positions1, labels=c("1","2","3","4","5","6","7","8","9","10", ">10")) +
  scale_y_continuous(expand =expansion(mult=c(0,0.05))) + 
  theme_classic() + 
  xlab("Exon number") + 
  ylab("Number of genes")
####### gene lengths
ge.length <- width(genes(txdb)) #读取基因的长度
aa = table(cut(ge.length, breaks=seq(0,4000, 500))) 
morethan4000 <- length(ge.length[ge.length > 4000])
geLen.df <- data.frame(cc = c(as.vector(aa), morethan4000))
x.lab = c("1-500", "501-1000", "1001-1500", "1501-2000", "2001-2500", "2501-3000", "3001-3500","3501-4000", ">4000")
positions2 = x.lab
cc2 = c(colorRampPalette(c("#7b2cbf", "#e0aaff"))(8), "#538d22")#设置颜色
p2 <- ggplot(data = geLen.df, aes(x = x.lab, y = cc)) + 
  geom_bar(stat = "identity", fill=cc2) + 
  geom_text(label = geLen.df$cc, nudge_y = 60) + 
  scale_x_discrete(limits = positions2, labels = positions2)  + 
  scale_y_continuous(expand =expansion(mult=c(0,0.05))) + 
  theme_classic() + 
  xlab("Gene length distribution") + 
  ylab("Number of genes")+
  theme(axis.text.x = element_text(angle = 270, hjust = 0, vjust = 0))
pdf("plot.pdf", width = 10, height = 6)
plot_grid(plotlist = list(p1,p2), align = "h", nrow = 1)
dev.off()
```
