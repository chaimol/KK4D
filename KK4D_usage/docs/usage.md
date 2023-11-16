Input: You can copy config.ini to your working path and modify it to your own configuration information. Use -c config.ini to specify the location of the configuration parameter file, Or directly input various parameters.

## for coline analysis
`KK4D.sh coline -c /path/to/config.ini`

## from gff3 cds.fa protein.fa ,get 1 or 2 species all the above information.
KK4D.sh all -c /path/to/config.ini

## for A.trichopoda and M.domestica genome chromosome1 gene and protein analysis (This is for the purpose of the testing process only, the general situation is that the whole genome needs to be analyzed.)
`KK4D.sh all -group 2 -cpu 32 -key ID ID -type mRNA mRNA -sample A.trichopoda M.domestica -abbr Ath Mdo -gff3 Ath.chr1.gff3 Mdo.chr1.gff3 -protein Ath.pep.fa.gz Mdo.genome.protein.fa -cds Ath.cds.fa.gz Mdo.cds.fa -chrnum 1 1`

## for M.domestica genome analysis
`KK4D.sh all -group 1 -cpu 24 -key ID -type mRNA -sample M.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17`