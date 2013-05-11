#!/bin/bash
# Continously check the 3G wireless modem every 15 minutes to see if there is countinous internet connection
# If there is no internet connection, the system runs "pon and poff" commands to reset the modem for 8 times
# After 8 time the system power cycle itself to reset everything for 5 minutes
# Written by Yuttanant Suwansiri 09 Sep. 2012

device0="/dev/modem"
sleep 5m

while [ 1 ]
do

if [ ! -e "$device0" ]
       then
        #echo "Rebooting in 5 seconds"
        sleep 5
        echo `date` >> /var/log/modem.log
        echo "Modem not present, rebooting" >> /var/log/modem.log
        'reboot'
       else
        i=0
        while [ $i -lt 8 ]
        do
                if [[ ! `ping -c 1 "google.com"` ]]
                then
                        #echo "pon and poff in 5 seconds"
                        sleep 5
                        echo `date` >> /var/log/modem.log
                        echo "Modem present, but cannot connect." >> /var/log/modem.log
                        `poff`
                        sleep 5
                        `pon`
                        sleep 5
                fi
        ((i +=1))
        sleep 15m
        done
        #echo "Done"
       if [[ ! `ping -c 1 "google.com"` ]]
       then
        #echo "Going to power cycle in 5 seconds"
        echo `date` >> /var/log/modem.log
        echo "Went to power cycle" >> /var/log/modem.log
        sleep 5
        `ts8160ctl --sleep 300`
       fi
fi
sleep 15m

done
