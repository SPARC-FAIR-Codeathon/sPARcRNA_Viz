General Notes: 
- Don't believe there are any specific requirements for the readme, so simply modeled after previous winners
- Importantly, the 2 most recent winning README's are partly authored by the same person, explaining the similarity
- For workflow section, used README from "develop" branch

A logo and possible slogan could potentially be included, as is the case with the KnowMore project
# Table of Contents
- About
- Research Purpose
  - Introduction
  - Background
  - Importance of FAIR Principles
  - Current SPARC Portal Tools
  - Challenges Encountered
  - Our Solution: <Team 7 Project Name>
  - FAIR-Centered Design
- Using <Team 7 Project Name>
  - <Team 7 Project Name> Requirements
  - <Team 7 Project Name> Workflow
  - Tutorial
- Additional Information
  - FAIR Practices
  - Team
  - Materials Cited
  - Acknowledgements
# About
Easily generate differential expression results from [SPARC](https://sparc.science) scRNA-seq data in a FAIR manner.
# Research Purpose
## Introduction
<Team 7 Project Name> is an **all-in-one gene expression visualization utility** integratable with [o²S²PARC](https://osparc.io/). Using <Team 7 Project Name>, researchers can create an interactive t-SNE from single-cell RNA-sequencing data, as well as perform in silico GSEA analysis to determine the most highly expressed genes. From these statistically significant genes, researchers can determine potential gene ontologies arising from their sample(s). In addition, the seamless integration of <Team 7 Project Name> with the o²S²PARC computing platform enables data accessibility concordant with FAIR Data Principles.
### Notable Features of <Team 7 Project Name>
<Team 7 Project Name> provides the user with the ability to fine-tune multiple gene expression parameters:
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
- HTML
- JavaScript
- Tailwind CSS
Can make a visual once this is finalized
## Background
In recent years, single-cell RNA-sequencing (scRNA-seq) has emerged as a preeminent method for the analysis of gene expression in biological tissue, providing researchers access to genetic data previously inaccessible. This is largely due to advancements in wet lab and dry leb techniques, as well computing power, where these improvements enable the collection of large datasets often spanning hundreds of millions of entries. With this newfound wealth of data, a need has arisen for high-efficiency bioinformatics pipelines and tools that allow for the analysis of scRNA-seq data. Thus, one computational method currently in use is differential gene expression (DGE) analysis, which identifies statistically significant genes (i.e., results that are minimally confounded by dropouts/experimental errors) and determines the expression level of a gene relative to the entire dataset. Using these statistically significant results, it is possible to correlate the most highly expressed genes to their tangible, biological effects through the use of gene ontology databases such as the Gene Ontology Knowledgebase (GO) (https://www.geneontology.org/).
<br></br>
The SPARC Portal currently hosts a rich collection of scRNA-seq data across several different tissues and species. Therefore, the SPARC platform could be further enhanced by the inclusion of data visualization and the aforementioned DGE tools. This is achieved in <Team 7 Project Name> through the use of **t-SNE plotting** and **GSEA**.
### About t-SNE Plots
t-distributed Stochastic Neighbor Embedding (t-SNE) is a plotting and visualization technique that focuses on pairwise similarities among datasets. Like PCA, it is a dimensionality reduction technique. For its utility in comparing large, complex datasets, t-SNE is commonly employed by RNA-seq researchers.
### About GSEA
Gene Set Enrichment Analysis (GSEA) is a popular technique for determining statistically significant genes, as well as those that are upregulated and downregulated. This is achieved through a ranking system whereby genes are organized by statistically significance.
## Importance of FAIR Data Principles
(May insert graphic here to add visual interest to this section)
FAIR Data is 
## Current SPARC Portal Tools
- Details about Transcriptomic_oSPARC, citing accordingly
## The Problem
- Gene expression visualization integratable (one might even say … interoperable) with SPARC, with a focus on FAIR Principles
## Our Solution: <Team 7 Project Name>
- Detailed discussion of inputs, outputs, pipeline
- These could all be separate subheadings to maintain organization
- Can make diagrams to enhance the text
## FAIR-Centered Design
- Specific discussion of how our design is more FAIR than existing
| FAIR Principle | Other Tools | <Team 7 Project Name> |
| --- | --- | --- |
| **F**indable |  |  |
| **A**ccessible |  |  |
| **I**nteroperable |  |  |
| **R**eusable |  |  |
# Using <Team 7 Project Name>
## <Team 7 Project Name> Requirements
- GNU Make
- Python3
- [``Docker``](https://docs.docker.com/get-docker/) (if you wish to build and test the service locally)
### Required Input Format
## <Team 7 Project Name> Workflow
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
## Configuring <Team 7 Project Name>
<Team 7 Project Name> offers a variety of `make` options:
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
<Team 7 Project Name> is designed around the use of FAIR Practices. Further explanation as to FAIR Principle adherence is included in this [document](https://docs.google.com/document/d/1Me_6LzF9eMdD2Bhh9df7ncxRGepV7pU6kBUjl15Dyhw/edit?usp=sharing).
## Team
- It seems all the Grand Prize-winning teams listed the recommended team roles here (Lead, Writer, Sysadmin, etc.)
## Materials Cited
(Will probably change to APA)
1. 
2. https://www.pnas.org/doi/abs/10.1073/pnas.0506580102
3. https://www.nature.com/articles/sdata201618
4. https://www.go-fair.org/fair-principles/
5.
6.
<br></br>
Asterick-marked figures were created using [Canva](https://www.canva.com/).
## Acknowledgements
- Thanking the SPARC team
