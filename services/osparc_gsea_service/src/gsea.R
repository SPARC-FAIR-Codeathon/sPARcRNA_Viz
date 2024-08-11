#!/usr/bin/env Rscript

# Load required libraries
library(anndata)
library(Seurat)
library(fgsea)
library(msigdbr)
library(dplyr)
library(ggplot2)
library(optparse)

# Define command line options
option_list <- list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="Input AnnData file (.h5ad)", metavar="character"),
  make_option(c("-o", "--output"), type="character", default=NULL,
              help="Output directory path", metavar="character"),
  make_option(c("-s", "--species"), type="character", default="Homo sapiens",
              help="Species for gene set database", metavar="character"),
  make_option(c("-c", "--category"), type="character", default="H",
              help="MSigDB category", metavar="character")
)

# Parse command line arguments
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Validate input and output
if (is.null(opt$input) || is.null(opt$output)) {
  stop("Input file and output directory must be specified")
}

if (!file.exists(opt$input)) {
  stop("Input file does not exist: ", opt$input)
}

if (!dir.exists(opt$output)) {
  dir.create(opt$output, recursive = TRUE)
}

# Read the AnnData file
adata <- read_h5ad(opt$input)

# Convert to Seurat object
seurat_object <- CreateSeuratObject(counts = t(adata$X), meta.data = adata$obs)

# Normalize and identify variable features
seurat_object <- NormalizeData(seurat_object)
seurat_object <- FindVariableFeatures(seurat_object)

# Scale data and run PCA
seurat_object <- ScaleData(seurat_object)
seurat_object <- RunPCA(seurat_object)

# Cluster the cells
seurat_object <- FindNeighbors(seurat_object)
seurat_object <- FindClusters(seurat_object)

# Run differential expression
markers <- FindAllMarkers(seurat_object, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)

# Prepare ranked gene list
ranked_genes <- markers %>%
  group_by(cluster) %>%
  arrange(desc(avg_log2FC)) %>%
  select(gene, avg_log2FC)

# Get gene sets
msigdb_gsets <- msigdbr(species = opt$species, category = opt$category) %>%
  select(gs_name, gene_symbol) %>%
  as.data.frame()

# Run GSEA for each cluster
results <- lapply(unique(ranked_genes$cluster), function(cluster) {
  cluster_genes <- ranked_genes %>%
    filter(cluster == !!cluster) %>%
    deframe()

  fgseaRes <- fgsea(pathways = split(msigdb_gsets$gene_symbol, msigdb_gsets$gs_name),
                    stats = cluster_genes,
                    minSize = 15,
                    maxSize = 500)

  fgseaRes$cluster <- cluster
  return(fgseaRes)
})

# Combine results
all_results <- do.call(rbind, results)

# Save results
write.csv(all_results, file.path(opt$output, "gsea_results.csv"), row.names = FALSE)

# Plot top pathways for each cluster
for (cluster in unique(all_results$cluster)) {
  cluster_results <- all_results %>%
    filter(cluster == !!cluster) %>%
    arrange(pval) %>%
    head(20)

  p <- ggplot(cluster_results, aes(reorder(pathway, NES), NES)) +
    geom_col(aes(fill=pval)) +
    coord_flip() +
    labs(x="Pathway", y="Normalized Enrichment Score",
         title=paste("Top Pathways for Cluster", cluster)) +
    theme_minimal()

  ggsave(file.path(opt$output, paste0("gsea_plot_cluster_", cluster, ".png")), p, width = 10, height = 8)
}

print("GSEA analysis complete. Results saved in the output directory.")
