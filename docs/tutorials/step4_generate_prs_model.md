# Setp 4-1: Generate beta list
Generate PRS model by using Dosage by plink2.0

## Function: `gprs beta-list`

This option will generate the beta list required for multiple-prs function under ./result/prs:
 - `[your_prefix].list`

## How to use it

Shell:

```shell
$ gprs beta-list --beta_dirs [str] --out [str]
```

Example input:
```shell
$ gprs beta-list --beta_dirs './result/plink/ct' --out JA_height
```

## Output files
`[your_prefix].list`

# Step 4-2 Generate prs models
## Function: `gprs multiple-prs`
This option will generate a bash script to submit organizing all the models.

## How to use it?

Shell:
```shell
$ gprs multiple-prs --vcf_dir [str] --beta_dir_list [str] --slurm_name [str] --slurm_account [str] --slurm_time [str] --memory [int] --symbol [str] --columns [int] --plink_modifier [str] --combine [str] --out [str]
```

Example input:
```shell
$ gprs multiple-prs --vcf_dir ./vcf --beta_dir_list ./result/prs/JA_height.list --slurm_name multiple-prs --plink_modifier 'no-mean-imputation cols=nallele,dosagesum,scoresums' --out JA_height
```
## Output files
`build-prs.sh` The job will be automatically submitted. User could use `$ myqueue` to monitor the progress. `slurm.[slurm_name].[jobID].out` and `slurm.[slurm_name].[jobID].err` will be generated to root directory. Output see gprs build-prs below.

## Function: `gprs build-prs`

```
plink2 --vcf [training vcf input] dosage=DS --score [snplists afte clumped and qc]  --out 
```



## How to use it?

Shell:

```shell
$ gprs build-prs --vcf_dir [str] --model [str] --beta_dir_list [str] --memory [int] --out [str] --symbol [str/int] --columns [int] --plink_modifier [str] --combine [str]
```


Example input see `gprs multiple-prs` above.



## output files

- `*.sscore`

|IID|ALLELE_CT |NAMED_ALLELE_DOSAGE_SUM |
|---|---|---|
|HG00096 |130     |116    |
|HG00097 |130     |114     |
|HG00099 |130     |119    |
|HG00100 |130     |110     |


