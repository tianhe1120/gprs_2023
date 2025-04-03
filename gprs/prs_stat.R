#!/usr/bin/Rscript
#created by - Soyoung Jeon; modified by - He Tian
suppressWarnings(library(tidyverse))
suppressMessages(library(pROC))
suppressMessages(library(DescTools))
suppressMessages(library(boot))


####################################
# Please note that this version contains:
# Without stratified ORs, eg. top 5% vs. middle 20% (simplified)
# 95% bootstrap CI, stratified by cases/controls
# Rejecting implausible pseudo R2 estimates for each iteration
# liability R2 predictor from observed R2 to partial R2
# R2 on the liability scale does not depend on the proportion of cases in the sample but does require an estimate of the lifetime population prevalence of the disease. - Md. Moksedul Momin, Soohyun Lee, Naomi R. Wray, S. Hong Lee, Significance tests for R2 of out-of-sample prediction using polygenic scores, The American Journal of Human Genetics, Volume 110, Issue 2, 2023, Pages 349-358, ISSN 0002-9297, https://doi.org/10.1016/j.ajhg.2023.01.004.
#############################################################

# options
args <- commandArgs(TRUE)

model_name <- args[1]
scoref <- args[2] # doesn't need header, but first column ID; second column SCORE; plink2 output works
phenof <- args[3] # need to have header, first column ID; second column PHENO; the rest covariates
family <- args[4] # binary or quantitative
pop_prev <- args[5]
plotroc <- args[6] #plotroc OR no_plot
output_name <- args[7] #full output directory + model_name

cat("Specified Options: \n")
cat(paste("model_name = ",model_name,"\n"))
cat(paste("score file = ",scoref,"\n"))
cat(paste("pheno file = ",phenof,"\n"))
cat(paste("phenotype = ",family,"\n"))
cat(paste("population prevalence = ",pop_prev,"\n"))
cat(paste("output_name = ",output_name,"\n"))
cat("\n")

# function for converting R2 into liability R2
h2l_R2 <- function(k, r2, p) {
  # K baseline disease risk
  # r2 from a linear regression model attributable to genomic profile risk score
  # P proportion of sample that are cases
  # calculates proportion of variance explained on the liability scale
  #from ABC at http://www.complextraitgenomics.com/software/
  #Lee SH, Goddard ME, Wray NR, Visscher PM. (2012) A better coefficient of determination for genetic profile analysis. Genet Epidemiol. 2012 Apr;36(3):214-24.
  x= qnorm(1-k)
  z= dnorm(x)
  i=z/k
  C= k*(1-k)*k*(1-k)/(z^2*p*(1-p))
  theta= i*((p-k)/(1-k))*(i*((p-k)/(1-k))-x)
  h2l_R2 = C*r2 / (1 + C*theta*r2)
}


###########
# Read in prs
###########
score <- read.table(scoref)
names(score) <- c("ID","SCORE_STD","SCORE_STD","TOTAL_ALLELE_CT")


###########
# Read in the phenotype data
###########

pheno<-read.table(phenof, header = TRUE)
# Check first two columns are named right
if (names(pheno)[1] != "ID" | names(pheno)[2] != "PHENO"){
    stop('Header names for Phenotype file are wrong. Please read manual and format accordingly.\n')}

cat('Phenotype file contains',dim(pheno)[1],'individuals and ',dim(pheno)[2]-2,'covariates.\n')
cat("\n")

# Determine whether outcome is binary or continuous and formatted correctly
if(family == 'binary'){
  if( length(unique(pheno[,2])) > 2 ){
    stop('Phenotype has more than two values.\n')
  }
  if( pop_prev == 'NA'){
    stop('Population disease prevalence for calculating liability r2 is not specified')
  } else {
    pop_prev <- as.numeric(pop_prev)
  }
}

if(length(unique(pheno[,2])) == 2 & family == 'quantitative'){
    warning('Phenotype has only two values. \n')
}


###########
# Merge the phenotype and prs
###########
prs <- inner_join(score[,c(1,3)], pheno, by="ID")

