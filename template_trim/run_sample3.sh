#!/bin/bash                             
ulimit -u
echo "Run Group 3 called"

working_dir=sample_path
script_path=scripts_location
table_path=tables_path
MYSQL_LOAD_WAIT=120
code_src=code_path

base_dir=$(dirname "${working_dir}")
echo $base_dir
BASE=$base_dir/mysql
echo $BASE
mysql_socket=$BASE/thesock
echo $mysql_socket

cd $working_dir

#module load parallel
#module load R/3.1.1
#module load bedtools/2.25.0/bin/bedtools
#module load python/2.7.5
#PYTHONPATH=/soft/python/2.7.1/lib/python2.7/site-packages
#export PYTHONPATH=/soft/python/2.7.5/lib/python2.7/site-packages:$PYTHONPATH
#LD_LIBRARY_PATH=/soft/python/2.7.1/lib
#export LD_LIBRARY_PATH=/soft/python/2.7.5/lib:$LD_LIBRARY_PATH

_now=$(date +"%Y-%m-%d_%H-%M")


ls -1 $working_dir/reference_genes_file > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "$working_dir/reference_genes_file exists"
 else
        echo "chr15:48773651-48774177 FBN1" >> ${working_dir}/reference_genes_file
        echo "chr9:132584659-132585325 TOR1A" >> ${working_dir}/reference_genes_file
        echo "chr17:7573726-7574233 TP53" >> ${working_dir}/reference_genes_file      
fi

ls -1 $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "$working_dir/completed.txt exists"
else
    echo "Started a new run on $_now" >> $working_dir/completed.txt
fi

echo ${_now} >> $working_dir/time_check
timecheck=`(date +"Date: %Y-%m-%d Time %H:%M:%S")`;
# echo ${timecheck} >> $working_dir/time_check


grep "control_pileup.sh" $working_dir/completed.txt > /dev/null 2>&1
 if [ "$?" = "0" ]; then
     echo "control_pileup.sh already run"
 else
     echo "Run control_pileup.sh"
     sh control_pileup.sh
     if [[ $? -ne 0 ]] ; then
         echo "Run control_pileup.sh failed" >&2
         exit 1
     else
         echo "g3 control_pileup.sh done"
         echo "control_pileup.sh" >> $working_dir/completed.txt
     fi
 fi
 
 echo -n "Finished control_pileup " >> $working_dir/time_check
 timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
 echo ${timecheck} >> $working_dir/time_check
 
 # Generate pileups for sample
 grep "sample_pileup.sh" $working_dir/completed.txt > /dev/null 2>&1
 if [ "$?" = "0" ]; then
     echo "sample_pileup.sh already run"
 else
     echo "Run sample_pileup.sh"
     sh sample_pileup.sh
     if [[ $? -ne 0 ]] ; then
 	echo "Run sample_pileup.sh failed" >&2
 	exit 1
     else
        echo "g3 sample_pileup.sh done"
 	echo "sample_pileup.sh" >> $working_dir/completed.txt
     fi
 fi
 
 echo -n "Finished sample_pileup " >> $working_dir/time_check
 timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
 echo ${timecheck} >> $working_dir/time_check
 
# 
# grep "base_tables_loaded" $working_dir/completed.txt > /dev/null 2>&1
# if [ "$?" = "0" ]; then
#     echo "base tables already loaded"
# else
   # CREATE DATABASE
 #   mysql --socket=$BASE/thesock -u root -e "CREATE DATABASE cnv3;"
     
  #   echo "Load tables"
    # find $table_path -name "*.sql" | xargs -I {} -n 1 -P 24 sh -c "mysql --socket=$BASE/thesock -u root cnv3 < \"{}\" "
  
  
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/training_data_2016_07.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_data.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_exon_60bp_segments_main_data.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_exon_60bp_segments_pileup.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_exon_60bp_segments_window_data.sql">> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_exon_contig_pileup.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_reference_exon.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_reference.sql" >> $working_dir/basetables_load_commands
  # echo "mysql --socket=$BASE/thesock -u root cnv3 < $table_path/tso_windows_padded_pileup.sql" >> $working_dir/basetables_load_commands
  # cat $working_dir/basetables_load_commands | parallel -j +0 

  # if [[ $? -ne 0 ]] ; then
#	echo "MySQL base table loading failed" >&2
#	exit 1
 #   else
