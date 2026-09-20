# ECS - Hardware Perceptron in VHDL

[![VHDL](https://img.shields.io/badge/Language-VHDL-blue.svg)](https://en.wikipedia.org/wiki/VHDL)
[![Target-FPGA](https://img.shields.io/badge/Target-Xilinx%20Zynq--7000%20(xc7z010)-red.svg)](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html)
[![EDA-Tools](https://img.shields.io/badge/EDA-Vivado%20%7C%20ModelSim-green.svg)]()

This repository contains the VHDL design, implementation, and functional verification of a **Hardware Perceptron** classifier using fixed-point arithmetic on FPGA.

The project was developed for the **Electronics and Communications Systems** course (Master of Science in Computer Engineering, **Università di Pisa**).

---

## Project Overview

The Perceptron is a fundamental linear classifier that takes $N_{IN} = 10$ inputs $x_n$, computes their weighted sum with 10 weights $w_n$ plus a bias $b$, and passes the accumulator output to a custom piecewise-linear activation function $f(x)$:

$$y = f\left( \sum_{i=1}^{10} x_i \cdot w_i + b \right)$$

---

## Specifications & Arithmetic Representation

All input features, weights, and internal operands are defined using fixed-point arithmetic in the range $[-1, 1)$:

| Parameter | Bit Width | Fractional LSB | Range | Description |
| :--- | :---: | :---: | :---: | :--- |
| **Inputs ($x_n$)** | $b_x = 8$ bits | $2^{-7}$ | $[-1, 1)$ | 10 input feature channels |
| **Weights ($w_n$)** | $b_w = 9$ bits | $2^{-8}$ | $[-1, 1)$ | 10 synaptic weights |
| **Bias ($b$)** | $b_w = 9$ bits | $2^{-8}$ | $[-1, 1)$ | Perceptron offset bias |
| **Products ($x_i \cdot w_i$)** | $b_{pro} = 17$ bits | $2^{-15}$ | $[-1, 1)$ | Parallel multiplication outputs |
| **Sum Accumulation** | $b_{sum} = 21$ bits | $2^{-15}$ | $[-16, 16)$ | Extended tree accumulator (prevents overflow) |
| **Output ($y$)** | $b_{out} = 16$ bits | $2^{-10}$ | $[-1, 1)$ | Final output truncated to 16 bits |

### Activation Function $f(x)$

The activation function is implemented custom-coded (without Look-Up Tables) to minimize area and latency:

$$f(x) = \begin{cases} 
0 & \text{if } x < -2 \\ 
\frac{1}{4}x + \frac{1}{2} & \text{if } -2 \le x \le 2 \\ 
1 & \text{if } x > 2 
\end{cases}$$

- **Linear region ($-2 \le x \le 2$):** Division by 4 is computed via arithmetic right bit-shift by 2 (`x >> 2`), followed by adding $1/2$ via a Ripple Carry Adder.
- **Saturating regions ($x < -2$ and $x > 2$):** Handled by numerical magnitude comparators and multiplexers.

---

## Hardware Architecture & Design Details

The top-level architecture is modular and partitioned into four core sub-blocks:

1. **Parallel Multipliers ([`Products.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/Products.vhd), [`ParallelMultiplier.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/ParallelMultiplier.vhd)):**
   - Converts 2's complement inputs to Sign and Magnitude representation.
   - Computes $8 \times 9$-bit unsigned multiplications via AND-matrix partial products and Half-Adder/Full-Adder reduction trees.
   - Determines output sign via XOR gate and converts back to 2's complement (17-bit output).

2. **Adder Tree ([`AdderTree.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/AdderTree.vhd), [`RippleCarryAdder.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/RippleCarryAdder.vhd)):**
   - Sign-extends product terms to 21 bits ($b_{sum} = 21$) to avoid sum overflow.
   - Aligns bias $b$ by left-shifting 7 positions ($b \cdot 2^7$) to align $LSB_b = 2^{-8}$ with $LSB_{prod} = 2^{-15}$.
   - Performs a 4-level balanced binary tree summation across all 10 product terms plus bias using Ripple Carry Adders.

3. **Activation Function ([`ActivationFunction.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/ActivationFunction.vhd)):**
   - Compares the 21-bit input against integer threshold constants.
   - Computes linear shift and RCA addition for the non-saturating zone.

4. **Pipeline & Barrier Registers ([`Perceptron.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/Perceptron.vhd), [`PerceptronWrapper.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/PerceptronWrapper.vhd)):**
   - Inserts 4 pipeline register levels (`DFFN.vhd`) between computation stages to maximize clock frequency.
   - `PerceptronWrapper.vhd` surrounds the core logic with Register-to-Register (R-L-R) input/output barrier registers for accurate Vivado timing analysis.

---

## Repository Structure

```
.
├── Report.pdf              # Comprehensive project report (VHDL logic, diagrams, synthesis results)
├── Specifications.pdf      # Original project specifications
├── src/                    # VHDL Design Source Files
│   ├── myPackage.vhd           # Global constants, types, and fixed-point helper definitions
│   ├── HalfAdder.vhd           # 1-bit Half Adder cell
│   ├── FullAdder.vhd           # 1-bit Full Adder cell
│   ├── RippleCarryAdder.vhd    # Parameterized N-bit Ripple Carry Adder
│   ├── DFFN.vhd                # Parameterized N-bit D Flip-Flop Register
│   ├── ParallelMultiplier.vhd  # Signed NxM Parallel Multiplier
│   ├── Products.vhd            # Parallel instantiation of 10 multipliers
│   ├── AdderTree.vhd           # 4-level RCA binary adder tree
│   ├── ActivationFunction.vhd  # Custom threshold-based activation function
│   ├── Perceptron.vhd          # Top-level Perceptron structural design with pipeline stages
│   └── PerceptronWrapper.vhd   # Perceptron wrapper with I/O barrier registers
└── tb/                     # Testbenches for ModelSim Simulation
    ├── RippleCarryAdder_tb.vhd   # Testbench for RCA logic
    ├── ParallelMultiplier_tb.vhd # Testbench for multiplier operations
    ├── ActivationFunction_tb.vhd # Testbench covering all 3 operating regions
    └── Perceptron_tb.vhd         # Comprehensive system testbench
```

> **Note on omitted folders (`modelsim/`, `vivado/`):**  
> Autogenerated tool artifacts, simulation object caches, and build metadata (`modelsim/`, `vivado/`) are deliberately excluded from version control to maintain a clean, lightweight, and platform-independent codebase. For complete architectural block diagrams and waveform captures, refer to [Report.pdf](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/Report.pdf).

---

## Synthesis & Implementation Results (Xilinx Vivado)

The design was synthesized and implemented targeting the **Xilinx Zynq-7000 FPGA (`xc7z010clg400-1`)**:

- **Timing Summary:**
  - Clock Constraint: $T = 15\text{ ns}$ ($f = 66.67\text{ MHz}$)
  - Worst Negative Slack (WNS): **$+1.341\text{ ns}$** (All timing constraints satisfied)
  - Maximum Achievable Frequency: **$f_{max} = \frac{1}{15 - 1.341\text{ ns}} \approx 73.21\text{ MHz}$**
- **Critical Path:**
  - 10 critical paths originating at the input barrier registers, traversing the 2's complement conversion and unsigned multiplier array, and terminating at the first post-multiplier pipeline registers.
- **System Latency:**
  - **4 clock cycles** from input sampling to valid output due to the 4 internal register stages.

---

## Simulation & Execution Guide

### Running Functional Simulation (ModelSim / GHDL / Vivado Simulator)

Compile the VHDL source files in order of dependency:

```bash
# 1. Compile package and elementary gates
vcom src/myPackage.vhd
vcom src/HalfAdder.vhd
vcom src/FullAdder.vhd
vcom src/RippleCarryAdder.vhd
vcom src/DFFN.vhd

# 2. Compile functional sub-modules
vcom src/ParallelMultiplier.vhd
vcom src/Products.vhd
vcom src/AdderTree.vhd
vcom src/ActivationFunction.vhd

# 3. Compile top-level entity and wrapper
vcom src/Perceptron.vhd
vcom src/PerceptronWrapper.vhd

# 4. Compile and run testbenches from tb/
vcom tb/Perceptron_tb.vhd
vsim work.Perceptron_tb
```

### Running Vivado Synthesis
1. Open Xilinx Vivado and create a new RTL project for target part `xc7z010clg400-1`.
2. Import all files from [`src/`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src) into Design Sources and set [`PerceptronWrapper.vhd`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/src/PerceptronWrapper.vhd) as the Top Entity.
3. Import all files from [`tb/`](file:///Users/dariobandecchi/Documents/GitHub/ECS-Perceptron/tb) into Simulation Sources.
4. Apply timing constraint in an XDC file:
   ```tcl
   create_clock -period 15.000 -name clk [get_ports clk]
   ```
5. Run **Synthesis** and **Implementation**.
