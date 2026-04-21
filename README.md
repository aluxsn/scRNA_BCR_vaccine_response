scRNA-seq + BCR-seq Multi-Omics Pipeline

Paired gene expression and B-cell receptor analysis from CellRanger outputs
Seurat v5 • Nextflow • IgBLAST • Change-O • scRepertoire • tidyverse

 Overview

This repository contains a fully reproducible workflow for the integrated analysis of single-cell gene expression (GEX) and B-cell receptor (BCR) sequencing data from human B cells across multiple conditions.

The pipeline performs:

Quality control and integration of scRNA-seq datasets

BCR annotation using IgBLAST + Change-O (Nextflow)
Clonal assignment and lineage features (scRepertoire)
Mutation quantification (SHM)
Multi-condition comparison across B-cell subsets and vaccine platforms
Consistent linking between GEX clusters and BCR clonal features

 No raw data is included (unpublished human samples).

🧬 Biological Context

The dataset includes up to 10 B-cell conditions, spanning baseline subsets and vaccine-stimulated populations:

Baseline (D0): Naïve, Memory, Marginal Zone (BMZ), Spike⁺
Day 7 Stimulations: CD40Cov2, Novavax, Sanofi (CTV⁺/CTV⁻)

The pipeline allows analysis of:

Vaccine-induced clonal expansion
Somatic hypermutation profiles (VH/CDR3)
Clonal diversity
Evolution of B-cell clones on UMAP space
Isotype usage and lineage features

⚙️ Pipeline Components
1. scRNA-seq (GEX) Analysis — Seurat v5
Ambient RNA correction
Doublet removal
QC (MT%, nFeature, nCount)
Normalization 
Integration across all batches & stimulation conditions
Dimensionality reduction (PCA, UMAP)
Clustering & annotation
Visualization of vaccine responses

3. BCR Annotation — Nextflow IgBLAST/Change-O

A reproducible Nextflow workflow performing:

IgBLAST V(D)J alignment
Change-O formatting
Identification of:
V, D, J genes
CDR3 AA/NT sequences
SHM rates
Clonal groups
Generation of a complete changeo table ready for scRepertoire integration

3. scRepertoire Integration
   
Clonal abundance
Clonal expansion
CDR3 length distribution
Isotype switching
Linking clonal groups with Seurat metadata
“Clonotype overlay” on UMAPs

5. Mutation Analysis (SHM)
VH mutation profiling
CDR3 mutation quantification
Mapping mutated cells on UMAP
Comparing mutation levels across vaccine platforms
