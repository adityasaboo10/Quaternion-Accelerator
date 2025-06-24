#include <Wire.h>
#include <MPU6050.h>

MPU6050 imu;

const float ACCEL_SCALE = 16384.0;
const float GYRO_SCALE = 131.0;
const float GRAVITY = 9.80665;
const float DEG_TO_RAD_CONV = 3.14159265 / 180.0;  

struct SmallQuat { 
  float w, x, y, z;
};

void setup() {
  Serial.begin(9600);
  Wire.begin();
  imu.initialize();

  if (imu.testConnection()) {
    Serial.println("MPU6050 connection successful");
  } else {
    Serial.println("MPU6050 connection failed");
    while (1);
  }
}

void loop() {
  int16_t ax_raw, ay_raw, az_raw;
  int16_t gx_raw, gy_raw, gz_raw;

  imu.getMotion6(&ax_raw, &ay_raw, &az_raw, &gx_raw, &gy_raw, &gz_raw);  //getting raw data

  float ax = (ax_raw / ACCEL_SCALE) * GRAVITY;       //converting it to desired units 
  float ay = (ay_raw / ACCEL_SCALE) * GRAVITY;
  float az = (az_raw / ACCEL_SCALE) * GRAVITY;

  float gx = (gx_raw / GYRO_SCALE) * DEG_TO_RAD_CONV;         //in radians
  float gy = (gy_raw / GYRO_SCALE) * DEG_TO_RAD_CONV;
  float gz = (gz_raw / GYRO_SCALE) * DEG_TO_RAD_CONV;

  // Create small rotation quaternion (dq) from gyro angular velocity   (\ sampling rate dt defined above)
  float theta_x = gx * dt / 2.0;
  float theta_y = gy * dt / 2.0;
  float theta_z = gz * dt / 2.0;

  SmallQuat dq = {1.0, theta_x, theta_y, theta_z};         //the final qaunternion using small angle approximation 

  Serial.print("Accel (m/s²): ");                    //acc data
  Serial.print("X="); Serial.print(ax, 2);
  Serial.print(" Y="); Serial.print(ay, 2);
  Serial.print(" Z="); Serial.print(az, 2);

  Serial.print(" | Rotation Quaternion (dq): ");        //rotation qaunternion data 
  Serial.print("w="); Serial.print(dq.w, 4);         //printing dq.w with 4 numbers after decimal (can be increased for precision)
  Serial.print(" x="); Serial.print(dq.x, 4);
  Serial.print(" y="); Serial.print(dq.y, 4);
  Serial.print(" z="); Serial.println(dq.z, 4);

  delay(500);
}
