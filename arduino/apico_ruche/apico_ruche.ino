/*
 * 
 * Apico Ruche Arduino
 * 
 *  Olivier Boesch (c) 2021
 * 
 */

//timer lib
#include <SimpleTimer.h>
//include for env sensor
#include <Wire.h>
#include <SparkFun_SCD30_Arduino_Library.h>
//include for eeprom params read
#include <EEPROM.h>
//include for LORA radio
#include <RHReliableDatagram.h>
#include <RH_RF95.h>
#include <SPI.h>
//include for mass amp
#include <HX711.h>
//include for beesio
#include "SR4021.h"

//comment this if you don't want debug over serial
#define DEBUG 

#define TIMER_TRANSMIT 8000 //ms - should send every hour (3600000 ms) in production and 10s (6000ms) for tests
SimpleTimer message_timer(TIMER_TRANSMIT);

//----------- EEPROM Params and addresses
#define CLIENT_ADDRESS_POS 0  //client address position in eeprom
#define CLIENT_ADDRESS_SIZE sizeof(uint8_t)
#define MASS_OFFSET_POS CLIENT_ADDRESS_POS + CLIENT_ADDRESS_SIZE  //mass sensor offset in eeprom
#define MASS_OFFSET_SIZE sizeof(unsigned long)
#define MASS_SCALE_POS MASS_OFFSET_POS + MASS_OFFSET_SIZE //mass sensor scale in eeprom
#define MASS_SCALE_SIZE sizeof(float)
#define MASS_GAIN_POS MASS_SCALE_POS + MASS_SCALE_SIZE //mass sensor gain in eeprom
#define MASS_GAIN_SIZE sizeof(uint8_t)

//----------- Bees IO params
#define BEESIO_DATA 7  //data pin
#define BEESIO_CLK 8   //clock pin
#define BEESIO_LATCH 9 //latch pin to freeze data
#define BEESIO_REGISTER_COUNT 6 //register count in the pcb
ShiftRegister4021BP beesio_sensor(BEESIO_REGISTER_COUNT, BEESIO_DATA, BEESIO_CLK, BEESIO_LATCH);
uint32_t bees_in = 0;  //number of incoming bees
uint32_t bees_out = 0; //number of outcoming bees
uint8_t bees_data[BEESIO_REGISTER_COUNT]; //data of bees io sensor
//create table for triggers and init to 0 (one per sensor)
uint8_t bees_data_trig[BEESIO_REGISTER_COUNT];
//create table for inside bits and init to 0 (one per sensor pair)
uint8_t bees_inside[BEESIO_REGISTER_COUNT/2];

//----------- Radio params
#define SERVER_ADDRESS 254  //server address on LORA
#define RFM95_CS       4     //SPI channel select or slave select pin
#define RFM95_INT      3    //SPI interupt pin for data "ready" function
#define RFM95_RST      2     //Reset pin for initial reset of module
#define RFM95_FREQ     433.0  //Frequency Set function 915 MHz

//Radio Driver
RH_RF95 rf95(RFM95_CS, RFM95_INT); // (SlaveSelectPin, interrupt pin) Use standard SPI connections on Uno

// Class to manage message delivery and receipt, using the driver declared above
RHReliableDatagram * radio;
//message buffer
char buf[50];

//----------- Mass sensor params
#define MASS_DATA 6
#define MASS_CLK 5
//mass sensor
HX711 mass_sensor;
float mass = 0; //mass value

//----------- CO2, T, RH sensor params
SCD30  env_sensor;
float co2 = 0.0;
float temperature = 0.0;
float humidity = 0.0;

//Client client address programmed in eeprom
uint8_t get_client_address(){
  uint8_t client_address;
  EEPROM.get(CLIENT_ADDRESS_POS, client_address);
  return client_address;
}

unsigned long get_mass_offset(){
  unsigned long mass_offset;
  EEPROM.get(MASS_OFFSET_POS, mass_offset);
  return mass_offset;
}

