## hcl_launcher_master.sh 

#!/bin/bash 
FILE=$1
current_path=$(pwd)
echo "Current directory is: $current_path"

# Accept ini file as a sourcable input
source $FILE 

[[ -z ${control_name+unset} ]] && echo "Variable control_name not found." && exit -1  || echo "Variable control_name found: ${control_name}."
[[ -z ${c_s1r1Fastq+unset} ]] &&  echo "Variable c_s1r1Fastq not found." && exit -1  || echo "Variable c_s1r1Fastq found: ${c_s1r1Fastq}."
[[ -z ${c_s1r2Fastq+unset} ]] &&  echo "Variable c_s1r2Fastq not found." && exit -1  || echo "Variable c_s1r2Fastq found: ${c_s1r2Fastq}."
# [[ -z ${c_s2r1Fastq+unset} ]] &&  echo "Variable c_s2r1Fastq not found." && exit -1  || echo "Variable c_s2r1Fastq found: ${c_s2r1Fastq}."
# [[ -z ${c_s2r2Fastq+unset} ]] &&  echo "Variable c_s2r2Fastq not found." && exit -1  || echo "Variable c_s2r2Fastq found: ${c_s2r2Fastq}."

[[ -z ${sample_name+unset} ]] &&  echo "Variable sample_name not found." && exit -1  || echo "Variable sample_name found: ${sample_name}."
[[ -z ${s_s1r1Fastq+unset} ]] &&  echo "Variable s_s1r1Fastq not found." && exit -1  || echo "Variable s_s1r1Fastq found: ${s_s1r1Fastq}."
[[ -z ${s_s1r2Fastq+unset} ]] &&  echo "Variable s_s1r2Fastq not found." && exit -1  || echo "Variable s_s1r2Fastq found: ${s_s1r2Fastq}."
# [[ -z ${s_s2r1Fastq+unset} ]] &&  echo "Variable s_s2r1Fastq not found." && exit -1  || echo "Variable s_s2r1Fastq found: ${s_s2r1Fastq}."
# [[ -z ${s_s2r2Fastq+unset} ]] &&  echo "Variable s_s2r2Fastq not found." && exit -1  || echo "Variable s_s2r2Fastq found: ${s_s2r2Fastq}."

[[ -z ${training+unset} ]] &&  echo "Variable training not found." && exit -1  || echo "Variable training found: ${training}."
[[ -z ${ordered_genes+unset} ]] &&  echo "Variable ordered_genes not found." && exit -1  || echo "Variable ordered_genes found: ${ordered_genes}."
[[ -z ${email+unset} ]] &&  echo "Variable email not found." && exit -1  || echo "Variable email found: ${email}."
[[ -z ${bwa_db_value+unset} ]] &&  echo "Variable bwa_db_value not found." && exit -1  || echo "Variable bwa_db_value found: ${bwa_db_value}."
[[ -z ${bowtie2_db_value+unset} ]] &&  echo "Variable bowtie2_db_value not found." && exit -1  || echo "Variable bowtie2_db_value found: ${bowtie2_db_value}."
[[ -z ${seq_db+unset} ]] &&  echo "Variable seq_db not found." && exit -1  || echo "Variable seq_db found: ${seq_db}."
[[ -z ${archive_path+unset} ]] &&  echo "Variable archive_path not found." && exit -1  || echo "Variable archive_path found: ${archive_path}."
[[ -z ${user_tmp+unset} ]] &&  echo "Variable user_tmp not found." && exit -1  || echo "Variable user_tmp found: ${user_tmp}."
[[ -z ${version+unset} ]] &&  echo "Variable version not found." && exit -1  || echo "Variable version found: ${version}."

echo "All required variables found"

chrfiles_path="$current_path/exome_contig_chr_files"
echo $chrfiles_path

tables_path="$current_path/exome_pre_loaded_tables_Chr1_Chr2"
echo $tables_path

scripts_location="$current_path/scripts"
echo $scripts_location

template_pwd="$current_path/template_trim"
echo $template_pwd

sample_path="$user_tmp"
echo $sample_path

sample_result="$current_path/$version/$sample_name"
echo $sample_result

socket_path="$sample_path/mysql/thesock"
echo $socket_path

echo "Creating scripts in $sample_path"
# ######################################################################### CREATE DIRECTORIES
mkdir -p $sample_path
mkdir -p $sample_result

# ######################################################################### 
# NOTE: You can use "sed s,find,replace,g foo.txt" instead of "sed s/find/replace/g foo.txt"
# 
# If we use "," as a separator character, we won't need to worry about escaping the forward slashes.
# in the file paths

# run_master_sample.pbs
sed -e s,sample_path,"$sample_path",g -e s,sample_name,"$sample_name",g -e s,control_name,"$control_name",g -e s,scripts_location,"$scripts_location",g \
-e s,tables_path,"$tables_path",g -e s,sample_email@umn.edu,"$email",g -e s,archive_path,"$archive_path",g -e s,sample_result,"$sample_result",g \
-e s,code_path,"$current_path",g -e s,seq_db,"$seq_db",g < "$template_pwd/run_master_sample.pbs" > "$sample_path/run_master_$sample_name.pbs"

# control_pileup_master.sh 
sed -e s,control_name,"$control_name",g -e s,c_s1r1Fastq,"$c_s1r1Fastq",g -e s,c_s1r2Fastq,"$c_s1r2Fastq ",g \
-e s,c_s2r1Fastq,"$c_s2r1Fastq",g -e s,c_s2r2Fastq,"$c_s2r2Fastq",g -e s,bwa_db_value,"$bwa_db_value",g \
-e s,bowtie2_db_value,"$bowtie2_db_value",g -e s,bwa_db_value,"$bwa_db_value",g -e s,seq_db,"$seq_db",g \
-e s,working_dir,"$sample_path",g \
-e s,scripts_location,"$scripts_location",g \
-e s,exo_chrfiles,"$chrfiles_path",g \
< "$template_pwd/control_pileup_master.sh" > "$sample_path/control_pileup.sh"

# sample_pileup_master.sh 
sed -e s,sample_name,"$sample_name",g -e s,s_s1r1Fastq,"$s_s1r1Fastq",g -e s,s_s1r2Fastq,"$s_s1r2Fastq ",g \
-e s,s_s2r1Fastq,"$s_s2r1Fastq",g -e s,s_s2r2Fastq,"$s_s2r2Fastq",g -e s,bwa_db_value,"$bwa_db_value",g \
-e s,bowtie2_db_value,"$bowtie2_db_value",g -e s,bwa_db_value,"$bwa_db_value",g -e s,seq_db,"$seq_db",g \
-e s,working_dir,"$sample_path",g \
-e s,scripts_location,"$scripts_location",g \
-e s,exo_chrfiles,"$chrfiles_path",g \
< "$template_pwd/sample_pileup_master.sh" > "$sample_path/sample_pileup.sh"


