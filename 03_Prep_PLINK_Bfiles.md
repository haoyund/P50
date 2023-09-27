```
%%bash
rm merged.txt;
for i in $(seq 1 23)
do
echo "plink_bed/clinvar.chr$i.bed" >> merged.txt
echo "plink_bed/clinvar.chr$i.bim" >> merged.txt
echo "plink_bed/clinvar.chr$i.fam" >> merged.txt
done
```

```
!cat merged.txt
```