#	echo "base_tables_loaded" >> $working_dir/completed.txt
#    fi
# fi

echo -n "Skipped Finished Mysql load base tables cnv3 " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

 ## Pre load control and sample tables then mysqlimport all txt files to the tables

 
grep "Pre_Load_Control.sql" $working_dir/completed.txt > /dev/null 2>&1
if  [ "$?" = "0" ]; then
    echo "Pre_Load_Control.sql already run"
else
 echo "Run Pre_Load_Control.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < Pre_Load_Control.sql
    if [[ $? -ne 0 ]] ; then
        echo "Run Pre_Load_Control.sql failed" >&2
        ## mysqladmin --socket=$BASE/thesock shutdown -u root
        exit 1
    else    
    echo "g3 Pre_Load_Control.sql done"
     echo "Pre_Load_Control.sql" >> $working_dir/completed.txt
 fi
fi

echo -n "Finished pre_load_control " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "Pre_Load_Sample.sql" $working_dir/completed.txt > /dev/null 2>&1
 if  [ "$?" = "0" ]; then
    echo "Pre_Load_Sample.sql already run"
else
 echo "Run Pre_Load_Sample.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < Pre_Load_Sample.sql
     if [[ $? -ne 0 ]] ; then
        echo "Run Pre_Load_Sample.sql failed" >&2
        ## mysqladmin --socket=$BASE/thesock shutdown -u root
        exit 1
else
    echo "g3 Pre_Load_Sample.sql done"
     echo "Pre_Load_Sample.sql" >> $working_dir/completed.txt
 fi
fi

echo -n "Finished pre_load_sample " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "mysqlimport" $working_dir/completed.txt > /dev/null 2>&1
 if [ "$?" = "0" ]; then
   echo "mysqlimport already run"
else
 echo "Run mysqlimport"

     mysqlimport --local --socket=$BASE/thesock -u root cnv3 --use-threads=5 --debug-check \
     cnv_control_name_bwa_pileup_no_dup.chr6_t \
     cnv_control_name_bwa_pileup_no_dup.chr7_t \
     cnv_control_name_bwa_pileup_no_dup.chr8_t \
     cnv_control_name_bwa_pileup_no_dup.chr1_t \
     cnv_control_name_bwa_pileup_no_dup.chr2_t \
     cnv_control_name_bwa_pileup_no_dup.chr6_t \
     cnv_control_name_bwa_pileup_no_dup.chr9_t \
     cnv_control_name_bwa_pileup_no_dup.chr10_t \
     cnv_control_name_bwa_pileup_no_dup.chr13_t \
     cnv_control_name_bwa_pileup_no_dup.chr15_t \
     cnv_control_name_bwa_pileup_no_dup.chr17_t \
     cnv_control_name_bwa_pileup.chr6_t \
     cnv_control_name_bwa_pileup.chr7_t \
     cnv_control_name_bwa_pileup.chr8_t \
     cnv_control_name_bwa_pileup.chr1_t \
     cnv_control_name_bwa_pileup.chr2_t \
     cnv_control_name_bwa_pileup.chr6_t \
     cnv_control_name_bwa_pileup.chr9_t \
     cnv_control_name_bwa_pileup.chr10_t \
     cnv_control_name_bwa_pileup.chr13_t \
     cnv_control_name_bwa_pileup.chr15_t \
     cnv_control_name_bwa_pileup.chr17_t \
     cnv_control_name_bowtie_pileup.chr6_t \
     cnv_control_name_bowtie_pileup.chr7_t \
     cnv_control_name_bowtie_pileup.chr8_t \
     cnv_control_name_bowtie_pileup.chr1_t \
     cnv_control_name_bowtie_pileup.chr2_t \
     cnv_control_name_bowtie_pileup.chr6_t \
     cnv_control_name_bowtie_pileup.chr9_t \
     cnv_control_name_bowtie_pileup.chr10_t \
     cnv_control_name_bowtie_pileup.chr13_t \
     cnv_control_name_bowtie_pileup.chr15_t \
     cnv_control_name_bowtie_pileup.chr17_t \
     cnv_sample_name_bwa_pileup_no_dup.chr6_t \
     cnv_sample_name_bwa_pileup_no_dup.chr7_t \
     cnv_sample_name_bwa_pileup_no_dup.chr8_t \
     cnv_sample_name_bwa_pileup_no_dup.chr1_t \
     cnv_sample_name_bwa_pileup_no_dup.chr2_t \
     cnv_sample_name_bwa_pileup_no_dup.chr6_t \
     cnv_sample_name_bwa_pileup_no_dup.chr9_t \
     cnv_sample_name_bwa_pileup_no_dup.chr10_t \
     cnv_sample_name_bwa_pileup_no_dup.chr13_t \
     cnv_sample_name_bwa_pileup_no_dup.chr15_t \
     cnv_sample_name_bwa_pileup_no_dup.chr17_t \
     cnv_sample_name_bwa_pileup.chr6_t \
     cnv_sample_name_bwa_pileup.chr7_t \
     cnv_sample_name_bwa_pileup.chr8_t \
     cnv_sample_name_bwa_pileup.chr1_t \
     cnv_sample_name_bwa_pileup.chr2_t \
     cnv_sample_name_bwa_pileup.chr6_t \
     cnv_sample_name_bwa_pileup.chr9_t \
     cnv_sample_name_bwa_pileup.chr10_t \
     cnv_sample_name_bwa_pileup.chr13_t \
     cnv_sample_name_bwa_pileup.chr15_t \
     cnv_sample_name_bwa_pileup.chr17_t \
    cnv_sample_name_bowtie_pileup.chr6_t \
    cnv_sample_name_bowtie_pileup.chr7_t \
    cnv_sample_name_bowtie_pileup.chr8_t \
     cnv_sample_name_bowtie_pileup.chr1_t \
     cnv_sample_name_bowtie_pileup.chr2_t \
     cnv_sample_name_bowtie_pileup.chr6_t \
     cnv_sample_name_bowtie_pileup.chr9_t \
     cnv_sample_name_bowtie_pileup.chr10_t \
     cnv_sample_name_bowtie_pileup.chr13_t \
     cnv_sample_name_bowtie_pileup.chr15_t \
     cnv_sample_name_bowtie_pileup.chr17_t 
     
  if [[ $? -ne 0 ]]; then
   echo "Run mysqlimport failed" >&2
       echo "g3 Run mysqlimport failed"
       ## mysqladmin --socket=$BASE/thesock shutdown -u root
        exit 1
     else
      echo "g3 mysqlimport done"
      echo "mysqlimport " >> $working_dir/completed.txt
    fi
 fi
  
