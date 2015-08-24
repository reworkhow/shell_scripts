#!/bin/bash

#######################################################
#Author: Hao Cheng (haocheng@iastate.edu)
#
#script to clean phenotype and genotype data 
#
########################################################


#get header for phenotype file
head -1 trn_phens.csv > pheno.header

######################################################
#create phenotype files
#
#######################################################
#want to subtract these columns below
#e.g. id sire dam hwumgs bwt.phen
#######################################################

#get cols for e.g. (with phenotypes) for training and remove headers
awk -F, '{print $1,$2,$3,$5,$8}' trn_phens.csv > pheno.trn
awk 'NR>1{print $0}' pheno.trn > pheno.trn.temp #remove header

#get cols for e.g. (no phenotypes --> .) for testing and remove headers
awk -F, '{print $1,$2,$3,$5,"."}' tst_phens.csv > pheno.tst
awk 'NR>1{print $0}' pheno.tst >pheno.tst.temp #remove header

#put training and testing together and replace missing phnotype with .
cat pheno.trn.temp pheno.tst.temp> pheno.file.temp
sed s/-999/./g pheno.file.temp > pheno.file

rm pheno.*.temp
rm pheno.trn pheno.tst

##############################################################
#
#create genotype
##############################################################
#genotype: remove header(check at first to see whether header==true)
ORIGENO=genotype.new
head -1 $ORIGENO > geno.file.header
awk 'NR>1{print $0}' geno.file>geno.file.temp
mv geno.file geno.file.original
mv geno.file.temp geno.file

##Get a subset genotypes
awk -F, 'NR>1{print $1}' tst_phens.csv|sort > tst.ID
awk -F, '$7==1{print $1}' tst_phens.csv|sort > tst.male.ID
awk -F, '$7==2{print $1}' tst_phens.csv|sort > tst.female.ID
awk -F, '$7==1{print $1}' trn_phens.csv|sort > trn.male.ID
awk -F, '$7==2{print $1}' trn_phens.csv|sort > trn.female.ID

#rm testing genotypes and training male genotypes
GENOTYPE=geno.male.trn.rm.tst.rm
sort geno.file > geno.sorted
cat tst.ID trn.male.ID|sort > trn.male.tst.ID
join -v1 geno.sorted trn.male.tst.ID > $GENOTYPE 
rm trn.male.tst.ID

#rm testing genotypes and training male genotypes
GENOTYPE=geno.female.trn.rm.tst.rm
sort geno.file > geno.sorted
cat tst.ID trn.female.ID|sort > trn.female.tst.ID
join -v1 geno.sorted trn.female.tst.ID > $GENOTYPE
rm trn.female.tst.ID

#rm testing genotypes
GENOTYPE=geno.tst.rm
sort geno.file > geno.sorted
cat tst.ID |sort > tst.ID.sorted
join -v1 geno.sorted tst.ID.sorted > $GENOTYPE
rm tst.ID.sorted


#recode
sed 's/ 0/ -1/g;s/ 1/ 0/g;s/ 2/ 1/g' $GENOTYPE >geno.file.recoded
#filter
cut -d " " -f 2- geno.file.recoded > geno.temp
genofilter -i geno.temp -f 0.9 -o geno.filtered.temp -C centered
awk '{print $1}' geno.file.recoded > geno.ID
paste -d "" geno.ID geno.filtered.temp > $GENOTYPE.filtered
rm geno.temp geno.file.recoded geno.filtered.temp geno.ID

#get sum2pq 
awk '{a=(1-$1)/2; SUM+=2*a*(1-a)}END{print SUM}' centered > sum2pq
