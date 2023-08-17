if (!require("tidyverse"))
  install.packages('tidyverse')
if (!require("ggrepel"))
  install.packages('ggrepel')

library(ggplot2)
library(tidyverse)
library(ggrepel)

dataset<-read.csv("ALLDESeq2.csv",header = T)
dataset<-na.omit(dataset)

genedf<-read.table("genelist.txt",header = F)%>%rename_with(~"geneID",1)%>%left_join(dataset,by="geneID")


cut_off_fdr =0.05
cut_off_logFC= 1


dataset$change = ifelse(dataset$padj >= cut_off_fdr & abs(dataset$log2FoldChange) < cut_off_logFC,
                        'NS',ifelse(dataset$padj >= cut_off_fdr ,'logFC',ifelse(abs(dataset$log2FoldChange) >= cut_off_logFC ,'p-value and logFC','p-value'))
                        )


dataset<-dataset%>%mutate(change=case_when(dataset$padj >= cut_off_fdr & abs(dataset$log2FoldChange) < cut_off_logFC ~ "NS",
                                dataset$padj >= cut_off_fdr & abs(dataset$log2FoldChange) >= cut_off_logFC ~ "logFC",
                                dataset$padj < cut_off_fdr & abs(dataset$log2FoldChange) >= cut_off_logFC ~ "p-value and logFC",
                                TRUE ~ "p-value"))



ggplot(
  # draw plot
  dataset, aes(x =log2FoldChange , y = -log10(padj), colour=change)) +
  geom_point(alpha=0.8, size=1) +
  scale_color_manual(values=c("#8292B4","#EAE8E8","#70B69D","#916396"))+
  # draw line
  geom_vline(xintercept=c(-cut_off_logFC,cut_off_logFC),lty=4,col="black",lwd=0.8) +
  geom_hline(yintercept = -log10(cut_off_fdr),lty=4,col="black",lwd=0.8) +
  #add gene text
  geom_text_repel(
    data = genedf,
    aes(x =log2FoldChange , y = -log10(padj), label = geneID),
    colour="black",
    size = 1.8,
    force= 20,box.padding = 1, point.padding = 1,hjust = 0.5,
    min.segment.length = 0,
    arrow = arrow(length = unit( 0.01, "npc"), type = "open", ends = "last"),
    segment.color= "grey20",segment.size= 0.5,segment.alpha= 0.8,nudge_y= 1)+
  # change labs
  labs(x="log2(fold change)",
       y="-log10 (FDR)",
       title = "Volcano plot")+
  # set theme
  theme(panel.background = element_blank(),
        panel.grid.major = element_line(colour = "grey"),
        axis.line.x = element_line(colour = "black",size=0.8),
        axis.line.y = element_line(colour = "black",size=0.8),
        plot.title = element_text(hjust = 0.5),
        legend.position="right",
        legend.title = element_blank())