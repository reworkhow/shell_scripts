
#######################################################
###file path
##geno: geno.trn.filtered
#######################################################
myHOME=/home/haocheng/ssBayes/aviagen_single_sex/results_testing_removed_geno_ped
myGENO=../aviagenData/geno.filtered.tst.rm
myPHENO=../aviagenData/pheno.file
myPED=../aviagenData/stacked_ped
myOUTPUT=results/bw.pi95.out
myDfile=../aviagenData/D.file

DATA=/home/haocheng/ssBayes/aviagenData/originalData
SCRIPT1=/home/haocheng/0_shell_scripts/ssBayesC.sh
SCRIPT2=/home/haocheng/0_shell_scripts/check_r2.sh
myOUTPUT=results/bw.pi95.out

#######################################################
###input parameters
#######################################################
vare=148.7
varg=73.6
pq=15660.5
pi=0.95

cd $myHOME
