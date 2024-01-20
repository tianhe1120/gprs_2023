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

## Output files

- `*.bim`
- `*.bed`
- `*.fam`

## Notes
 - Manually merging the bfiles using Plink1.9 would not succeed if containing SNPID of more than 80 characters.
 - In this step, bfiles are generated for all individuals (not only the LD population or training population) for the sake of future extracting different populations.
 - Mannually extracting the bfiles for LD population and training population is required.
