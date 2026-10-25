/*================-Task 1-===================*/

/*
module traffic_light #(
    parameter int RED_DELAY         = 100, // how long lights stays ON
    parameter int RED_ORANGE_DELAY  = 30,
    parameter int GREEN_DELAY       = 80,
    parameter int ORANGE_DELAY      = 20,
    parameter int COUNTER_WIDTH     = 8
)(
    input  logic clk, rst_n,
    output logic red, orange, green
);
    typedef enum logic [1:0] { //define FSM states
        S_RED,
        S_RED_ORANGE,
        S_GREEN,
        S_ORANGE
    } state_t;

    state_t state, next_state;
    logic [COUNTER_WIDTH-1:0] counter;

    // Sequential 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RED;
            counter <= 0;
        end else if (counter == get_delay(state)) begin
            counter <= 0;
            state <= next_state;
        end else begin
            counter <= counter + 1;
        end
    end

    // Next state 
    always_comb begin
        case (state)
            S_RED:         next_state = S_RED_ORANGE;
            S_RED_ORANGE:  next_state = S_GREEN;
            S_GREEN:       next_state = S_ORANGE;
            S_ORANGE:      next_state = S_RED;
            default:       next_state = S_RED;
        endcase
    end

    // Output 
    always_comb begin
        red = 0; orange = 0; green = 0; // default off
        case (state)
            S_RED:        red = 1; //red
            S_RED_ORANGE: begin red = 1; orange = 1; end //red & orange
            S_GREEN:      green = 1;    //green 
            S_ORANGE:     orange = 1;   //orange
        endcase
    end

    // Function for state delays
    function automatic int get_delay(state_t s);
        case (s)
            S_RED:        return RED_DELAY;
            S_RED_ORANGE: return RED_ORANGE_DELAY;
            S_GREEN:      return GREEN_DELAY;
            S_ORANGE:     return ORANGE_DELAY;
            default:      return 0;
        endcase
    endfunction

endmodule */


/*================-Task 1b FPGA-===================*/

/*
module clock_divider #(parameter DIV = 50_000_000)(
    input  logic clk_in,
    input  logic rstn,
    output logic clk_out
);
    logic [$clog2(DIV)-1:0] count;
    always_ff @(posedge clk_in or negedge rstn) begin
        if (!rstn) begin count <= 0; clk_out <= 0; end
        else if (count == DIV-1) begin count <= 0; clk_out <= ~clk_out; end
        else count <= count + 1;
    end
endmodule


module top_traffic_light(
    input  logic CLK100MHZ,  // board clock
    input  logic rstn_btn,   // push button, active low
    output logic LED_R,      // red LED pin
    output logic LED_G,      // green LED pin
    output logic LED_B       // blue LED pin (used as orange)
);

    logic slow_clk;

    // Instantiate clock divider
    clock_divider #(.DIV(50_000_000)) slowclk (
        .clk_in (CLK100MHZ),
        .rstn   (rstn_btn),
        .clk_out(slow_clk)
    );

    // Instantiate traffic light FSM
    traffic_light #(
        .RED_DELAY(2),
        .RED_ORANGE_DELAY(1),
        .GREEN_DELAY(2),
        .ORANGE_DELAY(1),
        .COUNTER_WIDTH(24)
    ) fsm (
        .clk   (slow_clk),
        .rstn  (rstn_btn),
        .red   (LED_R),
        .orange(LED_B), // blue used for orange
        .green (LED_G)
    );

endmodule */


module traffic_light #(
    parameter int RED_DELAY        = 2,   // seconds of red
    parameter int RED_ORANGE_DELAY = 1,   // seconds of red+orange
    parameter int GREEN_DELAY      = 2,   // seconds of green
    parameter int ORANGE_DELAY     = 1,   // seconds of orange
    parameter int COUNTER_WIDTH    = 24   // counter bits
)(
    input  logic clk,                    // clock input
    input  logic rstn,                   // active-low reset
    output logic red,                    // red light output
    output logic orange,                 // orange light output
    output logic green                   // green light output
);

