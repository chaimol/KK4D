# Visualization module
### only for 2 genome collinearity  bar plot
```
Rscript bar2coline.R gff3file colinefile figset_up figset_down workpath
```
*Note:gff3 file colname must be same with the example*

Example:
```
Rscript bar2coline.R Spo.Ath.gff Spo.Ath.bar.coline Ath Spo /mnt/e/KK4D_develop/Visual/
```
in workpath should have `Spo.Ath.gff`,`Spo.Ath.bar.coline` file.

```
head Spo.Ath.bar.coline
V1          V2
AT1G20780.1 AT1G76390.2
AT1G20816.1 AT1G76405.2

head Spo_Ath.gff
chr       chrom start   end
Ath1 AT1G01010.1  3630  5899
Ath1 AT1G01020.1  6787  9130
```



### Obtain 1 or more genomic KaKs and/or 4DTv peaks
```
Rscript drawKaKs4DTV.R ref_genome_abbr config.tsv workpath both
Rscript drawKaKs4DTV.R ref_genome_abbr config.tsv workpath KaKs
Rscript drawKaKs4DTV.R ref_genome_abbr config.tsv workpath 4DTv
```
*Note:csv file colname must be same with the example*

Example1:
```
Rscript drawKaKs4DTV.R Spo config.tsv /mnt/e/KK4D_develop/Visual/ both
```
Example1 config.tsv:
```
Spo	S.pommunis
Ath	A.thaliana
Tca	T.cacao
Tha	T.hassleriana
```
in workpath should have file `Spo_Spo.kaks4DTv.csv`,`Spo_Tha.kaks4DTv.csv`,`Spo_Tca.kaks4DTv.csv`,`Spo_Ath.kaks4DTv.csv`
```
head Spo_Ath.kaks4DTv.csv
Seq,X4dtv_corrected,Ka,Ks,Ka/Ks
AT1G01010-Sp01G008830,0.333333333,,,
AT1G01020-Sp01G008670,0.25,,,
AT1G01030-Sp01G008660,0.529411765,0.521695,2.90182,0.179782
AT1G01040-Sp01G008650,0.363934426,0.143627,3.90695,0.036762
AT1G01050-Sp01G008640,0.260273973,0.0812117,1.79963,0.0451269
```

Example2:
```
Rscript drawKaKs4DTV.R Spo config.tsv /mnt/e/KK4D_develop/Visual KaKs
```
Example2 config.tsv:
```
Spo	S.pommunis
Ath	A.thaliana
Tca	T.cacao
Tha	T.hassleriana
```
in workpath should have file `Spo_Spo.all-kaks.csv`,`Spo_Tha.all-kaks.csv`,`Spo_Tca.all-kaks.csv`,`Spo_Ath.all-kaks.csv`
```
head Spo_Ath.all-kaks.csv
Seq,Ka,Ks,Ka/Ks
AT1G01030-Sp01G008660,0.521695,2.90182,0.179782
AT1G01040-Sp01G008650,0.143627,3.90695,0.036762
AT1G01050-Sp01G008640,0.0812117,1.79963,0.0451269
AT1G01060-Sp01G008590,0.424685,2.99626,0.141739
```

Example3:
```
Rscript drawKaKs4DTV.R Spo config.tsv /mnt/e/KK4D_develop/Visual 4DTv
```
Example3 config.tsv:
```
Spo	S.pommunis
Ath	A.thaliana
Tca	T.cacao
Tha	T.hassleriana
```
in workpath should have file `Spo_Spo.all-4dtv.csv`,`Spo_Tha.all-4dtv.csv`,`Spo_Tca.all-4dtv.csv`,`Spo_Ath.all-4dtv.csv`
```
head Spo_Ath.all-4dtv.csv
Seq,X4dtv_corrected
AT1G01010-Sp01G008830,0.333333333
AT1G01020-Sp01G008670,0.25
AT1G01030-Sp01G008660,0.529411765
AT1G01040-Sp01G008650,0.363934426
AT1G01050-Sp01G008640,0.260273973
AT1G01060-Sp01G008590,0.422077922
```

