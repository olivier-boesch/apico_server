#include <EEPROM.h>

long offset = 0;
float mult = 1;

long offset2;
float mult2;

#define OFFSETADDRESS 0
#define MULTADDRESS (OFFSETADDRESS+sizeof(offset))

void setup() {
  Serial.begin(115200);
  while(!Serial);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  delay(100);
  EEPROM.put(OFFSETADDRESS, offset);
  EEPROM.put(MULTADDRESS, mult);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(100);
  EEPROM.get(OFFSETADDRESS, offset2);
  EEPROM.get(MULTADDRESS, mult2);
  Serial.print("mass = (raw - ");
  Serial.print(offset2);
  Serial.print(" )/ ");
  Serial.println(mult2,5);
}

void loop() {
  //nothing to do.
}
