#!/bin/bash

# module load parallel

c_S1_R1=c_s1r1Fastq
c_S1_R2=c_s1r2Fastq

orig_c1_R1=c_s1r1Fastq
orig_c1_R2=c_s1r2Fastq

# Check to see if fastq files are compressed. If they are
# uncompress them into the working directory
#
# NOTE: The copying in the ELSE clause is not necessary. The files should be readable from data release. However, 
# there are instances where files permission are not set properly and user is unable to read files from data release. 
# This copying is a precautionary measure to make sure the program does not break if that happens. 

chrfiles_path=exo_chrfiles
script_path=scripts_location
WORKING_PATH=working_dir
BWA_DB=bwa_db_value
BOWTIE2_DB=bowtie2_db_value
S_DB=seq_db
ref=/panfs/roc/rissdb/genomes/Homo_sapiens/hg19_canonical/seq/hg19_canonical.fa

BASECOUNT=25000000
CUTOFF_VALUE=30000000
num=0

readcount=$(zcat ${orig_c1_R1} | awk 'NR%4==1' | wc -l)
echo "control sample read count: $readcount"
g=$(echo "$readcount > $CUTOFF_VALUE" | bc -l)
if [ ${g} -gt ${num} ]; then
## down sample here before mapping
chmod ug+rwx $script_path/seqtk
$script_path/seqtk sample -s100 ${orig_c1_R1} 25000000 > ${WORKING_PATH}/control_R1_sub1.fastq
$script_path/seqtk sample -s100 ${orig_c1_R2} 25000000 > ${WORKING_PATH}/control_R2_sub2.fastq
c_S1_R1=${WORKING_PATH}/control_R1_sub1.fastq
c_S1_R2=${WORKING_PATH}/control_R2_sub2.fastq
else
 echo "No down sampling needed for control fastqs"
fi

bwacommand="bwa mem -M -t 24 $BWA_DB $c_S1_R1 $c_S1_R2 | samtools view -q 10 -bS - > c_bwa.bam"
btcommand="bowtie2 -p 24 -k 5 -x $BOWTIE2_DB -1 $c_S1_R1 -2 $c_S1_R2 | samtools view -q 10 -bS - > c_bowtie2.bam"

echo ${bwacommand} > $WORKING_PATH/aligncommands
echo ${btcommand} >> $WORKING_PATH/aligncommands
cat ${WORKING_PATH}/aligncommands | parallel -j +0

#mkdir /mnt/tmp/tso_launcher_v3.0.0/javatmp2
#   echo "mkdir javatmp2 done"
   
#set _JAVA_OPTIONS=-Djava.io.tmpdir=/mnt/tmp/tso_launcher_v3.0.0/javatmp

export _JAVA_OPTIONS='-Djava.io.tmpdir=/mnt/tmp/tso_launcher_v3.0.0/javatmp'

java -Xmx4g -Djava.io.tmpdir=/mnt/tmp/tso_launcher_v3.0.0/javatmp -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=c_bwa.bam OUTPUT=c_bwa.fixed.bam
picard1="java -Xmx4g -Djava.io.tmpdir=/mnt/tmp/tso_launcher_v3.0.0/javatmp -jar  $CLASSPATH/picard.jar MarkDuplicates REMOVE_DUPLICATES=true ASSUME_SORTED=true METRICS_FILE=c_bwa_duplicate_stats.txt INPUT=c_bwa.fixed.bam OUTPUT=c_bwa.fixed_nodup.bam"
picard2="java -Xmx4g -Djava.io.tmpdir=/mnt/tmp/tso_launcher_v3.0.0/javatmp -jar  $CLASSPATH/picard.jar FixMateInformation SORT_ORDER=coordinate INPUT=c_bowtie2.bam OUTPUT=c_bowtie2.fixed.bam"

echo ${picard1} > $WORKING_PATH/cpicardcommands
echo ${picard2} >> $WORKING_PATH/cpicardcommands
cat ${WORKING_PATH}/cpicardcommands | parallel -j +0

 indexcomm1="samtools index c_bwa.fixed.bam"
 indexcomm2="samtools index c_bwa.fixed_nodup.bam"
 indexcomm3="samtools index c_bowtie2.fixed.bam"
 echo ${indexcomm1} > $WORKING_PATH/indexcommands
 echo ${indexcomm2} >> $WORKING_PATH/indexcommands
 echo ${indexcomm3} >> $WORKING_PATH/indexcommands
 cat ${WORKING_PATH}/indexcommands | parallel -j 3
