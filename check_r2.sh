#check result
### breeding value in validation u_2
ebv_nongeno=bw.pi975.out.50000.u_1
ebv_geno=bw.pi975.out.50000.u_2 
beta=bw.pi975.out.50000.beta
output=comp.pi975_2

cat $ebv_nongeno $ebv_geno|awk '{print $1}' > ebv.nongeno.geno
#add mu_g, u_1 and u_2 in bolt has no mu_g added
tail -1 $beta| awk '{print $1}'> mu_g
cvcat J1 J2 J
cmult -a J -b mu_g -c mu_g.J

ident $(wc -l ebv.nongeno.geno|awk '{print $1}')>ident.ebv
cmult -a ident.ebv -b ebv.nongeno.geno -c ebv.nongeno.geno.sparse
cadd -a ebv.nongeno.geno.sparse -b mu_g.J -c ebv.effect.temp
awk 'NR>1{print $3}' ebv.effect.temp > ebv.effect

paste -d" " nongeno.geno.ID ebv.effect |sort> ebv.list



##get phenotypes in testinig dataset
awk -F, 'NR!=1&&$8!="-999"{print $1,$5,$8}' aviagenData/tst_phens.csv|sort > phen.tst.list #id,fixed,pheno

join phen.tst.list ebv.list > $output

#genotyped test
join $output aviagenData/genotyped_TST.txt > $output".tst.geno"
#nongenotyped test
join -v1 $output aviagenData/genotyped_TST.txt > $output".tst.nongeno"


#some fixed effect level are not estimateed in testing data
#awk '{print $2}' phen.tst.list > fixed.test 
#cgen_z -d fixed.test -e fixed.eff -r fixed.test -o X.test


#awk '{print $1,$2}' phen.inp > phen.list
#paste phen.list out1.u | sort> ebv.list

#awk 'NR>1{print $1,$2}' bw.val | sort> val.list
#join val.list ebv.list | awk '{print $1,$2,$4,$5}' > val.ebv
#awk '{print $2,$3}' val.ebv > tmp
#corr tmp > val.cor
#rm tmp
#rm Mt.sparse M.sparse
#rm MtZtZMphi

