#!/usr/bin/bash
#用于获取脚本所在的路径，保存为变量path1,调用其他脚本都依赖这个路径。
path1="$(cd "$(dirname ${BASH_SOURCE[0]})";pwd)"
#此程序是主程序，运行此程序会调用其他脚本。

#########################################Copyright & Version info#########################################################
##Builder Info
Author="Mol Chai"
Version="V0.04"
Builddate="2022-04-22"
Email="chaimol@163.com"
Github="https://www.github.com/chaimol/"

#读取用户输入的参数
while [ -n "$1" ];
	do
		case $1 in
		-h|--help)
	echo -e "
	Usage: 
	
	运行方式有2种，指定config.ini的位置运行，或者是直接输入每个参数运行。
	输入的fa文件和gff3文件可以是普通文件，也可以是gz压缩文件。
	KK4D.sh all -c config.ini #指定config.ini的位置运行
	KK4D.sh all -group 2 -cpu 32 -key ID ID -type mRNA mRNA -sample A.trichopoda M.domestica -abbr Ath Mdo -gff3 Ath.chr1.gff3 Mdo.chr1.gff3 -protein Ath.pep.fa.gz Mdo.genome.protein.fa -cds Ath.cds.fa.gz Mdo.cds.fa -chrnum 1 1
	KK4D.sh all -group 1 -cpu 24 -key ID -type mRNA -sample M.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17 
	KK4D.sh coline -group 1 -key ID -type mRNA -sample M.domestica -abbr Mdo -gff3 gene_models_20170612.gff3.gz -protein /share/home/Mdo.pep.fa -cds /share/home/Mdo.cds.fa -chrnum 17 
	
	#控制命令参数（默认是：all）
	bed
	cds
	pep
	coline
	kaks
	all
	
	#指定输出文件夹
	-wd|-workpath 默认：是当前所在的路径
	
	#使用config.ini文件参数输入参数
	-c|-config config.ini文件的路径，使用config.ini来输入参数
	
	#输入文件参数(-g|-group参数一定要在最前面)
	-g|-group 样本组数，只能是1或2，应该和输入的参数的数目一致。否则会出错。
	-cpu|-threads cpu/进程数量，默认使用24个cpu
	-k|-key gff3文件的第9列的值,一般是ID
	-t|-type gff3文件的第3列的字符，一般是gene或mRNA
	-s|-sample 物种的拉丁学名
	-a|-abbr 物种3字符缩写
	-gf|-gff3 gff3文件，可以是gff3或gff3.gz
	-p|-protein 蛋白文件，可以是fa或fa.gz
	-cd|-cds CDS序列，可以是fa或fa.gz
	-chrn|-chrnum 染色体的数量（如果是scaffold，则设置共线性需要展示的scaffold的数量，一般scaffold设置为120）
	"
			exit 0
			;;
		-V|--version)
			echo -e "
			Version:${Version}\n
			Author:${Author} \n
			Email:${Email} \n
			Github:${Github} \n
			Builddate:${Builddate}
			"
			exit 0
			;;
		bed)
		mode="runbed"
		;;
		cds)
		mode="runcds"
		;;
		pep)
		mode="runpep"
		;;
		coline)
		mode="runcoline"
		;;
		kaks|KaKs)
		mode="runKaKs"
		;;
		4DTv|4DTV)
		mode="run4DTV"
		;;
		all|All)
		mode="runAll"
		;;
		-wd|-workpath)
			WorkPath=$2
			shift
			;;
		-c|-config)
			configfile=`readlink -f $2` #读取config.ini的绝对路径
			shift
			;;
		-cpu|-threads)
			threads=$2
			shift
			;;
		-g|-group)
			group=$2
			if [ $group -ne 1 ] && [ $group -ne 2 ];then
				echo "ERROR: input the group neither 1 nor 2!"
				exit 1
			fi
			shift
			;;
		-k|-key)
			if [ $group -eq 1 ];then 
				key=$2
				shift
			else
				key=($2 $3)
				shift 2
			fi
			;;
		-t|-type)
			if [ $group -eq 1 ];then 
				type=$2
				shift
			else
				type=($2 $3)
				shift 2
			fi
			;;
		-s|-sample)
			if [ $group -eq 1 ];then 
				sample=$2
				shift
			else
				sample=($2 $3)
				shift 2
			fi
			;;
		-a|-abbr)
			if [ $group -eq 1 ];then 
				abbr=$2
				shift
			else
				abbr=($2 $3)
				shift 2
			fi
			;;
		-gf|-gff3)
			if [ $group -eq 1 ];then 
				gff3=$2
				shift
			else
				gff3=($2 $3)
				shift 2
			fi
			;;
		-cd|-cds)
			if [ $group -eq 1 ];then 
				cds=$2
				shift
			else
				cds=($2 $3)
				shift 2
			fi
			;;
		-p|-protein)
			if [ $group -eq 1 ];then 
				protein=$2
				shift
			else
				protein=($2 $3)
				shift 2
			fi
			;;
		-chrn|-chrnum)
			chrnum=$2
			if [ $group -eq 1 ];then 
				chrnum=$2
				shift
			else
				chrnum=($2 $3)
				shift 2
			fi
			;;
			*)
			echo "use -h for help!"
			exit 1
			;;
		esac
		shift
