<a name="XGs8F"></a>
## 写在前面
最近需要绘制几副热图，就进一步了解了一下顾祖光老师的ComplexHeatmap包，越是学习越挖掘到这个包的强大，还意外发现顾老师在ComplexHeatmap包的基础上，开发了InteractiveComplexHeatmap包，该包是将ComplexHeatmap包生成的静态热图转换为交互式shiny APP。我发现该包很适合绘制一个复杂热图中的局部放大热图。例如，你有一个数据量非常大的矩阵，绘制热图后，你想要聚焦其中几行几列获得一个子热图，此时使用InteractiveComplexHeatmap包会帮你轻松实现这个需求。今天，我们将使用推文中的数据，利用InteractiveComplexHeatmap包来绘制一个复杂热图中的局部放大热图。


<a name="bGcOu"></a>
## 安装并加载R包
```r
if (!require("BiocManager"))
  install.packages("BiocManager")
if (!require("InteractiveComplexHeatmap"))
  BiocManager::install("InteractiveComplexHeatmap")
if (!require("ComplexHeatmap"))
  BiocManager::install("ComplexHeatmap")

library(InteractiveComplexHeatmap)
library(ComplexHeatmap)
```
<a name="Zyexi"></a>
## 读取并处理数据
```r
df<-read.csv("diffgene.csv",header = T)
df<-df[order(df$Pathway),] #按分组信息排序

#提取表达量数据转化成矩阵
mat<-as.matrix(df[-c(1,ncol(df))])
mat<-log2(mat+1)
rownames(mat)<-df$gene_id
```
<a name="qNgdS"></a>
## 图像绘制
根据矩阵绘制热图。
```r
left_col<-c("Pathway1"="#1E90FF","Pathway2"="#32CD32","Pathway3"="#006400","Pathway4"="#0000CD","Pathway5"="#FF1493","Pathway6"="#FF8C00","Pathway7"="#B22222")
left_anno<-rowAnnotation(Pathway=df[,ncol(df)],col=list(Pathway=left_col),show_annotation_name=F)

ht<-Heatmap(mat, name = "ht",
            cluster_rows = F,
            cluster_columns = T,
            heatmap_legend_param = list(title="Log2 FPKM"),
            col = c("lightblue","#FFFFFF","#D32F2F"),
            row_split = df$Pathway,
            row_title=NULL,
            row_gap = unit(4,"mm"),
            left_annotation = left_anno)
```
热图绘制完成后，在热图上添加方框，选取需要局部放大区域。注意，这个grid.lines接受的第一个向量是x的坐标，第二个向量是y的坐标，这里是将笛卡尔坐标系压缩到0-1之间，x=c(0.5, 1)表示x轴方向上，起点是整个坐标轴0.5处，终点是1处，y=c(0, 0)表示y轴方向上，起点是整个坐标轴0处，终点还是是0处。
```r
post_fun = function(ht_list) {
  decorate_heatmap_body("ht", {
    grid.lines(c(0.5, 1), c(0, 0), gp = gpar(lty = 2, lwd = 2))
    grid.lines(c(0.5, 1), c(1, 1), gp = gpar(lty = 2, lwd = 2))
    grid.lines(c(1, 1), c(0, 1), gp = gpar(lty = 2, lwd = 2))
    grid.lines(c(0.5, 0.5), c(0, 1), gp = gpar(lty = 2, lwd = 2))
  },row_slice =3 ) #热图中的行切片索引
}

ht<-draw(ht,post_fun=post_fun)
```
将静态热图ht转换为交互式 Shiny 应用。
```r
htShiny(ht, width1 = 400,height1 = 450)
```
运行上面一行代码后，会弹出一个shiny APP窗口，可以直接单击一个位置或从热图中选择一个区域。通过从框的右下方拖动，可以调整原始热图和所选子热图的大小。最后，可以将热图和子热图保存为你想要的格式输出，这里我们保存为PDF格式。



