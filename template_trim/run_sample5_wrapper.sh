#!/bin/bash                             
ulimit -u
echo "g5 wrapper called"

working_dir=sample_path

g5=$(basename $working_dir)
working_dir_g5=${working_dir}


cd $working_dir_g5

_now=$(date +"%Y-%m-%d_%H-%M")


ls -1 $working_dir_g5/wrapper_completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "$working_dir_g5/wrapper_completed.txt exists"
else
    echo "Started a new g5 run on $_now" >> $working_dir_g5/wrapper_completed.txt
fi

ATTEMPTS=1
 while [ $ATTEMPTS -lt 4 ]; do
    echo -e "\n\n------------- ATTEMPT $ATTEMPTS ---------------\n\n"
      sh ${working_dir_g5}/run_cnv_${g5}.sh 
   ec=$?
    if [[ $ec != 0 ]]; then
        sleep 10
    else
        break
    fi
    let ATTEMPTS=ATTEMPTS+1
done


