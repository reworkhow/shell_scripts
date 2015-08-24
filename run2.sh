#!/bin/bash


myHOME=/home/haocheng/ssBayes/small_data
DATA=/home/haocheng/ssBayes/small_data
SCRIPT1=/home/haocheng/0_shell_scripts/ssBayesC.sh
SCRIPT2=/home/haocheng/0_shell_scripts/check_r2.sh
GENOTYPE=/home/haocheng/ssBayes/small_data/sim.gen
GENOTYPEID=/home/haocheng/ssBayes/small_data/genotype.ID
myGENO=geno.filtered

################################
#1. get subset of genotype files
#################################

sort $GENOTYPEID > genotype.ID.sorted
sort -b $GENOTYPE > $GENOTYPE.sorted
join $GENOTYPE.sorted $GENOTYPEID > $GENOTYPE.sub

cut -d " " -f 2- $GENOTYPE.sub > geno.temp
genofilter -i geno.temp -f 0.9 -o geno.filtered.temp -C centered
awk '{print $1}' $GENOTYPE.sub > geno.ID
paste -d "" geno.ID geno.filtered.temp > $myGENO
rm geno.filtered.temp geno.ID

################################
#2.run analysis
################################

myPHENO=/home/haocheng/ssBayes/small_data/sim.phenotype
myPED=/home/haocheng/ssBayes/small_data/stacked_ped
myDfile=/home/haocheng/ssBayes/aviagenData/originalData/D.file
myOUTPUT=results/bw.pi95.out

bash -x $SCRIPT1

###############################
#3.create output file for julia code
################################
cd results
bash -x $SCRIPT2
#######################################################################################
