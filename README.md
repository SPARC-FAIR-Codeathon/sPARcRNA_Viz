<p align="center">
  <img width="488" alt="Screenshot 2024-08-12 at 2 46 32 PM" src="https://github.com/user-attachments/assets/d3281745-1e08-4287-8c0b-207fe80a2c85">
  <img width="722" alt="Screenshot 2024-08-12 at 11 35 07 AM" src="https://github.com/user-attachments/assets/f82ae7b8-71c2-490f-aedc-cb359e39762b">
  <br></br>
  <img width="600" alt="Screenshot 2024-08-12 at 2 49 10 PM" src="https://github.com/user-attachments/assets/e0eff2c0-072c-40d9-b528-58ca706b861a">
  <br></br>
</p>

# Table of Contents
- [About](#about)
- [Research Purpose](#research-purpose)
  - [Introduction](#introduction)
  - [Background](#background)
  - [Current SPARC Portal Tools](#current-sparc-portal-tools)
  - [The Problem](#the-problem)
  - [Our Solution: sPARcRNA_Viz](#our-solution-sparcrna_viz)
- [Using sPARcRNA_Viz](#using-sparcrna_viz)
  - [sPARcRNA_Viz Requirements](#sparcrna_viz-requirements)
  - [sPARcRNA_Viz Pipeline Workflow](#sparcrna_viz-pipeline-workflow)
  - [Configuring sPARcRNA_Viz](#configuring-sparcrna_viz)
  - [Tutorial](#tutorial)
- [FAIR-Centered Design](#fair-centered-design)
  - [Importance of FAIR Data Principles](#importance-of-fair-data-principles)
- [Additional Information](#additional-information)
  - [Issue Reporting](#issue-reporting)
  - [How to Contribute](#how-to-contribute)
  - [Cite Us](#cite-us)
  - [License](#license)
  - [Team](#team)
  - [Materials Cited](#materials-cited)
  - [Acknowledgements](#acknowledgements)

# About
Easily generate differential expression results from [SPARC](https://sparc.science) scRNA-seq data in a FAIR manner.
# Research Purpose
## Introduction
sPARcRNA_Viz is an **all-in-one gene expression visualization utility** integratable with [o²S²PARC](https://osparc.io/). Using sPARcRNA_Viz, researchers can create an interactive t-SNE from single-cell RNA-sequencing data, as well as perform in silico GSEA analysis to determine the most highly expressed genes. From these statistically significant genes, researchers can determine potential gene ontologies arising from their sample(s). In addition, the seamless integration of sPARcRNA_Viz with the o²S²PARC computing platform enables data accessibility concordant with **FAIR Data Principles**.
### Notable Features of sPARcRNA_Viz
sPARcRNA_Viz provides the user with the ability to fine-tune multiple **gene expression parameters**:
- Minimum number of cells expressing a gene
- Minimum number of features (genes) per cell
- Maximum number of features (genes) per cell
- Clustering resolution
- Species specification
- Minimum percentage for FindAllMarkers
- Log fold-change threshold for FindAllMarkers
- Minimum gene set size for GSEA
- MSigDB category for GSEA
### Technology Stack
- o²S²PARC
- R
- GNU Make
- Python3
- Docker
- Astro
- HTML
- JavaScript
- Tailwind CSS
## Background
In recent years, **single-cell RNA-sequencing** (scRNA-seq) has emerged as a preeminent method for the analysis of gene expression in biological tissue, providing researchers access to genetic data previously inaccessible. This is largely due to advancements in wet lab and dry leb techniques, as well computing power, where these improvements enable the collection of large datasets often spanning hundreds of millions of entries. With this newfound wealth of data, a need has arisen for high-efficiency bioinformatics pipelines and tools that allow for the analysis of scRNA-seq data. One computational method currently in use is **differential gene expression (DGE) analysis**, which identifies statistically significant genes (i.e., results that are minimally confounded by experimental errors) and determines the expression level of a gene relative to the entire dataset.<sup>2</sup> Using these statistically significant results, it is possible to correlate the most highly expressed genes to their tangible, biological effects through the use of **gene ontology** databases such as the [Gene Ontology Knowledgebase (GO)](https://www.geneontology.org/).
<br></br>
The SPARC Portal currently hosts a rich collection of scRNA-seq data across several different tissues and species. Therefore, the SPARC platform could be further enhanced by the inclusion of data visualization and the aforementioned DGE tools. This is achieved in sPARcRNA_Viz through the use of **t-SNE plotting** and **GSEA**.
### About t-SNE Plots
t-distributed Stochastic Neighbor Embedding (t-SNE) is a plotting and visualization technique that focuses on pairwise similarities among datasets. Like PCA, it is a dimensionality reduction technique. For its utility in comparing large, complex datasets, t-SNE is commonly employed by RNA-seq researchers.
### About GSEA
Gene Set Enrichment Analysis (GSEA) is a popular technique for determining statistically significant genes, as well as those that are upregulated and downregulated.<sup>5</sup> This is achieved through a ranking system whereby genes are organized by statistically significance.

## Current SPARC Portal Tools
As of 8/12/24, the [Transcriptomic_oSPARC](https://github.com/SPARC-FAIR-Codeathon/Transcriptomic_oSPARC) utility<sup>1</sup> would appear to be the most prominent SPARC tool relating to the analysis gene expression. This tool is very effective in displaying industry-standard static graphical outputs, which can prove quite useful to researchers. However, a limitation may perhaps exist in the current customization level; it may be necessary to edit the code itself to change particular parameters. There was also a niche to explore in adding interactivity to the graphs, further enahncing the user experience.
## The Problem
The gene expression data in SPARC is somewhat limited and is in a raw data format, rendering it less interoperable. Our goal was to make it more interoperable and easy to use. Therefore, our team sought to create a RNA-seq visualization utility that supports the specification of **specific parameters**, as well as **interactivity**. There was also room for experimentation in predicting gene ontology with **GSEA**.
## Our Solution: sPARcRNA_Viz
To address this challenge, we present **sPARcRNA_Viz**, an scRNA-seq visualization tool for potential entry alongside Transcriptomic_oSPARC. In incorporating flexible parameters, interactivity, and an additional DEA metric, sPARcRNA_Viz will complement Transcriptomic_oSPARC as part of a growing SPARC gene expression toolkit.

# Using sPARcRNA_Viz
## sPARcRNA_Viz Requirements
- GNU Make
- Python3
- [``Docker``](https://docs.docker.com/get-docker/) (if you wish to build and test the service locally)
### Required Input Format
sPARcRNA_Viz currently supports the following file format: **.csv/.tsv** (barcode and feature files), **.mtx** (matrix file) single-cell matrices along with R data. These formats and 3 files are required to run the analysis successfully.
## sPARcRNA_Viz Pipeline Workflow
Can refer to [Pipeline Documentation](add link).
### 1. Setup
Load libraries, set options, validate and prepare the directories; find and read raw data files; configure based on inputs
### 2. Create Seurat object
Seurat is an R package specially designed for the quality control (QC) , analysis, and exploration of single-cell RNA-seq data. Thus, it proved to be a suitable choice for the purposes of sPARcRNA_Viz.
### 3. Normalize and preprocess the data
Normalize (so that data reflects true biological differences); find variable features; scale (to standardize the data); perform PCA (Principal Component Analysis to reduce dimensionality); and cluster cells with similar profiles together
### 4. t-SNE
t-SNE allows us to visualize statistically significant genes based on these clusters. From these, researchers can determine potential gene ontologies arising from their sample(s).
### 5. Differential Gene Expression Analysis
Differential gene expression analysis takes the normalized gene read counts and allows researchers to determine quantitative changes in gene expression. 
### 6. GSEA
GSEA aids in determining gene groups highly represented in the data.
### 7. Combine t-SNE and GSEA results
All the cluster results after running GSEA are saved, and the top pathways are saved as well.
### 8. Export and Display Results
All values from the previous steps and top clusters, pathways, etc are saved in a Seurat object that is later visualized. The user can optionally convert this data into .csv file format.

## Configuring sPARcRNA_Viz
sPARcRNA_Viz offers a variety of command options:
| Option | Description | Default |
| --- | --- | --- |
| `-i`, `--input` | Input directory path | `'validation/input/data/'` |
| `-o`, `--output` | Output directory path | `'tmp_output/'` |
| `-n`, `--name` | The name of the dataset being analyzed | `"sPARcRNA"` |
| `-c`, `--min_cells` | Minimum number of cells expressing a gene | `3` |
| `-f`, `--min_features` | Minimum number of features (genes) per cell | `200` |
| `--max_features` | Maximum number of features (genes) per cell | `2500` |
| `--resolution` | Resolution parameter for clustering | `0.8` |
| `--species` | Species for GSEA | `"Mus musculus"` |
| `--min_pct` | Minimum percentage for FindAllMarkers | `0.25` |
| `--logfc_threshold` | Log fold-change threshold for FindAllMarkers | `0.25` |
| `--gsea_min_size` | Minimum gene set size for GSEA | `15` |
| `--gsea_max_size` | Maximum gene set size for GSEA | `500` |
| `--category` | MSigDB category for GSEA | `"H"` |
## Tutorial
The [scRNA-seq data]() used in the tutorial is from the SPARC Portal.
### 1. Log in to [o²S²PARC](https://osparc.io/)
<img width="500" alt="Screenshot 2024-08-12 at 9 36 07 PM" src="https://github.com/user-attachments/assets/5e295cbc-184a-42e9-b85b-8ad82bcc57a0">

### 2. Open a new Study
<img width="201" alt="Screenshot 2024-08-12 at 9 35 10 PM" src="https://github.com/user-attachments/assets/ced50573-fbf9-458f-8912-29374ad3c26f">

### 3. Add 3 File Picker Nodes and upload the required data
<img width="500" alt="Screenshot 2024-08-12 at 8 52 18 PM" src="https://github.com/user-attachments/assets/c565355d-8e57-43a1-aade-d653be2d2853">
<br></br>
<img width="500" alt="image" src="https://github.com/user-attachments/assets/c992bcbb-c061-46f0-a611-28753686e0ed">
<br></br>
<img width="500" alt="Screenshot 2024-08-12 at 9 34 49 PM" src="https://github.com/user-attachments/assets/0925c0d3-e128-4bb8-992b-62288973f005">
<br></br>
(Alternatively, drag and drop the needed files into the workspace.)

### 4. Add sPARcRNA_Viz Node
<img width="500" alt="Screenshot 2024-08-12 at 9 33 34 PM" src="https://github.com/user-attachments/assets/43b92fb3-44e4-42ea-ada2-bbf2bc866528">

### 5. Connect the Nodes
<img width="500" alt="Screenshot 2024-08-12 at 9 34 08 PM" src="https://github.com/user-attachments/assets/f49395fe-d51b-4ec1-88f9-b4eae37ce0a9">

### 6. Optionally run outputs through JupyterLab R for further analysis
<img width="500" alt="Screenshot 2024-08-12 at 9 21 20 PM" src="https://github.com/user-attachments/assets/8c8b0833-90eb-4fea-af5e-13e2947b7d33">

## Future Vision
sPARcRNA_Viz would be expanded to include other interactive visualizations and API calls to other gene databases. This would provide more ways to analyze genes and integrate with other websites.

# FAIR-Centered Design
Perhaps the **most important** aspect of sPARcRNA_Viz is its emphasis on the FAIR Data Principles. Summarized below are highlight features of sPARcRNA_Viz supporting the FAIR initiative. 
## Importance of FAIR Data Principles
<p align="left">
  <img width="576" alt="Screenshot 2024-08-12 at 9 58 14 AM" src=https://github.com/user-attachments/assets/fc0112ba-ac4e-41fe-92ac-65e5339a6eb7>
</p>

FAIR data is that which is **F**indable, **A**ccessible, **I**nteroperable, and **R**eusable.<sup>3</sup> These tenets are highly important within the scientific context as a lack of clarity surrounding data may introduce confounding variables. Thus, the FAIR system was derived so as to create a method to organize data, thus serving both present and future researchers.
<br></br>
Particularly in the case of scRNA-seq data, which is expensive from both a wet and dry lab standpoint, it is very useful to adhere to FAIR standards. For instance, one particularly common phenomemon with respect to scRNA-seq is **dropout**<sup>4</sup>, where portions of RNA are not captured by experimental techniques. scRNA-seq data can also be signficantly varied with regard to format; often, differently-labeled matrices may contain raw counts data, or data that has been normalized by a method such as CPM, TPM, or RPKM/FPKM. The FAIR article cited on the SPARC website expands upon this idea further: the licensing of data can also pose a challenge for the analysis of gene regulation and expression. Therefore, the intentional **categorization and stewardship** of data can present a major benefit to transcriptomics researchers, propelling scientific progress.

### Summary of FAIR Principles Application
| FAIR Principle | Other Tools | sPARcRNA_Viz |
| --- | --- | --- |
| **F**indable | May not be connected to an existing database such as the SPARC Portal, which could hinder the findability of data | sPARcRNA_Viz is connected to o²S²PARC, so it can use the well-organized datasets provided on the SPARC portal, and it is archived on Zenodo with the appropriate metadata |
| **A**ccessible | May have a user interface that requires a programming background | sPARcRNA_Viz's friendly user interface and visuals allow researchers to quickly engage with data and is open, free and universally implementable |
| **I**nteroperable | May not allow for connections between datasets | Through its use of GSEA, sPARcRNA_Viz allows for the meaningful connection of datasets: scRNA-seq data can be used in association with gene ontology. In addition, visualizations generated for each dataset can be compared with each other |
| **R**eusable | May only support the formatting of one dataset | sPARcRNA_Viz be used with multiple datasets due to the ability to specify parameters. Likewise, sPARcRNA_Viz offers a security benefit through its use of input validation |

# Additional Information
## Issue Reporting
Please utilize the **Issues** tab of this repository should you encounter any problems with sPARcRNA_Viz.
## How to Contribute
Fork this repository and submit a pull request to contribute.
## Cite Us
- All of the winning projects included a citation
## License
- sPARcRNA_Viz is distributed under the MIT License.
## Team
- Mihir Samdarshi (Lead, Sysadmin, Developer)
- Sanjay Soundarajan (Sysadmin, Developer)
- Mahitha Simhambhatla (Developer, Writer)
- Raina Patel (Writer)
- Ayla Bratton (Writer)
## Materials Cited
<a id="1">[1]</a>
Ben Aribi, H., Ding, M., & Kiran, A. (2023). 
Gene expression data visualization tool on the o2S2PARC platform. 
F1000Research, 11, 1267.
https://www.pnas.org/doi/abs/10.1073/pnas.0506580102<br />
<a id="2">[2]</a>
EMBL-EBI. (n.d.).
Differential gene expression analysis | Functional genomics II.
https://www.ebi.ac.uk/training/online/courses/functional-genomics-ii-common-technologies-and-data-analysis-methods/rna-sequencing/performing-a-rna-seq-experiment/data-analysis/differential-gene-expression-analysis/ <br />
<a id="3">[3]</a>
GO FAIR.(2017).
FAIR Principles - GO FAIR. GO FAIR.
https://www.go-fair.org/fair-principles/<br />
<a id="4">[4]</a>
Kim, T. H., Zhou, X., & Chen, M. (2020). Demystifying “drop-outs” in single-cell UMI data. Genome Biology, 21(1). 
https://doi.org/10.1186/s13059-020-02096-y <br />
<a id="5">[5]</a>
Subramanian, A., Tamayo, P., Mootha, V. K., Mukherjee, S., Ebert, B. L., Gillette, M. A., Paulovich, A., Pomeroy, S. L., Golub, T. R., Lander, E. S., & Mesirov, J. P. (2005).
Gene set enrichment analysis: A knowledge-based approach for interpreting genome-wide expression profiles.
Proceedings of the National Academy of Sciences, 102(43), 15545–15550. 
https://doi.org/10.1073/pnas.0506580102 <br />
<a id="6">[6]</a>
Wilkinson, M. D., Dumontier, M., Aalbersberg, Ij. J., Appleton, G., Axton, M., Baak, A., Blomberg, N., Boiten, J.-W., da Silva Santos, L. B., Bourne, P. E., Bouwman, J., Brookes, A. J., Clark, T., Crosas, M., Dillo, I., Dumon, O., Edmunds, S., Evelo, C. T., Finkers, R., & Gonzalez-Beltran, A. (2016).
The FAIR Guiding Principles for Scientific Data Management and Stewardship. Scientific Data, 3(1). 
https://www.nature.com/articles/sdata201618 <br />
<br></br>
Logo and figures were created using Microsoft Word; images were formatted using Canva.
## Acknowledgements
We would like to thank the SPARC Codeathon 2024 team for all their guidance and support.
