#!/usr/bin/bash
####此程序是函数定义脚本。主运行脚本是run.sh

##读取配置文件
#source config.ini
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

##获取输入文件

#test.cds #每个基因最长的转录本的DNA序列
#test.pep #每个基因最长的蛋白序列


#从gff3文件获取bed,用法：getbed gff3file output前缀 第三列的type 第9列的前缀字符
function getbed(){
	if [ $# -lt 2 ];then
		echo "usage:
		getbed inputgff3 outputprefix type key
		
		inputgff3 can be gff3 or gff3.gz .(Required)
		
		outputprefix is the output file prefix.Preferably a 3-character abbr.(Required)
		
		type is gfffile the 3rd cloumn string (Value:mRNA ,gene or other,Default:mRNA) 
		
		key is gfffile the Prefix for column 9.(Value:ID or other,Default:ID)
		"
		exit 1
	else
		inputgff3=$1
		prefix=$2
		if [ $# -eq 3 ];then
			type=$3
		elif [ $# -eq 4 ];then
			type=$3
			key=$4
		else
			echo "Usage: -h /-help "
			exit 1
		fi
	fi
	python3 -m jcvi.formats.gff bed --type=${type:=mRNA} --key=${key:=ID} ${inputgff3} -o ${prefix}.bed
	python3 -m jcvi.formats.bed uniq ${prefix}.bed
	mv ${prefix}.uniq.bed ${prefix}.bed
}


function getcds(){
	if [ $# -lt 2 ];then
		echo "usage:
		getbed input_cdsfa prefix 
		input_cdsfa can be fa or fa.gz .(Required)
		prefix is the input bed file prefix.Preferably a 3-character abbr.(Required)
		"
		exit 1
	else
		input_cdsfa=$1
		prefix=$2
	fi
	seqkit grep -f <(cut -f4 ${prefix}.bed) ${input_cdsfa} | seqkit seq -i >${prefix}.cds
}

function getpep(){
	if [ $# -lt 2 ];then
		echo "usage:
		getbed input_proteinfa prefix 
		input_proteinfa can be fa or fa.gz .(Required)
		prefix is the input bed file prefix.Preferably a 3-character abbr.(Required)
		"
		exit 1
	else
		input_proteinfa=$1
		prefix=$2
	fi
	seqkit grep -f <(cut -f4 ${prefix}.bed) ${input_proteinfa}  | seqkit seq -i >${prefix}.pep
}


function getcoline(){
	if [ $# -lt 2 ];then
		echo "usage:
		getcoline abbr1 abbr2 
		"
		exit 1
	fi
	species1="$1"
	species2="$2"
	## 运行代码
	python3 -m jcvi.compara.catalog ortholog --dbtype prot --no_strip_names $species1 $species2
	python3 -m jcvi.compara.synteny screen --minspan=30 --simple $species1.$species2.anchors $species1.$species2.anchors.new
	#绘制dotplot的共线性文件
	python3 -m jcvi.graphics.dotplot $species1.$species2.anchors --nosep --nochpf --colororientation --dpi=300 --font=Arial -o ${species1}.${species2}.dotplot.pdf
}

function VisualColine(){
	if [ $# -lt 2 ];then
		echo "usage:
		VisualColine abbr1 abbr2 chrnum1 chrnum2
		"
		exit 1
	fi
	abbr1=$1
	abbr2=$2
	chrnum1=$3
	chrnum2=$4
	##可视化
	#使用awk对bed文件的第3列挑选每条染色体上最大的基因的位置，然后根据长度倒序排序染色体，选择出最长的n条染色体，然后再按照字母顺序排序染色体，最后把行转为一列，并用逗号分割。
	awk '{if($3 > max[$1]) max[$1] = $3} END{for(key in max) print key, max[key]}' $abbr1.bed|sort -rn -k2|head -$chrnum1|sort|cut -d " " -f1|tr "\n" ","|sed 's/,$/\n/' >$abbr1.ids	
	#cat $abbr1.bed|cut -f1|sort |uniq |head -$chrnum1 |rev|cut -d " " -f1cut -d " " -f1|rev >$abbr1.id
	#cat $abbr1.id|awk 'BEGIN{c=0;} {for(i=1;i<=NF;i++) {num[c,i] = $i;} c++;} END{ for(i=1;i<=NF;i++){str=""; for(j=0;j<NR;j++){ if(j>0){str = str","} str= str""num[j,i]}printf("%s\n", str)} }' >$abbr1.ids
	awk '{if($3 > max[$1]) max[$1] = $3} END{for(key in max) print key, max[key]}' $abbr2.bed|sort -rn -k2|head -$chrnum2|sort|cut -d " " -f1|tr "\n" ","|sed 's/,$/\n/' >$abbr2.ids
	#cat $abbr2.bed|cut -f1|sort |uniq |head -$chrnum2 |rev|cut -d " " -f1|rev >$abbr2.id
	#cat $abbr2.id|awk 'BEGIN{c=0;} {for(i=1;i<=NF;i++) {num[c,i] = $i;} c++;} END{ for(i=1;i<=NF;i++){str=""; for(j=0;j<NR;j++){ if(j>0){str = str","} str= str""num[j,i]}printf("%s\n", str)} }' >$abbr2.ids
	cat $abbr1.ids $abbr2.ids >${abbr1}.${abbr2}.seqids
	
	# 设置颜色，长宽等,注意下面的代码一定不能修改缩进，否则后续就会报错，python3严格依赖缩进
echo -e '# y, xstart, xend, rotation, color, label, va, bed
 .6,    .1,    .8,    0,    red,    latin1,    top,     abbr1.bed
 .4,    .1,    .8,    0,    blue,    latin2,    top,    abbr2.bed
# edges
e, 0, 1, abbr1.abbr2.anchors.simple' >${abbr1}.${abbr2}.layout
	sed -i "s/abbr1/${abbr1}/g;s/abbr2/${abbr2}/g;s/latin1/${latin1}/g;s/latin2/${latin2}/g;" ${abbr1}.${abbr2}.layout
	#生成共线性图片，很可能运行失败。注意：修改layout的细节就好，python3对文件要求比较严格。
	python3 -m jcvi.graphics.karyotype ${abbr1}.${abbr2}.seqids ${abbr1}.${abbr2}.layout --font=Arial 
	#输出的是基于块的共线性
	mv karyotype.pdf ${abbr1}_${abbr2}.block.coline.pdf
	echo "${abbr1}_${abbr2}.block.coline.pdf is the coline picture!"
	
	#输出的是具体的基因对的共线性
	cat ${abbr1}.${abbr2}.anchors|grep -v ^#|awk '{print $1"\t"$1"\t"$2"\t"$2"\t"$3"\t""+"}' >${abbr1}.${abbr2}.anchors.sample
	sed -i 's/simple/sample/g' ${abbr1}.${abbr2}.layout
	python3 -m jcvi.graphics.karyotype ${abbr1}.${abbr2}.seqids ${abbr1}.${abbr2}.layout --font=Arial --nocircles 
	#输出的是基于块的共线性
	mv karyotype.pdf ${abbr1}_${abbr2}.gene.coline.pdf
	echo "${abbr1}_${abbr2}.gene.coline.pdf is the coline picture!"
	
	#准备barplot和sankey的绘图数据
	cat <(awk '{print $1,$4,$2,$3}' ${abbr1}.bed|sed "s/^/${abbr1}/g") <(awk '{print $1,$4,$2,$3}' ${abbr2}.bed|sed "s/^/${abbr2}/g") |tr " " "\t" >${abbr1}.${abbr2}.gff
	grep -f <(sed "s/^/${abbr1}/g" ${abbr1}.ids) ${abbr1}.${abbr2}.gff >${abbr1}.coline.gff
	grep -f <(sed "s/^/${abbr2}/g" ${abbr2}.ids) ${abbr1}.${abbr2}.gff >${abbr2}.coline.gff
	cat ${abbr1}.coline.gff ${abbr2}.coline.gff >${abbr1}.${abbr2}.gff
	grep -v ^# ${abbr1}.${abbr2}.anchors|cut -f1-2 >${abbr1}.${abbr2}.bar.coline
}

#准备kaks和4DTv的文件
function prepareResult(){
	if [ $# -lt 2 ];then
		echo "Usage:prepareResult abbr1 abbr2 threads 
		threads should be a number 32 or 64 or other
		"
		exit 1
	elif [ $# -eq 2 ];then
		abbr1=$1
		abbr2=$2
	else
		abbr1=$1
		abbr2=$2
		thread=$3
	fi
	#判断旧版本的输出目录是否存在
	if [ -d ${abbr1}_${abbr2}.result_dir ];then
		read -p "The fold ${abbr1}_${abbr2}.result_dir is exist.Delete the old version ?(Y/N):" -n 1 answer
		case $answer in
			Y|y)
				echo -e "\n ok!Delete the fold ${abbr1}_${abbr2}.result_dir！"
				;;
			N|n)
				echo -e "\n The old version will be rename ${abbr1}_${abbr2}.result_dir.old!"
				mv ${abbr1}_${abbr2}.result_dir ${abbr1}_${abbr2}.result_dir.old
				;;
			*)
				echo -e "\n The old version will be rename ${abbr1}_${abbr2}.result_dir.old!"
				mv ${abbr1}_${abbr2}.result_dir ${abbr1}_${abbr2}.result_dir.old
				;;
		esac
	fi
	echo ${thread:=32} >${abbr1}.${abbr2}.proc
	cat ${abbr1}.${abbr2}.anchors|grep -v ^#|cut -f 1-2 >${abbr1}_${abbr2}.homolog
	cat ${abbr1}.cds ${abbr2}.cds >${abbr1}_${abbr2}.cds
	cat ${abbr1}.pep ${abbr2}.pep >${abbr1}_${abbr2}.pep
	#此程序需要依赖较多
	ParaAT.pl -h ${abbr1}_${abbr2}.homolog -n ${abbr1}_${abbr2}.cds -a ${abbr1}_${abbr2}.pep -p ${abbr1}.${abbr2}.proc -m mafft -f axt -g -k -o ${abbr1}_${abbr2}.result_dir
	#制作可视化的config文件
	echo -e "${abbr1}\t${latin1}\n${abbr2}\t${latin2}" >${abbr1}.${abbr2}.config.tsv
}

#输出结果在result_dir目录
function getkaks(){
	if [ $# -lt 2 ];then
		echo "usage:
		getkaks abbr1 abbr2
		"
		exit 1
	fi
	abbr1=$1
	abbr2=$2
	#判断是否存在result_dir,不存在则需要先运行prepareResult
	if [ ! -d ${abbr1}_${abbr2}.result_dir ];then
		echo "请先运行prepareResult函数，以生成准备文件!"
		exit 1
	fi
	#合并所有同源基因对的kaks值
	find ${abbr1}_${abbr2}.result_dir -name "*.axt.kaks"|xargs cat | cut -f 1,3,4,5 | grep -v 'Sequence'|sort|uniq >${abbr1}_${abbr2}.all-kaks.results
	cat ${abbr1}_${abbr2}.all-kaks.results|sed '1i\Seq\tKa\tKs\tKa/Ks'|tr "\t" "," >${abbr1}_${abbr2}.all-kaks.csv
}

function get4DTv(){
	if [ $# -lt 2 ];then
		echo "usage:
		get4DTv abbr1 abbr2
		"
		exit 1
	fi
	abbr1=$1
	abbr2=$2
	#判断是否存在result_dir,不存在则需要先运行prepareResult
	if [ ! -d ${abbr1}_${abbr2}.result_dir ];then
		echo "请先运行prepareResult函数，以生成准备文件!"
		exit 1
	fi
	##获取4DTv的值
	#将多行axt文件转换成单行
	for i in `find ${abbr1}_${abbr2}.result_dir -name "*.axt"`;do axt2one-line.py $i ${i}.one-line;done
	#使用calculate_4DTV_correction.pl脚本计算4dtv值
	find ${abbr1}_${abbr2}.result_dir -name "*.axt.one-line"|while read id;do calculate_4DTV_correction.pl $id >${id%%one-line}4dtv;done
	#合并所有同源基因对的4dtv
	find ${abbr1}_${abbr2}.result_dir -name "*.4dtv" |xargs cat| cut -f 1,3| grep -v '4dtv_raw'|sort|uniq >${abbr1}_${abbr2}.all-4dtv.results
	cat ${abbr1}_${abbr2}.all-4dtv.results| sed '1i\Seq\t4dtv_corrected'|tr "\t" "," >${abbr1}_${abbr2}.all-4dtv.csv
}

function getkaks4DTv(){
	if [ $# -lt 2 ];then
		echo "usage:
		getkaks4DTv abbr1 abbr2
		"
		exit 1
	fi
	abbr1=$1
	abbr2=$2
	#判断是否存在result_dir,不存在则需要先运行prepareResult
	if [ ! -e ${abbr1}_${abbr2}.all-4dtv.results ];then
		echo "请先运行get4DTv函数，以生成4DTv!"
		exit 1
	fi
	if [ ! -e ${abbr1}_${abbr2}.all-kaks.results ];then
		echo "请先运行getkaks函数，以生成kaks!"
		exit 1
	fi
	#将kaks结果和4Dtv结果合并
	join -a 1 -a 2 -1 1 -2 1 ${abbr1}_${abbr2}.all-4dtv.results ${abbr1}_${abbr2}.all-kaks.results |sed '1i\Seq 4dtv_corrected Ka Ks Ka/Ks' >${abbr1}_${abbr2}.all-results.txt
	#给结果文件添加标题
	cat ${abbr1}_${abbr2}.all-results.txt|sed 's/ /,/g'   >${abbr1}_${abbr2}.kaks4DTv.csv
}
