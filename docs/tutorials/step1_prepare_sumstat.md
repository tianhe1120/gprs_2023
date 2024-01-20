# Get started: prepare the summary statistics data





# Before step1:

Download the summary statistics files. Please unzip your .gz file first.

# Step1: Unify the data format
After knowing the data format, users can unify the data format and filter out SNPs(optional).
:heavy_exclamation_mark: SNPs are extract out by RSID not chromosome position

## Function: `gprs geneatlas-filter-data`

Filter GeneAtlas csv file by P-value and unify the data format as following order:
SNPID, ALLELE,  BETA,  StdErr, Pvalue

## How to use it?

Shell:

```shell
$ gprs geneatlas-filter-data --ref [str] --data_dir [str] --result_dir [str] --snp_id_header [str] --allele_header [str] --beta_header [str] --se_header [str] --pvalue_header [str] --pvalue [float/scientific notation] --output_name [str]  
$ gprs gwas-filter-data --ref [str] --data_dir [str] --result_dir [str] --snp_id_header [str] --allele_header  [str] --beta_header [str] --se_header [str] --pvalue_header [str] --pvalue [float/scientific notation] --output_name [str]  
```

Python:

```python
from gprs.gene_atlas_model import GeneAtlasModel
if __name__ == '__main__':
    geneatlas = GeneAtlasModel( ref='1000genomes/hg19',
                    data_dir='data/2014_GWAS_Height' )

    geneatlas.filter_data( snp_id_header='MarkerName',
                            allele_header='Allele1',
                            beta_header='b',
                            se_header ='SE',
                            pvalue_header='p',
                            output_name='2014height')
   
from gprs.gwas_model import GwasModel
if __name__ == '__main__':
    gwas = GwasModel( ref='/home1/ylo40816/1000genomes/hg19',
                 data_dir='/home1/ylo40816/Projects/GPRS/data/2019_GCST008970')

    gwas.filter_data( snp_id_header='RSID',
                   allele_header='Allele1',
                   beta_header='Effect',
                   se_header='StdErr',
                   pvalue_header='P-value',
                   output_name='GCST008970',
                   file_name='gout_chr1_22_LQ_IQ06_mac10_all_201_rsid.csv')
```

## output files
- `*.QC.csv` (QC files )
- `*.csv` (snplist)



## Necessary quality control




