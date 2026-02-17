# Fixed Point FIR Verification

## Overview
In this project, we design a simple FIR (Finite Impulse Response) filter and study how it behaves in both software and hardware. The filter processes a stream of input numbers and produces an output by combining the current input with a small number of past inputs.

The project begins with a MATLAB model that describes how the filter should behave mathematically. This model is first written using floating-point arithmetic to verify correctness, and then rewritten using fixed-point arithmetic to closely match real hardware behavior.

Using the MATLAB fixed-point model, test vectors and reference outputs are generated. These reference results are then used to validate a Verilog hardware implementation of the same FIR filter. By comparing the Verilog output against the MATLAB reference, we ensure that the hardware implementation functions correctly across different input values and corner cases.
