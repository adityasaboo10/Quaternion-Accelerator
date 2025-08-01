# Hardware Accelerator for Quaternion Multiplication with Real-Time IMU Orientation Estimation


## Overview

This project presents the design and simulation of a custom hardware accelerator for quaternion multiplication optimized for real-time orientation estimation using IMU data. Quaternions provide a robust way to represent 3D orientation without issues like gimbal lock, widely used in aerospace, robotics, and motion tracking.

The computational complexity of quaternion operations poses challenges for general-purpose processors, so we designed an FPGA-based accelerator to offload these tasks and achieve faster, low-latency processing.

---

## Key Features

- **Two Multiplication Approaches**:  
  - Direct quaternion multiplication based on the classical formula  
  - An optimized algorithmic approach using the Hadamard transform, reducing multiplication operations and improving speed

- **Real-Time IMU Orientation Calculation**:  
  Uses live gyroscope data from MPU6050 IMU sensor processed through an Arduino, which transmits data to the FPGA.

- **FPGA Implementation**:  
  Designed and simulated in Verilog, employing pipelining and asynchronous FIFO buffers for smooth data flow between Arduino and FPGA.

- **Communication Protocol**:  
  SPI protocol enables synchronized and efficient data transfer between Arduino (master) and FPGA (slave), with an optional I2C master integration designed for future expansions.

---

## System Architecture

- **Data Acquisition**: Arduino reads angular velocity from the MPU6050 IMU, converts it to 16-bit quaternion components.
- **Data Transmission**: Quaternion data bits transmitted via SPI protocol to the FPGA.
- **Data Handling**: FPGA uses asynchronous FIFO buffers to synchronize and buffer data between different clock domains.
- **Quaternion Multiplication**:  
   FPGA executes quaternion multiplications using either a direct or Hadamard-based pipelined design.
- **Output Transmission**: Resulting quaternions sent back to the Arduino for further use or display.

---

## Why Use the Hadamard Algorithm?

- Cuts down the number of multiplications required from 16 (direct) to 8 multiplications.
- Employs simpler shift and add operations, minimizing delay and resource usage.
- Achieves faster clock cycles per multiplication and reduced FPGA LUT (Look-Up Table) and Flip-Flop utilization.
- Well-suited for resource-constrained hardware common in embedded applications.

---

## Performance Summary

| Design Type                 | Clock Cycles | LUTs Used | Flip-Flops |  
|----------------------------|--------------|-----------|------------|  
| Simple Multiplication       | 360          | 3119      | 0          |  
| Algorithmic Multiplication  | 260          | 2026      | 0          |  
| Pipelined Simple Multiplication | 293      | 3192      | 520        |  
| Pipelined Algorithmic Multiplication | 153   | 1900      | 610        |  

The pipelined Hadamard approach delivers significantly lower latency and hardware resource consumption.

---

## Project Highlights

- Reliable clock domain synchronization using asynchronous FIFOs for SPI communication.
- Modular and scalable Verilog design with FIFO buffering and pipelining for throughput optimization.
- Tested using Vivado simulations with real IMU data sets.
- Designed for easy extension with I2C master integration.

---

## Getting Started

### Prerequisites

- Vivado Design Suite for simulation and synthesis
- Arduino board (e.g., Arduino Uno)
- MPU6050 IMU sensor
- Basic tools for SPI and I2C communication setup

### Running the Simulation

1. Load the Vivado project files from this repository.
2. Simulate both the direct and Hadamard quaternion multiplication modules.
3. Use the provided testbenches with sample IMU datasets to verify correctness.
4. Compare output quaternions with reference software outputs.


## Code Structure

- `/verilog/` — Verilog source files for quaternion multiplication modules, FIFO buffers, and protocols
- `/arduino/` — Arduino sketches for IMU readout, SPI master and slave communication
- `/testbench/` — Simulation scripts and test data files
- `/docs/` — Project report, block diagrams, and related documentation

---

## Challenges & Solutions

- **Clock Domain Crossing:** Implemented asynchronous FIFO buffers to avoid data corruption.
- **Resource Optimization:** Applied Hadamard transform algorithm to reduce latency and usage.
- **SPI Reliability:** Developed and refined FSM for robust SPI communication.
- **Simulation Limitations:** Created comprehensive testbenches with real IMU data for validation.

---