float get_mass_scale(){
  float mass_scale;
  EEPROM.get(MASS_SCALE_POS, mass_scale);
  return mass_scale;
}

byte get_mass_gain(){
  byte mass_gain;
  EEPROM.get(MASS_GAIN_POS, mass_gain);
  return mass_gain;
}

//radio_setup
void setup_radio(){
  #ifdef DEBUG
      Serial.println("-- LORA Radio Setup");
  #endif
  uint8_t client_address = get_client_address();
  #ifdef DEBUG
      Serial.print("Client address is: ");
      Serial.println(client_address);
    Serial.print("Radio reset...");
  #endif
  pinMode(RFM95_RST, OUTPUT);
  //initialize reset pin
  digitalWrite(RFM95_RST, HIGH);  
  // manual reset module
  digitalWrite(RFM95_RST, LOW);
  delay(10);
  digitalWrite(RFM95_RST, HIGH);
  delay(10);
  #ifdef DEBUG
    Serial.println("done.");
    Serial.print("LORA init...");
  #endif
  //initialize RFM95 radio
  if (!rf95.init()) {
    #ifdef DEBUG
      Serial.println("failed");
    #endif
    while(1);
  }
  #ifdef DEBUG
    Serial.println("done.");
    Serial.print("Radio init...");
  #endif
  radio = new RHReliableDatagram(rf95, client_address);
  if(!radio->init()){
    #ifdef DEBUG
      Serial.println("failed.");
    #endif
    while(1);
  }
  #ifdef DEBUG
    Serial.println("done.");
  #endif
  //Set frequency
  #ifdef DEBUG
    Serial.print("frequency(MHz) set to: ");
    Serial.println(RFM95_FREQ, 1);
  #endif
  if (!rf95.setFrequency(RFM95_FREQ)) {
     //Serial.println("setFrequency failed");
  }
  //set crc on
  #ifdef DEBUG
    Serial.println("enable CRC check");
  #endif
  rf95.setPayloadCRC(true);
  //set power to 23db (max)
  #ifdef DEBUG
    Serial.println("set transmit power to 23dB");
  #endif
  rf95.setTxPower(23, false); //Set transmitter power, 23 dBm and false (no RFO pins)
  #ifdef DEBUG
      Serial.println("-- LORA Radio Setup Finished.");
  #endif
}

//mass sensor setup
void setup_mass(){
  #ifdef DEBUG
    Serial.println("-- Mass Sensor Setup");
  #endif
  mass_sensor.begin(MASS_DATA, MASS_CLK, get_mass_gain());
  mass_sensor.set_scale(get_mass_scale());
  mass_sensor.set_offset(get_mass_offset());
  #ifdef DEBUG
    Serial.print("gain:");
    Serial.print(get_mass_gain());
    Serial.print("\toffset:");
    Serial.print(get_mass_offset());
    Serial.print("\tscale:");
    Serial.println(get_mass_scale());
    Serial.print("Waiting the sensor to become ready...");
  #endif
  mass_sensor.wait_ready(200);
  #ifdef DEBUG
    Serial.println("done.");
  #endif
  #ifdef DEBUG
      Serial.println("-- Mass Sensor Setup Finished.");
  #endif
}

//Environement (co2, t, rh) sensor setup
void setup_env(){
  #ifdef DEBUG
    Serial.println("-- Environement Sensor Setup");
  #endif
  Wire.begin();
  #ifdef DEBUG
      Serial.print("Waiting the sensor to become ready...");
  #endif
  if (!env_sensor.begin())
  {
    #ifdef DEBUG
      Serial.println("Air sensor not detected. Please check wiring. Freezing...");
    #endif
    while(true);
  }
  #ifdef DEBUG
      Serial.println("done.");
      Serial.println("-- Environement Sensor Setup Finished.");
  #endif
}

//beesio setup
void setup_beesio(){
    //done by the lib
    //bees_data = (uint8_t *) malloc(BEESIO_REGISTER_COUNT * sizeof(uint8_t));
    //memset(bees_data, 0, BEESIO_REGISTER_COUNT * sizeof(uint8_t));
    memset(bees_data_trig, 0, BEESIO_REGISTER_COUNT * sizeof(uint8_t));
    memset(bees_inside, 0, BEESIO_REGISTER_COUNT * sizeof(uint8_t));
}

