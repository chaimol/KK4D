# require software list
### provid binary software list
- [seqkit](https://github.com/shenwei356/seqkit)
- [maff](thttps://mafft.cbrc.jp/alignment/software/)
- [KaKs_Calculator 2.0](https://sourceforge.net/projects/kakscalculator2/)
- ParaAT2.0

### Must be install software by yourself
- [jcvi](https://github.com/tanghaibao/jcvi)
- Rscript
- Python3

If your input is genome.fa and genome.gff3, you need to run genome2cdspep.sh first. This script relies on [gffread](https://github.com/gpertea/gffread)

### Check whether dependent software has been successfully installed or configured
```
bash check_ENV.sh
```
- If the last line of output is **All require software pass the check!**, it means that all dependent software has been installed.
- If there is an error message in the output, please install the corresponding dependent software.
