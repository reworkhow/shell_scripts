##get stacked_ped
PED=hao.ped

stack_ped -r ref.list $PED stacked_ped

#add two extra column of . for animals
awk '{$(NF+1)=".";}1' nopedrec | awk '{$(NF+1)=".";}1' > nopedrec2
#paste vertically
cat nopedrec2 $PED > ped.file
stack_ped -r ref.list ped.file stacked_ped
rm ped.file ped.temp nopedrec* ref.list

