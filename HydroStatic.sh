#!/bin/bash
# Control local computer to power on and off a hydrostatic sensor
# Take the reading and send to the remote server
# Written by Yuttanant Suwansiri 24 Oct. 2012

# Tell the local computer server to initialize starting after 15 seconds
sleep 15
tsctl --server &

# Start the program
while [ 1 ]
do
sleep 2

#Power the analog channel
tsctl 127.0.0.1 Bus:2 BitSet16 2 12
sleep 3

# Get the ADC signal and convert to level
adc3=`/home/APSoftware/HydroStatic/get-ADC3.sh`
level=`/home/APSoftware/HydroStatic/get_level.sh`
echo $level

# If the level is more than 0
if [[ $level > 0 ]]
then

# Take the reading
dt=`date +%s`
tankid=1120
fileid=""$tankid"_$dt.csv"
echo "$dt|$tankid|$level" >> $fileid

sleep 1
# Power off the analog channel
tsctl 127.0.0.1 Bus:2 BitClear16 2 12
sleep 1

#sending the data to server
scp $fileid asuwansiri@99.99.99.99:/xxx/asuwansiri/data/xxx
sleep 1
ssh asuwansiri@99.99.99.99 "cd /xxx/asuwansiri/data/4200stack; scp $fileid petropoweroil@dashboard.petropower.com:/var/www/vhost4/petropoweroil/www/data_files/4200stack; ssh petropoweroil@dashboard.petropower.com "/usr/bin/curl -silent -o test.text https://dashboard.petropower.com/4200stack_update.ppo""
#remove
#rm /home/APSoftware/HydroStatic/$fileid
sleep 1
#ts8160ctl --sleep 900
echo "Sleeping"

else

echo "wait 2 secs"
sleep 2
tsctl --server &

fi
done