echo -n "Finished mysqlimport tables " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check
  
grep "load_control.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "load_control.sql already run"
else
    echo "Run load_control.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < load_control.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run load_control.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	# exit 1
    else
        echo "g3 load_control.sql done"
	echo "load_control.sql" >> $working_dir/completed.txt
    fi
fi

echo -n "Finished load_control " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check


grep "load_sample.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "load_sample.sql already run"
else
    echo "Run load_sample.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < load_sample.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run load_sample.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	# exit 1
    else
        echo "g3 load_sample.sql done"
	echo "load_sample.sql" >> $working_dir/completed.txt
    fi
fi

echo -n "Finished load_sample " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_reference_g3.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_reference_g3.sql already run"
else
    echo "Run create_reference_g3.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_reference_g3.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_reference_g3.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_reference_g3.sql" >> $working_dir/completed.txt
    fi
fi

echo -n "Finished create_reference.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "find_median.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "find_median.R already run"
else
    echo "Run  find_median.R"
    R CMD BATCH find_median.R
    if [[ $? -ne 0 ]] ; then
	echo "Run find_median.R failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
        echo "g3 find_median.R done"
	echo "find_median.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished find_median.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_tables_part1.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_tables_part1.sql already run"
else
    echo "Run  create_tables_part1.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_tables_part1.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_tables_part1.sql failed" >&2
	# ## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
        echo "g3 create_tables_part1.sql done"
	echo "create_tables_part1.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_table_part1.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "normalize_coverage.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "normalize_coverage.R already run"
else
    echo "Run  normalize_coverage.R"
    R CMD BATCH normalize_coverage.R
    if [[ $? -ne 0 ]] ; then
	echo "Run normalize_coverage.R failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
        echo "g3 normalize_coverage.R done"
	echo "normalize_coverage.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished normalize_coverage.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "smooth_coverage.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "smooth_coverage.R already run"
