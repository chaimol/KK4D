# KK4D
This is a pipline for one or two genome analysis of Ka,Ks,4DTv,coline

- [KK4D website](https://chaimol.com/product/KK4D/)
- [KK4D github](https://github.com/chaimol/KK4D)

=======
# Readme
#### It can analysis 2 species or 1 species.

# Input files
###  Prepare Input file(can be normal or *.gz)
- genome.gff3 
- genome.pep.fa 
- genome.cds.fa

if you don’t have protein or cds file,you can install [gffread](https://github.com/gpertea/gffread.git) ,and extract protein and cds sequence from genome and gff3 file by `genome2cdspep.sh`.

`bash genome2cdspep.sh genome.fa genome.gff3 genome_abbr .`
```
bash genome2cdspep.sh GCF_000816755.2_Araip1.1_genomic.fa GCF_000816755.2_Araip1.1_genomic.gff A.ipaensis .
```
The files A.ipaensis.cds and A.ipaensis.pep are the input files for KK4D.
The final parameter str default is `.`, which is the separator that distinguishes different transcripts.

# Require software

`Install.sh` 
- [jcvi](https://github.com/tanghaibao/jcvi)
- Rscript
- Python3
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
pip install jcvi
source ~/.bashrc
```
- Step2: `KK4D.sh -h` 
If all dependent software is installed correctly, help information will be displayed, otherwise an error message will be reported for XX software that is not installed correctly.

# Useage

### get `config.ini` file
`KK4D.sh init`  or  `KK4D.sh -i` 

#### There are two running methods: 
- specify the location of config.ini to run, 
- directly enter each parameter to run.
The input fa files and gff3 files can be ordinary files or gz compressed files.

#### Running mode 1: use config.ini as input
`KK4D.sh all -c config.ini`

#### Running mode 2: Enter all required parameters directly on the command line
`KK4D.sh all -group 2 -cpu 32 -key ID ID -type mRNA mRNA -sample A.trichopoda M.domestica -abbr Ath Mdo -gff3 Ath.chr1.gff3 Mdo.chr1.gff3 -protein Ath.pep.fa.gz Mdo.genome.protein.fa -cds Ath.cds.fa.gz Mdo.cds.fa -chrnum 5 17`
`KK4D.sh all -group 1 -cpu 24 -key ID -type mRNA -sample Malus.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17` 
`KK4D.sh coline -group 1 -key ID -type mRNA -sample Malus.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17`


#### Control command parameters (default: all)
- bed
- cds
- pep
- coline
- kaks
- 4DTv
- all

##### workpath
	-wd|-workpath default：Current working path
	
##### Use the config.ini file as the input parameter file
	-c|-config path to config.ini 
	
##### Enter the file parameters (be sure to enter each required parameter in order, otherwise an error will be reported)
	-g|-group  genome groups number，here must be set 1 or 2
	-cpu|-threads use threads,default:24
	-k|-key Characters in column 9 of gff3 file,general is ID
	-t|-type Characters in column 3 of gff3 file, general is  gene or mRNA
	-s|-sample Latin name of species
	-a|-abbr Abbreviation of species name
	-gf|-gff3 gff3 file，can be gff3 or gff3.gz
	-p|-protein protein file, can be fasta or fa.gz
	-cd|-cds CDS file, can be fasta or fa.gz
	-chrn|-chrnum The number of chromosomes (if it is scaffold, set the number of scaffolds to be displayed for collinearity, generally set the scaffold to 120)
Input:
You can copy config.ini to your working path and modify it to your own configuration information. Use -c config.ini to specify the location of the configuration parameter file,
Or directly input various parameters.

#### for Collinearity analysis
`KK4D.sh coline -c /path/to/config.ini`

#### from gff3 cds.fa  protein.fa ,get 1 or 2 species all the above information.
`KK4D.sh all -c /path/to/config.ini`

#### for A.trichopoda and M.domestica genome chromosome1 gene and protein analysis (This is for the purpose of the testing process only, the general situation is that the whole genome needs to be analyzed.)
`KK4D.sh all -group 2 -cpu 32 -key ID ID -type mRNA mRNA -sample A.trichopoda M.domestica -abbr Ath Mdo -gff3 Ath.chr1.gff3 Mdo.chr1.gff3 -protein Ath.pep.fa.gz Mdo.genome.protein.fa -cds Ath.cds.fa.gz Mdo.cds.fa -chrnum 1 1`

#### for M.domestica genome analysis 
`KK4D.sh all -group 1 -cpu 24 -key ID -type mRNA -sample M.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17`
# Warning
Please make sure that the input sequence IDs of cds.fa and protein.fa are the same.If the pep and cds file IDs you downloaded do not meet the specifications, you can use `genome2cdspep.sh` to obtain files that meet the specifications directly from the genome.
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
#### 2024.1.5 update the Version to 1.0
1. Comprehensive optimization of visual code
2. Fixed an empty file bug that would occur when the input file and KK4D output file have the same name.
3. Added example genome data
4. Updated Chinese and English instructions for use


## citations
Mao Chai. (2023). KK4D: A pipeline for analyzing collinearity, Ka, Ks, 4DTv of two genomes (V1.0). Zenodo.https://doi.org/10.5281/zenodo.8342998. 