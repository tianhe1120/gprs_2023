# Setp 2: Generate Plink bfiles (.bim, .bam, .fam)
After filtering SNPs in GWAS summary statistics data. 
Users have to generate plink files for generate PRS model.

## Function: `gprs generate-plink-bfiles`

This option encodes plink1.9 make-bed function
```
plink --vcf [ref] --extract [snplists after qc] --make-bed --out [bfile folder/output_name]
```

## How to use it?

Shell:

```shell
$ gprs generate-plink-bfiles --ref [str] --sumstat [str] --out [str] --symbol [str] --extra_commands [str] --merge / --no-merge
````

Python:

```shell
$ gprs generate-plink-bfiles --ref docs/Height/data/vcf --sumstat JA_height --out JA_height_all --no-merge
```

## output files

- `*.bim`
- `*.bed`
- `*.fam`

