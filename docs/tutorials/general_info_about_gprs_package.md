# About gprs package
This package aims to generate the PRS model from GWAS summary statistics. 
It is designed to deal with the data format based on the GWAS catalog and GeneATLAS database GWAS summary statistics data.

- Understanding the workflow of this package:

1. Filter GWAS summary statistics files (remove duplicate SNPID and select significant SNPs by P-value)
2. Generate bfiles by Plink1.9
3. Do clumping by Plink1.9
4. Generate PRS model by Plink2.0
5. Calculate statistic value of PRS model

## Environment setup

1. Setup virtualenv

```shell
$ python3 -m venv venv
```

2. Activate virtualenv

```shell
$ source ./venv/bin/activate
```

3. Install this package

```shell
$ pip install -r requirements.txt
$ pip install -r requirements.readthedocs.txt
$ pip install -e .
```

- Eighteen commands in gprs:

1. `prepare-sumstat`

2. `generate-plink-bfiles`

3. `generate-plink-bfiles-w-individual-info`

4. `clump`

5. `select-clump-snps`  

6. `build-prs`

7. `beta-list`

8. `prs-stat`

9. `multiple-prs`

10. `combine-prs`

11. `combine-stat`

12. `ldpred2-train`

13. `create-new-marker`

14. `filtered-sscore-w-indv`

15. `transfer_atcg` (optional)

16. `subset-pop` (optional)

17. `subset-vcf-w-random-sample` (optional)

18. `random_draw_samples_from_fam` (optional)
