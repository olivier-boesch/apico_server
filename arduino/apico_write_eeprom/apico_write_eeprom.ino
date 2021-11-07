#include <EEPROM.h>

#define CLIENT_ADDRESS_POS 0  //client address position in eeprom
#define CLIENT_ADDRESS_SIZE sizeof(uint8_t)
#define MASS_OFFSET_POS CLIENT_ADDRESS_POS + CLIENT_ADDRESS_SIZE  //mass sensor offset in eeprom
#define MASS_OFFSET_SIZE sizeof(long)
#define MASS_SCALE_POS MASS_OFFSET_POS + MASS_OFFSET_SIZE //mass sensor scale in eeprom
#define MASS_SCALE_SIZE sizeof(float)
#define MASS_GAIN_POS MASS_SCALE_POS + MASS_SCALE_SIZE //mass sensor gain in eeprom
#define MASS_GAIN_SIZE sizeof(uint8_t)

uint8_t node = 1;
long mass_offset = 20000;
float mass_scale = 1000.0;
uint8_t mass_gain = 64;

void setup() {
  Serial.begin(115200);
  while(!Serial);
  Serial.println("Writing Parameters to EEPPROM");
  Serial.print("Node address:");
  Serial.println(node);
  EEPROM.put(CLIENT_ADDRESS_POS, node);
  Serial.print("Mass Offset:");
  Serial.println(mass_offset);
  EEPROM.put(MASS_OFFSET_POS, mass_offset);
  Serial.print("Mass Scale:");
  Serial.println(mass_scale);
  EEPROM.put(MASS_SCALE_POS, mass_scale);
  Serial.print("Mass Gain:");
  Serial.println(mass_gain);
  EEPROM.put(MASS_GAIN_POS, mass_gain);
  Serial.println("done.");
}

void loop() {
}
