logger Heater starting ser2net 
/usr/sbin/ser2net -c /etc/ser2net.conf 2>/heater/error.log & 
sleep 1
logger Heater starting LUA script 
/usr/bin/lua /heater/heater.lua 2>/heater/error.log &
echo $! > /heater/heater.pid
logger Heater script started pid=$(cat /heater/heater.pid)
