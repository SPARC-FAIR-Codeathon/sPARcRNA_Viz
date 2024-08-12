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
  - [Importance of FAIR Data Principles](#importance-of-fair-data-principles)
  - [Current SPARC Portal Tools](#current-sparc-portal-tools)
  - [Challenge Encountered](#challenge-encountered)
  - [Our Solution: sPARcRNA_Viz](#our-solution-sparcrna_viz)
  - [FAIR-Centered Design](#fair-centered-design)
- [Using sPARcRNA_Viz](#using-sparcrna_viz)
  - [sPARcRNA_Viz Requirements](#sparcrna_viz-requirements)
  - [sPARcRNA_Viz Workflow](#sparcrna_viz-workflow)
  - [Tutorial](#tutorial)
- [Additional Information](#additional-information)
  - [FAIR Practices](#fair-practices)
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
(Quickly jotted down some stuff -- please please add if anything is missing here!!)
- o²S²PARC
- R
- GNU Make
- Python3
- Docker
- Astro
- HTML
- JavaScript
- Tailwind CSS
<br></br>
Can make a visual once this is finalized
## Background
In recent years, **single-cell RNA-sequencing** (scRNA-seq) has emerged as a preeminent method for the analysis of gene expression in biological tissue, providing researchers access to genetic data previously inaccessible. This is largely due to advancements in wet lab and dry leb techniques, as well computing power, where these improvements enable the collection of large datasets often spanning hundreds of millions of entries. With this newfound wealth of data, a need has arisen for high-efficiency bioinformatics pipelines and tools that allow for the analysis of scRNA-seq data. Thus, one computational method currently in use is **differential gene expression (DGE) analysis**, which identifies statistically significant genes (i.e., results that are minimally confounded by experimental errors) and determines the expression level of a gene relative to the entire dataset. Using these statistically significant results, it is possible to correlate the most highly expressed genes to their tangible, biological effects through the use of **gene ontology** databases such as the [Gene Ontology Knowledgebase (GO)](https://www.geneontology.org/).
<br></br>
The SPARC Portal currently hosts a rich collection of scRNA-seq data across several different tissues and species. Therefore, the SPARC platform could be further enhanced by the inclusion of data visualization and the aforementioned DGE tools. This is achieved in sPARcRNA_Viz through the use of **t-SNE plotting** and **GSEA**.
### About t-SNE Plots
t-distributed Stochastic Neighbor Embedding (t-SNE) is a plotting and visualization technique that focuses on pairwise similarities among datasets. Like PCA, it is a dimensionality reduction technique. For its utility in comparing large, complex datasets, t-SNE is commonly employed by RNA-seq researchers.
### About GSEA
Gene Set Enrichment Analysis (GSEA) is a popular technique for determining statistically significant genes, as well as those that are upregulated and downregulated. This is achieved through a ranking system whereby genes are organized by statistically significance.
## Importance of FAIR Data Principles
<p align="left">
  <img width="576" alt="Screenshot 2024-08-12 at 9 58 14 AM" src=https://github.com/user-attachments/assets/fc0112ba-ac4e-41fe-92ac-65e5339a6eb7>
</p>

FAIR data is that which is **F**indable, **A**ccessible, **I**nteroperable, and **R**eusable. These tenets are highly important within the scientific context as a lack of clarity surrounding data may introduce confounding variables. Thus, the FAIR system was derived so as to create a method to organize data, thus serving both present and future researchers.
<br></br>
Particularly in the case of scRNA-seq data, which is expensive from both a wet and dry lab standpoint, it is very useful to adhere to FAIR standards. For instance, one particularly common phenomemon with respect to scRNA-seq is **dropout**, where portions of RNA are not captured by experimental techniques. scRNA-seq data can also be signficantly varied with regard to format; often, differently-labeled matrices may contain raw counts data, or data that has been normalized by a method such as CPM, TPM, or RPKM/FPKM. The FAIR article cited on the SPARC website expands upon this idea further: the licensing of data can also pose a challenge for the analysis of gene regulation and expression. Therefore, the intentional **categorization and stewardship** of data can present a major benefit to transcriptomics researchers, propelling scientific progress.

## Current SPARC Portal Tools
As of 8/12/24, the Transcriptomic_oSPARC utility would appear to be the most prominent SPARC tool relating to the analysis gene expression. This tool is very effective in displaying industry-standard static graphical outputs, which can prove quite useful to researchers. However, a limitation may perhaps exist in the current customization level; it may be necessary to edit the code itself to change particular parameters. There is also a niche to potentially explore in adding interactivity to the graphs, further enahncing the user experience.
## Challenge Encountered
Therfore, our team sought to create a RNA-seq visualization utility that supports the specification of **specific parameters**, as well as **interactivity**. There was also room for experimentation in predicting gene ontology with **GSEA**.
## Our Solution: sPARcRNA_Viz
To address this challenge, we present sPARcRNA_Viz, an scRNA-seq visualization tool for potential entry alongside Transcriptomic_oSPARC. In incorporating flexible parameters, interactivity, and an additional DEA metric, sPARcRNA_Viz will complement Transcriptomic_oSPARC as part of a growing SPARC gene expression toolkit.
### sPARcRNA_Viz Pipeline
Would love input here if possible
Can make a diagram once the pipeline is establshed
## FAIR-Centered Design
Perhaps the most important aspect of sPARcRNA_Viz is its emphasis on the FAIR Data Principles. Summarized below are highlight features of sPARcRNA_Viz supporting the FAIR initiative.

### Summary of FAIR Principles Application
| FAIR Principle | Other Tools | sPARcRNA_Viz |
| --- | --- | --- |
| **F**indable | May not be connected to an existing database such as the SPARC Portal, which could hinder the findability of data. | sPARcRNA_Viz is connected to o²S²PARC, so it can use the well-organized datasets provided on the SPARC portal |
| **A**ccessible | May have a user interface that requires a programming background | sPARcRNA_Viz's friendly user interface and visuals allow researchers to quickly engage with data |
| **I**nteroperable | May not allow for connections between datasets | Through its use of GSEA, sPARcRNA_Viz allows for the meaningful connection of datasets: scRNA-seq data can be used in association with gene ontology. In addition |
| **R**eusable | May only support the formatting of one dataset | sPARcRNA_Viz be used with multiple datasets due to the ability to specify parameters. Likewise, sPARcRNA_Viz offers a security benefit through its use of input validation |

Additional information surrounding these applications is detailed in the sPARcRNA_Viz FAIR Practices document found [here](#fair-practices).
## Our Vision
Maybe we could add what could be the future of sPARcRNA_Viz here (maybe add different graphs, api calls, etc)
Would welcome any input here
# Using sPARcRNA_Viz
## sPARcRNA_Viz Requirements
- GNU Make
- Python3
- [``Docker``](https://docs.docker.com/get-docker/) (if you wish to build and test the service locally)
### Required Input Format
sPARcRNA_Viz currently supports JSON and .csv single-cell matrices.
<br></br>
Is this correct? Do we have a specific input format in terms of the matrix
## sPARcRNA_Viz Workflow
### Create the Service
1. The [Dockerfile](osparc_dex_service/docker/Dockerfile) shall be modified to install the command-line tool you'd like to execute and additional dependencies
All the rest is optional:
1. The [.osparc](.osparc) is the configuration folder and source of truth for metadata: describes service info and expected inputs/outputs of the service. If you need to change the inputs/outputs of the service, description, thumbnail, etc... check the [`metadata.yml`](./.osparc/metadata.yml) file
2. If you need to change the start-up behavior of the service, modify the [`service.cli/execute.sh`](./service.cli/execute.sh) file
Testing: 
1. The service docker image may be built with ``make build`` (see "Useful Commands" below)
2. The service docker image may be run locally with ``make run-local``. You'll need to edit the [input.json](./validation/input/inputs.json) to execute your command.
### Publish the Service on o²S²PARC
Once you're happy with your code:
1. Push it to a public repository.
2. An automated pipeline (GitHub Actions) will build the Docker image for you
3. Wait for the GitHub pipeline to run successfully
4. Check that the automated pipeline executes successfully
5. Once the pipeline has run successfully, get in touch with [o²S²PARC Support](mailto:support@osparc.io), we will take care of the final steps!
### Change the Service (after it has been published on o²S²PARC)
If you wish to change your Service (e.g. add additional libraries), after it has been published on o²S²PARC, you have to **create a new version**:
1. Go back to your repository
2. Apply the desired changes and commit them
3. Increase ("bump") the Service version: in your console execute: ``make version-patch``, or ``make version-minor``, or  ``make version-major``
4. Commit and push the changes to your repository
5. Wait for the GitHub/GitLab pipelines to run successfully
5. Once the pipeline has run successfully, get in touch with [o²S²PARC Support](mailto:support@osparc.io), we will take care of publishing the new version!
### Useful Commands
```
$ make help
$ make build # This will build an o²S²PARC-compatible image (similar to `Docker build` command)
$ make run-local # This will start a new Docker container on your computer and run the command.
```
## Configuring sPARcRNA_Viz
sPARcRNA_Viz offers a variety of `make` options:
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
- Maybe some kind of tutorial if applicable and we have extra time
- This could possibly consist of sample inputs
# Additional Information
## Cite Us
- All of the winning projects included a citation
## License
- All of the winning projects included a license
## FAIR Practices
sPARcRNA_Viz is designed around the use of FAIR Practices. Further explanation as to FAIR Principle adherence is included in this [document](https://docs.google.com/document/d/1Me_6LzF9eMdD2Bhh9df7ncxRGepV7pU6kBUjl15Dyhw/edit?usp=sharing).
## Team
- It seems all the Grand Prize-winning teams listed the recommended team roles here (Lead, Writer, Sysadmin, etc.)
## Materials Cited
(Will probably change to APA)
1. 
2. https://www.pnas.org/doi/abs/10.1073/pnas.0506580102
3. https://www.nature.com/articles/sdata201618
4. https://www.go-fair.org/fair-principles/
5. https://genomebiology.biomedcentral.com/articles/10.1186/s13059-020-02096-y
6. Ben Aribi H, Ding M and Kiran A. Gene expression data visualization tool on the o²S²PARC platform [version 2; peer review: 2 approved]. F1000Research 2023, 11:1267 (https://doi.org/10.12688/f1000research.126840.2)
<br></br>
Logo and figures were created using Microsoft Word; images were formatted using Canva.
## Acknowledgements
- Thanking the SPARC team
