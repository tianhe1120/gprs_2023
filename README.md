# Genome-wide Polygenic Risk Score (GPRS) 

[![Documentation Status](https://readthedocs.org/projects/gprs/badge/?version=latest)](https://gprs.readthedocs.io/en/latest/?badge=latest)

---

This package aims to generate the Polygenic Risk Scores (PRS) models based on a heuristic (Pruning+Thresholding) approach and a Bayesian approach (LDPred2). 
It is designed to deal with GWAS summary statistics in different formats including the public databases such as GWAS catalog and GeneATLAS database.

:octocat: Understanding the workflow of this package:

1. Filter GWAS summary statistics files (unify the data format. optional: remove duplicate SNPID and select significant SNPs by P-value)
2. Generate bfiles using Plink1.9
3. Do clumping and thresholding using Plink1.9
4. Generate PRS model using Plink2.0
5. General PRS models using LDPred2


## Environment setup

1. Setup virtualenv

The second "venv" is the name of your virtual environment. "venv" should be used to comform the following steps.

```shell
$ python3 -m venv venv
```

2. Activate virtualenv

```shell
$ source ./venv/bin/activate
```

3. Install this package

"-e" means to install the pipeline in a modifiable mode.

```shell
$ pip install -r requirements.txt
$ pip install -r requirements.readthedocs.txt
$ pip install -e .
```


## Additional requirements
Install both version 1.9 and 2.0 plink.  https://zzz.bwh.harvard.edu/plink/download.shtml

If you are USC users:
Please load the plink modules by using:
```shell
$ module load plink2
```
```shell
$ module load plink/1.9
```

## Prepare dataset
Download GWAS summary statistics from available resources.
(The GWAS summary statistics should contain the information: SNPID, ALLELE, BETA, P-value, and StdErr)


## Usage guidance
### Before starting:
If your GWAS summary statistics data are zipped, please unzip your .gz file first.

 
### Commands

```shell
$ gprs prepare-sumstat --file / --dir --sumstat [str] --comment [str] --symbol [str] --out [str] --snpid [str] --chr [str] --pos [str] --ea [str] --nea [str] --beta [str] --se [str] --pval [str] --neff [str] --total [int] --case_control [int]
$ gprs generate-plink-bfiles --ref [str] --sumstat [str] --out [str] --symbol [str] --extra_commands [str] --merge / --no-merge
$ gprs clump --plink_bfile_name [str] --output_name [str] --clump_kb [int] --clump_p1 [float/scientific notation] --clump_p2 [float/scientific notation] --clump_r2 [float] --clump_field [str] --sumstat [str] --clump_snp_field [str]   
$ gprs select-clump-snps --sumstat [str] --clump_file_name [str] --output_name [str] --clump_kb [int] --clump_p1 [float/scientific notation] --clump_r2 [float] --clumpfolder_name [str]
$ gprs beta-list --beta_dirs [str] --out [str]
$ gprs multiple-prs --vcf_dir [str] --beta_dir_list [str] --slurm_name [str] --slurm_account [str] --slurm_time [str] --memory [int] --symbol [str] --columns [int] --plink_modifier [str] --combine [str] --out [str]
$ gprs build-prs --vcf_dir [str] --model [str] --beta_dir_list [str] --memory [int] --out [str] --symbol [str/int] --columns [int] --plink_modifier [str] --combine [str]  
$ gprs prs-stat --score [str] --pheno [str] --data [str] --model [str] --r [str] --binary / --quantitative --pop_prev [str] --plotroc / --no_plot
$ gprs combine_stat --data [str]

```



## Commands in gprs package:

:octocat: Nine commands in gprs:

1. `prepare-sumstat`

2. `generate-plink-bfiles`

3. `clump`

4. `select-clump-snps`

5. `beta-list`

6. `multiple-prs`

7. `build-prs`

8. `prs-stats`

9. `combine-stat`


### Result folder
In the first step, you need to indicate the path to creating the result folder.
Five folders will automatically generate under the result folder by script. 

- qc folder: `./result/sumstat/`
- bfile folder: `./result/plink/bfiles`
- clump folder: `./result/plink/clump`
- prs folder: `./result/plink/prs`


### Output file format
This package will generate output files below: 
- `*.csv` 
- `*.bim`
- `*.bed`
- `*.fam`
- `*.clumped`
- `*.qc_clump_snpslist.csv`
- `*.sscore`
- `*_stat.txt`
- `*_combined_stat.txt`

All output files will be named as: `[chrnb]_[name].[extension]`. 
The chrnb will given automatically, users only have to give `[name]` while using the package.
Thus, it is better use the same output name to generate all files.

- `--output_name` 
- `--snplist_name`
- `--qc_file_name`
- `--clump_file_name`
- `--plink_bfile_name`



### `gprs prepare-sumstat`

Parse the summary statistics and unify the data format as following order:
SNPID, ALLELE,  BETA,  StdErr, Pvalue

#### Options:

````
  --file / --dir             Whether summary statistics is given as one file, or as a directory with 22 chromosome files with --sumstat, default=True
  --sumstat                  Path to one summary statistic file(default), or a directory with 22 chromosome files (use with --dir flag in this case)  [required]
  --comment                  In summary statistic file(s), indicate the text for lines that should be skipped (for example, "#" for snptest results)
  --symbol                   When giving summary statistics DIRECTORY, indicate the symbol or text after chromosome number in each file, default = "." 
  --out                      Output prefix for 22 processed summary statistics, deposited in sumstat folder  [required]
  --snpid                    Column header name for SNP ID in sumstat  [required]
  --chr                      Column header name for CHROMOSOME in sumstat  [required]
  --pos                      Column header name for POSITION in sumstat  [required]
  --ea                       Column header name for EFFECT ALLELE in sumstat  [required]
  --nea                      Column header name for NON-EFFECT ALLELE in sumstat  [required]
  --beta                     Column header name for BETA(EFFECT SIZE) for EFFECT ALLELE in sumstat  [required]
  --se                       Column header name for STANDARD ERROR in sumstat  [required]
  --pval                     Column header name for P-VALUE in sumstat  [required]
  --neff                     Column header name for EFFECTIVE SAMPLE SIZE in sumstat  [required]
  --total                    Total sample size for quantitative trait; DO NOT use with --Neff or --case_control  [required]
  --case_control             Case and control sample size for binary trait, separated by a space (order does not matter); DO NOT use with --Neff or --total  [required]
  --help                     Show this message and exit.
````

#### Result:

This option generates csv files for 22 chromosomes in `sumstat` folder:

- `your_prefix_chrnb.csv` 


### `gprs generate-plink-bfiles`
This option encodes plink1.9 make-bed function
```
plink --vcf [ref] --extract [snplists after qc] --make-bed --out [bfile folder/output_name]
```
snplists and bfiles folders will automatically be filled in the script.
Users have to indicate ref and output name only.

#### Options:
````
  --ref                directory containing chromosome-separated vcf files for LD reference panel  [required]
  --sumstat            prefix to summary statistics files outputted from perepare_sumstat function
  --out                prefix for output plink files
  --symbol             indicate the symbol or text after chrnb in vcf file, default = "." ; i.e. ALL.chr8.vcf.gz, you can put "." or ".vcf.gz" 
  --extra_commands     argument to add for plink 1 make-bed function
  --help               Show this message and exit.
````

#### Result:

This option will generate three files in `bfiles` folder:

- `*.bim`
- `*.bed`
- `*.fam`

### `gprs clump`
This option encodes plink1.9 clump function
```
plink --bfile [bfiles] --clump [qc snpslists] --clump-p1  --clump-p2  --clump-r2  --clump-kb  --clump-field  --clump-snp-field  --out 
```
The plink_bfiles_dir, qc snpslists and clump_output_dir will automatically be filled in the script.
Users have to indicate the options below.

#### Options:
 ````
  --plink_bfile_name         plink_bfile_name is [output_name] from [chrnb]_[output_name].bim/bed/fam [required]
  --output_name              it is better if the output_name remain the same. The clump output: 
  --clump_kb                 distance(kb) parameter for clumping [required]
  --clump_p1                 first set of P-value for clumping [required]
  --clump_p2                 should equals to p1 reduce the snps [required]
  --clump_r2                 r2 value for clumping, default = 0.1
  --clump_field              P-value column name, default = Pvalue
  --sumstat                  [output_name] from [output_name]_[chrnb].csv in sumstat directory [required]
  --clump_snp_field          SNP ID column name, default = SNPID
  --help                     Show this message and exit.
````

#### Result:

This option will generate one file in `clump` folder:

- `*.clumped`


### `gprs select-clump-snps`

#### Options:
```` 
  --sumstat                      [output_name] from [output_name]_[chrnb].csv in sumstat directory
  --clump_file_name              clump_file_name is [output_name] from [chrnb]_[output_name].clump
  --output_name                  it is better if the output_name remain the same. output: [chrnb]_[output_name]_clumped_snplist.csv [required]
  --clump_kb                     distance(kb) parameter for clumping [required]
  --clump_p1                     first set of P-value for clumping [required]
  --clump_r2                     r2 value for clumping, default = 0.1
  --clumpfolder_name             folder name for .clumped files [required]
  --help                         Show this message and exit.
````

#### Result:
This option will generate files in `../result/plink/clump` folder:
- `your_prefix_clumped_snpslist.csv`

also makes directories under `../result/plink/ct/` with name of the models

Under each model directory, files are generated for each chromosome:
- `chrnb_your_prefix_model_parameters.weight`


### `gprs build-prs`
This option encodes plink2.0 function
```
plink2 --vcf [vcf input] dosage=DS --score [snplists afte clumped and qc]  --out 
```
The clumped qc snpslists and prs_output_dir will automatically be filled in the script.
Users have to indicate the options below.

#### Options:
````
  --symbol                       indicate the symbol or text after chrnb in vcf file, default = "." ; i.e. ALL.chr8.vcf.gz, you can put "." or ".vcf.gz"
  --vcf_input                    path to vcf files  [required]
  --qc_clump_snplist_foldername  the folder name of .qc_clump_snpslist.csv file. The folder name should be 
                                 the same as the output name in select_clump_snps step
  --columns                      a column index indicate the [SNPID] [ALLELE] [BETA] position; column nb starts from 1
  --plink_modifier               no-mean-imputation as default in here, get more info by searching plink2.0 modifier
  --output_name                  it is better if the output_name remain the same. output: [chrnb]_[output_name].sscore
  --clump_kb                     distance(kb) parameter for clumping [required]
  --clump_p1                     first set of P-value for clumping [required]
  --clump_r2                     r2 value for clumping, default = 0.1
  --help                         Show this message and exit.
````
#### Result:
This option will generate `.sscore` files in `prs` folder:
- `*.sscore`


### `gprs combine-prs`

Combine-prs option will combine all .sscore files as one .sscore file.

#### Options:
````
  --filename          name of .sscore, i.e.  chr10_geneatlas_500_1e-7_0.05.sscore, The file name here is "geneatlas"
  --clump_kb          distance(kb) parameter for clumping [required]
  --clump_p1          first set of P-value for clumping [required]
  --clump_r2          r2 value for clumping, default = 0.1
  --help              Show this message and exit.
````
#### Result:
This option will generate one file in `prs` folder:
- `*.sscore`


### `gprs prs-statistics`

After obtained combined sscore file, `prs-statistics` calculate BETA, AIC, AUC, PseudoR2 and OR ratio 

#### Options:
````
  --score_file             the absolute path to combined .sscore file [required]
  --pheno_file             the absolute path to pheno file  [required]
  --output_name            the output name  [required]
  --data_set_name          the name of the data-set i.e. gout_2019_GCST008970
                           [required]
  --clump_kb               distance(kb) parameter for clumping [required]
  --clump_p1               first set of P-value for clumping [required]
  --clump_r2               r2 value for clumping, default = 0.1
  --prs_stats_R            the absolute path to "prs_stats.R"  [required]
  --r_command              use "which R" in linux, and copy the path after
                           --r_command  [required]
  --help                   Show this message and exit.
````
#### Result:
This option will generate .txt file in `stat` folder:
- `*_stat.txt`


### `gprs combine-prs-stat`

If you have more than one trained PRS model, `combine-prs-stat` function is designed to combine statistics results.
For instance: the first PRS model was filtered with P < 0.05, the second PRS model was filtered with P < 0.0005. You will have DATA_0.05_stat.txt/DATA_0.0005_stat.txt
Combining two statistic tables allows users easy to compare between PRS models

#### Options:
````
  --data_set_name        the name of the data-set i.e. gout_2019_GCST008970 [required]
  --clump_kb             distance(kb) parameter for clumping [required]
  --clump_p1             first set of P-value for clumping [required]
  --clump_r2             r2 value for clumping, default = 0.1
  --help                 Show this message and exit.
````
#### Result:
This option will generate .txt file in `stat` folder:
- `*_combined_stat.txt`
