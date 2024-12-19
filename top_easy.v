`timescale 10ns / 1ps

module top_easy (
    input clk,
    input reset,
    input next,    // Stabilized by Debouncer
    input hit,     // Stabilized by Debouncer
    input stand,   // Stabilized by Debouncer
    input double,  // Stabilized by Debouncer
    input split,   // Stabilized by Debouncer
    input bet_8,
    input bet_4,
    input bet_2,
    input bet_1,
    output reg [5:0] display12,
    output reg [5:0] display34,
    output reg can_split,
    output reg Win,
    output reg Lose,
    output reg Draw
);

    // Internal signals and registers
    reg [3:0] game_phases;
    reg [4:0] bet_coin, bet_coin_2;
    reg [5:0] current_coin;
    reg [5:0] dealer_current_score;
    reg [5:0] sum, sum2;
    reg double_check;
    reg [5:0] c1, c2, c3, c4; // Card values

    // Reset and initialization
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            game_phases <= 0;
            bet_coin <= 0;
            bet_coin_2 <= 0;
            current_coin <= 30; // Initial coin value
            dealer_current_score <= 0;
            sum <= 0;
            sum2 <= 0;
            double_check <= 0;
            Win <= 0;
            Lose <= 0;
            Draw <= 0;
            c1 <= 0;
            c2 <= 0;
            c3 <= 0;
            c4 <= 0;
            can_split <= 0;
        end else begin
            case (game_phases)
                0: begin
                    // Betting phase
                    bet_coin <= bet_8 * 8 + bet_4 * 4 + bet_2 * 2 + bet_1;
                    display12 <= 6'd62; // "b"
                    display34 <= current_coin;

                    if (next) begin
                        game_phases <= 1;
                    end
                end

                1: begin
                    // Dealer card draw phase
                    dealer_current_score <= dealer_current_score + 10; // Mock value for dealer cards
                    display12 <= 6'd63; // "d"
                    display34 <= 6'd10; // Mock value

                    if (next) begin
                        game_phases <= 2;
                    end
                end

                2: begin
                    // Player turn
                    if (hit) begin
                        c1 <= 5; // Mock card value
                        sum <= sum + c1;

                        display12 <= sum;
                        display34 <= c1;

                        if (sum > 21) begin
                            Lose <= 1;
                            game_phases <= 4; // End phase
                        end
                    end else if (stand) begin
                        game_phases <= 3; // Move to dealer phase
                    end
                end

                3: begin
                    // Dealer turn
                    dealer_current_score <= dealer_current_score + 5; // Mock value
                    display12 <= dealer_current_score;

                    if (dealer_current_score > 21) begin
                        Win <= 1;
                    end else if (dealer_current_score > sum) begin
                        Lose <= 1;
                    end else if (dealer_current_score == sum) begin
                        Draw <= 1;
                    end
                    game_phases <= 4;
                end

                4: begin
                    // Game over
                    if (next) begin
                        Win <= 0;
                        Lose <= 0;
                        Draw <= 0;
                        game_phases <= 0; // Reset game
                    end
                end
            endcase
        end
    end

endmodule
