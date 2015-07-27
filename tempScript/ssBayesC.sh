#!/bin/bash
#######################################################
#Author: Hao Cheng (haocheng@iastate.edu)
#
#script for single-trait single-step Bayesian analysis
#
########################################################

##pheno.header
##_id sire dam hwumgs bwt.phen

sort geno.file > geno.sorted
awk '$5!="."{print $1,$5,$4}'  pheno.file|sort > pheno.sorted #id,phe,fixed 

##This part is done in datawork.sh
#awk '{print $1,$2,$3}' pheno.file > ped.file
#stack_ped -r ref.list ped.file stacked_ped
invnrm -a -v Ainverse -i stacked_ped -o inbreeding

#get genotyp ready
cut -d " " -f 2- geno.sorted > geno.sorted.temp
conv2sbr -i geno.sorted.temp -o genotype.bin

#get genotyped animlas ID and non-genotyped animal ID
awk '{print $1}' geno.sorted > geno.ID.sorted
awk '{print $1}' stacked_ped > ped.ID #need for permsub
sort ped.ID > ped.ID.sorted 
join -v1 ped.ID.sorted geno.ID.sorted|sort > nongeno.ID.sorted 
cat nongeno.ID.sorted geno.ID.sorted > nongeno.geno.ID

#get phenotype for nongenotype(y1) and genotype(y2) animals
join pheno.sorted nongeno.ID.sorted| awk '{print $2 > "phe.y1";print $1>"id.y1";print $3>"fixed.y1"}'
join pheno.sorted geno.ID.sorted| awk '{print $2>"phe.y2";print $1>"id.y2";print $3 > "fixed.y2"}' 

mv phe.y1 y1
mv phe.y2 y2
cat y1 y2 >y
cat id.y1 id.y2 > id.y
cat fixed.y1 fixed.y2 > fixed.y

#make the permutaion matrix to permute Ainverse with new order "nongenotype then genotype"
cgen_z -d nongeno.geno.ID -e ped.ID -r nongeno.geno.ID -o permMatrix
cmult -a permMatrix -b Ainverse -c Ainv.perm.temp
cmult -a Ainv.perm.temp -t -b permMatrix -c Ainv.perm

mv Ainv.perm Ainverse.reordered

#use permsub to get A^11 with order nongenotyped at the beginning
awk '{print $1,"N"}' nongeno.ID.sorted > nongeno.group
awk '{print $1,"G"}' geno.ID.sorted > geno.group
cat nongeno.group geno.group > perm.list

permsub -i nongeno.geno.ID -r perm.list -A Ainverse.reordered -p perm.group
mv Ainverse.reordered.N_N Ainv11
mv Ainverse.reordered.G_N Ainv21
mv Ainverse.reordered.N_G Ainv12
mv Ainverse.reordered.G_G Ainv22
rm geno.group nongeno.group perm.list


## make incidence matrices X and Z 
cp nongeno.geno.ID id.eff 
sort -u fixed.y > fixed.eff 

cgen_z -d id.y -e id.eff -r y -o Z
cgen_z -d fixed.y -e fixed.eff -r y -o X

ny1=`wc -l y1|awk '{print $1}'`
nb1=`wc -l nongeno.ID.sorted|awk '{print $1}'`
zcol=`awk 'NR==1{print $3}' Z` 
zrow=`awk 'NR==1{print $2}' Z`
csubm -i Z -o Z1 -p 1:1:$ny1:$nb1
csubm -i Z -o Z2 -p $(echo "$ny1+1" | bc -l):$(echo "$nb1+1" | bc -l):$zrow:$zcol

##make J2 and J1
n2=`wc -l geno.ID.sorted | awk '{print $1}'` 

echo "SPARSE $n2 1 $n2" > J2
i=1

for((i=1;i<=$n2;i++))
do 
echo "$i 1 -1" >>J2
done

cmult -a Ainv12 -b J2 -r -1 -c rhs.temp
csolve -A Ainv11 -b rhs.temp -x J1 > J1.log 

##make X_star
cmult -a Z1 -b J1 -c J1.temp
cmult -a Z2 -b J2 -c J2.temp
cvcat J1.temp J2.temp J.temp 
chcat X J.temp X_star

#get X1, X2, Z1
xcol=`awk 'NR==1{print $3}' X_star`
xrow=`awk 'NR==1{print $2}' X_star`

csubm -i X_star -o X1 -p 1:1:$ny1:$xcol
csubm -i X_star -o X2 -p $(echo "$ny1+1" | bc -l):1:$xrow:$xcol

#get X'X,X'y,X'Z,Z'y
cmult -t -a X1 -b Z1 -c X1tZ1
cmult -t -a X2 -b Z2 -c X2tZ2
cmult -t -a X_star -b y -c Xty
cmult -t -a X_star -b X_star -c XtX
cmult -t -a Z -b Z -c ZtZ 
cmult -t -a Z1 -b Z1 -c Z1tZ1
cmult -t -a Z1 -b y1 -c Z1ty1
cmult -t -a Z -b y -c Zty

