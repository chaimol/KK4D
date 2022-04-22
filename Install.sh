#请按照下面顺序安装对应的软件
#1.add path
chmod 757 calculate_4DTV_correction.pl
chmod 757 axt2one-line.py
chmod 757 KK4D.sh
chmod 757 getKaKs.sh
chmod 757 KaKs_Calculator2.0/bin/Linux/KaKs_Calculator
chmod 757 mafft/mafft
chmod 757 seqkit
chmod 757 Visual/bar2coline.R
chmod 757 Visual/drawKaKs4DTV.R
echo "export PATH=${PWD}:\$PATH" >>~/.bashrc


#2.use conda install requirement software
# conda create -n mmdetection python=3.7
# conda activate mmdetection
# conda install -y jcvi
#从V0.03版本开始，直接安装jcvi,不在使用conda安装了。
pip install jcvi
#或者直接使用pip安装jcvi也可以
#pip install jcvi
echo "export PATH=${PWD}/KaKs_Calculator2.0/bin/Linux:\$PATH" >>~/.bashrc
echo "export PATH=${PWD}/KaKs_Calculator2.0/src:\$PATH" >>~/.bashrc
echo "export PATH=${PWD}/mafft/:\$PATH" >>~/.bashrc
echo "export PATH=${PWD}/ParaAT2.0:\$PATH" >>~/.bashrc
source ~/.bashrc
