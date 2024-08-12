#!/usr/bin/env Rscript

# Load required libraries
library(Seurat)
library(jsonlite)
library(dplyr)
library(fgsea)
library(msigdbr)
library(ggplot2)
library(optparse)

# Function to save data as both JSON and CSV
save_data <- function(data,
                      name,
                      output_folder,
                      json = TRUE,
                      csv = TRUE) {
  output_path <- file.path(output_folder)
  json_file <- file.path(output_path, paste0(name, ".json"))
  csv_file <- file.path(output_path, paste0(name, ".csv"))

  if (!json && !csv) {
    stop("At least one of JSON or CSV must be enabled")
  }

  out <- list()

  if (json) {
    # Check if data is a data frame and the first column is named 'cluster'
    if (is.data.frame(data) && names(data)[1] == "cluster") {
      # Convert to a named list
      data_list <- split(data[-1], data$cluster)
      json_data <- toJSON(data_list, pretty = TRUE, auto_unbox = TRUE)
    } else {
      json_data <- toJSON(data, pretty = TRUE, auto_unbox = TRUE)
    }
    write(json_data, json_file)
    out$json <- json_file
  }

  if (csv) {
    # Prepare data for CSV
    csv_data <- as.data.frame(data)  # Convert to data frame if it's not already
    list_cols <- sapply(csv_data, is.list)

    for (col in names(csv_data)[list_cols]) {
      csv_data[[col]] <- sapply(csv_data[[col]], function(x)
        paste(x, collapse = ";"))
    }

    # Save as CSV
    write.csv(csv_data, csv_file, row.names = FALSE)
    out$csv <- csv_file
  }

  return(out)
}

# Define command line options
option_list <- list(
  make_option(
    c("-i", "--input"),
    type = "character",
    default = NULL,
    help = "Input directory path",
    metavar = "character"
  ),
  make_option(
    c("-o", "--output"),
    type = "character",
    default = NULL,
    help = "Output directory path",
    metavar = "character"
  ),
  make_option(
    c("-n", "--name"),
    type = "character",
    default = "sPARcRNA",
    help = "The name of the dataset being analyzed",
    metavar = "character"
  ),
  make_option(
    c("-c", "--min_cells"),
    type = "integer",
    default = 3,
    help = "Minimum number of cells expressing a gene",
    metavar = "integer"
  ),
  make_option(
    c("-f", "--min_features"),
    type = "integer",
    default = 200,
    help = "Minimum number of features (genes) per cell",
    metavar = "integer"
  ),
  make_option(
    c("--max_features"),
    type = "integer",
    default = 2500,
    help = "Maximum number of features (genes) per cell",
    metavar = "integer"
  ),
  make_option(
    c("--resolution"),
    type = "numeric",
    default = 0.8,
    help = "Resolution parameter for clustering",
    metavar = "numeric"
  ),
  make_option(
    c("--species"),
    type = "character",
    default = "Homo sapiens",
    help = "Species for GSEA",
    metavar = "character"
  ),
  make_option(
    c("--min_pct"),
    type = "numeric",
    default = 0.25,
    help = "Minimum percentage for FindAllMarkers",
    metavar = "numeric"
  ),
  make_option(
    c("--logfc_threshold"),
    type = "numeric",
    default = 0.25,
    help = "Log fold-change threshold for FindAllMarkers",
    metavar = "numeric"
  ),
  make_option(
    c("--gsea_min_size"),
    type = "integer",
    default = 15,
    help = "Minimum gene set size for GSEA",
    metavar = "integer"
  ),
  make_option(
    c("--gsea_max_size"),
    type = "integer",
    default = 500,
    help = "Maximum gene set size for GSEA",
    metavar = "integer"
  ),
  make_option(
    c("--category"),
    type = "character",
    default = "H",
    help = "MSigDB category for GSEA",
    metavar = "character"
  )
)