else
    echo "Run  smooth_coverage.R"
    R CMD BATCH smooth_coverage.R
    if [[ $? -ne 0 ]] ; then
	echo "Run smooth_coverage.R failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
        echo "g3 smooth_coverage.R done"
	echo "smooth_coverage.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished smooth_coverage.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "get_three_ref.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "get_three_ref.R already run"
else
    echo "Run  get_three_ref.R"
    R CMD BATCH get_three_ref.R
    if [[ $? -ne 0 ]] ; then
	echo "Run get_three_ref.R failed cnv3" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	cp $working_dir/completed.txt $working_dir/completed.old.txt
	head -n1 $working_dir/completed.txt > $working_dir/completed.txt.tmp
	mv $working_dir/completed.txt.tmp $working_dir/completed.txt
	rm $working_dir/*_t
	exit 1
    else
        echo "g3 get_three_ref.R done"
	echo "get_three_ref.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished get_three_ref.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_tables_ref_v1.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_tables_ref_v1.sql already run"
else
    echo "Run  create_tables_ref_v1.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_tables_ref_v1.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_tables_ref_v1.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_tables_ref_v1.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_tables_ref_v1.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_tables_ref.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_tables_ref.R already run"
else
    echo "Run  create_tables_ref.R"
    R CMD BATCH create_tables_ref.R
    if [[ $? -ne 0 ]] ; then
	echo "Run create_tables_ref.R failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_tables_ref.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_tables_ref.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_tables_ref_v2.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_tables_ref_v2.sql already run"
else
    echo "Run  create_tables_ref_v2.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_tables_ref_v2.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_tables_ref_v2.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_tables_ref_v2.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_tables_ref_v2.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_coverage.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_coverage.sql already run"
else
    echo "Run  create_coverage.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_coverage.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_coverage.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_coverage.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_coverage.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_sample_coverage.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_sample_coverage.sql already run"
else
    echo "Run  create_sample_coverage.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_sample_coverage.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_sample_coverage.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_sample_coverage.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_sample_coverage.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

chmod o+w $working_dir
grep "Get_3_random_ref_genes" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "Get_3_random_ref_genes already run"
else
 echo "Run Get_3_random_ref_genes"
  mysqldump -u root --socket=$BASE/thesock --tab=$working_dir cnv3 cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov
  chromo=$(awk '{FS=" ";print $2}' cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov.txt | sort -u | awk -F ":" '{print $1}')
  digit=$(awk '{FS=" ";print $2}' cnv_sample_name_over_control_name_60bp_exon_ref1_med_gene_cov.txt | sort -u | awk -F ":" '{print $2}' | cut -c1)
  colon=":"
  chromosome=$chromo$colon$digit
  r1=$(grep ${chromosome} ${working_dir}/reference_genes_file)
  echo $r1
   ref1_gene=$(echo $r1 | cut -d" " -f2)
   echo -n "ref1: " >> ${working_dir}/Three_Ref_Genes
   echo "$ref1_gene" >> ${working_dir}/Three_Ref_Genes

  mysqldump -u root --socket=$BASE/thesock --tab=$working_dir cnv3 cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov
   chromo=$(awk '{FS=" ";print $2}' cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov.txt | sort -u | awk -F ":" '{print $1}')
   digit=$(awk '{FS=" ";print $2}' cnv_sample_name_over_control_name_60bp_exon_ref2_med_gene_cov.txt | sort -u | awk -F ":" '{print $2}' | cut -c1)
   colon=":"
   chromosome=$chromo$colon$digit
   r2=$(grep ${chromosome} ${working_dir}/reference_genes_file)
   echo $r2
   ref2_gene=$(echo $r2 | cut -d" " -f2)
   echo -n "ref2: " >> ${working_dir}/Three_Ref_Genes
   echo "$ref2_gene" >> ${working_dir}/Three_Ref_Genes

  mysqldump -u root --socket=$BASE/thesock --tab=$working_dir cnv3 cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov
  chromo=$(awk '{FS=" ";print $2}' cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov.txt | sort -u | awk -F ":" '{print $1}')
  digit=$(awk '{FS=" ";print $2}' cnv_sample_name_over_control_name_60bp_exon_ref3_med_gene_cov.txt | sort -u | awk -F ":" '{print $2}' | cut -c1)
  colon=":"
  chromosome=$chromo$colon$digit
  r3=$(grep ${chromosome} ${working_dir}/reference_genes_file)
  echo $r3
  ref3_gene=$(echo $r3 | cut -d" " -f2)
  echo -n "ref3: " >> ${working_dir}/Three_Ref_Genes
  echo "$ref3_gene" >> ${working_dir}/Three_Ref_Genes

 echo "Get_3_random_ref_genes" >> $working_dir/completed.txt

fi
chmod o+w $working_dir


grep "create_control_coverage.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_control_coverage.sql already run"
else
    echo "Run  create_control_coverage.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_control_coverage.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_control_coverage.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_control_coverage.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_control_coverage.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "cnv_tables.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "cnv_tables.sql already run"
else
    echo "Run  cnv_tables.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < cnv_tables.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run cnv_tables.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "cnv_tables.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished cnv_tables.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "cnv_tables_amplifications.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "cnv_tables_amplifications.sql already run"
else
    echo "Run  cnv_tables_amplifications.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < cnv_tables_amplifications.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run cnv_tables_amplifications.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "cnv_tables_amplifications.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished cnv_tables_amplications.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "ordered_genes.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "ordered_genes.sql already run"
else
    echo "Run ordered_genes.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < ordered_genes.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run ordered_genes.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "ordered_genes.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished ordered_genes.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "create_data.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "create_data.sql already run"
else
    echo "Run create_data.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < create_data.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run create_data.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "create_data.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished create_data.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "get_machine_learning_data.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "get_machine_learning_data.sql already run"
else
    echo "Run get_machine_learning_data.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < get_machine_learning_data.sql > sample_name_raw_data_$_now.txt
    if [[ $? -ne 0 ]] ; then
	echo "Run get_machine_learning_data.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "get_machine_learning_data.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished get_machine_learning_data.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "aggregate_window.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "aggregate_window.R already run"
else
    echo "Run aggregate_window.R"
    R CMD BATCH aggregate_window.R
    if [[ $? -ne 0 ]] ; then
	echo "Run aggregate_window.R failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "aggregate_window.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished aggregate_window.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "combine_data.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "combine_data.sql already run"
else
    echo "Run combine_data.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < combine_data.sql
    if [[ $? -ne 0 ]] ; then
	echo "Run combine_data.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "combine_data.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished combine_data.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "cnv_randomForest_predict.R" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "cnv_randomForest_predict.R already run"
else
    echo "Run cnv_randomForest_predict.R"
    R CMD BATCH cnv_randomForest_predict.R
    if [[ $? -ne 0 ]] ; then
	echo "Run cnv_randomForest_predict.R failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "cnv_randomForest_predict.R" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished cnv_randomForest_predict.R " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "get_predicted.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "get_predicted.sql already run"
else
    echo "Run get_predicted.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < get_predicted.sql > sample_name_predicted_$_now.txt
    if [[ $? -ne 0 ]] ; then
	echo "Run get_predicted.sql failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	exit 1
    else
	echo "get_predicted.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished get_predicted.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

# Raw data
if [ -s sample_name_raw_data_$_now.txt ]
then
    mkdir -p archive_path/raw_data
    chmod 775 archive_path/raw_data
    mv  sample_name_raw_data_$_now.txt archive_path/raw_data
    chmod 664 archive_path/raw_data/sample_name_raw_data_$_now.txt
else
    echo "sample_name_raw_data_$_now.txt is empty."
    # do something as file is empty 
fi

if [ -s sample_name_raw_data_amp_$_now.txt ]
then
    mv  sample_name_raw_data_amp_$_now.txt archive_path/raw_data
    chmod 664 archive_path/raw_data/sample_name_raw_data_amp_$_now.txt
else
    echo "sample_name_raw_data_amp_$_now.txt is empty."
    # do something as file is empty 
fi


# Predicted
if [ -s sample_name_predicted_$_now.txt ]
then
    mkdir -p archive_path/predicted_data
    chmod 775 archive_path/predicted_data
    mv  sample_name_predicted_$_now.txt  archive_path/predicted_data
    chmod 664 archive_path/predicted_data/sample_name_predicted_$_now.txt
else
    echo "sample_name_predicted_$_now.txt is empty"
fi

if [ -s sample_name_predicted_amp_$_now.txt ]
then
    mv  sample_name_predicted_amp_$_now.txt  archive_path/predicted_data
    chmod 664 archive_path/predicted_data/sample_name_predicted_amp_$_now.txt
else
    echo "sample_name_predicted_amp_$_now.txt is empty"
fi

grep "plot_script.pl" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "plot_script.pl cnv3 already run"
else
    echo "plot_script.pl cnv3"
    perl $script_path/plot_script.pl -t cnv_sample_name_tso_over_control_name_n_bowtie_bwa_ratio_gene_out -s sample_name -c cnv_sample_name_ordered_genes -k cnv_sample_name_ordered_genes -h localhost -u root -d cnv3 -o plot_genes_ordered_cnv3.py -ms $mysql_socket -a 1
    if [[ $? -ne 0 ]] ; then
	echo "Run plot_script.pl cnv3 failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	#exit 1
    else
	echo "plot_script.pl cnv3" >> $working_dir/completed.txt
    fi
fi
#
grep "plot_genes_ordered_cnv3.py" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "plot_genes_ordered_cnv3.py already run"
else
    echo "plot_genes_ordered_cnv3.py"
    #R CMD BATCH plot_genes_ordered.R
    python plot_genes_ordered_cnv3.py
    if [[ $? -ne 0 ]] ; then
	echo "Run plot_genes_ordered_cnv3.py failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	#exit 1
    else
	echo "plot_genes_ordered_cnv3.py" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished plot_genes_ordered_cnv3.py " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check


#grep "get_ordered_genes.sql" $working_dir/completed.txt > /dev/null 2>&1
#if [ "$?" = "0" ]; then
#    echo "get_ordered_genes.sql cnv3 already run"
#else
#    echo "get_ordered_genes.sql cnv3"
#    mysql --socket=$BASE/thesock -u root cnv3 < get_ordered_genes.sql  > sample_name_cnv_calls_on_ordered_genes_$_now.txt
#   sync
#  if [[ $? -ne 0 ]] ; then
#	echo "Run get_ordered_genes.sql cnv3 failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	#exit 1
 #   else
#	echo "get_ordered_genes.sql cnv3" >> $working_dir/completed.txt
#	sed -e s,NULL,,g < sample_name_cnv_calls_on_ordered_genes_$_now.txt > sample_name_cnv_calls_on_ordered_genes_$_now.txt.bak
#	mv sample_name_cnv_calls_on_ordered_genes_$_now.txt.bak sample_name_cnv_calls_on_ordered_genes_$_now.txt
	# mv sample_name_cnv_calls_on_ordered_genes_$_now.txt.bak sample_name_cnv_calls_on_ordered_genes.txt
 #   fi
#fi
#echo -n "Finished get_ordered_genes.sql " >> $working_dir/time_check
#timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
#echo ${timecheck} >> $working_dir/time_check

#if [ -s sample_name_cnv_calls_on_ordered_genes_$_now.txt ]
#then
#    cp  sample_name_cnv_calls_on_ordered_genes_$_now.txt sample_result
    #callsize=`du -sh sample_name_cnv_calls_on_ordered_genes.txt | cut -f1`
    #echo -n "cnv call file size is: " 
    #echo $callsize
#else
    #echo "No cnv call file and sample_name_cnv_calls_on_ordered_genes_$_now.txt is empty."
# do nothing as file is empty
#fi
grep "get_ordered_genes.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "get_ordered_genes.sql cnv3 already run"
else
    echo "get_ordered_genes.sql cnv3"
    mysql --socket=$BASE/thesock -u root cnv3 < get_ordered_genes.sql  > sample_name_cnv_calls_on_ordered_genes_$_now.txt
   sync
  if [[ $? -ne 0 ]] ; then
	echo "Run get_ordered_genes.sql cnv3 failed" >&2
	## mysqladmin --socket=$BASE/thesock shutdown -u root
	#exit 1
    else
	echo "get_ordered_genes.sql cnv3" >> $working_dir/completed.txt
	sed -e s,NULL,,g < sample_name_cnv_calls_on_ordered_genes_$_now.txt > sample_name_cnv_calls_on_ordered_genes_$_now.txt.bak
	mv sample_name_cnv_calls_on_ordered_genes_$_now.txt.bak sample_name_cnv_calls_on_ordered_genes_$_now.txt
	mv sample_name_cnv_calls_on_ordered_genes_$_now.txt sample_name_cnv_calls_on_ordered_genes_$_now.txt.tmp
        cat sample_name_cnv_calls_on_ordered_genes_$_now.txt.tmp >> ${working_dir}/Three_Ref_Genes
        mv ${working_dir}/Three_Ref_Genes sample_name_cnv_calls_on_ordered_genes_$_now.txt
	sed 's/^.*.txt://g' sample_name_cnv_calls_on_ordered_genes_$_now.txt
	
    fi
fi
echo -n "Finished get_ordered_genes.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

if [ -s sample_name_cnv_calls_on_ordered_genes_$_now.txt ]
then
    cp  sample_name_cnv_calls_on_ordered_genes_$_now.txt sample_result
else
   echo "sample_name_cnv_calls_on_ordered_genes_$_now.txt is empty"
   cp $working_dir/completed.txt $working_dir/completed.old.txt
	head -n1 $working_dir/completed.txt > $working_dir/completed.txt.tmp
	mv $working_dir/completed.txt.tmp $working_dir/completed.txt
        echo "Empty cnv_calls file..RESTARTING cnv3"
	rm $working_dir/*_t
exit 1
# do nothing as file is empty
fi

grep "move_script.pl" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "move_script.pl cnv3 already run"
else
    echo "move_script.pl"
    perl $script_path/move_script.pl -c cnv_sample_name_ordered_genes -p sample_result -h localhost -u root -d cnv3 -o move_plots_cnv3.sh -ms $mysql_socket
    if [[ $? -ne 0 ]] ; then
        echo "Run move_script.pl cnv3 failed" >&2
        ## mysqladmin --socket=$BASE/thesock shutdown -u root
        #exit 1
    else
        echo "move_plots.pl cnv3 ran successfully"
    fi
fi

echo -n "Finished move_script.pl " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check
#
## Run script to move plots for ordered genes
#
grep "move_plots_cnv3.sh" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "move_plots_cnv3.sh already run"
else
    echo "Run move_plots_cnv3.sh"
    sh move_plots_cnv3.sh
    if [[ $? -ne 0 ]] ; then
        echo "Run move_plots_cnv3.sh  failed" >&2
        #exit 1
    else
    	echo "move_script.pl" >> $working_dir/completed.txt
        echo "move_plots_cnv3.sh" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished move_plots.pl " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

grep "cnv2vcf.py" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "cnv2vcf.py already run"
else
    echo "cnv2vcf.py"
    python $script_path/cnv2vcf.py sample_name_cnv_calls_on_ordered_genes_$_now.txt 4 17 16 seq_db > sample_name_cnv.vcf
    if [[ $? -ne 0 ]] ; then
	echo "Run cnv2vcf.py failed" >&2
	exit 1
    else
	echo "cnv2vcf.py" >> $working_dir/completed.txt
    fi 
fi
echo -n "Finished cnv2vcf.py " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

if [ -s sample_name_cnv.vcf ]
then
    cp  sample_name_cnv.vcf sample_result
else
    echo "sample_name_cnv.vcf is empty."
fi

grep "get_qc_data.sql" $working_dir/completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "get_qc_data.sql already run"
else
    echo "get_qc_data.sql"
    mysql --socket=$BASE/thesock -u root cnv3 < get_qc_data.sql > sample_name_qc_data_$_now.txt
    if [[ $? -ne 0 ]] ; then
        echo "Run get_qc_data.sql failed" >&2
        exit 1
    else
        echo "get_qc_data.sql" >> $working_dir/completed.txt
    fi
fi
echo -n "Finished get_qc_data.sql " >> $working_dir/time_check
timecheck=`(date +"%Y-%m-%d [ %H:%M:%S ]")`;
echo ${timecheck} >> $working_dir/time_check

#Skip QC Test
#if [ -s sample_name_qc_data_$_now.txt ]
#then
#    cp  sample_name_qc_data_$_now.txt  archive_path/QC
#    chmod 664 archive_path/QC/sample_name_qc_data_$_now.txt
#else
 #   echo "sample_name_qc_data_$_now.txt is empty"
#fi

# don't shutdown mysql here, shutdown via the master 
# SHUT DOWN MySQL 
# echo "Shutdown MySQL"
# ## mysqladmin --socket=$BASE/thesock shutdown -u root
