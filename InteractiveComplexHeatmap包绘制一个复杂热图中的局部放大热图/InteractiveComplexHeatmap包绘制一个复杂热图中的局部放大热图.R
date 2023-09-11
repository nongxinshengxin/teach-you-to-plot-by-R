if (!require("BiocManager"))
  install.packages("BiocManager")
if (!require("InteractiveComplexHeatmap"))
  BiocManager::install("InteractiveComplexHeatmap")
if (!require("ComplexHeatmap"))
  BiocManager::install("ComplexHeatmap")

library(InteractiveComplexHeatmap)
library(ComplexHeatmap)


df<-read.csv("diffgene.csv",header = T)
df<-df[order(df$Pathway),] #按分组信息排序

#提取表达量数据转化成矩阵
mat<-as.matrix(df[-c(1,ncol(df))])
mat<-log2(mat+1)
rownames(mat)<-df$gene_id

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

###热图绘制完成后，在热图上添加方框，选取需要局部放大区域
post_fun = function(ht_list) {
  decorate_heatmap_body("ht", {
    grid.lines(c(0.5, 1), c(0, 0), gp = gpar(lty = 2, lwd = 2))
    grid.lines(c(0.5, 1), c(1, 1), gp = gpar(lty = 2, lwd = 2))
    grid.lines(c(1, 1), c(0, 1), gp = gpar(lty = 2, lwd = 2))
    grid.lines(c(0.5, 0.5), c(0, 1), gp = gpar(lty = 2, lwd = 2))
  },row_slice =3 ) #热图中的行切片索引
}

ht<-draw(ht,post_fun=post_fun)


#将静态热图ht转换为交互式 Shiny 应用
htShiny(ht, width1 = 400,height1 = 450)