default_options <- list(
  input = 'validation/input/data/',
  output = 'tmp_output/',
  name = "sPARcRNA",
  prefix = "",
  min_cells = 3,
  min_features = 200,
  max_features = 2500,
  resolution = 0.8,
  species = "Mus musculus",
  min_pct = 0.25,
  logfc_threshold = 0.25,
  gsea_min_size = 15,
  gsea_max_size = 500,
  category = "H"
)

# Parse command line arguments
opt_parser <- OptionParser(option_list = option_list)
# opt <- parse_args(opt_parser)
opt <- default_options

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
find_file <- function(dir, patterns) {
  for (pattern in patterns) {
    files <- list.files(dir, pattern = pattern, full.names = TRUE)
    if (length(files) > 0)
      return(files[1])
  }
  return(NULL)
}

# Find input files
matrix_file <- find_file(opt$input, c("matrix.mtx", "matrix.mtx.gz", ".*matrix\\.mtx"))
features_file <- find_file(
  opt$input,
  c(
    "features.tsv",
    "features.tsv.gz",
    "genes.tsv",
    "genes.tsv.gz",
    ".*genes\\.tsv"
  )
)
barcodes_file <- find_file(opt$input,
                           c("barcodes.tsv", "barcodes.tsv.gz", ".*barcodes\\.tsv"))

# Check if all required files are found
if (is.null(matrix_file) ||
    is.null(features_file) || is.null(barcodes_file)) {
  stop("Unable to find all required input files. Please check your input directory.")
}

# Read the data
print("Reading data...")
data <- ReadMtx(mtx = matrix_file,
                features = features_file,
                cells = barcodes_file)

# Create Seurat object
print("Creating Seurat object...")
seurat_object <- CreateSeuratObject(
  counts = data,
  project = opt$name,
  min.cells = opt$min_cells,
  min.features = opt$min_features
)

#seurat_object[["percent.mt"]] <- PercentageFeatureSet(seurat_object, pattern = "^MT-")
#seurat_object$log10GenesPerUMI <- log10(seurat_object$nFeature_RNA) / log10(seurat_object$nCount_RNA)

# Normalize data
print("Normalizing data...")
seurat_object <- NormalizeData(seurat_object)

# Find variable features
print("Finding variable features...")
seurat_object <- FindVariableFeatures(seurat_object,
                                      selection.method = "vst",
                                      nfeatures = 2000)

# Scale data
print("Scaling data...")
all_genes <- rownames(seurat_object)
seurat_object <- ScaleData(seurat_object, features = all_genes)

# Perform PCA
print("Running PCA...")
seurat_object <- RunPCA(seurat_object, features = VariableFeatures(object = seurat_object))

# Cluster the cells
print("Clustering cells...")
seurat_object <- FindNeighbors(seurat_object)
seurat_object <- FindClusters(seurat_object, resolution = opt$resolution)

# Run t-SNE
print("Running t-SNE...")
seurat_object <- RunTSNE(seurat_object)

# Create t-SNE plot
print("Creating t-SNE plot...")
tsne_plot <- DimPlot(seurat_object, reduction = "tsne", label = TRUE) +
  ggtitle("t-SNE plot of cell clusters") +
  theme(plot.title = element_text(hjust = 0.5))

# Save t-SNE plot
ggsave(
  file.path(opt$output, "tsne_plot.png"),
  tsne_plot,
  width = 10,
  height = 8,
  dpi = 300
)

# Export t-SNE coordinates and cluster information
print("Exporting t-SNE coordinates and cluster information...")
tsne_data <- data.frame(
  cell_id = colnames(seurat_object),
  cluster = Idents(seurat_object),
  tSNE_1 = Embeddings(seurat_object, reduction = "tsne")[, 1],
  tSNE_2 = Embeddings(seurat_object, reduction = "tsne")[, 2]
)

tsne_files <- save_data(tsne_data, "tsne_data", opt$output)

# Perform differential expression analysis
print("Performing differential expression analysis...")
markers <- FindAllMarkers(
  seurat_object,
  only.pos = TRUE,
  min.pct = opt$min_pct,
  logfc.threshold = opt$logfc_threshold
)
top10 <- markers %>% group_by(cluster) %>% top_n(n = 10, wt = avg_log2FC)

