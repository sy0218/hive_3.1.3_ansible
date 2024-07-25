#!/bin/bash

system_file="/data/work/system_download.txt"
conf_dir=$1
work_dir=$2
postgresql_jar_file=$3
ip_array=($(grep hive_ip ${system_file} | awk -F '|' '{for(i=2; i<=NF; i++) print $i}'))
len_ip_array=${#ip_array[@]}


for hive_site_config_low in $(awk '/\[hive-site.xml-start\]/{flag=1; next} /\[hive-site.xml-end\]/{flag=0} flag' ${system_file});
do
        file_name=$(find ${conf_dir} -type f -name *hive-site.xml*)
        hive_site_name=$(echo ${hive_site_config_low} | awk -F '|' '{print $1}' | sed 's/[][]//g')
        hive_site_value=$(echo ${hive_site_config_low} | awk -F '|' '{print $2}')
        sed -i "/<name>${hive_site_name}<\/name>/!b;n;c<value>${hive_site_value}</value>" ${file_name}
done



# 동적 setup된 hive 설정 관련 파일 scp
for cp_file in $(ls ${conf_dir});
do
	if [[ "$cp_file" != "entrypoint.sh" && "$cp_file" != *.tar.gz && "$cp_file" != *.yml && "$cp_file" != *.ini && "$cp_file" != "system_download.txt" && "$cp_file" != "tar_scp.sh" ]]; then
		if [[ "$cp_file" == ${postgresql_jar_file} ]]; then
			local_path=$(find ${work_dir}/*hive*/lib -name lib -type d)
		else
			local_path=$(find ${work_dir}/*hive*/conf -name conf -type d)
		fi
	for ((i=0; i<len_ip_array; i++)); 
	do
		current_ip=${ip_array[$i]}
		scp ${conf_dir}/${cp_file} root@${current_ip}:${local_path}/
	done
	fi
done
