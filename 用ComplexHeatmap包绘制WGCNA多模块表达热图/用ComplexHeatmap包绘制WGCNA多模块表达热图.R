library(ComplexHeatmap)
mat<-read.csv("tpm.csv",header = T,row.names = 1)
colnames(mat)<-c("Co","8h","16h","24h","48h","72h","96h","144h")
mat<-as.matrix(mat)
mat=t(scale(t(mat)))

ht<-Heatmap(mat,
        row_split = factor(c(rep("M1", 30), rep("M2", 25),rep("M3", 20),
                             rep("M4", 19),rep("M5", 18),rep("M6", 17),rep("M7", 8),
                             rep("M8", 7),rep("M9", 5),rep("M10", 9)),
                           levels = paste("M",seq(10),sep = "")),
        cluster_row_slices = FALSE,
        cluster_columns = F,
        show_row_names =F,
        row_title_gp = gpar(col = c("pink", "brown","cyan","yellow","green","magenta","purple","greenyellow","tan","skyblue"),
                            font=2),
        heatmap_legend_param = list(
          title = "Centered Expression Level",  
          direction = "horizontal",
          title_position = "topcenter"
        )
)

draw(ht, heatmap_legend_side = "bottom")
