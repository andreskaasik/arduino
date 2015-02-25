logger Heater stopping pid=$(cat /heater/heater.pid)
kill -KILL $(cat /heater/heater.pid) 2> /dev/null
killall ser2net 2> /dev/null