if(family == 'binary'){
    prs$PHENO<-factor(prs$PHENO, labels=c('CONTROL','CASE'))
    
    logit <- glm(PHENO~., data=prs[,-c(1)], family="binomial")
    prs.coef <- summary(logit)$coeff["SCORE_STD",]
    prs.pseudor2 <- as.numeric(PseudoR2(logit,which="Nagelkerke"))
    logit_reduced <- glm(PHENO~., data=prs[,-c(1, 2)], family="binomial")
    prs.pseudor2_reduced <- as.numeric(PseudoR2(logit_reduced,which="Nagelkerke"))
    prs.partialr2 <- prs.pseudor2 - prs.pseudor2_reduced
    prs.obs_r2<-cor(predict(logit), as.numeric(prs$PHENO))^2
    prs.leesr2 <- h2l_R2(pop_prev, prs.partialr2, sum(prs$PHENO== 'CASE')/length(prs$PHENO))
    myroc <-roc(prs$PHENO, prs$SCORE_STD, auc=TRUE, quiet=TRUE)
    
    calc_stats <- function(data) {
    # Fit full model
    logit <- glm(PHENO ~ ., data = data[,-c(1)], family = "binomial")
    prs.coef <- summary(logit)$coeff["SCORE_STD",]
    
    # Calculate pseudo R2 and partial R2
    prs.pseudor2 <- as.numeric(PseudoR2(logit, which = "Nagelkerke"))
    logit_reduced <- glm(PHENO ~ ., data = data[,-c(1, 2)], family = "binomial")
    prs.pseudor2_reduced <- as.numeric(PseudoR2(logit_reduced, which = "Nagelkerke"))
    prs.partialr2 <- prs.pseudor2 - prs.pseudor2_reduced
    
    # Check conditions
    if (prs.pseudor2 < 0 || prs.pseudor2 > 1 || prs.pseudor2_reduced < 0 || prs.pseudor2_reduced > 1) {
      return(NULL)  # Return NULL if conditions are violated
    }
    
    # Calculate additional statistics
    prs.obs_r2 <- cor(predict(logit), as.numeric(data$PHENO))^2
    prs.leesr2 <- h2l_R2(pop_prev, prs.partialr2, sum(data$PHENO == 'CASE') / length(data$PHENO))
    
    return(c(prs.coef[1], prs.coef[2], prs.pseudor2, prs.partialr2, prs.obs_r2, prs.leesr2))
  }
  
    # Custom function to perform stratified sampling with conditional checks
    custom_boot <- function(data, R) {
    results <- list()  # Store results
    count <- 0         # Track successful iterations
    
    while (count < R) {
      # Perform stratified sampling based on PHENO levels
      indices_case <- sample(which(data$PHENO == "CASE"), replace = TRUE)
      indices_control <- sample(which(data$PHENO == "CONTROL"), replace = TRUE)
      indices <- c(indices_case, indices_control)
      
      # Extract the stratified sample
      d <- data[indices, ]
      
      # Calculate statistics and apply conditions
      stats <- calc_stats(d)
      if (!is.null(stats)) {  # If valid, add to results
        count <- count + 1
        results[[count]] <- stats
      }
    }
    
    # Convert list to data frame for analysis
    results_df <- do.call(rbind, results)
    colnames(results_df) <- c("Coef Estimate", "Std Error", "Pseudo R2", "Partial R2", "Observed R2", "Lees R2")
    
    return(results_df)
  }
  
  # Run the custom bootstrap function to get exactly 1000 successful iterations
  set.seed(123)
  R <- 1000
  boot_results <- custom_boot(data = prs, R = R)
  
  ci <- apply(boot_results, 2, quantile, probs = c(0.025, 0.975))
  
    if(plotroc == 'plotroc'){
      pdf(paste0(output_name,".pdf"))
      plot.roc(myroc,auc.polygon=TRUE, print.auc=TRUE)
      dev.off()
      cat(paste0('ROC plot with AUC saved: ',output_name,'.pdf\n\n'))
    }
    
    
    
    cat("nrow(prs): ", nrow(prs), "length(prs$Pheno):", length(prs$PHENO), ". /n")
    


    
    ci_prs_coef_lower <- ci["2.5%", "Coef Estimate"]
    ci_prs_coef_upper <- ci["97.5%", "Coef Estimate"]
    ci_prs_se_lower <- ci["2.5%", "Std Error"]
    ci_prs_se_upper <- ci["97.5%", "Std Error"]
    ci_prs_pseudor2_lower <- ci["2.5%", "Pseudo R2"]
    ci_prs_pseudor2_upper <- ci["97.5%", "Pseudo R2"]
    ci_prs_partialr2_lower <- ci["2.5%", "Partial R2"]
    ci_prs_partialr2_upper <- ci["97.5%", "Partial R2"]
    ci_prs_obs_r2_lower <- ci["2.5%", "Observed R2"]
    ci_prs_obs_r2_upper <- ci["97.5%", "Observed R2"]
    ci_prs_leesr2_lower <- ci["2.5%", "Lees R2"]
    ci_prs_leesr2_upper <- ci["97.5%", "Lees R2"]

    
    
    
    # result dataframe
    stat <- data.frame(
      Model = model_name,
      MAX_SNP_CT = ceiling(max(score$TOTAL_ALLELE_CT) / 2),
      P = prs.coef[4],
      Beta = prs.coef[1],
      Beta_lower = ci_prs_coef_lower,
      Beta_upper = ci_prs_coef_upper,
      SE = prs.coef[2],
      SE_lower = ci_prs_se_lower,
      SE_upper = ci_prs_se_upper,
      OR = exp(prs.coef[1]),
      OR_lower = exp(ci_prs_coef_lower),
      OR_upper = exp(ci_prs_coef_upper),
      AUC = myroc$auc,
      PseudoR2 = prs.pseudor2,
      PseudoR2_lower = ci_prs_pseudor2_lower,
      PseudoR2_upper = ci_prs_pseudor2_upper,
      PartialR2=prs.partialr2, 
      PartialR2_lower = ci_prs_partialr2_lower,
      PartialR2_upper = ci_prs_partialr2_upper,
      R2 = prs.obs_r2,
      R2_lower = ci_prs_obs_r2_lower,
      R2_upper = ci_prs_obs_r2_upper,
      LiabilityR2 = prs.leesr2,
      LiabilityR2_lower = ci_prs_leesr2_lower,
      LiabilityR2_upper = ci_prs_leesr2_upper,
      N = length(prs$PHENO),
      N_cas = sum(prs$PHENO == 'CASE'),
      N_ctrl = sum(prs$PHENO == 'CONTROL')
    )
    
    } else {
      lnr <- glm(PHENO~., data=prs[,-c(1)], family="gaussian")
      lnr_reduced <- glm(PHENO ~ ., data = prs[,-c(1, 2)], family = "gaussian")
      ssr_full <- sum(resid(lnr)^2)
      ssr_reduced <- sum(resid(lnr_reduced)^2)
      partial_r2 <- 1 - (ssr_full / ssr_reduced)
      prs.coef <- summary(lnr)$coeff[c(2),]
      prs.obs_r2<-cor(predict(lnr), as.numeric(prs$PHENO))^2
      
      calc_stats <- function(data, indices) {
        d <- data[indices, ]
        lnr <- glm(PHENO~., data=d[,-c(1)], family="gaussian")
        lnr_reduced <- glm(PHENO ~ ., data = d[,-c(1, 2)], family = "gaussian")
        ssr_full <- sum(resid(lnr)^2)
        ssr_reduced <- sum(resid(lnr_reduced)^2)
        partial_r2 <- 1 - (ssr_full / ssr_reduced)
        prs.coef <- summary(lnr)$coeff[c(2),]
        prs.obs_r2<-cor(predict(lnr), as.numeric(d$PHENO))^2
        
      
        return(c(prs.coef[1], prs.coef[2], prs.coef[4], prs.obs_r2, partial_r2))
      }
      
      set.seed(123)
    
      boot_results <- boot(data = prs, statistic = calc_stats, R = 1000)
    
      ci_prs_coef <- boot.ci(boot_results, type = "perc", index = 1) # Beta
      ci_prs_se <- boot.ci(boot_results, type = "perc", index = 2) # SE
      ci_prs_p <- boot.ci(boot_results, type = "perc", index = 3) # P
      ci_prs_obs_r2 <- boot.ci(boot_results, type = "perc", index = 4) # Observed R2
      ci_prs_partial_r2 <- boot.ci(boot_results, type = "perc", index = 5) # Partial R2
    
      ci_prs_coef_lower <- ci_prs_coef$perc[4]
      ci_prs_coef_upper <- ci_prs_coef$perc[5]
      ci_prs_se_lower <- ci_prs_se$perc[4]
      ci_prs_se_upper <- ci_prs_se$perc[5]
      ci_prs_obs_r2_lower <- ci_prs_obs_r2$perc[4]
      ci_prs_obs_r2_upper <- ci_prs_obs_r2$perc[5]
      ci_prs_partial_lower <- ci_prs_partial_r2$perc[4]
      ci_prs_partial_upper <- ci_prs_partial_r2$perc[5]
    
    
      stat <- data.frame(Model = model_name,
      P = prs.coef[4],
      Beta = prs.coef[1],
      Beta_lower = ci_prs_coef_lower,
      Beta_upper = ci_prs_coef_upper,
      SE = prs.coef[2],
      SE_lower = ci_prs_se_lower,
      SE_upper = ci_prs_se_upper,
      R2 = prs.obs_r2,
      R2_lower = ci_prs_obs_r2_lower,
      R2_upper = ci_prs_obs_r2_upper,
      Partial_R2 = partial_r2,
      Partial_R2_lower = ci_prs_partial_lower,
      Partial_R2_upper = ci_prs_partial_upper,
      N = length(prs$PHENO)
      )
}

write.table( format(stat, digits=3), paste0(output_name, ".stat"), row.names = F, quote = F, sep=" ")
cat("\n")
cat(paste0("Statistics calculation is done. Results saved as ",output_name,".stat \n"))
cat(paste0("Statistics calculation is done. Results saved as ",output_name,".stat \n"))
