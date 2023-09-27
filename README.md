This workspace documents the steps to run a GWAS case-control study on OUD

Please run the notebooks in the following order: </p>

- 01_Prepare_Case_Control_Samples </p>
  - This notebook extracts EHR, demographics, and survey data from All of Us based on our case and control definitions for OUD. </p>
- 02_Prepare_Phenotype </p>
  - This notebook pre-processes the phenotype data and generates covariates to a PLINK readable format
- 04a_All_Plink_Analysis
  - This notebook uses Plink to complete quality control analysis
- 04b_Investigating_Plink_results
  - This notebook takes plink-generated files and manipulates them into histogram plots.
- 05_Investigating_Plink_results
  - This notebook takes plink-generated files and manipulates them into histogram plots.
- 06_GWAS_Plots
  - This notebook generates manhatten and qqplot from the logistic regression
