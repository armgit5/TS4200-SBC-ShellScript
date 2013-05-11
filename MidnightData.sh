#!/bin/bash
# Takes the sensor data and pushes the data from local computer to remote server every midnight
# Written by Yuttanant Suwansiri 28 Nov. 2012

sleep 5

while [ 1 ]
do
        dt=`date +%H`
        time=`date +%s`
        if [[ $dt == 00 ]]
        then
        #get Meter Reading
                        meter=`quick-Flow.sh 265`
                        until [[ $meter =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        meter=`quick-Flow.sh 265`
                        sleep 1
                        done
                        echo $meter
        #get Tank Inventory
                        tankIn=`quick-VEGA.sh`
                        tankIn=`echo "scale=4; $tankIn * 1.665 *12*4"|bc | sed 's/^\./0./'`
                        until [[ $tankIn =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        tankIn=`quick-VEGA.sh`
                        tankIn=`echo "scale=4; $tankIn * 1.665 *12*4"|bc | sed 's/^\./0./'`
                        sleep 1
                        done
                        echo $tankIn

        uniqueid=5555
        fileid="$uniqueid$dt.csv"
                echo "$time| | | | | | | | |$meter|$tankIn" >> $fileid
        #Send CSV to server
                while [[ ! `ping -c 1 "google.com"` ]]
                do
                echo "no internet"
                sleep 5
                done
        scp /xxx/xxx/xxx/$fileid asuwansiri@99.99.99.99:/xxx/asuwansiri/data/xxx
        ssh asuwansiri@99.99.99.99 "cd /xxx/asuwansiri/data/xxx; scp $fileid xxx@xxx.xxx.com:/var/www/xxx/xxx/www/data_files; ssh xxx@xxx.xxx.com "/usr/bin/curl -silent -o test.text https://xxx.xxx.com/xxx-update.php""
        #Remove CSV
        rm $fileid
        sleep 120m
        fi
        echo "not midnight yet"
        sleep 5

done
