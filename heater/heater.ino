

#include <OneWire.h>
#include <DallasTemperature.h>

#include "commands.h"

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

void setup(void)
{
  Serial.begin(9600);
  Serial.flush();
  pinMode(HEAT_LED_PIN, OUTPUT);
  pinMode(HEAT_RELAY_PIN, OUTPUT);
  pinMode(POWER_LED_PIN, OUTPUT);
  digitalWrite(POWER_LED_PIN, HIGH);  
  sensors.begin(); 
}

void loop(void)
{
  processCommands();
  sensors.requestTemperatures();   
  processTemperature(sensors.getTempCByIndex(0)); 
  delay(300);
}

