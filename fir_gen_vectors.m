% ==============================================================================
% Project:      8-Tap FIR Moving Average Filter
% File:         fir_gen_vectors.m
% Description:  Generates stimulus (input) and reference (output) vectors.
%               This script acts as the "Mathematical Reference" to verify
%               the hardware implementation.
% ==============================================================================

clear; clc; close all;

% --- 1. Configuration & Setup ---
rng(1);        % [IMPORTANT] Set Random Seed.
               % This forces the random noise to be the same every time we run.
               % Without this, your Verilog and MATLAB will never match!

N_taps = 8;    % Number of filter taps (coefficients)
Length = 100;  % Total number of samples to simulate

% Moving Average Coefficients:
% We want the average of 8 numbers, so each weight is 1/8.
% Sum of coefficients = 1.0 (Unity Gain).
b = ones(1, N_taps) / N_taps; 

% --- 2. Generate Stimulus (Input Data) ---
t = 0:Length-1;

% Signal Generation:
% A clean low-frequency sine wave + high-frequency random noise.
% Sine period is 20 samples.
raw_signal = 100 * sin(2*pi*t/20) + 10 * randn(1, Length);

% Quantization (Input):
% Real-world ADCs output integers. We round to nearest integer.
x = round(raw_signal);

% Clipping (Saturation):
% Ensure data fits in 8-bit signed range [-128, 127].
x(x > 127)  = 127; 
x(x < -128) = -128;

% --- 3. Filter Processing ---
% We use MATLAB's built-in 'filter' function for the "perfect" math result.
y_float = filter(b, 1, x);

% Quantization (Output):
% Hardware doesn't do decimals. We must convert floating point back to integer.
%
% CRITICAL DESIGN CHOICE:
% Verilog '>>>' operator truncates (rounds down/floor).
% MATLAB 'round()' rounds to nearest integer.
% To make them match perfectly, we use floor() in MATLAB.
y_ref = floor(y_float); 

% --- 4. Plotting Results ---
figure('Name', 'FIR Filter Verification');
subplot(2,1,1);
stem(x, 'filled', 'MarkerFaceColor', 'b'); 
title('Input Stimulus (Noisy)'); grid on;
ylim([-140 140]); ylabel('Amplitude');

subplot(2,1,2);
stem(y_ref, 'filled', 'MarkerFaceColor', 'r'); 
title('Expected Output (Filtered)'); grid on;
ylim([-140 140]); ylabel('Amplitude');

% --- 5. Export for Verilog ---
% writematrix expects columns, so we transpose (x') the arrays.
writematrix(x', 'input_data.txt');
writematrix(y_ref', 'expected_out.txt');

disp('-------------------------------------------------------');
disp('Data Generation Complete.');
disp('Success! Files "input_data.txt" and "expected_out.txt" have been generated.');
disp(['First 5 Inputs: ', num2str(x(1:5))]);
disp(['First 5 Outputs: ', num2str(y_ref(1:5))]);
disp('-------------------------------------------------------');