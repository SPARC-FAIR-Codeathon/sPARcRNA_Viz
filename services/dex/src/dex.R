#!/usr/bin/env Rscript

# Load required libraries
library(Seurat)
library(jsonlite)
library(optparse)
library(reticulate)

# Define command line options
option_list <- list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="Input directory path", metavar="character"),
  make_option(c("-o", "--output"), type="character", default=NULL, 
              help="Output directory path", metavar="character"),
  make_option(c("-p", "--prefix"), type="character", default="", 
              help="Output prefix for filtering datasets", metavar="character"),
  make_option(c("-c", "--min_cells"), type="integer", default=3, 
              help="Minimum number of cells expressing a gene", metavar="integer"),
  make_option(c("-f", "--min_features"), type="integer", default=200, 
              help="Minimum number of features (genes) per cell", metavar="integer")
)

# Parse command line arguments
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Validate input and output directories
if (is.null(opt$input) || is.null(opt$output)) {
  stop("Input and output directories must be specified")
}

if (!dir.exists(opt$input)) {
  stop("Input directory does not exist: ", opt$input)
}

if (!dir.exists(opt$output)) {
  dir.create(opt$output, recursive = TRUE)
}

# Function to find files matching patterns
find_files <- function(dir, patterns) {
  all_files <- list.files(dir, full.names = TRUE)
  matching_files <- lapply(patterns, function(pattern) {
    grep(pattern, all_files, value = TRUE)
  })
  return(unique(unlist(matching_files)))
}

# Find all potential input file sets
matrix_files <- find_files(opt$input, c("matrix\\.mtx", ".*matrix\\.mtx"))
features_files <- find_files(opt$input, c("features\\.tsv", "genes\\.tsv", ".*genes\\.tsv"))
barcodes_files <- find_files(opt$input, c("barcodes\\.tsv", ".*barcodes\\.tsv"))

# Group files by their prefix
file_groups <- lapply(seq_along(matrix_files), function(i) {
  prefix <- sub("_matrix\\.mtx.*$", "", basename(matrix_files[i]))
  list(
    prefix = prefix,
    matrix = matrix_files[i],
    features = features_files[grep(prefix, features_files)][1],
    barcodes = barcodes_files[grep(prefix, barcodes_files)][1]
  )
})

# Filter groups based on output_prefix if specified
if (opt$prefix != "") {
  file_groups <- file_groups[sapply(file_groups, function(group) grepl(opt$prefix, group$prefix))]
}

if (length(file_groups) == 0) {
  stop("No matching datasets found.")
}

# Initialize Python and import anndata
use_python("/usr/bin/python3")
anndata <- import("anndata")

# Process each group
output_files <- list()
for (group in file_groups) {
  print(paste("Processing dataset:", group$prefix))
  
  # Read the data
  data <- ReadMtx(mtx = group$matrix, features = group$features, cells = group$barcodes)
  
  # Create Seurat object
  seurat_object <- CreateSeuratObject(counts = data, 
                                      project = group$prefix, 
                                      min.cells = opt$min_cells, 
                                      min.features = opt$min_features)
  
  # Perform basic QC
  seurat_object[["percent.mt"]] <- PercentageFeatureSet(seurat_object, pattern = "^MT-")
  
  # Normalize and identify variable features
  seurat_object <- NormalizeData(seurat_object)

  # Find variable features
  seurat_object <- FindVariableFeatures(seurat_object, selection.method = "vst", nfeatures = 2000)
  
  # Scale data
  all_genes <- rownames(seurat_object)
  seurat_object <- ScaleData(seurat_object, features = all_genes)
  
  # Perform PCA
  seurat_object <- RunPCA(seurat_object, features = VariableFeatures(object = seurat_object))
  
  seurat_object <- FindVariableFeatures(seurat_object)

  # Scale data and run PCA
  seurat_object <- ScaleData(seurat_object)
  seurat_object <- RunPCA(seurat_object)

  # Cluster the cells
  seurat_object <- FindNeighbors(seurat_object)
  seurat_object <- FindClusters(seurat_object)

  # Run differential expression
  markers <- FindAllMarkers(seurat_object, only.pos = TRUE,
                            min.pct = opt$min_pct,
                            logfc.threshold = opt$logfc_threshold)

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
                      minSize = opt$gsea_min_size,
                      maxSize = opt$gsea_max_size)

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

  print(paste("AnnData object saved as", output_file))
}

# Create and save outputs.json
outputs <- list(
  processed_datasets = names(output_files),
  output_files = unlist(output_files)
)
write_json(outputs, file.path(opt$output, "outputs.json"))

print("Processing complete.")