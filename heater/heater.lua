#!/usr/bin/lua

-- Constants
local HEAT_SAMPLE_SECONDS = 300 
local HEAT_HISTORY_DAYS = 90 
local HEAT_DATABASE = "/heater/heat.rrd"
local HEAT_LOGFILE = "/heater/heat.log"
local HEAT_LOGOPEN = 0
local HEAT_TEMPERATURE = 2.5 
local RRDTOOL = "/usr/bin/rrdtool"

-- RRA: MIN stores 2160 records, each calculated using last 12 PDPs (5 min * 12) = 1 hour
-- RRA: MAX stores 2160 records, each calculated using last 12 PDPs (5 min * 12) = 1 hour
-- RRA: AVG stores 25920 PDPs (25920 * 5 min = 2160 hours = 90 days)
local RRDTOOL_CREATE = RRDTOOL .. " create %s --start $(date +%%s) --step %d DS:probe1:GAUGE:600:-55:55 DS:probe2:GAUGE:600:-55:55 RRA:MIN:0.5:12:%d RRA:MAX:0.5:12:%d RRA:AVERAGE:0.5:1:%d"
local RRDTOOL_UPDATE = RRDTOOL .. " update %s $(date +%%s):%s:%s"
local DEBUG = 1

--require "luarocks.loader"
local socket = require("socket")

local function log_open()
  if HEAT_LOGOPEN == 0 then
    HEAT_LOGOPEN = 1
    io.output(HEAT_LOGFILE);
  end
end

local function log(m)
  log_open()
  io.write(os.date()..": "..m.."\n")
  io.flush()
end

local function dbg(m)
  if DEBUG == 1 then 
    log_open()
    io.write(os.date()..": "..m.."\n")
    io.flush()
  end
end

function sleep(n)
  os.execute("sleep ".. tonumber(n))
end 

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function create_database()
  if not file_exists(HEAT_DATABASE) then
    log("Creating database: " .. HEAT_DATABASE)
    local RRA_MIN_SAMPLES = HEAT_HISTORY_DAYS*24
    local RRA_MAX_SAMPLES = HEAT_HISTORY_DAYS*24
    local RRA_AVG_SAMPLES = HEAT_HISTORY_DAYS*24*60*60 / HEAT_SAMPLE_SECONDS
    local cmd = string.format(RRDTOOL_CREATE, HEAT_DATABASE, HEAT_SAMPLE_SECONDS, RRA_MIN_SAMPLES, RRA_MAX_SAMPLES, RRA_AVG_SAMPLES)
    dbg(cmd)
    assert(os.execute(cmd) == 0)
  end
end

local function update_database(tempc, heatc)
  local cmd = string.format(RRDTOOL_UPDATE, HEAT_DATABASE, tempc, heatc)
  dbg(cmd)
  -- assert(os.execute(cmd) == 0)
  local error_code = os.execute(cmd)
  if error_code ~= 0 then
    log("ERROR: Failed to update database error code="..error_code)
  end
end

local function connect_serial(s, host, port)
  log("Connecting to serial..")
  assert(s:connect(host, port))
  assert(s:send("PING\n"))
  log("Waiting device to restart..")
  sleep(2)
  log("Connected")
end

local function read_temperature(s)
  dbg("read_temperature")
  assert(s:send("TEMP\n"))
  local response = s:receive("*l")
  dbg(response)
  for tempc in string.gmatch(response, "(%-?%d+.%d+)") do
    if tonumber(tempc) > tonumber(HEAT_TEMPERATURE) then
      update_database(tempc, -100)
    else
      update_database(tempc, HEAT_TEMPERATURE)
    end
  end
end

local function set_auto_temperature(s,newval)
  dbg("set_auto_temperature(" .. newval..")")
  assert(s:send("AUTO "..newval.."\n"))
  local response = s:receive("*l")
  dbg(response)
end

local function main()
  local s = assert(socket.tcp())
  create_database()
  connect_serial(s, "127.0.0.1", 2000)
  set_auto_temperature(s, HEAT_TEMPERATURE)
  while(1) do
    read_temperature(s)
    sleep(HEAT_SAMPLE_SECONDS)
  end
end

main()
