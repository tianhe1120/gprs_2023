# Setp 3-1: Clumping (remove linked SNPs)

## Function: `gprs clump`

This option encodes plink1.9 clump function

```
plink --bfile [bfiles] --clump [qc snpslists] --clump-p1  --clump-p2  --clump-r2  --clump-kb  --clump-field  --clump-snp-field  --out 
```

p1 and p2 should be the same.

## How to use it?

Shell:

```shell
$ gprs clump --plink_bfile_name [str] --output_name [str] --clump_kb [int] --clump_p1 [float/scientific notation] --clump_p2 [float/scientific notation] --clump_r2 [float] --clump_field [str] --sumstat [str] --clump_snp_field [str] 
```

Example input:

```shell
$ gprs clump --plink_bfile_name JA_height_LD --output_name JA_height --clump_kb 250 --clump_p1 0.0001 --clump_p2 0.0001 --clump_r2 0.005 --sumstat JA_height
```

## output files
- `*.clumped`
- ie. `chr10_JA_height_250_0.0001_0.005.clumped`

|CHR|F|SNP|BP|P|TOTAL|NSIG|S05|S01|S001|S0001|SP2|
|---|---|---|---|---|---|---|---|---|---|---|---|
|1   | 1   |chr1:118307139:G:C | 118307139  | 2.1e-54   |    927  |    189  |    103   |   60  |    71  |    504 |chr1:118087217:T:C(1),chr1:118111143:G:A(1)...|
|1   | 1  |  chr1:16986248:C:T  |16986248 |  2.2e-34    |   582   |   230   |   19  |    20   |   9 |     304 |chr1:16861896:T:C(1),chr1:16949400:A:T(1)...|


# Setp 3-2: Filter SNPs depends on `.clumped` 
After clumping, we have to filter SNPs again, to remove linked SNPs.
In this step, we will have new SNPs list, and use it for generate PRS model.

## Function: `gprs select-clump-snps`

## How to use it?

Shell:

```shell
$ gprs select-clump-snps --sumstat [str] --clump_file_name [str] --output_name [str] --clump_kb [int] --clump_p1 [float/scientific notation] --clump_r2 [float] --clumpfolder_name [str]
```

Example input:

```shell
$ gprs select-clump-snps --sumstat height --clump_file_name JA_height --output_name JA_height --clump_kb 600 --clump_p1 0.02 --clump_r2 0.9 --clumpfolder_name JA_height_600_0.02_0.9

```

## output files

- `[your_prefix]_clumped_snpslist.csv`
- ie. `chr10_JA_height_250_0.0001_0.005_clumped_snplist.csv`
- `[chrnb]_[your_prefix]_[model_parameters].weight`
- ie. `chr10_JA_height_250_0.0001_0.005.weight`


