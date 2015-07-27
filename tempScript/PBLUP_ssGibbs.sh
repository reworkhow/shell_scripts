#!/bin/bash

## order pedigree ISU.ped- pedigree file bw.obs-phenotype file
## this example contains two fixed factors
stack_ped -r reord ISU.ped stacked_ped

invnrm -a -v ainverse -i stacked_ped -o inbrg &
awk 'NR>1{print $1}' bw.obs > id.dat &
awk '{print $1}' stacked_ped > id.eff &
awk 'NR>1{print $2}' bw.obs >y &
awk 'NR>1{print $3}' bw.obs  >cg1.dat &
awk 'NR>1{print $4}' bw.obs >cg2.dat &
awk 'NR>1{print $3}' bw.obs| sort -u >cg1.eff &
awk 'NR>1{print $4}' bw.obs|sort -u >cg2.eff &
wait

## make incidence matrices
sed '1d' cg1.eff > cg1.eff.new
replace=`awk 'NR==1{print $1}' cg1.eff`
sed "s/$replace/\./g" cg1.dat>cg1.dat.new

cgen_z -d cg1.dat.new -e cg1.eff.new -r y -o X1 &
cgen_z -d id.dat -e id.eff -r y -o Z &
cgen_z -d cg2.dat -e cg2.eff -r y -o X2 &
wait
chcat X1 X2 X

cmult -t -a X -b X -c XtX &
cmult -t -a X -b Z -c XtZ &
cmult -t -a Z -b Z -c ZtZ &
cmult -t -a Z -b X -c ZtX &
cmult -t -a Z -b y -c Zty &
cmult -t -a X -b y -c Xty &
wait

cadd -a ZtZ -r 0.8 -b ainverse -c ZtZ.L

chcat XtX XtZ lhs.1 &
chcat ZtX ZtZ.L lhs.2 &
wait
cvcat lhs.1 lhs.2 lhs &
cvcat Xty Zty rhs &
wait

## solve
csolve -A lhs -x solve.sln -b rhs -d -t 1e-15 > solve.log

## correlation
awk '{print $1}' stacked_ped > all.list &
awk 'NR>1{print $3}' solve.sln > effect &
awk 'NR>1{print $1,$2}' bw.obs | sort > phen
wait

cat cg1.eff.new cg2.eff all.list > sln.list
paste sln.list effect | sort > solve.out

join solve.out phen > ebv.out
awk '{print $2,$3}' ebv.out > tmp
corr tmp > result.out

rm effect all.list tmp


#### pev
#sp2mm -i lhs -o lhs.mm
#cholesky -A lhs.mm -x pev.out

invnrmdcmp -i stacked_ped -o inbrg.2 -P pmatrix -D dmatrix -d dinv &
ccat -h X Z XZ &
wait

numEff=`head -1 XZ |awk '{print $2}'`

ident $numEff >Ieff

cmult -t -a XZ -b Ieff -c ZtXt

lambayes -Z Z -P pmatrix -D dmatrix -l lhs -x ZtXt -n 10000 -S 7 -y y -r 6.64 -g 7.44 -o lmb_pev

paste sln.list lmb_pev | sort > lmb_effect.out

join lmb_effect.out phen > lmb_ebv.out


scale=0.023 # Rinverse
ckron -a lhs -b $scale -c lhs.gibs
ckron -a rhs -b $scale -c rhs.gibs
 
ssgibbs -A lhs.gibs -b rhs.gibs -o gibs.pev -n 10000 -B 3000 -s 7

paste sln.list gibs.pev | sort > gibs_effect.out

join gibs_effect.out phen > gibs_ebv.out

#cat fixed.gibs random.gibs > effect.gibs
#paste sln.list effect.gibs > gibs_effect.out

#rm effect.gibs

