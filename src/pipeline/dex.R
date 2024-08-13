#!/usr/bin/env Rscript

# Load required libraries
library(Seurat)
library(jsonlite)
library(dplyr)
library(fgsea)
library(msigdbr)
library(ggplot2)
library(optparse)
library(gficf)

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


#' All credit for this function goes to the gambalab/seurat-wrappers github repository
#' This is a PR to satijalab/seurat-wrappers repository
#' 
#' See biorxiv preprint: https://www.biorxiv.org/content/10.1101/2022.10.24.513476v1
#' See code: https://github.com/satijalab/seurat-wrappers/pull/147
#' 
#' Run Single cell Gene Set Enrichement Analysis on GF-ICF on a Seurat object
#'
#' This function run runScGSEA function from GF-ICF package on Seurat object. 
#' It computes GSEA for each cells across a set of input pathways by using NMF.
#'
#' @param object Seurat object
#' @param assay Assay to use, defaults to the default assay
#' @param filterGenes Rank of NMF to use for the enrichment
#' @param nmf.dim Rank of NMF to use for the enrichment
#' @param geneID The type of gene names in rownames of \code{object}. It can be either 'ensamble' or 'symbol'. Default: 'ensamble'
#' @param species The type of species in \code{object}. It can be either 'mouse' or 'human'. Default: 'human'
#' @param category MSigDB collection abbreviation, such as H or C1
#' @param subcategory MSigDB sub-collection abbreviation, such as CGP or BP
#' @param rescale If different by none, pathway's activity scores are resealed as Z-score. Possible values are none, byGS or byCell. Default is none
#'
#' @return returns a Seurat object with pathways x cell matrix 
#' @export

RunScGSEA <- function(
    object,
    assay = NULL,
    filterGenes = TRUE,
    nmf.dim = 100,
    geneID = c("ensamble","symbol"),
    species = c("mouse", "human"),
    category = "H",
    subcategory = NULL,
    verbose = F) {
  
  # Store Seurat metadata in separate variable to enable working on different assay types. (i.e. SCT assay does not have metadata slot as it refers to RNA assay)  
  meta.data = object@meta.data
  
  SeuratWrappers:::CheckPackage(package = 'gambalab/gficf', repository = 'github')
  assay <- assay %||% SeuratObject::DefaultAssay(object = object)
  
  # Get raw count matrix from Seurat object from the assay slot defined by the user
  M <- SeuratObject::GetAssayData(object = object, slot = "counts")
  # Data normalization and gene filtering
  M <- gficf::gficf(M = M, filterGenes = filterGenes)
  # Create NMF-subspace 
  M <- gficf::runNMF(data = M, dim = nmf.dim)
  # Create t-UMAP space
  M <- gficf::runReduction(data = M, reduction = "umap", verbose = verbose)
  # Compute GSEA for each cells across a set of input pathways by using NMF
  M <- gficf::runScGSEA(data = M,
                        geneID = geneID,
                        species = species,
                        category = category,
                        subcategory = subcategory,
                        nmf.k = nmf.dim,
                        fdr.th = .1,
                        rescale = 'none',
                        verbose = verbose)
  
  # Add cell names to enrichment results
  raw_enrich <- t(M$scgsea$x)
  colnames(raw_enrich) <- colnames(object)
  # Normalize enrichment results by computing pathway's activity z-scores
  norm_enrich <- Matrix::Matrix((raw_enrich - Matrix::rowMeans(raw_enrich)) / apply(raw_enrich, 1, sd), sparse=T)
  # Create a new Seurat object containing the raw pathway x cell matrix in counts slot and preserving meta data (adding _byGenes tag only if clusters were already computed)
  if('seurat_clusters' %in% colnames(meta.data)) {
    colnames(meta.data) <- gsub('seurat_clusters', 'seurat_clusters_byGenes', colnames(meta.data))
  }
  path_obj <- CreateSeuratObject(counts = raw_enrich, meta.data = meta.data, assay = 'pathway')
  # And the z-score-normalized one in data and scale.data slots
  path_obj <- SetAssayData(object = path_obj, slot = 'data', new.data = norm_enrich)
  path_obj <- SetAssayData(object = path_obj, slot = 'scale.data', new.data = as.matrix(norm_enrich))
  # Store metadata of pathways retained after significance filtering
  feat.meta <- M$scgsea$stat[M$scgsea$stat$pathway%in%colnames(M$scgsea$x), ] 
  feat.meta <- data.frame(feat.meta, row.names = 1)
  feat.meta$genes <- do.call(c, lapply(M$scgsea$pathways[rownames(feat.meta)], function(x) paste(x, collapse = ',')))
  path_obj[['pathway']]@meta.features <- feat.meta
  
  # Store dimensionality reduction results computed on genes x cells matrix
  path_obj@reductions <- object@reductions
  names(path_obj@reductions) <- paste0(names(path_obj@reductions), '_byGenes')
  
  return(path_obj)
}

# Integrate scGSEA steps
print("Running scGSEA...")
seurat_object_gsea <- RunScGSEA(
  object = seurat_object,
  geneID = "symbol",
  species = opt$species,
  category = opt$category
)

# Visualize UMAP plot computed on pathways activity scores
print("Computing UMAP on pathway activity scores...")
seurat_object_gsea <- RunPCA(seurat_object_gsea, features = rownames(seurat_object_gsea))
seurat_object_gsea <- RunUMAP(seurat_object_gsea, dims = 1:10)

