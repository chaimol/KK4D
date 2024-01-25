#!/bin/bash

# 检测jcvi是否安装
jcvi_installed=$(python3 -m jcvi.compara.synteny screen -h)
if [ ! -z "$jcvi_installed" ]; then
    echo "jcvi check pass!"
else
    echo "jcvi not install!"
	exit 1
fi

# 检测seqkit是否安装
seqkit_installed=$(command -v seqkit)
if [ ! -z "$seqkit_installed" ]; then
    echo "seqkit check pass!"
else
    echo "seqkit not install!"
	exit 1
fi

# 检测ParaAT2.0是否安装
ParaAT_installed=$(ParaAT.pl -V)
if [ ! -z "$ParaAT_installed" ]; then
    echo "ParaAT2.0 check pass!"
else
    echo "ParaAT2.0 not install!"
	exit 1
fi

# 检测mafft是否安装
mafft_installed=$(command -v mafft)
if [ ! -z "$mafft_installed" ]; then
    echo "mafft check pass!"
else
    echo "mafft not install!"
	exit 1
fi

# 检测KaKs_Calculator2.0是否安装
KaKs_Calculator_installed=$(command -v KaKs_Calculator)
if [ ! -z "$KaKs_Calculator_installed" ]; then
    echo "KaKs_Calculator2.0 check pass!"
else
    echo "KaKs_Calculator2.0 not install!"
	exit 1
fi

#检查是否安装R语言
Rscript_installed=$(command -v R)
if [ ! -z "$Rscript_installed" ]; then
    echo "Rscript check pass!"
else
    echo "Rscript not install!
	Warning: R language not installed, unable to perform visual drawing!"
	#exit 1
fi

#所有的依赖都正确配置
if [ $? -eq 0 ];then
	echo "All require software pass the check!"
fi
