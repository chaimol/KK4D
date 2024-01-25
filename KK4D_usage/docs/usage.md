
# Option1: Start with genome.fa and genome.gff3 file
```
bash genome2cdspep.sh genome.fa genome.gff3 genome_abbr key_str
```
`key_str` is the dividing character that distinguishes different transcripts, usually `.` or `-`
Output file for KK4D:
- genome_abbr.pep
- genome_abbr.cds 

for example: 
Ath.gff3 
```
1       araport11       gene    3631    5899    .       +       .       ID=gene:AT1G01010;Name=NAC001;biotype=protein_coding;description=NAC domain-containing protein 1 [Source:UniProtKB/Swiss-Prot%3BAcc:Q0WV96];gene_id=AT1G01010;logic_name=araport11
1       araport11       mRNA    3631    5899    .       +       .       ID=AT1G01010.1;Parent=gene:AT1G01010;biotype=protein_coding;transcript_id=AT1G01010.1
1       araport11       five_prime_UTR  3631    3759    .       +       .       Parent=AT1G01010.1
1       araport11       exon    3631    3913    .       +       .       Parent=AT1G01010.1;Name=AT1G01010.1.exon1;constitutive=1;ensembl_end_phase=1;ensembl_phase=-1;exon_id=AT1G01010.1.exon1;rank=1
1       araport11       CDS     3760    3913    .       +       0       ID=CDS:AT1G01010.1;Parent=AT1G01010.1;protein_id=AT1G01010.1
1       araport11       exon    3996    4276    .       +       .       Parent=AT1G01010.1;Name=AT1G01010.1.exon2;constitutive=1;ensembl_end_phase=0;ensembl_phase=1;exon_id=AT1G01010.1.exon2;rank=2
1       araport11       CDS     3996    4276    .       +       2       ID=CDS:AT1G01010.1;Parent=AT1G01010.1;protein_id=AT1G01010.1
```
Part of the content of Ath.gff3 is as follows. We can see `protein_id=AT1G01010.1`. AT1G01010.1 here is to distinguish different transcripts of the same gene based on the last `.`. So the command to obtain the cds and pep files of Ath should be similar to the following:
```
bash genome2cdspep.sh Ath.genome.fa Ath.gff3 Ath .
```
This script will finally output Ath.pep and Ath.cds, which are the protein sequence and CDS sequence as input to KK4D.

# Option2: Start with genome.gff3,genome.pep,genome.cds file.
Input: You can copy config.ini to your working path and modify it to your own configuration information. Use -c config.ini to specify the location of the configuration parameter file, Or directly input various parameters.

## get the config.ini file
`KK4D.sh init`
This will create a config.ini file in your current working path.

## for coline analysis
`KK4D.sh coline -c /path/to/config.ini`

## from gff3 cds.fa protein.fa ,get 1 or 2 species all the above information.
```
KK4D.sh all -c /path/to/config.ini
```

## for A.trichopoda and M.domestica genome chromosome1 gene and protein analysis (This is for the purpose of the testing process only, the general situation is that the whole genome needs to be analyzed.)
`KK4D.sh all -group 2 -cpu 32 -key ID ID -type mRNA mRNA -sample A.trichopoda M.domestica -abbr Ath Mdo -gff3 Ath.chr1.gff3 Mdo.chr1.gff3 -protein Ath.pep.fa.gz Mdo.genome.protein.fa -cds Ath.cds.fa.gz Mdo.cds.fa -chrnum 1 1`

## for M.domestica genome analysis
`KK4D.sh all -group 1 -cpu 24 -key ID -type mRNA -sample M.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17`