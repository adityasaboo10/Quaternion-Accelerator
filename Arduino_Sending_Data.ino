#include <Wire.h>
  #include <MPU6050.h>

  MPU6050 imu;

  const float GYRO_SCALE = 131.0;
  const float DEG_TO_RAD_CONV = 3.14159265 / 180.0;  
  const float dt = 0.01;

  const int CSPin = 10;
  const int ClkPin = 11;
  const int MOSIPin = 12;

  const int ClockDelay = 5;

  struct quaternion { 
    float w, x, y, z;
  };

  void setup() {
    Serial.begin(9600);
    Wire.begin();
    imu.initialize();

    pinMode (CSPin, OUTPUT);
    pinMode (ClkPin, OUTPUT);
    pinMode (MOSIPin, OUTPUT);

    digitalWrite (CSPin, HIGH);
    digitalWrite (ClkPin, LOW);
    digitalWrite (MOSIPin, LOW);
  }

  int16_t floatToQ15(float val) {
  val = constrain(val, -1.0f, 1.0f); 
  return (int16_t)(val * 32767.0f);
  }

  void Clock() {
    digitalWrite(ClkPin, HIGH);
    delayMicroseconds(ClockDelay);
    digitalWrite(ClkPin, LOW);
    delayMicroseconds(ClockDelay);
  }

  void send16Bits(int16_t data) {
    for (int i = 15; i >= 0; i--) {
      digitalWrite(MOSIPin, (data >> i) & 0x01);
      Clock();
    } 
  }

  void loop() {
    int16_t gx_raw, gy_raw, gz_raw;

    imu.getRotation(&gx_raw, &gy_raw, &gz_raw);  

    float gx = (gx_raw / GYRO_SCALE) * DEG_TO_RAD_CONV;         
    float gy = (gy_raw / GYRO_SCALE) * DEG_TO_RAD_CONV;
    float gz = (gz_raw / GYRO_SCALE) * DEG_TO_RAD_CONV;

    float omega_mag = sqrt(gx * gx + gy * gy + gz * gz);
    float theta = omega_mag * dt;
    float vx = 0, vy = 0, vz = 0;

    if (omega_mag > 0.00001){ 
      vx = gx / omega_mag;
      vy = gy / omega_mag;
      vz = gz / omega_mag;
    }

    quaternion dq;

    dq.w = cos(theta / 2.0);
    dq.x = vx * sin(theta / 2.0);
    dq.y = vy * sin(theta / 2.0);
    dq.z = vz * sin(theta / 2.0);
    
    int16_t dq_w_q15 = floatToQ15(dq.w);
    int16_t dq_x_q15 = floatToQ15(dq.x);
    int16_t dq_y_q15 = floatToQ15(dq.y);
    int16_t dq_z_q15 = floatToQ15(dq.z);

    int16_t q_data[4] = {dq_w_q15, dq_x_q15, dq_y_q15, dq_z_q15};

    digitalWrite(CSPin, LOW);

    for (int i = 0; i < 4; i++) {
      send16Bits(q_data[i]);  // Send 16-bit signed data
      delayMicroseconds(ClockDelay * 2);
    }

    digitalWrite(CSPin, HIGH);

    delay(500);
  }