done

#如果存在configfile，则直接使用configfile里的参数
if ! [ -z $configfile ];then 
source ${configfile} #配置文件
fi

##配置全局变量
if [ ${group} -eq 2 ];then
	prefix1=${abbr[0]}
	prefix2=${abbr[1]}
	gff3file1=${gff3[0]}
	gff3file2=${gff3[1]}
	latin1=${sample[0]}
	latin2=${sample[1]}
	protein1=${protein[0]}
	protein2=${protein[1]}
	cds1=${cds[0]}
	cds2=${cds[1]}
	key1=${key[0]}
	key2=${key[1]}
	type1=${type[0]}
	type2=${type[1]}
	chrnum1=${chrnum[0]}
	chrnum2=${chrnum[1]}
else
	prefix1=${abbr[0]}
	gff3file1=${gff3[0]}
	latin1=${sample[0]}
	protein1=${protein[0]}
	cds1=${cds[0]}
	key1=${key[0]}
	type1=${type[0]}
	chrnum1=${chrnum[0]}
	prefix2=${abbr[0]}
	gff3file2=${gff3[0]}
	latin2=${sample[0]}
	protein2=${protein[0]}
	cds2=${cds[0]}
	key2=${key[0]}
	type2=${type[0]}
	chrnum2=${chrnum[0]}
fi

#如果threads是空值则执行下面的命令
if [ -z ${threads} ];then
	threads=24 #默认使用24个cpu.
fi

if [ -z ${WorkPath} ];then
	WorkPath=`pwd` #默认输出路径是当前工作路径
fi

if [ -z ${mode} ];then
	mode="runAll" #默认运行命令分析所有
fi

if [ -z ${prefix2} ] || [ -z ${gff3file2} ] || [ -z ${latin2} ] || [ -z ${protein2} ] || [ -z ${cds2} ] || [ -z ${key2} ] || [ -z ${type2} ] || [ -z ${chrnum2} ];then
	echo "Error:please check the input parameter !"
	exit 1
fi

source ${path1}/getKaKs.sh #函数定义脚本
cd ${WorkPath} #进入工作路径

#V0.03版本开始不再依赖conda了，如果还想继续使用conda,把下面的这几行注释掉的删除#即可恢复使用conda
	#激活conda环境(shell脚本里，激活conda比较麻烦，需要先source)
	# condapath=`conda info | grep 'base environment'|cut -d : -f2|cut -d " " -f2`
	# source ${condapath}/etc/profile.d/conda.sh
	# conda deactivate
	# conda activate mmdetection
	#检测用户的输入文件是否存在
if [ -e $gff3file1 ] && [ -e $cds1 ] && [ -e $protein1 ] && [ -e $gff3file2 ] && [ -e $cds2 ] && [ -e $protein2 ];then
	#echo "Please check the input file path or make sure the file is exist !"
	echo "Pass the file check !"
else
	echo "May be you are run not from the first step!"
fi


function runbed(){
	echo "Begin run analysis of bed in `date '+%Y-%m-%d %H:%M:%S'`"
	#先从gff3获取bed
	if [ $group -eq 2 ];then
		getbed $gff3file1 $prefix1 $type1 $key1
		getbed $gff3file2 $prefix2 $type2 $key2
	else
		getbed $gff3file1 $prefix1 $type1 $key1
	fi
	echo "End run analysis of bed in `date '+%Y-%m-%d %H:%M:%S'`"
}

function runcds(){
	#先判断是否存在bed，否，则运行bed
	if [ ! -e $prefix1.bed ];then
		runbed
	fi
	#开始cds
	echo "Begin run analysis of cds in `date '+%Y-%m-%d %H:%M:%S'`"
	if [ $group -eq 2 ];then
		getcds $cds1 $prefix1
		getcds $cds2 $prefix2
	else 
		getcds $cds1 $prefix1
	fi
	echo "End run analysis of cds in `date '+%Y-%m-%d %H:%M:%S'`"	
}

