📌 Overview

This project implements a **Universal Asynchronous Receiver/Transmitter (UART)** in **Verilog HDL**.
It includes:

* **Baud Rate Generator**
* **Transmitter**
* **Receiver**
* **Top-Level UART Module**
* **Testbench** for behavioral simulation in **Xilinx Vivado**

The design was written, compiled, and simulated using **Vivado 202x.x**.

---

## 🏗️ Project Structure

```
UART/
├── UART.srcs/
│   ├── sources_1/new/
│   │   ├── baud_rate_gen.v     # Baud rate generator
│   │   ├── transmitter.v       # UART transmitter logic
│   │   ├── receiver.v          # UART receiver logic
│   │   ├── uart.v              # Top-level UART module
│   └── sim_1/new/
│       └── uart_tb.v           # Testbench
```

---

## ⚙️ Features

* Fully parameterized **baud rate generator**.
* **Serial transmission** with start, data, and stop bits.
* **Receiver with sampling** at the correct baud rate.
* **Synthesizable design** for FPGA implementation.
* **Testbench** for functional verification.

---

## ▶️ Running the Simulation

1. Open **Vivado**.
2. Create a new project and add all `.v` files from `sources_1/new`.
3. Add `uart_tb.v` from `sim_1/new` as the **simulation source**.
4. In **Flow Navigator → Simulation**, select **Run Behavioral Simulation**.
5. Ensure `uart_tb` is set as the **top module** for simulation.
6. View the waveforms (`clk`, `tx`, `rx`, `data_in`, `data_out`) in the **Vivado Waveform Viewer**.

---

## 🖥️ Testbench

The provided testbench (`uart_tb.v`) generates:

* Clock signal
* Reset signal
* Data stimulus for transmission
* Monitors receiver output

---

## 📷 Example Waveforms

* **Transmission (TX line showing start, data, and stop bits)**
* **Reception (RX sampled and reconstructed data)**
  *(Waveform screenshots can be added here after simulation)*

---

## 🚀 Future Improvements

* Add **parity bit** support.
* Support for **configurable baud rates** at runtime.
* Extend to **FIFO-based buffered UART**.

---

## 🛠️ Tools Used

* **Xilinx Vivado 202x.x** (recommended)
* **Verilog HDL**
