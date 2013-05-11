#!/bin/bash
#This code gets data from HMI when user submits the data, store in sqlite database, output csv database file to the server.
sleep 1

#initialize the database
sqlite3 /usr/xxx/xxx/sys/xxx.db "CREATE TABLE mvp_results (dateTime integer,truckingCom integer,driverNum integer,supplier integer,ticketNum integer,netVol real,observed_gravity real,observed_temperature real,bs_w real,meter real,tankIn real)" >> /dev/null

while [ 1 ]
do
        #Check Status (0 means no user submiting data, 1 means user has submitted data)
                st=`quick-HMI-16.sh 3021`
                until [[ $st =~ ^[0-9]+([.][0-9]+)?$ ]]
                do
                st=`quick-HMI-16.sh 3021`
                echo "poll again"
                sleep 1
                done
                echo $st
        if [[ $st == 1 ]]
        then
        #get Date and Time
                        dt=`date +%s`
                        echo $dt
        #get Trucking Number
                        truckingCom=`quick-HMI-32.sh 3001`
                        until [[ $truckingCom =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        truckingCom=`quick-HMI-32.sh 3001`
                        echo "poll again"
                        sleep 1
                        done
                        echo $truckingCom
        #get Driver Number
                        driverNum=`quick-10digits.sh 3701`
                    until [[ $driverNum =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        driverNum=`quick-10digits.sh 3701`
                        sleep 1
                        done
                        echo $driverNum
                #get Supplier
                        supplier=`quick-HMI-32.sh 3005`
                        until [[ $supplier =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        supplier=`quick-HMI-32.sh 3005`
                        sleep 1
                        done
                        echo $supplier
                #get Ticket Number
                        ticketNum=`quick-10digits.sh 3751`
                        until [[ $ticketNum =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        ticketNum=`quick-10digits.sh 3751`
                        sleep 1
                        done
                        echo $ticketNum
        #get Net Volume
                        netVol=`quick-HMI-32.sh 3007`
                        netVol=`echo "scale=2; $netVol /100"|bc | sed 's/^\./0./'`
                        until [[ $netVol =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        netVol=`quick-HMI-32.sh 3007`
                        netVol=`echo "scale=2; $netVol /100"|bc`
                        sleep 1
                        done
                        echo $netVol
        #get Observed Gravity
                        observedGravity=`quick-HMI-32.sh 3009`
                        observedGravity=`echo "scale=1; $observedGravity /10"|bc | sed 's/^\./0./'`
                        until [[ $observedGravity =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        observedGravity=`quick-HMI-32.sh 3009`
                        observedGravity=`echo "scale=1; $observedGravity /10"|bc | sed 's/^\./0./'`
                        sleep 1
                        done
                        echo $observedGravity
        #get Observed Temperature
                        observedTemp=`quick-HMI-32.sh 3011`
                        observedTemp=`echo "scale=1; $observedTemp /10"|bc | sed 's/^\./0./'`
                        until [[ $observedTemp =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        observedTemp=`quick-HMI-32.sh 3011`
                        observedTemp=`echo "scale=1; $observedTemp /10"|bc | sed 's/^\./0./'`
                        sleep 1
                        done
                        echo $observedTemp
        #get BS&W
                        bsw=`quick-HMI-32.sh 3013`
                        bsw=`echo "scale=2; $bsw /100"|bc | sed 's/^\./0./'`
                        until [[ $bsw =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        bsw=`quick-HMI-32.sh 3013`
                        bsw=`echo "scale=2; $bsw /100"|bc | sed 's/^\./0./'`
                        sleep 1
                        done
                        echo $bsw
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
                        tankIn=`echo "scale=4; $tankIn * 1.665 *12 *4"|bc | sed 's/^\./0./'`
                        until [[ $tankIn =~ ^[0-9]+([.][0-9]+)?$ ]]
                        do
                        tankIn=`quick-VEGA.sh`
                        tankIn=`echo "scale=4; $tankIn * 1.665 *12 *4"|bc | sed 's/^\./0./'`
                        sleep 1
                        done
                        echo $tankIn

        echo "Insert to sqlite"
        sqlite3 /usr/xxx/xxx/sys/xxx.db "INSERT INTO mvp_results VALUES ($dt,$truckingCom,$driverNum,$supplier,$ticketNum,$netVol,$observedGravity,$observedTemp,$bsw,$meter,$tankIn)"
        echo "Export csv to server"
        uniqueid=142233
        fileid="$uniqueid$dt.csv"
        #Generate CSV file
        cd /usr/xxx/xxx/sys/
        sqlite3 /usr/xxx/xxx/sys/xxx.db "select*from mvp_results where dateTime=$dt" >> $fileid
        #Send CSV to server
                while [[ ! `ping -c 1 "google.com"` ]]
                do
                echo "no internet"
                sleep 5
                done
        scp /usr/xxx/xxx/sys/$fileid asuwansiri@99.99.99.99:/xxx/asuwansiri/data/xxx
        ssh asuwansiri@99.99.99.99 "cd /home/asuwansiri/data/mvp; scp $fileid mvp@mvp.petropower.com:/var/www/vhost4/mvp/www/data_files; ssh mvp@mvp.petropower.com "/usr/bin/curl -silent -o test.text https://mvp.petropower.com/data-update.php""
        #Remove CSV
        rm /usr/xbow/xxx/sys/$fileid
        sleep 1
        echo "write 0 back to HMI register 3021"
                quick-HMI-16.sh 3021 0
                st2=`quick-HMI-16.sh 3021`
                until [[ $st2 == 0 ]]
                do
        quick-HMI-16.sh 3021 0
                st2=`quick-HMI-16.sh 3021`
                echo "write again"
                sleep 1
                done
        fi

        echo "No submission yet, I'm sleeping"
                #This time should be longer than the thank you for submitting time
        sleep 5
done
