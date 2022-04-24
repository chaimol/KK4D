#!/usr/bin/env python3
#此脚本用于从基因组的蛋白质或CDS文件中，找出每个基因最长的转录本
import sys
if len(sys.argv) < 3:
    print('usage:\n python3 getLongerSequences.py input_fafile output_fafile split_string')#输入参数：输入fa文件，输出fa文件，序列id的最后的分割字符（一般是.）
    sys.exit()
def removeRedundant(in_file,out_file,split_str):
    gene_dic = {}
    flag = ''
    with open (in_file) as in_fasta:
        for line in in_fasta:
            if '>' in line:
                line1 = line.strip('>\n')
                line2 = line1.split(split_str)
                if len(line2) > 1:
                    line2.pop(-1)#删除分隔符后最后一组文本
                    li = split_str.join(line2)#使用分隔符拼接字符串
                    flag = li
                else:
                    li = line2[0]#使用分隔符拼接字符串
                    flag = li
                try:
                    gene_dic[li]
                except KeyError:
                    gene_dic[li] = [line]
                else:
                    gene_dic[li].append(line)
            else:
                gene_dic[flag][-1] += line
    with open (out_file,'w') as out_fasta:
        for k,v in gene_dic.items():
            if len(v) == 1:
                out_fasta.write(gene_dic[k][0])
            else:
                trans_max = ''
                for trans in gene_dic[k]:
                    a = len(list(trans))
                    b = len(list(trans_max))
                    if a > b:
                        trans_max = trans
                out_fasta.write(trans_max)
in_file=sys.argv[1]
out_file=sys.argv[2]
split_str=sys.argv[3]
removeRedundant(in_file,out_file,split_str)
