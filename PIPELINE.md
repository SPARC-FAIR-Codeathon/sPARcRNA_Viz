# Pipeline Information
This pipeline is the backbone of sPARcRNA_Viz and provides the coordinates required to create the scRNA-seq visualizations. 

## Input
It takes the barcodes, features, and matrix files as inputs. The files need to either be in .csv/.tsv and .mtx format or in an R data format.

## Output
A json file with all the coordinates of the points in a tSNE that is used by the frontend to visualize it in an interactive way.

## Workflow
### 1. Setup
Load libraries, set options, validate and prepare the directories, find and read raw data files, configure based on inputs
### 2. Create Seurat object
Seurat is an R package designed for QC, analysis, and exploration of single-cell RNA-seq data.
- Seurat was chosen because the gene expression data analyzed through this pipeline is single-cell RNA-seq, and it provides ways to normalize, scale, and visualize this data.
### 3. Normalize and preprocess the data
Normalize (so that data reflects true biological differences), find variable features, scale (to standardize the data), perform PCA (Principal Component Analysis to reduce dimensionality), cluster cells with similar profiles together
### 4. t-SNE
t-SNE allows us to visualize statistically significant genes based on these clusters. From these, researchers can determine potential gene ontologies arising from their sample(s).
### 5. Differential Gene Expression Analysis
Differential gene expression analysis takes the normalized gene read counts and allows researchers to determine quantitative changes in gene expression. 
### 6. GSEA
GSEA, or Gene set enrichment analysis, helps determine the gene groups that are highly represented in the data.
### 7. Combine t-SNE and GSEA results
All the cluster results after running GSEA are saved, and the top pathways are saved as well.
### 8. Export and Display Results
All values from the previous steps and top clusters, pathways, etc are saved in a json file that is later visualized

## Overview of Functions
- `make_options()`: allows for user input through command line, allows to input data files from local machine
- `Read_MTX()`: reads the data from barcodes, features, and matrix files after patterns have been made and properly found from the input files given by the user
- `CreateSeuratObject()`: Seurat object created from data saved and user inputs on the name, cells, and features
- Cleaning the data and making it standardized so that it can be used for a tSNE and GSEA:
    - `NormalizeData()`
    - `ScaleData()`
- Reducing the dimensionality, clustering, and running the tSNE and saving it:
    - `RunPCA()`
    - `FindNeighbors()`
    - `FindClusters()`
    - `RunTSNE()`
    - `DimPlot()`
    - `ggsave()`
- `FindAllMarkers()`: performs the differential expression analysis
- `GetAssayData()`: saves the normalized gene expression data, which makes sure that the data is not due to technical biases
- tSNE coordinates, top 10 markers, top pathways, cluster results, cluster centroids, cluster average expression data, and more are saved and exported as a json file
