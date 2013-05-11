#!/bin/bash
# Execution: ./ClockSync.sh
# This code check and output sensor readings synchronizing with the local computer's clock time interval of 15,30,45,59th minutes
# According the local computer's clock, the system inserts sensor data into the local database, and pushes the data to the remote server
# Written by Yuttanant Suwansiri 6 Dec. 2012

# Start the program 
while [ 1 ]
do
#functions
    # Get flow meter information
{ 	function getMeter() {
		meter=`quick-Flow.sh 265`
		meter=`echo ${meter#0}` #Ignore 0 before the decimal point Ex. 0.75 -> .75, 7.5 -> 7.5
		until [[ $meter =~ ^[0-9]+([.][0-9]+)?$ && $meter != 0 ]] #Convert . to 0. & string to #Ex. .70 will be 0.70 or string to 0.7
		do
		meter=`quick-Flow.sh 265`
		meter=`echo ${meter#0}`
		sleep 1
		done
		echo $meter
	}
	# Get tank information
	function getTank() {
		tankIn=`quick-VEGA.sh`
		tankIn=`echo ${tankIn#0}`
		tankIn=`echo "scale=6; (20.70913 - $tankIn) * 1.665 *12*4"|bc | sed 's/^\./0./'` #Calculation to convert level to bbls
		until [[ $tankIn =~ ^[0-9]+([.][0-9]+)?$ && $tankIn != 0 ]]
		do
		tankIn=`quick-VEGA.sh`
		tankIn=`echo ${tankIn#0}`
		tankIn=`echo "scale=6; (20.70913 - $tankIn) * 1.665 *12*4"|bc | sed 's/^\./0./'`
		sleep 1
		done
		echo $tankIn
	}
	# Check clock minute
	function checkMin() {
		until (( $min >= $1 ))
		do
		sleep 5
		echo "Checking"
		min=`date +%M`
		min=`echo ${min#0}`
		echo "$min $1"
		done
		dt3=`date +%s`
    }
	# Insert data into local database
	function insertData() {
		sqlite3 /xxx/xxx/xxx/xxx/xxx.db "INSERT INTO xxx_results VALUES ($1,0,0,0,0,0,0,0,0,$2,$3)"
	}
	# Gerating CSV file
	function genCSV() {
		uniqueid=1111
        fileid="$uniqueid$dt2.csv"
		echo "generating csv file"
		echo "$1 $2 $3"
		echo "$1| | | | | | | | |$2|$3" >> $fileid
	}
	function pushData() {
		while [[ ! `ping -c 1 "google.com"` ]] #Check to see if there's internet connection by pinging google.com
		do
		echo "no internet"
		sleep 5
		done
		echo "Uploading to servers"
		scp $fileid asuwansiri@99.999.99.99:/xxx/asuwansiri/data/xxx
        ssh asuwansiri@99.999.99.99 "cd /xxx/asuwansiri/data/xxx; scp $fileid xxx@xxx.xxx.com:/var/www/xxx/xxx/www/data_files; ssh xxx@xxx.xxx.com "/usr/bin/curl -silent -o test.text https://xxx.xxx.com/xxx-update.php""
	}
	function operation() {
	    # Set date
	    dt2=`date "+%m%d%H$minLogic%y"`
		{ checkMin $minLogic #Check to see if it's 0,15,30,45
		}
		{ getMeter #Get meter and tank barrels
		getTank
		echo "inside loop meter and tank: $meter $tankIn"
		}
		{ insertData $dt2 $meter $tankIn #Insert date/time, meter, tank barrel into database 
		genCSV $dt3 $meter $tankIn #Output a csv file
		pushData #push data to servers
		sleep 1
		echo "removing csv file"
		rm $fileid
		echo "finish the process"
	}
}
#get hr and min
{	hr=`date +%H`
	hr=`echo ${hr#0}`
	echo $hr
	min=`date +%M`
	min=`echo ${min#0}`
	echo $min
}
# Mail program, start the logic
	{ if (( 0 <= $min && $min <= 15 )) 
	then {
		minLogic=15
		operation
		}
	}
	elif (( 15 < $min && $min <= 30 )) 
	then {
		minLogic=30
		operation
		}
	}
	elif (( 30 < $min && $min <= 45 )) 
	then {
		minLogic=45
		operation
		}
	}
	elif (( 45 < $min && $min <= 59 ))
	then {
		min4=00
		minLogic=59
		if (( $hr == 23 ))
		then {
			hr=00
			operation
			}
		}
		elif (( $hr < 9 ))
		then {
			((hr= $hr+1))
			operation			
			}
		}
		else {
			((hr= $hr+1))
			operation
			}
			}
		fi
	}
	else {
	echo "no matches"
	}
	fi
}
sleep 2m
done