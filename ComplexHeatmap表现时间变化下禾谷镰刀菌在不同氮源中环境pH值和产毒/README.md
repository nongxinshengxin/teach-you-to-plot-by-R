
欢迎关注农心生信工作室


后台有读者私信了一个比较细致的问题，他通过对一种名为禾谷镰刀菌的真菌施加不同氮源处理，追踪几个时间节点下，真菌环境pH值的变化，同时，由于该真菌会产生一种名为DON的真菌毒素，因此他观测了最后一个时间节点下禾谷镰刀菌DON毒素的产量，由于整个试验产生了多组数据，他想通过一张图片来进行可视化，以表现随着时间变化，禾谷镰刀菌在不同氮源中，环境pH值和产毒的联系。根据他提供的原始数据，我们决定使用顾祖光博士开发ComplexHeatmap包来实现，该R包正如其名一样复杂，但是其功能却异常强大，值得大家仔细学习。

1. R包检测和安装。先安装_ComplexHeatmap_包及其依赖并将所有包载入
```{}
# 检查开发者工具devtools，如没有则安装
if (!require("devtools"))
  install.packages("devtools")
# 加载开发者工具devtools
library(devtools)
# 检查热图包，没有则通过github安装最新版
if (!require("ComplexHeatmap"))
  install_github("jokergoo/ComplexHeatmap")
# 加载包
library(ComplexHeatmap)
2. 生成测试数据。根据读者提供的数据进行修改。数据一matrix.CSV为矩阵数据，行名为不同的氮源处理，列名为不同时间节点，矩阵中每个元素为pH值。数据二DON.CSV为在最后一个时间节点，不同氮源处理下，测得的DON毒素产毒量。（示例数据获取方式见文末）
# 读取数据
mat_df = read.csv("matrix.CSV",header = T,row.names = 1)
don<-read.csv("DON.CSV",header = T)
#重命名列名
colnames(mat_df)<-c("0h","12h","32h","76h","168h")
#将读取的数据一转化为矩阵
mat<-as.matrix(mat_df)
```




3. 热图预览，开始用ComplexHeatmap中最重要的函数Heatmap()绘制一张简单的热图。
```{}
ht1<-Heatmap(mat,
        cluster_rows = F,  #不按行聚类
        cluster_columns = F,  #不按列聚类
        heatmap_legend_param =list(title="pH")) #设置图例名称
```


4. 添加行分组注释，用柱状图的行分组注释来表示最后一个时间节点不同氮源下禾谷镰刀菌产毒量，核心函数是rowAnnotation()。
```{}
#将数据转化为向量
don<-c(t(don))
#生成行分组注释
row_ha = rowAnnotation(DON = anno_barplot(don))
ht2<-Heatmap(mat,cluster_rows = F,
        cluster_columns = F,
        heatmap_legend_param = list(title="pH"),
        right_annotation = row_ha)
```


5. 同时，为了更清楚的表现pH随时间变化的趋势，我们通过HeatmapAnnotation()函数添加一组折线图，表示pH的变化。
```{}
# 将矩阵的每行赋值给以不同氮源命名的变量，作为绘制折线图的数据
for (i in 1:nrow(mat_df)){
  assign(rownames(mat_df[i,]),c(t(mat_df[i,])))
}
#生成列分组注释
top_anno<-HeatmapAnnotation(Gln = anno_lines(Gln,add_points = TRUE),
                            Spd=anno_lines(Spd,add_points = TRUE),
                            Spm=anno_lines(Spm,add_points = TRUE),
                            NH4NO3=anno_lines(NH4NO3,add_points = TRUE),
                            `(NH4)2SO4`=anno_lines(`(NH4)2SO4`,add_points = TRUE),
                            Put=anno_lines(Put,add_points = TRUE),
                            Arg=anno_lines(Arg,add_points = TRUE),
                            Orn=anno_lines(Orn,add_points = TRUE),
                            Agmatine=anno_lines(Agmatine,add_points = TRUE))

ht3<-Heatmap(mat,cluster_rows = F,cluster_columns = F,
        heatmap_legend_param = list(title="pH"),
        right_annotation = row_ha,
        top_annotation = top_anno)
```



完整代码

```{}
# 检查开发者工具devtools，如没有则安装
if (!require("devtools"))
  install.packages("devtools")
# 加载开发者工具devtools
library(devtools)
# 检查热图包，没有则通过github安装最新版
if (!require("ComplexHeatmap"))
  install_github("jokergoo/ComplexHeatmap")
# 加载包
library(ComplexHeatmap)
​
​
# 读取数据
mat_df = read.csv("matrix.CSV",header = T,row.names = 1)
don<-read.csv("DON.CSV",header = T)
#重命名列名
colnames(mat_df)<-c("0h","12h","32h","76h","168h")
#将读取的数据一转化为矩阵
mat<-as.matrix(mat_df)
​
​
#将数据转化为向量
don<-c(t(don))
#生成行分组注释
row_ha = rowAnnotation(DON = anno_barplot(don))
​
​
# 将矩阵的每行赋值给以不同氮源命名的变量，作为绘制折线图的数据
for (i in 1:nrow(mat_df)){
  assign(rownames(mat_df[i,]),c(t(mat_df[i,])))
}
#生成列分组注释
top_anno<-HeatmapAnnotation(Gln = anno_lines(Gln,add_points = TRUE),
                            Spd=anno_lines(Spd,add_points = TRUE),
                            Spm=anno_lines(Spm,add_points = TRUE),
                            NH4NO3=anno_lines(NH4NO3,add_points = TRUE),
                            `(NH4)2SO4`=anno_lines(`(NH4)2SO4`,add_points = TRUE),
                            Put=anno_lines(Put,add_points = TRUE),
                            Arg=anno_lines(Arg,add_points = TRUE),
                            Orn=anno_lines(Orn,add_points = TRUE),
                            Agmatine=anno_lines(Agmatine,add_points = TRUE))
​
​
pdf("plot.pdf",width = 5,height = 7)
Heatmap(mat,cluster_rows = F,cluster_columns = F,
        heatmap_legend_param = list(title="pH"),
        right_annotation = row_ha,
        top_annotation = top_anno)
dev.off()
```

当然，该图并不只限定于这一种场景下，如果你也有多组数据不知如何处理，推荐你使用强大的ComplexHeatmap来解决可视化难的问题。

最后，感谢这位热心读者的提问，如果大家在阅读推文的过程中有任何问题，欢迎在后台留言，或加入 农心生信工作室学习交流群 提问，我们会努力为大家答疑解惑。





