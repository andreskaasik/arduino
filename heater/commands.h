#ifndef COMMANDS_H
#define COMMANDS

// Pins
#define ONE_WIRE_BUS   2    // Data wire is plugged into port 2 on the Arduino
#define HEAT_LED_PIN   3    // Heater (red) LED
#define HEAT_RELAY_PIN 4    // 220v relay pin
#define POWER_LED_PIN  5    // Power (green) LED

// Command processing
void processCommands();
void processTemperature(float tempc);

#endif // COMMANDS_H
