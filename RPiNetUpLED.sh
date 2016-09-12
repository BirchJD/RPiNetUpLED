#!/bin/bash

# RPiNetUpLED - Network connected LED indicator.
# Copyright (C) 2016 Jason Birch
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see &lt;http://www.gnu.org/licenses/>.

#/**********************************************************************/
#/* V1.00   2016-09-12  Jason Birch                                    */
#/*                                                                    */
#/* Periodically check the Raspberry Pi Wifi interface is connected by */
#/* pinging the specified network address, if it is successful switch  */
#/* the LED indicator on. If pinging the network address fails, switch */
#/* the LED indicator off and try reestablishing a network connection. */
#/*                                                                    */
#/* This prevents a Raspberry Pi from becoming unreachable. If an      */
#/* attempted connection fails, wait for the check period and retry    */
#/* the connection.                                                    */
#/*                                                                    */
#/* CHECK ROUTER CONNECTIVITY:                                         */
#/* nohup sudo ./RPiNetUpLED.sh 192.168.0.1 &                          */
#/*                                                                    */
#/* CHECK INTERNET CONNECTIVITY:                                       */
#/* nohup sudo ./RPiNetUpLED.sh www.google.com &                       */
#/**********************************************************************/

if [ "$1" == "" ]
then
   echo $0 [PING_ADDRESS]
else
   echo 14 > /sys/class/gpio/export 
   echo out > /sys/class/gpio/gpio14/direction

   while [ 1 -eq 1 ]
   do
      ping -nq -W 1 -I wlan0 -c 1 $1 2>&1 > /dev/null

      if [ $? -eq 0 ]
      then
         echo 1 > /sys/class/gpio/gpio14/value
      else
         echo 0 > /sys/class/gpio/gpio14/value

         sudo ip link set wlan0 down
         sleep 2
         sudo ip link set wlan0 up
      fi

      sleep 15
   done

   echo 14 > /sys/class/gpio/unexport
fi

