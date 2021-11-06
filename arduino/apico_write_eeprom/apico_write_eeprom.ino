#include <EEPROM.h>

#define CLIENT_ADDRESS_POS 0  //client address position in eeprom
#define CLIENT_ADDRESS_SIZE sizeof(uint8_t)
#define MASS_OFFSET_POS CLIENT_ADDRESS_POS + CLIENT_ADDRESS_SIZE  //mass sensor offset in eeprom
#define MASS_OFFSET_SIZE sizeof(unsigned long)
#define MASS_SCALE_POS MASS_OFFSET_POS + MASS_OFFSET_SIZE //mass sensor scale in eeprom
#define MASS_SCALE_SIZE sizeof(float)
#define MASS_GAIN_POS MASS_SCALE_POS + MASS_SCALE_SIZE //mass sensor gain in eeprom
#define MASS_GAIN_SIZE sizeof(uint8_t)

void setup() {
  Serial.begin(9600);
  while(!Serial);
  Serial.println("Writing Parameters to EEPPROM");
  uint8_t node = 1;
  EEPROM.put(CLIENT_ADDRESS_POS, node);
  unsigned long mass_offset = 20000;
  EEPROM.put(MASS_OFFSET_POS, mass_offset);
  float mass_scale = 1000.0;
  EEPROM.put(MASS_SCALE_POS, mass_scale);
  byte mass_gain = 64;
  EEPROM.put(MASS_GAIN_POS, mass_gain);
  Serial.println("done.");
}

void loop() {
}
