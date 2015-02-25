#!/usr/bin/lua

local function main()
  print("Content-Type: text/html")
  print("")
  print("<!DOCTYPE html>")
  print("<head>")
  print("<meta http-equiv=\"refresh\" content=\"300\">")
  print("</head>")
  print("<body>")

  os.execute([[cd /www/heater && rrdtool graph heat_day.png -a PNG \
    --title "Today" \
    --vertical-label "Temp" \
    --width 800 \
    --height 200 \
    --imginfo '<IMG SRC="/heater/%s" WIDTH="%lu" HEIGHT="%lu" ALT="Heater daily graph">' \
    DEF:probe1=/heater/heat.rrd:probe1:AVERAGE \
    DEF:probe2=/heater/heat.rrd:probe2:AVERAGE \
    LINE1:probe1#ff0000:Pipe \
    LINE2:probe2#00ff00:Heat \
    COMMENT:"\\n" \
    GPRINT:probe1:LAST:"Last %2.1lf C" \
    GPRINT:probe1:MAX:"Max %2.1lf C" \
    GPRINT:probe1:MIN:"Min %2.1lf C" \
    GPRINT:probe1:AVERAGE:"Avg %2.1lf C" \
    > heat.tmp
    ]])

  for line in io.lines("/www/heater/heat.tmp") do 
    print(line) 
  end
  print("<p>")

  os.execute([[cd /www/heater && rrdtool graph heat_week.png -a PNG \
    --title "Last week" \
    --vertical-label "Temp" \
    --width 800 \
    --height 200 \
    --start $(( $(date +%s) - 7*24*3600 )) \
    --end $(( $(date +%s) )) \
    --imginfo '<IMG SRC="/heater/%s" WIDTH="%lu" HEIGHT="%lu" ALT="Heater weekly graph">' \
    DEF:probe1=/heater/heat.rrd:probe1:AVERAGE \
    DEF:probe2=/heater/heat.rrd:probe2:AVERAGE \
    LINE1:probe1#ff0000:Pipe \
    LINE2:probe2#00ff00:Heat \
    COMMENT:"\\n" \
    GPRINT:probe1:LAST:"Last %2.1lf C" \
    GPRINT:probe1:MAX:"Max %2.1lf C" \
    GPRINT:probe1:MIN:"Min %2.1lf C" \
    GPRINT:probe1:AVERAGE:"Avg %2.1lf C" \
    > heat.tmp
    ]])

  for line in io.lines("/www/heater/heat.tmp") do 
    print(line) 
  end
  print("<p>")

  os.execute([[cd /www/heater && rrdtool graph heat_month.png -a PNG \
    --title "Last month" \
    --vertical-label "Temp" \
    --width 800 \
    --height 200 \
    --start $(( $(date +%s) - 31*24*3600 )) \
    --end $(( $(date +%s) )) \
    --imginfo '<IMG SRC="/heater/%s" WIDTH="%lu" HEIGHT="%lu" ALT="Heater monthly graph">' \
    DEF:probe1=/heater/heat.rrd:probe1:AVERAGE \
    DEF:probe2=/heater/heat.rrd:probe2:AVERAGE \
    LINE1:probe1#ff0000:Pipe \
    LINE2:probe2#00ff00:Heat \
    COMMENT:"\\n" \
    GPRINT:probe1:LAST:"Last %2.1lf C" \
    GPRINT:probe1:MAX:"Max %2.1lf C" \
    GPRINT:probe1:MIN:"Min %2.1lf C" \
    GPRINT:probe1:AVERAGE:"Avg %2.1lf C" \
    > heat.tmp
    ]])

  for line in io.lines("/www/heater/heat.tmp") do 
    print(line) 
  end
  print("<p>")

  print("</body>")
end

main()
