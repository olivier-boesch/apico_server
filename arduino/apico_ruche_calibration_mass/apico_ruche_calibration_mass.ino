#include <HX711.h>

//----------- Mass sensor params
#define TIMES 2
#define GAIN 64  //or 128
#define SCALE -30000.0
#define MASS_DATA 6
#define MASS_CLK 5
//----------- Mass sensor
HX711 mass_sensor;

long offset = 0;

void setup() {
  Serial.begin(115200);
  while (!Serial)
    ;
  Serial.println("---Mass Calibration Sketch");
  Serial.print("Starting Load Sensor (avg on ");
  Serial.print(TIMES);
  Serial.print(" readings) ");
  Serial.println("-- Mass Sensor Setup");
  mass_sensor.begin(MASS_DATA, MASS_CLK);
  mass_sensor.wait_ready(200);
  Serial.println("done.");
  Serial.println("-- Mass Sensor Setup Finished.");
  mass_sensor.set_gain(GAIN);
  mass_sensor.tare(TIMES);
  offset = mass_sensor.get_offset();
  Serial.print("offset is ");
  Serial.println(offset);
}

void loop() {
  long reading = mass_sensor.read_average(TIMES);
  Serial.print("Offset: ");
  Serial.print(offset);
  Serial.print("\tRaw Mass (w/o off): ");
  Serial.print(reading);
  Serial.print("\tScaled Mass: ");
  Serial.print((reading - offset) / SCALE);
  Serial.println("kg");
  delay(300);
}
