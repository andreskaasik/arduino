
#if ARDUINO >= 100
#include "Arduino.h"
#endif

//#define DEBUG 1

#include "string.h"
#include "commands.h"

// Commands
#define CMD_HEAT_MODE "HEAT"
#define CMD_HEAT_TEMP "AUTO"
#define CMD_LAST_TEMP "TEMP"

// Critical level to swicth heater on
#ifdef DEBUG
#define HEAT_TEMPERATURE float(28.0)
#else    
#define HEAT_TEMPERATURE float(1.0)
#endif    

// Heater modes
typedef enum
{
  HEAT_MODE_OFF = 0,
  HEAT_MODE_ON = 1,
  HEAT_MODE_AUTO = 2

} HeatMode;

bool doCommandHeatMode(const String& arg);
bool doCommandHeatTemperature(const String& arg);
bool doCommandLastTemperature();

static String receiveBuffer;
static float heatTemperature = HEAT_TEMPERATURE;
static float lastTemperature = 0.0;
static HeatMode heatMode = HEAT_MODE_AUTO;
static bool heating = false;

char* HeatModeToStr(HeatMode mode) 
{
  switch (mode) {
    case (HEAT_MODE_OFF):
      return "OFF";
    case (HEAT_MODE_ON):
      return "ON";
    case (HEAT_MODE_AUTO):      
      return "AUTO";
    default:
      return "UNKNOWN";
  }   
}

void serialWriteError(char* msg)
{
  Serial.print("ERROR: ");
  Serial.println(msg);
}

void serialWriteLastTemperature()
{
  Serial.print("TEMP ");
  Serial.println(lastTemperature);
}

void serialWriteHeatTemperature()
{
  Serial.print("AUTO ");
  Serial.println(heatTemperature);
}

void serialWriteHeatMode(HeatMode mode)
{
  Serial.print("HEAT ");
  Serial.println(HeatModeToStr(mode));
}

void switchHeaterOn()
{ 
  if (!heating)
  {
    heating = true;
#ifdef DEBUG
    Serial.println("switch heater on");
#endif    
    digitalWrite(HEAT_LED_PIN, HIGH);
    digitalWrite(HEAT_RELAY_PIN, HIGH);
  }
}

void switchHeaterOff()
{
  if (heating)
  {
    heating = false;
#ifdef DEBUG
    Serial.println("switch heater off");
#endif      
    digitalWrite(HEAT_LED_PIN, LOW);
    digitalWrite(HEAT_RELAY_PIN, LOW);
  }
}

void processCommands()
{  
  while (Serial.available() > 0)
  {
    char val = Serial.read();    
    if (val == '\n')
    {
      String command, argument;
      receiveBuffer.trim();
      receiveBuffer.toUpperCase();      
      
      int firstSpaceIndex = receiveBuffer.indexOf(' ');
      if (firstSpaceIndex > 0) {
        command = receiveBuffer.substring(0, firstSpaceIndex);
        argument = receiveBuffer.substring(firstSpaceIndex);
      } else {
        command = receiveBuffer;        
      }
      command.trim();
      argument.trim();      

      if (command == CMD_HEAT_MODE)
        doCommandHeatMode(argument);
      else 
      if (command == CMD_HEAT_TEMP)
        doCommandHeatTemperature(argument);
      else 
      if (command == CMD_LAST_TEMP)
        doCommandLastTemperature();
      else
        serialWriteError("invalid command");
        
      receiveBuffer = "";  
    }
    else
    {
      receiveBuffer += val;
    }
  }  
}

bool changeHeatMode(HeatMode newVal)
{
  heatMode = newVal;  
  if (heatMode == HEAT_MODE_ON) {
    digitalWrite(HEAT_LED_PIN, HIGH);
    digitalWrite(HEAT_RELAY_PIN, HIGH);
  } else if (heatMode == HEAT_MODE_OFF) {
    digitalWrite(HEAT_LED_PIN, LOW);
    digitalWrite(HEAT_RELAY_PIN, LOW);
  }
  serialWriteHeatMode(heatMode);
  return true;
}

bool doCommandHeatMode(const String& arg)
{
  if (!arg.length()) {
    serialWriteHeatMode(heatMode);
    return true;
  } else if (arg == "ON") {
    return changeHeatMode(HEAT_MODE_ON);  
  } else if (arg == "OFF") {
    return changeHeatMode(HEAT_MODE_OFF);
  } else if (arg == "AUTO") {
    return changeHeatMode(HEAT_MODE_AUTO);
  } else {
    serialWriteError("invalid argument");
    return false;    
  }
}

void processTemperature(float tempc)
{
  lastTemperature = tempc;
  if (heatMode == HEAT_MODE_AUTO) {
    if (lastTemperature <= heatTemperature)
      switchHeaterOn();
    else 
    if (lastTemperature > (heatTemperature + float(0.5)))
      switchHeaterOff();
  }
#ifdef DEBUG
  serialWriteLastTemperature();
#endif  
}

bool doCommandHeatTemperature(const String& arg)
{
  if (arg.length()) {
    heatTemperature = arg.toInt();   
  }
  serialWriteHeatTemperature();
  return true;
}

bool doCommandLastTemperature()
{
  serialWriteLastTemperature();
}


