#!/usr/bin/bash

system_file="/data/work/system_download.txt"

hive_array=($(cat ${system_file} | grep hive_ip | awk -F '|' '{for(i=2; i<=NF; i++) print $i}'))
len_array=${#hive_array[@]}

ansible_dir=$1
tar_dir=$2

for ((i=0; i<len_array; i++));
do
        current_ip=${hive_array[$i]}
	echo $current_ip
	scp ${ansible_dir}/*hive*tar* root@${current_ip}:${tar_dir}/
done
