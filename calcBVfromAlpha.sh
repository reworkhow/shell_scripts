#!/bin/bash

awk '{print $1}' geno.filtered.tst >geno.tst.ID
cut -d " " -f 2- geno.filtered.tst > geno.temp
conv2sbr -i geno.temp -C ../centered.value -o genotype.centered.bin
insbmtx -m genotype.centered.bin -d geno.centered.sparse

awk '{print $1}' bw.pi95.out.50000.alpha > alpha
cmult -a geno.centered.sparse -b alpha -c bv.tst.geno.sparse

awk 'NR>1{print $3}' bv.tst.geno.sparse > bv.tst.geno
paste -d " " geno.tst.ID bv.tst.geno > bw.pi95.out.50000.u_tst_geno
