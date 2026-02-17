// ==============================================================================
// Module:      simple_fir
// Description: 8-Tap Signed Moving Average Filter
//              Implements y[n] = (x[n] + x[n-1] + ... + x[n-7]) / 8
//
// Hardware Architecture:
// 1. Shift Register: Stores the last 8 samples (Taps).
// 2. Adder Tree:     Sums all taps together.
// 3. Shifter:        Performs division by 8.
// ==============================================================================

module simple_fir (
    input  logic        clk,
    input  logic        rst_n,      // Active-low asynchronous reset
    input  logic        valid_in,   // Data validity flag (High = Process this sample)
    input  logic signed [7:0] data_in,
    
    output logic        valid_out,  // High when data_out is valid
    output logic signed [7:0] data_out
);

    // --- Internal Storage (The Taps) ---
    // An array of 8 registers, each 8-bits wide.
    // taps[0] is current input, taps[1] is previous, etc.
    logic signed [7:0] taps [0:7];
    
    // --- Accumulator ---
    // Max value calculation: 8 * 127 = 1016.
    // 1016 fits in 11 bits (signed). We use 12 bits to be safe.
    logic signed [11:0] sum;

    // --- Main Sequential Process ---
    // Triggered on the rising edge of clock or falling edge of reset.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset State: Clear all registers to zero
            for (int i=0; i<8; i++) begin
                taps[i] <= '0;
            end
            valid_out <= 0;
            data_out  <= 0;
            
        end else if (valid_in) begin
            // Only process if the input data is marked valid
            
            // ---------------------------------------------------------
            // 1. Shift Register Operation (The "Bucket Brigade")
            // ---------------------------------------------------------
            // Load new data into the first tap
            taps[0] <= data_in;
            
            // Shift older data down the line.
            // taps[0] moves to taps[1], taps[1] moves to taps[2], etc.
            for (int i=1; i<8; i++) begin
                taps[i] <= taps[i-1];
            end
            
            // ---------------------------------------------------------
            // 2. The Calculation (Math)
            // ---------------------------------------------------------
            // We verify the filter by summing all 8 stored samples.
            // Note: In this simple architecture, we sum the 'current' state 
            // of the registers before the non-blocking assignments (<=) update them.
            // This effectively sums the *previous* cycle's window + new input.
            // For a moving average, this is acceptable.
            
            sum = taps[0] + taps[1] + taps[2] + taps[3] + 
                  taps[4] + taps[5] + taps[6] + taps[7];
            
            // ---------------------------------------------------------
            // 3. Division and Output
            // ---------------------------------------------------------
            // Divide by 8 using Arithmetic Shift Right (>>>).
            // >>> preserves the sign bit (crucial for negative numbers).
            // Example: -16 (11110000) >>> 3 becomes -2 (11111110).
            data_out  <= sum >>> 3;
            
            valid_out <= 1; // Mark output as valid
            
        end else begin
            // If valid_in is low, we mark output as invalid
            valid_out <= 0;
        end
    end

endmodule