library(ComplexHeatmap)

mat_df = read.csv("matrix.CSV",header = T,row.names = 1)
don<-read.csv("DON.CSV",header = T)

colnames(mat_df)<-c("0h","12h","32h","76h","168h")
mat<-as.matrix(mat_df)
Heatmap(mat,cluster_rows = F,cluster_columns = F,heatmap_legend_param = list(title="pH"))

don<-c(t(don))
row_ha = rowAnnotation(DON = anno_barplot(don))
Heatmap(mat,cluster_rows = F,cluster_columns = F,heatmap_legend_param = list(title="pH"),right_annotation = row_ha)

for (i in 1:nrow(mat_df)){
  assign(rownames(mat_df[i,]),c(t(mat_df[i,])))
}

top_anno<-HeatmapAnnotation(Gln = anno_lines(Gln,add_points = TRUE),
                            Spd=anno_lines(Spd,add_points = TRUE),
                            Spm=anno_lines(Spm,add_points = TRUE),
                            NH4NO3=anno_lines(NH4NO3,add_points = TRUE),
                            `(NH4)2SO4`=anno_lines(`(NH4)2SO4`,add_points = TRUE),
                            Put=anno_lines(Put,add_points = TRUE),
                            Arg=anno_lines(Arg,add_points = TRUE),
                            Orn=anno_lines(Orn,add_points = TRUE),
                            Agmatine=anno_lines(Agmatine,add_points = TRUE))

Heatmap(mat,cluster_rows = F,cluster_columns = F,
        heatmap_legend_param = list(title="pH"),
        right_annotation = row_ha,
        top_annotation = top_anno)
