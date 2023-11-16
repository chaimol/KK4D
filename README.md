# KK4D
This is a pipline for one or two genome analysis of Ka,Ks,4DTv,coline
=======
# Readme.md
### this is a pipline for analysis of coline genes,KaKs and 4DTv .
#### It can analysis 2 species or 1 species.

# Input files
###  Prepare Input file(can be normal or *.gz)
- genome.gff3 
- genome.pep.fa 
- genome.cds.fa

if you don’t have protein or cds file,you can use [gffread](https://github.com/gpertea/gffread.git) extract protein and cds sequence from genome and gff3 file.
I wrote the python3 script "getLongerSequences.py" to get the longest transcript sequence for each gene protein or cds sequence.

example bash code
```
genome="/share/database/Arachis_ipaensis/GCF_000816755.2_Araip1.1_genomic.fa"
gff3="/share/database/Arachis_ipaensis/GCF_000816755.2_Araip1.1_genomic.gff"
abbr="A.ipaensis"
gffread ${gff3} -g ${genome} -x ${abbr}.cds.fa -y ${abbr}.pep.fa
python3 getLongerSequences.py ${abbr}.cds.fa ${abbr}.cds .
python3 getLongerSequences.py ${abbr}.pep.fa ${abbr}.pep .
```
The files A.ipaensis.cds and A.ipaensis.pep are the input files for KK4D.

# Require software

`Install.sh` 
- [jcvi](https://github.com/tanghaibao/jcvi)
- Rscript
- python3
#### Require software (These software will be automatically added to your ~/.bashrc)
The binary version of the dependent software has been provided, and you don’t have to install a list of software yourself. You also can install these software yourself and add it to the ~/.bashrc.
- [seqkit](https://github.com/shenwei356/seqkit)
- [mafft](https://mafft.cbrc.jp/alignment/software/)
- [KaKs_Calculator 2.0](https://sourceforge.net/projects/kakscalculator2/)
- [ParaAT2.0](ftp://download.big.ac.cn/bigd/tools/ParaAT2.0.tar.gz)

# Install
- Step1:Install software (Install.sh will use pip install jcvi,and put other require software to your ~/.bashrc )
```
git clone https://github.com/chaimol/KK4D.git
cd KK4D
bash Install.sh
source ~/.bashrc
```
- Step2: `KK4D.sh -h` for help

# [Useage](https://chaimol.com/product/KK4D/)
Input:
You can copy config.ini to your working path and modify it to your own configuration information. Use -c config.ini to specify the location of the configuration parameter file,
Or directly input various parameters.

#### for coline analysis
`KK4D.sh coline -c /path/to/config.ini`

#### from gff3 cds.fa  protein.fa ,get 1 or 2 species all the above information.
`KK4D.sh all -c /path/to/config.ini`

#### for A.trichopoda and M.domestica genome chromosome1 gene and protein analysis (This is for the purpose of the testing process only, the general situation is that the whole genome needs to be analyzed.)
`KK4D.sh all -group 2 -cpu 32 -key ID ID -type mRNA mRNA -sample A.trichopoda M.domestica -abbr Ath Mdo -gff3 Ath.chr1.gff3 Mdo.chr1.gff3 -protein Ath.pep.fa.gz Mdo.genome.protein.fa -cds Ath.cds.fa.gz Mdo.cds.fa -chrnum 1 1`

#### for M.domestica genome analysis 
`KK4D.sh all -group 1 -cpu 24 -key ID -type mRNA -sample M.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17`
# Warning
Please make sure that the input sequence IDs of cds.fa and protein.fa are the same.
Such as:
`head Ath.protein.fa`
```
>AT3G05780.1 pep chromosome:TAIR10:3:1714941:1719608:-1 gene:AT3G05780 transcript:AT3G05780.1 gene_biotype:protein_coding transcript_biotype:protein_coding gene_symbol:LON3 description:Lon protease homolog 3, mitochondrial [Source:UniProtKB/Swiss-Prot;Acc:Q9M9L8]
MMPKRFNTSGFDTTLRLPSYYGFLHLTQSLTLNSRVFYGARHVTPPAIRIGSNPVQSLLL
FRAPTQLTGWNRSSRDLLGRRVSFSDRSDGVDLLSSSPILSTNPNLDDSLTVIALPLPHK
PLIPGFYMPIHVKDPKVLAALQESTRQQSPYVGAFLLKDCASTDSSSRSETEDNVVEKFK
VKGKPKKKRRKELLNRIHQVGTLAQISSIQGEQVILVGRRRLIIEEMVSEDPLTVRVDHL
```
`head Ath.cds.fa`
```
>AT3G05780.1 cds chromosome:TAIR10:3:1714941:1719608:-1 gene:AT3G05780 gene_biotype:protein_coding transcript_biotype:protein_coding gene_symbol:LON3 description:Lon protease homolog 3, mitochondrial [Source:UniProtKB/Swiss-Prot;Acc:Q9M9L8]
ATGATGCCTAAACGGTTTAACACGAGTGGCTTTGACACGACTCTTCGTCTACCTTCGTAC
TACGGTTTCTTGCATCTTACACAAAGCTTAACCCTAAATTCCCGCGTTTTCTACGGTGCC
CGCCATGTGACTCCTCCGGCTATTCGGATCGGATCCAATCCGGTTCAGAGTCTACTACTC
```
`head Ath.gff3`
```
1       TAIR10  chromosome      1       30427671        .       .       .       ID=chromosome:1;Alias=CP002684.1,Chr1,NC_003070.9
1       araport11       gene    3631    5899    .       +       .       ID=gene:AT1G01010;Name=NAC001;biotype=protein_coding;description=NAC domain-containing protein 1 [Source:UniProtKB/Swiss-Prot%3BAcc:Q0WV96];gene_id=AT1G01010;logic_name=araport11
1       araport11       mRNA    3631    5899    .       +       .       ID=transcript:AT1G01010.1;Parent=gene:AT1G01010;biotype=protein_coding;transcript_id=AT1G01010.1
1       araport11       five_prime_UTR  3631    3759    .       +       .       Parent=transcript:AT1G01010.1
1       araport11       exon    3631    3913    .       +       .       Parent=transcript:AT1G01010.1;Name=AT1G01010.1.exon1;constitutive=1;ensembl_end_phase=1;ensembl_phase=-1;exon_id=AT1G01010.1.exon1;rank=1
1       araport11       CDS     3760    3913    .       +       0       ID=CDS:AT1G01010.1;Parent=transcript:AT1G01010.1;protein_id=AT1G01010.1
1       araport11       exon    3996    4276    .       +       .       Parent=transcript:AT1G01010.1;Name=AT1G01010.1.exon2;constitutive=1;ensembl_end_phase=0;ensembl_phase=1;exon_id=AT1G01010.1.exon2;rank=2
1       araport11       CDS     3996    4276    .       +       2       ID=CDS:AT1G01010.1;Parent=transcript:AT1G01010.1;protein_id=AT1G01010.1
```
In this example,the cds and protein IDs is "AT3G05780.1",so we must be set the "key" and "type" in config.ini. "key" should be set is "transcript_id" and "type" should be set is "mRNA".
If this example,if the "key" is set to "ID", then the output IDs of Ath.bed will be "transcript:AT1G01010.1" is different with the protein.fa and cds.fa IDs "AT1G01010.1".So this will course Error.

Before each script is run, it will check whether the output file of the previous step exists. So if the output bed format is incorrect, you can manually adjust it and still rename it to the name of the program output. Then run subsequent commands. If the latter step fails, be sure to delete the failed file.
If your input sequence contains scaffold, and the ID prefix of the chromosome is the same as that of scaffold, the number of chromosomes may not be correctly resolved when drawing collinearity.

# Update information
#### 2021.3.18 release the Version 0.01
#### 2021.3.19 update the Version to 0.02
#### 2021.4.22 update the Version to 0.04
Update info:
1. The V0.01 has to much bug.
2. All commands in this version have been tested and run normally.
3. This version does not include a visualization module, and the next version may add the visualization module.
#### 2021.8.13 update the Version to 0.021
1. update the Require software info 
2. add require software info
3. modify the Install.sh , debug the Error of "mafft" or "KaKs_Calculator" not found.
#### 2022.3.18 update the Version to 0.03
1. add visualization module,need Rscript.
2. Install jcvi by pip , not require conda.
#### 2022.4.22 update the Version to 0.04
1. from this version, can be use -c setting the config.ini path or Or directly enter the parameters.