# Export top 10 markers
top10_files <- save_data(top10, "top10_markers", opt$output)

# Perform GSEA
print("Performing GSEA...")
# Get gene sets
m_df <- msigdbr(species = opt$species, category = opt$category)
fgsea_sets <- m_df %>% split(x = .$gene_symbol, f = .$gs_name)

# Function to perform GSEA for a single cluster
perform_gsea <- function(cluster) {
  cluster_markers <- markers %>% filter(cluster == !!cluster) %>% arrange(desc(avg_log2FC))
  stats <- setNames(cluster_markers$avg_log2FC, cluster_markers$gene)
  fgsea_result <- fgsea(
    pathways = fgsea_sets,
    stats = stats,
    minSize = opt$gsea_min_size,
    maxSize = opt$gsea_max_size,
    scoreType = "pos",
    nPermSimple = 10000
  )
  fgsea_result$cluster <- cluster
  return(fgsea_result)
}

# Perform GSEA for each cluster
gsea_results <- lapply(unique(markers$cluster), perform_gsea)
gsea_results <- do.call(rbind, gsea_results)

# Export GSEA results
gsea_files <- save_data(gsea_results, "gsea_results", opt$output)

# Save top pathways for each cluster as JSON
gsea_cluster_results <- list()

for (cluster in unique(gsea_results$cluster)) {
  cluster_results <- gsea_results %>%
    # Filter all results to the current cluster
    filter(cluster == !!cluster) %>%
    # Sort by p-value
    arrange(pval) %>%
    # Select top 20 pathways
    head(20) %>%
    # Select specific columns
    select(pathway, NES, pval, padj, size) %>%
    # Round numeric values for compression/readability
    mutate(across(where(is.numeric), round, digits = 5))  # Round numeric values for readability

  # Set the cluster results in the list
  gsea_cluster_results[[as.character(cluster)]] <- cluster_results
}

# Save all cluster results to a single JSON file
save_data(gsea_cluster_results,
          "gsea_cluster_results",
          opt$output,
          csv = FALSE)
print("Integrating t-SNE and GSEA results...")

# Get top pathways for each cluster
# The GSEA results provide pathways enriched in different clusters.
# This step filters the top 5 pathways with the lowest p-values for each cluster.
top_pathways <- gsea_results %>%
  group_by(cluster) %>%
  top_n(n = 5, wt = -pval) %>%
  summarise(top_pathways = list(pathway))

# Create a data frame with t-SNE coordinates and cluster information
# Here, we prepare a data frame that includes essential cell metadata.
# This data includes the cell ID, cluster assignment, and t-SNE coordinates,
# which are crucial for visualizing the spatial organization of cells.
# Including this data helps in correlating gene expression with cellular identity and spatial distribution.
integrated_data <- data.frame(
  cell_id = colnames(seurat_object),
  cluster = Idents(seurat_object),
  tSNE_1 = Embeddings(seurat_object, reduction = "tsne")[, 1],
  tSNE_2 = Embeddings(seurat_object, reduction = "tsne")[, 2]
)

# Add top pathways for each cluster
# This step merges the top pathways data with the t-SNE coordinates and cluster information.
# By integrating pathway data, it becomes possible to map enriched pathways to their respective clusters,
# allowing for a more comprehensive understanding of the biological processes at play within each cluster.
integrated_data <- integrated_data %>%
  left_join(top_pathways, by = "cluster") %>%
  # Ensure 'cluster' is the first column
  select(cluster, everything())


# Calculate cluster centroids
# Here, the centroids of each cluster in the t-SNE space are calculated.
# The centroid represents the average position of all cells within a cluster,
# and can be used as a reference point for cluster location in visualizations.
# This step is important for summarizing the spatial distribution of clusters.
cluster_centroids <- integrated_data %>%
  group_by(cluster) %>%
  summarise(centroid_x = mean(tSNE_1),
            centroid_y = mean(tSNE_2))

