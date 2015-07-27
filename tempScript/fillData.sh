#!/bin/bash!

awk '{print $1}' phe.bw phe.ww phe.yw phe.fw | sort -u > IDs.sorted
sort phe.bw >phe.bw.sorted
sort phe.ww >phe.ww.sorted
sort phe.yw >phe.yw.sorted
sort phe.fw >phe.fw.sorted

join -a 1 -a 2 phe.yw.sorted IDs.sorted > phe.yw.fill_IDs
join -a 1 -a 2 phe.ww.sorted IDs.sorted > phe.ww.fill_IDs
join -a 1 -a 2 phe.fw.sorted IDs.sorted > phe.fw.fill_IDs
join -a 1 -a 2 phe.bw.sorted IDs.sorted > phe.bw.fill_IDs
		
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.fw phe.ww phe.bw phe.yw|sort -n -u > maxNum
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.fw|sort -n -u > maxNum
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.fw|sort -n -u|tail 1
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.fw|sort -n -u|tail -1
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.ww|sort -n -u|tail -1
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.yw|sort -n -u|tail -1
#awk '{print $2;print $3;print $4;print $5;print $6;print $7}' phe.bw|sort -n -u|tail -1
awk 'BEGIN{v=2000000}{for(i=1;i<=4;i++) if($i=="") $i=v++}1' phe.yw.fill_IDs phe.ww.fill_IDs phe.fw.fill_IDs phe.bw.fill_IDs > phe.BIG

awk 'NR<=5006001 {print $0}' phe.BIG > phe.yw.fill
awk 'NR>5006001 && NR <= 5006001*2 {print $0}' phe.BIG > phe.ww.fill
awk 'NR>5006001*2 && NR <= 5006001*3 {print $0}' phe.BIG > phe.fw.fill
awk 'NR>5006001*3 && NR <= 5006001*4 {print $0}' phe.BIG > phe.bw.fill
