#!/bin/bash
# Execution: ./GetSensor.sh
# This code is used to get modbus sensor reading every 15 minutes and insert the data into the database
# If the reading is 0, don't take any reading
# Written by Yuttanant Suwansiri 06 Dec. 2012

#time between poll
sampleTime=15m
#update the devices to look for
list="/usr/local/etc/nodelist.txt"
#initialize the database
sqlite3 /usr/xxx/xxx/sys/xxx.db "CREATE TABLE xxx_results (result_time integer,sensor integer,reading real)" >> /dev/null

#funcitons 
{	function getList() { #get information from nodelist file
		index=0
		while read line ; do
		MYARRAY[$index]="$line"
		#echo "MYARRAY $index: ${MYARRAY[$index]}"
		index=$(($index+1))
		done < "`echo $list`"
	}
	function getData() {
		data=`quick-data.sh $1`
		until [[ $data =~ ^[0-9]+([.][0-9]+)?$ ]] #Convert . to 0. & string to #Ex. .70 will be 0.70 or string to 0.7
		do
		data=`quick-data.sh $1`
		sleep 1
		done
		#echo $data
	}
	function insertData() {
	#echo "Insert into database"
	#echo "database: $1 $2 $3"
	sqlite3 /usr/xxx/xxx/sys/xxx.db "INSERT INTO xxx_results (result_time,sensor,reading) VALUES ($1,$2,$3)"
	}

}
#run
while [ 1 ] ; do
{
	#get info from nodelist.txt and assign it in arrays
	getList
	#start the process
	#get date and time
	dt=`date +%s`
	totalData=${MYARRAY[0]}
	#echo "Total data: $totalData"
	for ((i=1; i<=$totalData; i++))
	do {
		#get unique id from nodelist.txt
		{ #echo "Loop #: $i"
		((uniqueArray= $i*4))
		uniqueId=${MYARRAY[$uniqueArray]}
		#echo "The uniqueId: $uniqueId"
		}
		#get sensor data reading 
		{ ((registerArray= $uniqueArray-1))
		#echo "registerArray: $registerArray"
		registerNum=${MYARRAY[$registerArray]}
		#echo "registerNum: $registerNum"
		#getData $registerNum
		}
		#check to see if data = 0
		getData $registerNum
		{ data2=${data%.*} #remove everything after dot
		if (($data2 != 0))
		then {
			insertData $dt $uniqueId $data
			}
		#else {
		#	echo "Equals 0 not inserting"
		#	}
		fi
		}
	}
	done
	#echo "finish the process"
	sleep $sampleTime
}
done