function runpep(){
	#先判断是否存在bed，否，则运行bed
	if [ ! -e $prefix1.bed ];then
		runbed
	fi
	#再运行pep
	echo "Begin run analysis of pep in `date '+%Y-%m-%d %H:%M:%S'`"
	if [ $group -eq 2 ];then
		getpep $protein1 $prefix1
		getpep $protein2 $prefix2
	else 
		getpep $protein1 $prefix1
	fi
	echo "End run analysis of pep in `date '+%Y-%m-%d %H:%M:%S'`"
}

function runcoline(){
	#先判断是否存在cds，否，则运行cds
	if [ ! -e $prefix1.cds ];then
		runcds
	fi
	#先判断是否存在pep，否，则运行pep
	if [ ! -e $prefix1.pep ];then
		runpep
	fi
	#判断之前运行是否有错误。如果没有错误，则后续出错的概率比较低。
	if [ ! $? -eq 0 ];then
		echo "There is an ERROR before run getcoline!"
		exit 1
	fi
	echo "Begin run analysis of coline in `date '+%Y-%m-%d %H:%M:%S'`"
	# if [ $group -eq 2 ];then
		getcoline $prefix1 $prefix2
		#可视化，可能会失败。jcvi绘制共线性
		VisualColine $prefix1 $prefix2 $chrnum1 $chrnum2
		#R绘制barplot的共线性，倒换参数4,5的顺序，可以互换出图的上下位置
		Rscript ${path1}/Visual/bar2coline.R ${prefix1}.${prefix2}.gff ${prefix1}.${prefix2}.bar.coline ${prefix1} ${prefix2} ${WorkPath}
		Rscript ${path1}/Visual/bar2coline.R ${prefix1}.${prefix2}.gff ${prefix1}.${prefix2}.bar.coline ${prefix2} ${prefix1} ${WorkPath}
		Rscript ${path1}/Visual/sankey2coline.R ${prefix1}.coline.gff ${prefix2}.coline.gff ${prefix1}.${prefix2}.bar.coline ${latin1} ${latin2} ${WorkPath}
	# else 
		# getcoline $prefix1 $prefix1
	# fi
	echo "End run analysis of coline in `date '+%Y-%m-%d %H:%M:%S'`"
}

function runprepare(){
	#先判断是否存在共线性文件，否，则运行coline
	if [ ! -e ${prefix1}.${prefix2}.anchors ];then
		runcoline
	fi
	echo "Begin analysis of prepareResult in `date '+%Y-%m-%d %H:%M:%S'`"
	prepareResult $prefix1 $prefix2 $threads
	echo "End analysis of prepareResult in `date '+%Y-%m-%d %H:%M:%S'`"
}

function run4DTV(){
	#判断是否已经生成上一步的输出文件夹result_dir
	if [ ! -d ${prefix1}_${prefix2}.result_dir ];then
		runprepare
	fi
	echo "Begin analysis of 4DTv in `date '+%Y-%m-%d %H:%M:%S'`"
	get4DTv $prefix1 $prefix2
	Rscript ${path1}/Visual/drawKaKs4DTV.R ${prefix1} ${prefix1}.${prefix2}.config.tsv ${PWD} 4DTv
	echo "End analysis of 4DTv in `date '+%Y-%m-%d %H:%M:%S'`"
}

function runKaKs(){
	#判断是否已经生成上一步的输出文件夹result_dir
	if [ ! -d ${prefix1}_${prefix2}.result_dir ];then
		runprepare
	fi
	echo "Begin run analysis of KaKS in `date '+%Y-%m-%d %H:%M:%S'`"
	getkaks $prefix1 $prefix2
	Rscript ${path1}/Visual/drawKaKs4DTV.R ${prefix1} ${prefix1}.${prefix2}.config.tsv ${PWD} KaKs
	echo "End run analysis of KaKS in `date '+%Y-%m-%d %H:%M:%S'`"
}

function runAll(){

	#判断是否已经生成上一步的输出文件kaks
	if [ ! -e ${prefix1}_${prefix2}.all-kaks.results ];then
		runKaKs
	fi
	#判断是否已经生成上一步的输出文件4dtv
	if [ ! -e ${abbr1}_${abbr2}.all-4dtv.results ];then
		run4DTV
	fi
	echo "Begin run analysis of All begin in `date '+%Y-%m-%d %H:%M:%S'`"
	getkaks4DTv $prefix1 $prefix2
	Rscript ${path1}/Visual/drawKaKs4DTV.R ${prefix2} ${prefix1}.${prefix2}.config.tsv ${PWD} both
	echo "End run analysis of All in `date '+%Y-%m-%d %H:%M:%S'`"
}

#执行分析
${mode}
