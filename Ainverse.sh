#!/bin/bash

#######################################################
#Author: Hao Cheng (haocheng@iastate.edu)
#
#script to generate stacked_ped for A inverse
#
########################################################

#pheno.header
#id sire dam hwumgs bwt.phen

##input file name here
file="pheno.file"

##get pedigree and use stack_ped to reorder
awk '{print $1,$2,$3}' $file > ped.temp
stack_ped -r ref.list ped.temp stacked_ped

#add two extra column of . for nopedrec (generated from stack_ped) 
awk '{for(i=1;i<=2;i++) $(NF+1)=".";print}' nopedrec > nonpedrec2

#paste vertically to get full pedigree
cat nopedrec2 ped.temp > ped.file

#run stack_ped agian to get stacked_ped
stack_ped -r ref.list ped.file stacked_ped

#remove redundant fiels
rm nopedrec2 ped.temp ref.list ped.file
