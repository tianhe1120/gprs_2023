# Get started: prepare the summary statistics data



## Before step1:

Download the summary statistics files. Please unzip your .gz file first.

## Unify the data format
 - Summary statistics may contain a lot of information. Some information is not necessary for our analysis. Extra information is excluded in this step.
 - To unify the column names.
 - To put columns in desired order.

### Function: `gprs geneatlas-filter-data`

Filter GeneAtlas csv file by P-value and unify the data format as following order:
SNPID, ALLELE,  BETA,  StdErr, Pvalue

### How to use it?

Shell:

```shell
$ gprs geneatlas-filter-data --ref [str] --data_dir [str] --result_dir [str] --snp_id_header [str] --allele_header [str] --beta_header [str] --se_header [str] --pvalue_header [str] --pvalue [float/scientific notation] --output_name [str]  
$ gprs gwas-filter-data --ref [str] --data_dir [str] --result_dir [str] --snp_id_header [str] --allele_header  [str] --beta_header [str] --se_header [str] --pvalue_header [str] --pvalue [float/scientific notation] --output_name [str]  
```

Example input:

```shell

```

### output files
- `*.QC.csv` (QC files )
- `*.csv` (snplist)



## Necessary quality control




