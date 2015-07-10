#!/bin/bash

head -1 trn_phens.csv > pheno.header

awk -F, '{print $1,$2,$3,$5,$8}' trn_phens.csv > pheno.trn
awk 'NR>1{print $0}' pheno.trn >pheno.trn.temp #remove header

awk -F, '{print $1,$2,$3,$5,"."}' tst_phens.csv > pheno.tst
awk 'NR>1{print $0}' pheno.tst >pheno.tst.temp #remove header

cat pheno.trn.temp pheno.tst.temp> pheno.file.temp
sed s/-999/./g pheno.file.temp >pheno.file
rm pheno.*.temp

awk '{print $1,$2,$3}' pheno.file > ped.temp
stack_ped -r ref.list ped.temp stacked_ped

rm nopedrec2 ped.temp ref.list
rm pheno.trn pheno.tst

#add two extra column of .
awk '{$(NF+1)=".";}1' nopedrec | awk '{$(NF+1)=".";}1' > nopedrec2
#paste vertically
cat nopedrec2 ped.temp > ped.file
stack_ped -r ref.list ped.file stacked_ped

#genotype: remove header(check at first to see whether header==true)
head -1 geno.file > geno.file.header
awk 'NR>1{print $0}' geno.file>geno.file.temp
mv geno.file geno.file.original
mv geno.file.temp geno.file