//get the right bit in the table
bool get_bee_bit_at(uint8_t idx, uint8_t * t){
  return (t[idx / 8] >> (idx % 8)) & 1;
}

//set the right bit in the table
void set_bee_bit_at(uint8_t idx, uint8_t * t, uint8_t state){
  t[idx / 8] = (t[idx / 8] & ~((uint8_t) 1 << (idx % 8))) | (state << (idx % 8));
}


//update beesio counters from states
void update_beesio(){
  beesio_sensor.getAll(bees_data);
  uint8_t s1, s2;
  uint8_t s1_trig=0, s2_trig=0;
  uint8_t inside=0;
  //for each bit in a half table (one half for front, the other for rear)  
  for(uint8_t i=0; i < BEESIO_REGISTER_COUNT * 8 / 2; i++){
    //extract right bits from table
    s1 = get_bee_bit_at(i, bees_data);
    s2 = get_bee_bit_at(i+BEESIO_REGISTER_COUNT * 8 / 2, bees_data);
    if(!s1 && !inside && s1_trig){
      inside = 0;
      s1_trig = 0;
    }
    if(!s2 && inside && s2_trig){
      inside = 0;
      bees_in ++;
      s2_trig = 0;
    }
    if(!s2 && !inside && s2_trig){
      inside = 1;
      s2_trig = 0;
    }
    if(!s1 && inside && s1_trig){
      inside = 0;
      bees_out ++;
      s1_trig = 0;
    }
    if(s1){
      s1_trig = 1;
    }
    if(s2){
      s2_trig = 1;
    }
    //store bits for the next time
    set_bee_bit_at(i, bees_data_trig, s1_trig);
    set_bee_bit_at(i+BEESIO_REGISTER_COUNT * 8 / 2, bees_data_trig, s2_trig);
    set_bee_bit_at(i, bees_inside, inside);
    #ifdef DEBUG
      /*Serial.print("Bees\tIn:");
      Serial.print(bees_in);
      Serial.print("\tOut:");
      Serial.println(bees_out);*/
    #endif
  }
  //free memory allocated by the lib
  free(bees_data);
}

//reset beesio counters
void reset_beesio(){
  bees_in = 0;
  bees_out = 0;
}

void send_message(){
  mass = mass_sensor.get_units(2);
  //while(!env_sensor.dataAvailable());
  co2 = env_sensor.getCO2();
  temperature = env_sensor.getTemperature();
  humidity = env_sensor.getHumidity();
  sprintf(buf, "{\"M\":%d,\"T\":%d,\"H\":%d,\"C\":%d,\"I\":%d,\"O\":%d}", (unsigned int) mass*100, (unsigned int) temperature*10, (unsigned int) humidity*10, (unsigned int) co2, bees_in, bees_out);
  #ifdef DEBUG
    Serial.println("send message...");
  #endif
  
  //send message over LORA
  #ifdef DEBUG
    Serial.println(buf);
  #endif
  if(!radio->sendtoWait((uint8_t*)&buf, strlen(buf), SERVER_ADDRESS)){
    #ifdef DEBUG
      Serial.println("nack");
    #endif
  }
  else{
    #ifdef DEBUG
      Serial.println("ack");
    #endif
    reset_beesio();
  }
}

void setup() 
{
  #ifdef DEBUG
    Serial.begin(115200);
    while(!Serial);
  #endif
  #ifdef DEBUG
      Serial.println("---- APICO HIVE ARDUINO CODE ----");
  #endif
  setup_radio();
  setup_mass();
  setup_env();
  setup_beesio();
}


void loop()
{
  update_beesio();
  if(message_timer.isReady()){
    #ifdef DEBUG
      Serial.println("...Send message");
    #endif
    send_message();
    message_timer.reset();  
  }
}
