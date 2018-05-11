#!/bin/bash                             
ulimit -u

echo "g2 wrapper called"

working_dir=sample_path

g2=$(basename $working_dir)
working_dir_g2=${working_dir}


cd $working_dir_g2

_now=$(date +"%Y-%m-%d_%H-%M")


ls -1 $working_dir_g2/wrapper_completed.txt > /dev/null 2>&1
if [ "$?" = "0" ]; then
    echo "$working_dir_g2/wrapper_completed.txt exists"
else
    echo "Started a new g2 run on $_now" >> $working_dir_g2/wrapper_completed.txt
fi

ATTEMPTS=1
 while [ $ATTEMPTS -lt 4 ]; do
    echo -e "\n\n------------- ATTEMPT $ATTEMPTS ---------------\n\n"
      sh ${working_dir_g2}/run_cnv_${g2}.sh 
   ec=$?
    if [[ $ec != 0 ]]; then
        sleep 10
    else
        break
    fi
    let ATTEMPTS=ATTEMPTS+1
done