# Add centroids and top pathways to the cluster information
# The cluster centroids and top pathways are combined to create a final summary of each cluster.
# This data will be useful for visualizations and downstream analyses that require cluster-level information.
# By including both spatial and functional data (pathways), this step ensures that the cluster summaries are comprehensive.
cluster_info <- cluster_centroids %>%
  left_join(top_pathways, by = "cluster") %>%
  select(cluster, everything())

# Save integrated data
integrated_files <- save_data(integrated_data, "integrated_tsne_gsea", opt$output)

# Save cluster info
cluster_info_files <- save_data(cluster_info, "cluster_info", opt$output)

print("Integrating cell IDs with gene expression data...")

# Get normalized gene expression data
# This retrieves the normalized gene expression matrix from the Seurat object.
# The normalization step is crucial to ensure that differences in gene expression
# are not due to technical biases but reflect true biological variation.
gene_expression <- GetAssayData(seurat_object, slot = "data")

# Select top variable genes to reduce data size
# Here, the most variable genes are selected from the dataset.
# Focusing on these genes reduces the data size, making downstream analysis
# more computationally efficient while retaining the most informative features.
top_genes <- VariableFeatures(seurat_object)
gene_expression <- gene_expression[top_genes, ]

# Create a summary of average gene expression per cluster
# This step summarizes gene expression by calculating the average expression
# of each gene across all cells within the same cluster.
# Such summaries are valuable for identifying cluster-specific gene expression patterns,
# which can highlight key biological processes or marker genes for each cluster.
metadata <- data.frame(
  cell_id = colnames(seurat_object),
  cluster = Idents(seurat_object),
  tSNE_1 = Embeddings(seurat_object, reduction = "tsne")[, 1],
  tSNE_2 = Embeddings(seurat_object, reduction = "tsne")[, 2]
)

# Create gene expression dataframe and filter out zeros
gene_data <- as.data.frame(t(as.matrix(gene_expression)))
gene_data_filtered <- lapply(1:nrow(gene_data), function(i) {
  cell_data <- gene_data[i, ]
  non_zero <- cell_data[cell_data != 0]
  if (length(non_zero) > 0) {
    return(as.list(non_zero))
  } else {
    return(NULL)
  }
})

# Remove NULL entries (cells with no non-zero gene expression)
gene_data_filtered <- gene_data_filtered[!sapply(gene_data_filtered, is.null)]

# Combine metadata and filtered gene expression data
cell_gene_data <- list(metadata = metadata, gene_expression = gene_data_filtered)

# Save cell-gene data
cell_gene_files <- save_data(cell_gene_data, "cell_gene_data", opt$output)

# Create a summary of average gene expression per cluster
cluster_avg_expression <- gene_expression %>%
  as.data.frame() %>%
  t() %>%
  as.data.frame() %>%
  mutate(cluster = Idents(seurat_object)) %>%
  group_by(cluster) %>%
  summarise(across(everything(), mean))

# Ensure 'cluster' is the first column
cluster_avg_expression <- cluster_avg_expression %>%
  select(cluster, everything())

# Save cluster average expression data
cluster_avg_files <- save_data(cluster_avg_expression, "cluster_avg_expression", opt$output)

# Save the Seurat object
print("Saving Seurat object...")
saveRDS(seurat_object, file = file.path(opt$output, paste0(opt$prefix, "seurat_object.rds")))

# Create and save outputs.json
outputs <- list(
  seurat_object = paste0(opt$prefix, "seurat_object.rds"),
  initial_cell_count = ncol(data),
  final_cell_count = ncol(seurat_object),
  gene_count = nrow(seurat_object),
  project_name = opt$name,
  cluster_count = length(unique(Idents(seurat_object))),
  tsne_plot = "tsne_plot.png",
  tsne_data_csv = tsne_files$csv,
  top_markers_csv = top10_files$csv,
  gsea_results_csv = gsea_files$csv,
  integrated_tsne_gsea_csv = integrated_files$csv,
  cluster_info_csv = cluster_info_files$csv,
  cell_gene_data_csv = cell_gene_files$csv,
  cluster_avg_expression_csv = cluster_avg_files$csv
)
write_json(outputs, file.path(opt$output, "outputs.json"))

print("Processing complete.")