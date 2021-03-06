#!/bin/bash

#######################################################
#Author: Hao Cheng (haocheng@iastate.edu)
#
#script for single-trait single-step Bayesian analysis
#
#calculate accuracy for results from single-trait Bayes
########################################################

#check result
### breeding value in validation u_2
ebv_nongeno=bw.pi95.out.50000.u_1
ebv_geno=bw.pi95.out.50000.u_2 
beta=bw.pi95.out.50000.beta
output=comp.pi95

cat $ebv_nongeno $ebv_geno|awk '{print $1}' > ebv.nongeno.geno
#add mu_g, u_1 and u_2 in bolt has no mu_g added
tail -1 $beta| awk '{print $1}'> mu_g
cvcat ../J1 ../J2 J
cmult -a J -b mu_g -c mu_g.J

ident $(wc -l ebv.nongeno.geno|awk '{print $1}')>ident.ebv
cmult -a ident.ebv -b ebv.nongeno.geno -c ebv.nongeno.geno.sparse
cadd -a ebv.nongeno.geno.sparse -b mu_g.J -c ebv.effect.temp
awk 'NR>1{print $3}' ebv.effect.temp > ebv.effect

paste -d" " ../nongeno.geno.ID ebv.effect |sort> ebv.list

##get phenotypes in testinig dataset
awk -F, 'NR!=1&&$8!="-999"{print $1,$5,$8}' $DATA/tst_phens.csv | sort > phen.tst.list #id,fixed,pheno

join phen.tst.list ebv.list > $output

#genotyped test
join $output $DATA/genotyped_TST.txt > $output".tst.geno"
#nongenotyped test
join -v1 $output $DATA/genotyped_TST.txt > $output".tst.nongeno"

#female test and male test
join $output $DATA/../tst.male.id > $output.tst.male
join -v1 $output $DATA/../tst.male.id > $output.tst.female