vare=148.7
varg=73.6
lambda1=$(echo $vare/$varg| bc -l)
cadd -a Z1tZ1 -r $lambda1 -b Ainv11 -c Z1tZ1.v ### r is the lamda 

#################
#prepare genotype
##################
#impute
cholesky -A Ainv11 -x mat.ch -p perm.order -o Ainv11.L

numRow=`head -1 Ainv11 |awk '{print $2}'`
ident $numRow > identity 
cmult -t -a Ainv11.L -b identity -c Ainv11.L.t 

##awk '{ for(i=1;i<=NF;i++) printf "%-19s", $i; printf "\n"}' id.srt > id.fm
awk '{printf "%-19s\n", $1}'  geno.sorted > geno.ID.sorted.formated 
awk '{ for(i=2;i<=NF;i++) printf "%3s", $i; printf "\n"}' geno.sorted > genotype.obs
paste -d "" geno.ID.sorted.formated genotype.obs> genotype.obs.fm

#impute -F Ainv11.L -T Ainv11.L.t -A Ainv12 -M genotype.obs.fm

temp=`head -1 geno.sorted|awk '{print NF}'`
nLoci=$(echo "$temp-1" | bc -l)
impute -F Ainv11.L -T Ainv11.L.t -A Ainv12 -M genotype.obs.fm -x M.1 -p perm.order -n $nLoci -s 1 -e 10000 -b -t &
impute -F Ainv11.L -T Ainv11.L.t -A Ainv12 -M genotype.obs.fm -x M.2 -p perm.order -n $nLoci -s 10001 -e 20000 -b -t &
impute -F Ainv11.L -T Ainv11.L.t -A Ainv12 -M genotype.obs.fm -x M.3 -p perm.order -n $nLoci -s 20001 -e 30000 -b -t & 
impute -F Ainv11.L -T Ainv11.L.t -A Ainv12 -M genotype.obs.fm -x M.4 -p perm.order -n $nLoci -s 30001 -e 40000 -b -t &
impute -F Ainv11.L -T Ainv11.L.t -A Ainv12 -M genotype.obs.fm -x M.5 -p perm.order -n $nLoci -s 40001 -b -t &
wait

cat M.1 M.2 M.3 M.4 M.5 > Mt.impute
#insbmtx -m Mt.impute -d Mt.sparse 

#before geno.filter will give frequency
#sed -e 's/0/-1/g' -e 's/\ 1/\ 0/g' -e 's/2/1/g' geno.file|cut -d " " -f 2- > geno.file2
#
#cut -d " " -f 2- geno.file>geno.file2
#genofilter -i geno.file2 -o genotype.filter -f 2.0 -C colmean ## genotype.inp coded as -1, 0, and 1 #remove fixed AA,aa
#nMarker=$(wc -l colmean|awk '{print $1}')
#ident $nMarker > identity
#
#echo "SPARSE $nMarker 1 $nMarker" > one
#i=1
#
#for((i=1;i<=$nMarker;i++))
#do
#echo "$i 1 1" >>one
#done
#
#cmult -a identity -b colmean -c mean 
#cadd -a mean.sparse -b 1 -c mean
#cmult -a identity -b mean -r 0.5 -c Pfreq
#cadd -a Pfreq -b -1 -c Qfreq_neg
#cmult -a identity -b Qfreq_neg -r -1 -c Qfreq
#cmult -t -a Pfreq -b Qfreq -r 2 -c sum2pq  
#pqn=`awk 'NR==2{print $3}' sum2pq`
#phi=$(echo "$vare/$varg*$pqn" | bc -l)
pq=15989.6
pi=0.975
vara=$(echo $varg/$pq/'('1-$pi')'|bc -l)
phi=$(echo $vare/$vara|bc -l)

#cmult -a Mt.sparse -b Zty -c MtZty.sparse
mmultongpu -m Mt.impute -y Zty -o MtZty.sparse
mtmgpu -m Mt.impute -o MtZtZMphi -z ZtZ -p $phi


#Now RUN IT!!!
sthmgibbsC -D aviagenData/D.file -o bw.out -n 50000 -p 0 -r $vare -a $vara -s 314 -B 1000
sthmgibbsC -D aviagenData/D.file -o bw.pi95.out.new -n 50000 -p 0.95 -r $vare -a $vara -s 314 -B 1000

sthmgibbsC -D aviagenData/D.file -o bw.pi95.out.new -n 50000 -p 0.975 -r $vare -a $vara -s 314 -B 1000
#check result
### breeding value in validation u_2
#cat out.40000.u_1 out.40000.u_2  > out1.u
#awk '{print $1,$2}' phen.inp > phen.list
#paste phen.list out1.u | sort> ebv.list

#awk 'NR>1{print $1,$2}' bw.val | sort> val.list
#join val.list ebv.list | awk '{print $1,$2,$4,$5}' > val.ebv
#awk '{print $2,$3}' val.ebv > tmp
#corr tmp > val.cor
#rm tmp
#rm Mt.sparse M.sparse
#rm MtZtZMphi
