`timescale 1ns / 1ps
/*====================  Task 2 a: Digital Lock  ====================*/
module digital_lock (
    input  logic       clk,        // System clock
    input  logic       rst_n,      // Active-low reset
    input  logic [3:0] key,        // Keypad input (0-F)
    input  logic       valid_key,  // 1 when user presses a key
    output logic       state       // 1 = locked, 0 = unlocked
);

    // State encoding
    typedef enum logic [1:0] {
        UNLOCKED   = 2'b00,
        LOCKED     = 2'b01,
        CHANGE_PIN = 2'b10
    } state_t;

    // Internal registers and default values
    parameter logic [15:0] DEFAULT_PIN = 16'h1234; // default 1234
    state_t current_state, next_state;

    logic [15:0] pin_stored;   // stored PIN
    logic [15:0] pin_input;    // entered digits
    logic [2:0]  digit_count;  // counts entered digits (0-4)

    // Sequential logic - state transitions and data handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= UNLOCKED;
            pin_stored    <= DEFAULT_PIN;
            pin_input     <= 16'b0;
            digit_count   <= 3'b000;
        end else begin
            current_state <= next_state;

            // Enter digits when locked or changing PIN
            if (valid_key &&
                (current_state == LOCKED || current_state == CHANGE_PIN) &&
                key != 4'hB && key != 4'hC && key != 4'hE &&
                (digit_count < 3'd4)) begin
                pin_input   <= {pin_input[11:0], key};
                digit_count <= digit_count + 3'd1;
            end

            // Save new PIN after 4 digits + 'B'
            if (current_state == CHANGE_PIN &&
                valid_key && key == 4'hB && digit_count == 3'd4)
                pin_stored <= pin_input;

            // Check code when 'C' pressed
            if (valid_key && key == 4'hC && current_state == LOCKED) begin
                if (pin_input == pin_stored)
                    current_state <= UNLOCKED; // correct PIN
                pin_input   <= 16'b0;
                digit_count <= 3'b000;
            end

            // Clear entered data on state change (except unlocking)
            if (current_state != next_state &&
                !(current_state == LOCKED && next_state == UNLOCKED)) begin
                pin_input   <= 16'b0;
                digit_count <= 3'b000;
            end
        end
    end

    // Next-state logic
    always_comb begin
        next_state = current_state;

        case (current_state)
            UNLOCKED: begin
                if (valid_key && key == 4'hB)
                    next_state = LOCKED;       // Lock
                else if (valid_key && key == 4'hE)
                    next_state = CHANGE_PIN;   // Change PIN
            end

            LOCKED: begin
                // unlocking handled in sequential section
            end

            CHANGE_PIN: begin
                if (valid_key && key == 4'hB && digit_count == 3'd4)
                    next_state = LOCKED;
            end
        endcase
    end

    // Output flag
    assign state = (current_state == LOCKED);

endmodule



/*====================  Task 2 b: Key Press Detector  ====================*/
module key_press_detector (
    input  logic clk,       // same 100 MHz clock
    input  logic rst_n,     // active-low reset
    input  logic key_in,    // raw button input
    output logic key_pulse  // one-cycle pulse
);
    typedef enum logic { RELEASED, PRESSED } key_state_t;
    key_state_t press_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            press_state <= RELEASED;
            key_pulse   <= 0;
        end else begin
            case (press_state)
                RELEASED:
                    if (key_in) begin
                        press_state <= PRESSED;
                        key_pulse   <= 1;
                    end else
                        key_pulse <= 0;

                PRESSED:
                    if (!key_in)
                        press_state <= RELEASED;
                    else
                        key_pulse <= 0;
            endcase
        end
    end
endmodule



/*====================  FPGA Integration  ====================*/
module urbana_top_digital_lock (
    input  logic CLK_100MHZ,     // 100 MHz board clock
    input  logic [3:0] SW,       // switches as keypad
    input  logic [3:0] BTN,      // BTN[0]=reset, BTN[1]=enter
    output logic [2:0] RGB0,     // RGB0 indicates status
    output logic [2:0] RGB1      // RGB1 unused
);

    // Internal signals
    logic rst_n_btn;
    logic valid_key_pulse;
    logic locked_state;
    logic [2:0] rgb0_color;

    // Reset and key press detector
    assign rst_n_btn = ~BTN[0];  // active-low reset

    key_press_detector keypress_inst (
        .clk       (CLK_100MHZ),
        .rst_n     (rst_n_btn),
        .key_in    (BTN[1]),
        .key_pulse (valid_key_pulse)
    );

    // Digital lock FSM instance
    digital_lock lock_inst (
        .clk        (CLK_100MHZ),
        .rst_n      (rst_n_btn),
        .key        (SW[3:0]),
        .valid_key  (valid_key_pulse),
        .state      (locked_state)
    );

    // RGB display logic
    always_comb begin
        if (!rst_n_btn)
            rgb0_color = 3'b111;    // OFF on reset
        else if (locked_state)
            rgb0_color = 3'b110;    // RED = locked
        else
            rgb0_color = 3'b100;    // GREEN = unlocked
    end

    assign RGB0 = ~rgb0_color;  // active-low
    assign RGB1 = 3'b000;       // always off

endmodule

