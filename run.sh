#!/bin/bash


myHOME=/home/haocheng/ssBayes/small_data
DATA=/home/haocheng/ssBayes/small_data
SCRIPT1=/home/haocheng/0_shell_scripts/ssBayesC.sh
SCRIPT2=/home/haocheng/0_shell_scripts/check_r2.sh
GENOTYPE=/home/haocheng/ssBayes/aviagenData/geno.file.recoded
GTID=/home/haocheng/ssBayes/aviagenData/geno.train.ID
myGENO=geno.filtered

################################
#1. get subset of genotype files
#################################
NUMGENO=12000
cd $myHOME/$NUMGENO.rm

#head -$NUMGENO $GTID > $GTID.$NUMGENO
#join -v1 $GENOTYPE $GTID.$NUMGENO > geno.$NUMGENO.rm

cut -d " " -f 2- geno.$NUMGENO.rm > geno.temp
genofilter -i geno.temp -f 0.9 -o geno.filtered.temp -C centered
awk '{print $1}' geno.$NUMGENO.rm > geno.ID
paste -d "" geno.ID geno.filtered.temp > $myGENO
rm geno.filtered.temp geno.ID

################################
#2.run analysis
################################

myPHENO=/home/haocheng/ssBayes/aviagenData/originalData/pheno.file
myPED=/home/haocheng/ssBayes/aviagenData/stacked_ped
myDfile=/home/haocheng/ssBayes/aviagenData/originalData/D.file
myOUTPUT=results/bw.pi95.out

bash -x $SCRIPT1

###############################
#3.create output file for julia code
################################
cd results
bash -x $SCRIPT2
#######################################################################################
