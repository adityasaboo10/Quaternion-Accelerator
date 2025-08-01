# Hardware Accelerator for Quaternion Multiplication

This repository contains the Verilog and Arduino code for a hardware accelerator designed for real-time quaternion multiplication, developed as part of the IIT Indore Summer of Code (IITISOC) 2025. The project focuses on accelerating orientation estimation using data from an Inertial Measurement Unit (IMU) by offloading computationally intensive quaternion calculations to an FPGA.

The system reads gyroscopic data from an MPU6050 IMU, processes it on an Arduino, and sends it to an FPGA for high-speed multiplication. The core of this project is the comparison between two different hardware implementations for quaternion multiplication: a standard **direct method** and an optimized **Hadamard transform-based method**.

---

## Key Features

* [cite_start]**Hardware Acceleration:** Offloads quaternion multiplication from a general-purpose CPU to dedicated hardware (FPGA) for significant performance gains[cite: 30, 54].
* **Dual Implementation:** Features two distinct Verilog implementations for multiplication:
    * [cite_start]**Direct Design:** A straightforward approach based on the standard mathematical formula[cite: 35, 105, 106].
    * [cite_start]**Algorithmic (Hadamard) Acceleration:** An optimized method that reduces the number of required multiplications from 16 to 8, lowering latency and resource consumption[cite: 35, 124, 170].
* [cite_start]**Pipelined Architecture:** Both multiplication methods are pipelined to increase data throughput, making them suitable for real-time applications[cite: 35, 179, 519].
* [cite_start]**IMU Integration:** Designed to process live data from an MPU6050 IMU for orientation tracking[cite: 34, 68].
* [cite_start]**FPGA-Arduino Communication:** Uses the SPI protocol for efficient and reliable data exchange between the FPGA and an Arduino microcontroller[cite: 70, 90].
* [cite_start]**Clock Domain Synchronization:** Employs Asynchronous FIFO (First-In, First-Out) buffers to safely manage data transfer between the unsynchronized clock domains of the FPGA and Arduino, preventing data loss[cite: 99, 507, 513].
* [cite_start]**Bonus I2C Module:** Includes an optional I2C master logic design in Verilog, allowing the FPGA to directly communicate with I2C sensors and eliminating the need for an intermediate microcontroller[cite: 483, 484].

---

## System Architecture

[cite_start]The system is partitioned into hardware (FPGA) and software (Arduino) components to balance functionality and performance[cite: 79].

* **Arduino (Software Domain)**:
    1.  [cite_start]Configures and reads gyroscopic data from the MPU6050 IMU via the I2C protocol[cite: 67, 86].
    2.  [cite_start]Converts the raw angular velocity data into 16-bit quaternion components[cite: 69].
    3.  [cite_start]Acts as the SPI master to serialize and transmit the quaternion data to the FPGA[cite: 70, 91].
    4.  [cite_start]Receives the final computed quaternions back from the FPGA and displays them[cite: 77, 82].

* **FPGA (Hardware Domain)**:
    1.  [cite_start]Acts as the SPI slave, receiving serialized data into shift registers[cite: 71].
    2.  [cite_start]Uses asynchronous FIFO buffers to store incoming quaternions, managing the clock speed difference with the Arduino[cite: 75, 102].
    3.  [cite_start]Performs quaternion multiplication using either the direct or the accelerated hardware module[cite: 82].
    4.  [cite_start]Sends the 32-bit result back to the Arduino via SPI for display[cite: 77].

---

## Performance and Simulation Results

[cite_start]The designs were simulated and analyzed using Vivado, with a focus on correctness, clock cycles (latency), and resource utilization (LUTs and Flip-Flops)[cite: 230, 232]. [cite_start]The results clearly demonstrate the superiority of the pipelined algorithmic approach[cite: 259].

### Comparison of Multiplication Methods

[cite_start]The following table summarizes the simulation results for performing six multiplications[cite: 260, 261]:

| Implementation Method | Clock Cycles | LUTs Used | Flip Flops Used |
| :--- | :---: | :---: | :---: |
| Simple Multiplication | 360 | 3119 | 0 |
| Algorithmic Multiplication | 260 | 2026 | 0 |
| Pipelined Simple Multiplication | 293 | 3192 | 520 |
| **Pipelined Algorithmic Multiplication** | **153** | **1900** | **610** |

[cite_start]As shown, the **Pipelined Algorithmic (Hadamard) Multiplication** is the most efficient design, offering the lowest latency (153 clock cycles) and consuming the fewest Look-Up Tables (LUTs) (1900), making it ideal for resource-constrained FPGAs[cite: 259].

*Note: All designs were validated through simulation in Vivado. [cite_start]No physical deployment on FPGA hardware was performed[cite: 231, 239].*

---

## Repository Content

[cite_start]This repository contains all the necessary files for the project[cite: 551].

* **`/verilog`**: Verilog source files for all hardware modules.
    * [cite_start]`direct_multiplier.v`: The standard quaternion multiplier[cite: 105].
    * [cite_start]`algorithmic_multiplier.v`: The Hadamard transform-based multiplier[cite: 123].
    * [cite_start]`pipelined_direct.v`: Pipelined version of the direct multiplier[cite: 177].
    * [cite_start]`pipelined_algorithmic.v`: Pipelined version of the Hadamard multiplier[cite: 177].
    * [cite_start]`spi_module.v`: SPI slave logic for communication[cite: 90].
    * [cite_start]`async_fifo.v`: Asynchronous FIFO buffer[cite: 98].
    * [cite_start]`i2c_master.v`: Optional I2C master controller[cite: 483, 488].
* **`/arduino`**: Arduino sketches.
    * [cite_start]`transmitter.ino`: Code to read from the IMU and send data to the FPGA[cite: 196].
    * [cite_start]`receiver.ino`: Code to receive processed data from the FPGA and display it[cite: 207].
* [cite_start]**`/simulation`**: Vivado testbenches used for verifying the designs with real IMU data[cite: 520].


