#include <SPI.h>

volatile int16_t a, x, y, z;
volatile uint8_t byte_counter = 0;
volatile bool data_ready = false;

void setup() {
  Serial.begin(9600);
  Serial.println("SPI Slave Initialized. Waiting for data (LSB first)...");

  pinMode(MISO, OUTPUT);
  SPCR |= _BV(SPE);
  SPCR |= _BV(SPIE);
}

ISR(SPI_STC_vect) {
  static uint8_t buffer[8];
  uint8_t received_byte = SPDR;

  if (byte_counter < 8) {
    buffer[byte_counter] = received_byte;
    byte_counter++;
  }
  
  if (byte_counter >= 8) {
    a = (buffer[1] << 8) | buffer[0];
    x = (buffer[3] << 8) | buffer[2];
    y = (buffer[5] << 8) | buffer[4];
    z = (buffer[7] << 8) | buffer[6];

    byte_counter = 0;
    data_ready = true;
  }
}

void loop() {
  if (data_ready) {
    Serial.print("a=");
    Serial.print(a);
    Serial.print(" ,x=");
    Serial.print(x);
    Serial.print(" ,y=");
    Serial.print(y);
    Serial.print(" ,z=");
    Serial.println(z);

    data_ready = false;
  }
}