// state encoding
    typedef enum logic [1:0] {
        S_RED,                           // only red is ON
        S_RED_ORANGE,                    // red + orange
        S_GREEN,                         // green
        S_ORANGE                         // only orange
    } state_t;

    state_t state, next_state;            // current and next state
    logic [COUNTER_WIDTH-1:0] counter;    // timing counter

    //--------- SEQUENTIAL PART (STATE + COUNTER) --------------
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state   <= S_RED;             // start at RED
            counter <= 0;
        end else if (counter == get_delay(state)) begin
            counter <= 0;
            state   <= next_state;        // go to next state
        end else begin
            counter <= counter + 1;
        end
    end

    //--------- NEXT STATE LOGIC -------------------------------
    always_comb begin
        case (state)
            S_RED:         next_state = S_RED_ORANGE; // red → red+orange
            S_RED_ORANGE:  next_state = S_GREEN;      // red+orange → green
            S_GREEN:       next_state = S_ORANGE;     // green → orange
            S_ORANGE:      next_state = S_RED;        // orange → red
            default:       next_state = S_RED;
        endcase
    end

    //--------- OUTPUT LOGIC -----------------------------------
    always_comb begin
        red = 0; orange = 0; green = 0;   // default all OFF
        case (state)
            S_RED:        red = 1;
            S_RED_ORANGE: begin red = 1; orange = 1; end
            S_GREEN:      green = 1;
            S_ORANGE:     orange = 1;
        endcase
    end

    //--------- DELAY FUNCTION ---------------------------------
    function automatic int get_delay(state_t s);
        case (s)
            S_RED:        return RED_DELAY;
            S_RED_ORANGE: return RED_ORANGE_DELAY;
            S_GREEN:      return GREEN_DELAY;
            S_ORANGE:     return ORANGE_DELAY;
            default:      return 0;
        endcase
    endfunction
endmodule

/*================-Task 1b-===================*/
// Divides 100 MHz board clock down to ~1 Hz so the
module clock_divider #(parameter DIV = 50_000_000)(
    input  logic clk_in,                  // input clock 100 MHz
    input  logic rstn,                    // active-low reset
    output logic clk_out                  // slower clock output
);
    logic [$clog2(DIV)-1:0] count;        // counter register

    always_ff @(posedge clk_in or negedge rstn) begin
        if (!rstn) begin
            count   <= 0;
            clk_out <= 0;
        end else if (count == DIV-1) begin
            count   <= 0;
            clk_out <= ~clk_out;          // toggle every DIV cycles
        end else begin
            count <= count + 1;
        end
    end
endmodule

/*================-Task FPGA-===================*/
module urbana_top_traffic_light(
    input  logic CLK_100MHZ,     // 100 MHz board clock
    input  logic [3:0] BTN,      // BTN[0] used for reset
    output logic [2:0] RGB0,     // side lamp (orange)
    output logic [2:0] RGB1      // main lamp (red/green)
);
    // Internal signals
    logic rstn_btn;              // active-low reset
    logic slow_clk;              // divided clock
    logic [1:0] phase;           // 00, 01, 10, 11 repeating
    
    // Reset and clock divider
    assign rstn_btn = ~BTN[0];

    clock_divider #(.DIV(50_000_000)) clkdiv (
        .clk_in (CLK_100MHZ),
        .rstn   (rstn_btn),
        .clk_out(slow_clk)
    );
    // 4-state phase FSM
    always_ff @(posedge slow_clk or negedge rstn_btn) begin
        if (!rstn_btn)
            phase <= 2'b00;       // start at red
        else begin 
            case (phase)
                2'b00: phase <= 2'b01;    // 01 → red+orange
                2'b01: phase <= 2'b10;    // 10 → green
                2'b10: phase <= 2'b11;    // 11 → orange
                2'b11: phase <= 2'b00;    // back to 00
                default: phase <= 2'b00;
            endcase
        end
    end

    // Define color codes (R G B)
    localparam logic [2:0] COL_OFF    = 4'b1111; //OFF
    localparam logic [2:0] COL_RED    = 4'b0110; //RED
    localparam logic [2:0] COL_GREEN  = 4'b1100;  //GREEN
    localparam logic [2:0] COL_BLUE = 4'b0011; //BLUE

    // Light control logic
    logic [2:0] rgb0_color, rgb1_color;

    always_comb begin
        rgb0_color = COL_OFF;
        rgb1_color = COL_OFF;

        case (phase)
            2'b00: begin                   // RED
                rgb1_color = COL_RED;      // RGB1 = red
                rgb0_color = COL_OFF;      // RGB0 = off
            end
            2'b01: begin                   // RED + (side) ORANGE
                rgb1_color = COL_RED;      // <-- keep main on RED (not red+orange)
                rgb0_color = COL_BLUE;     // side shows "orange"
            end
            2'b10: begin                   // GREEN
                rgb1_color = COL_GREEN;    // main green
                rgb0_color = COL_OFF;      // side off
            end
            2'b11: begin                   // ORANGE (main only)
                rgb1_color = COL_BLUE;     // main "orange"
                rgb0_color = COL_OFF;      // <-- side OFF (was orange before)
            end
            default: begin
                rgb1_color = COL_OFF;
                rgb0_color = COL_OFF;
            end
        endcase
    end

    //(ACTIVE-LOW) LEDs light when pin=0 → invert once here.
    assign RGB1 = ~rgb1_color;   // RGB1 shows main lamp (red/red/green)
    assign RGB0 = ~rgb0_color;   // RGB0 shows side orange only in 2nd red
endmodule



