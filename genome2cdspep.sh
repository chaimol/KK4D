#!/usr/bin/env bash
#从基因组文件和gff3文件提取cds和pep文件
if [ "$#" -lt 3 ]; then
    echo "
from genome get cds and pep file. 
Usage: $0 <genome> <gff3> <abbr> [str]"
    exit 1
fi
path1="$(cd "$(dirname ${BASH_SOURCE[0]})";pwd)"
genome="$1"
gff3="$2"
abbr="$3"
str="$4"

if [ -z "$str" ]; then
    str="."
fi

gffread "${gff3}" -g "${genome}" -x "${abbr}.cds.fa" -y "${abbr}.pep.fa"

#获取每个基因最长的转录本，最后的参数str默认是.,即区分不同转录本的分隔符
python3 ${path1}/getLongerSequences.py "${abbr}.cds.fa" "${abbr}.cds" "${str}"
python3 ${path1}/getLongerSequences.py "${abbr}.pep.fa" "${abbr}.pep" "${str}"
