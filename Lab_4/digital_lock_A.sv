`timescale 1ns / 1ps

module digital_lock (
    input  logic       clk,        // Clock
    input  logic       rstn,       // Active-low reset
    input  logic [3:0] key,        // Keypad input (0–F)
    input  logic       valid_key,  // 1 when user presses a key
    output logic       state       // 1 = locked, 0 = unlocked
);

  // =====================================================
  // Parameters & state type
  // =====================================================
  parameter logic [15:0] DEFAULT_PIN = 16'h1234;

  typedef enum logic [1:0] {
    UNLOCKED   = 2'b00,
    LOCKED     = 2'b01,
    CHANGE_PIN = 2'b10
  } state_t;

  state_t current_state, next_state;

  // =====================================================
  // Internal registers
  // =====================================================
  logic [15:0] correct_pin;  // lagrad PIN
  logic [15:0] written_pin;  // inmatad PIN
  logic [ 2:0] digit_counter;  // antal inmatade siffror

  // =====================================================
  // Sekventiell logik (uppdaterar tillstånd och data)
  // =====================================================
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      current_state <= UNLOCKED;
      correct_pin   <= DEFAULT_PIN;
      written_pin   <= 16'b0;
      digit_counter <= 3'b000;
    end else begin
      current_state <= next_state;

      // Hantera tangenttryckning
      if (valid_key) begin
        // Mata in siffror i LOCKED eller CHANGE_PIN
        if (current_state == LOCKED || current_state == CHANGE_PIN) begin
          if (key <= 4'hF) begin
            written_pin   <= {written_pin[11:0], key};
            digit_counter <= digit_counter + 1;
          end
        end

        // Om användaren ändrar PIN (E + 4 siffror)
        if (current_state == CHANGE_PIN && digit_counter == 3'd4) begin
          correct_pin   <= written_pin;
          written_pin   <= 16'b0;
          digit_counter <= 3'b000;
        end

        // Kontrollera PIN när C trycks i LOCKED-läge
        if (current_state == LOCKED && key == 4'hC) begin
          if (written_pin == correct_pin) next_state <= UNLOCKED;  // korrekt kod
          written_pin   <= 16'b0;
          digit_counter <= 3'b000;
        end
      end
    end
  end

  // =====================================================
  // Kombinatorisk logik (bestämmer nästa tillstånd)
  // =====================================================
  always_comb begin
    next_state = current_state;

    case (current_state)
      UNLOCKED: begin
        if (valid_key && key == 4'hB) next_state = LOCKED;  // lås
        else if (valid_key && key == 4'hE) next_state = CHANGE_PIN;  // ändra PIN
      end

      LOCKED: begin
        if (valid_key && key == 4'hC && written_pin == correct_pin)
          next_state = UNLOCKED;  // lås upp
      end

      CHANGE_PIN: begin
        if (digit_counter == 3'd4) next_state = UNLOCKED;  // efter 4 siffror → olåst
      end

      default: next_state = LOCKED;
    endcase
  end

  // =====================================================
  // Utgång (LED eller status)
  // =====================================================
  assign state = (current_state == LOCKED);

endmodule