# Run t-SNE on pathway activity scores
print("Running t-SNE on pathway activity scores...")
seurat_object_gsea <- RunTSNE(seurat_object_gsea, dims = 1:10)

# Cluster cells based on pathways activity scores
print("Clustering cells based on pathway activity scores...")
seurat_object_gsea <- FindNeighbors(seurat_object_gsea, dims = 1:10)
seurat_object_gsea <- FindClusters(seurat_object_gsea, resolution = opt$resolution)

# Export UMAP and t-SNE coordinates and cluster information for both gene expression and pathway activity
print("Exporting UMAP and t-SNE coordinates and cluster information...")
dim_reduction_data <- data.frame(
  cell_id = colnames(seurat_object_gsea),
  cluster_genes = Idents(seurat_object),
  cluster_pathways = Idents(seurat_object_gsea),
  UMAP_1_genes = Embeddings(seurat_object, reduction = "umap")[, 1],
  UMAP_2_genes = Embeddings(seurat_object, reduction = "umap")[, 2],
  UMAP_1_pathways = Embeddings(seurat_object_gsea, reduction = "umap")[, 1],
  UMAP_2_pathways = Embeddings(seurat_object_gsea, reduction = "umap")[, 2],
  tSNE_1_genes = Embeddings(seurat_object, reduction = "tsne")[, 1],
  tSNE_2_genes = Embeddings(seurat_object, reduction = "tsne")[, 2],
  tSNE_1_pathways = Embeddings(seurat_object_gsea, reduction = "tsne")[, 1],
  tSNE_2_pathways = Embeddings(seurat_object_gsea, reduction = "tsne")[, 2]
)

dim_reduction_files <- save_data(dim_reduction_data, "dim_reduction_data", opt$output)

# Calculate cluster centroids for gene expression-based clustering (UMAP and t-SNE)
print("Calculating cluster centroids for gene expression-based clustering...")
gene_cluster_centroids <- dim_reduction_data %>%
  group_by(cluster_genes) %>%
  summarise(
    umap_centroid_x_genes = mean(UMAP_1_genes),
    umap_centroid_y_genes = mean(UMAP_2_genes),
    tsne_centroid_x_genes = mean(tSNE_1_genes),
    tsne_centroid_y_genes = mean(tSNE_2_genes)
  )

# Calculate cluster centroids for pathway activity-based clustering (UMAP and t-SNE)
print("Calculating cluster centroids for pathway activity-based clustering...")
pathway_cluster_centroids <- dim_reduction_data %>%
  group_by(cluster_pathways) %>%
  summarise(
    umap_centroid_x_pathways = mean(UMAP_1_pathways),
    umap_centroid_y_pathways = mean(UMAP_2_pathways),
    tsne_centroid_x_pathways = mean(tSNE_1_pathways),
    tsne_centroid_y_pathways = mean(tSNE_2_pathways)
  )

# Export pathway activity scores
print("Exporting pathway activity scores...")
pathway_scores <- GetAssayData(seurat_object_gsea, slot = "data")
pathway_scores_df <- as.data.frame(t(as.matrix(pathway_scores)))
pathway_scores_df$cell_id <- rownames(pathway_scores_df)
pathway_scores_files <- save_data(pathway_scores_df, "pathway_scores", opt$output)

# Identify top pathways for each cluster
print("Identifying top pathways for each cluster...")
Idents(seurat_object_gsea) <- seurat_object_gsea$seurat_clusters
top_pathways <- FindAllMarkers(
  seurat_object_gsea,
  only.pos = TRUE,
  min.pct = 0.25,
  logfc.threshold = 0.25
)
top_pathways_per_cluster <- top_pathways %>%
  group_by(cluster) %>%
  top_n(n = 5, wt = avg_log2FC) %>%
  summarise(top_pathways = list(gene))

# Combine cluster centroids with top pathways
cluster_info_genes <- gene_cluster_centroids %>%
  left_join(top_pathways_per_cluster, by = c("cluster_genes" = "cluster"))

cluster_info_pathways <- pathway_cluster_centroids %>%
  left_join(top_pathways_per_cluster, by = c("cluster_pathways" = "cluster"))

# Save cluster info
cluster_info_files_genes <- save_data(cluster_info_genes, "cluster_info_genes", opt$output)
cluster_info_files_pathways <- save_data(cluster_info_pathways, "cluster_info_pathways", opt$output)

# Create and save outputs.json
outputs <- list(
  seurat_object = paste0(opt$prefix, "seurat_object.rds"),
  initial_cell_count = ncol(data),
  final_cell_count = ncol(seurat_object),
  gene_count = nrow(seurat_object),
  project_name = opt$name,
  cluster_count_genes = length(unique(Idents(seurat_object))),
  cluster_count_pathways = length(unique(Idents(seurat_object_gsea))),
  dim_reduction_data_csv = dim_reduction_files$csv,
  pathway_scores_csv = pathway_scores_files$csv,
  cluster_info_genes_csv = cluster_info_files_genes$csv,
  cluster_info_pathways_csv = cluster_info_files_pathways$csv
)
write_json(outputs, file.path(opt$output, "outputs.json"))

print("Processing complete.")