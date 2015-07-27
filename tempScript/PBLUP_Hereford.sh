#!/bin/bash

## order pedigree ISU.ped- pedigree file bw.obs-phenotype file
## this example contains two fixed factors

##Get A inverse based on stacked_ped
invnrm -a -v Ainverse -i stacked_ped -o inbreedings  &

##
awk '{print $1}' phe.bw > id.dat &
awk '{print $1}' stacked_ped > id.eff &
awk '{print $2}' phe.bw > y &

##fit fixed effect for comtemporary groups and slices

awk '{print $3}' phe.bw > cg1.dat &
awk '{print $4}' phe.bw > cg2.dat &
awk '{print $3}' phe.bw | sort -u > cg1.eff &
awk '{print $4}' phe.bw | sort -u > cg2.eff &
wait

## make incidence matrices
cgen_z -d cg1.dat -e cg1.eff -r y -o X1 &
cgen_z -d cg2.dat -e cg2.eff -r y -o X2 &
cgen_z -d id.dat -e id.eff -r y -o Z &
wait

chcat X1 X2 X

cmult -t -a X -b X -c XtX &
cmult -t -a X -b Z -c XtZ &
cmult -t -a Z -b X -c ZtX &
cmult -t -a Z -b Z -c ZtZ &
cmult -t -a X -b y -c Xty &
cmult -t -a Z -b y -c Zty &
wait

cadd -a ZtZ -r 1.5 -b Ainverse -c ZtZ.L

chcat XtX XtZ lhs.1 &
chcat ZtX ZtZ.L lhs.2 &
wait
cvcat lhs.1 lhs.2 lhs &
cvcat Xty Zty rhs &
wait

## solve
csolve -A lhs -x solve.sln -b rhs -d -t 1e-15 > solve.log
