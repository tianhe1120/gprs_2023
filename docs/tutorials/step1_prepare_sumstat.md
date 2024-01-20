# Get started: prepare the summary statistics data



### Before step1:

Download the summary statistics files. Please unzip your .gz file first.

## 1-1: Unify the data format
 - Summary statistics may contain a lot of information. Some information is not necessary for our analysis. Extra information is excluded in this step.
 - To unify the column names.
 - To put columns in desired order.

### Function: `gprs prepare-sumstat`

Filter summary statistics and unify the data format as follows:

SNPID, CHR, POS, Effect_Allele, NonEffect_Allele, Beta, SE, Pvalue, N_eff

### How to use it?

Shell:

```shell
$ gprs prepare-sumstat --file / --dir --sumstat [str] --comment [str] --symbol [str] --out [str] --snpid [str] --chr [str] --pos [str] --ea [str] --nea [str] --beta [str] --se [str] --pval [str] --neff [str] --total [int] --case_control [int] 
```

Example input:

```shell
$ gprs prepare-sumstat --file --sumstat docs/Height/sumstats/2019_BBJ_Height_autosomes_BOLT_liftover_to_hg38.txt --out JA_height --snpid Variants --chr CHR --pos POS --ea REF --nea ALT --beta BETA --se SE --pval P_INF --total 5022
```

### Output files
- `[your_prefix]_[chrnb].csv`
- ie. JA_height_chr7.csv



## 1-2: Necessary quality control
 - SNPID: SNPID should be of the format `chrnb:POS:Effect_Allele:NonEffect_Allele`, ie. `chr7:31439:T:A`. The `gprs prepare-sumstat` doesn't modify the SNPID extracted. Manually adjusting the SNPID is required.
 - Long SNPID: Current Plink1.9 couldn't handle the SNPIDs of more than 80 characters. Manually filtering out the long SNPIDs is required.
 - Pvalue: Pvalue of exactly 1 is for some reason recognized as more than 1 in following steps. Filtering on condition Pvalue < 1 is required.
 - Duplicates: Duplicated SNPIDs exist because of potential genome build update. Filtering out the duplicated SNPIDs is required.



