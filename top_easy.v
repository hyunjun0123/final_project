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

    // Edge detection registers
    reg next_sync, next_sync_prev;
    reg hit_sync, hit_sync_prev;
    reg stand_sync, stand_sync_prev;
    reg double_sync, double_sync_prev;
    reg split_sync, split_sync_prev;

    // Rising edge signals
    wire next_edge = next_sync & ~next_sync_prev;
    wire hit_edge = hit_sync & ~hit_sync_prev;
    wire stand_edge = stand_sync & ~stand_sync_prev;
    wire double_edge = double_sync & ~double_sync_prev;
    wire split_edge = split_sync & ~split_sync_prev;

    // Synchronize all input signals to the clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            next_sync <= 0; next_sync_prev <= 0;
            hit_sync <= 0; hit_sync_prev <= 0;
            stand_sync <= 0; stand_sync_prev <= 0;
            double_sync <= 0; double_sync_prev <= 0;
            split_sync <= 0; split_sync_prev <= 0;
        end else begin
            next_sync_prev <= next_sync; next_sync <= next;
            hit_sync_prev <= hit_sync; hit_sync <= hit;
            stand_sync_prev <= stand_sync; stand_sync <= stand;
            double_sync_prev <= double_sync; double_sync <= double;
            split_sync_prev <= split_sync; split_sync <= split;
        end
    end

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
            display12 <= 0;
            display34 <= 0;
        end else begin
            case (game_phases)
                0: begin
                    // Betting phase
                    bet_coin <= bet_8 * 8 + bet_4 * 4 + bet_2 * 2 + bet_1;
                    display12 <= 6'd62; // "b"
                    display34 <= current_coin;

                    if (next_edge) begin
                        game_phases <= 1;
                    end
                end

                1: begin
                    // Dealer card draw phase
                    dealer_current_score <= 5 + 10; // Mock value for dealer cards
                    display12 <= 6'd63; // "d"
                    display34 <= 6'd10; // Mock value

                    if (next_edge) begin
                        game_phases <= 2;
                    end
                end

                2: begin
                    // Player card draw phase 
                    c1 <= 10;
                    c2 <= 8;

                    sum <= c1 + c2 + 10 * (c1 == 1 || c2 == 1);
                    can_split <= (c1 == c2);

                    if (c1 == 1 && c2 == 1) begin 
                        display12 <= 6'd61;
                        display34 <= c2;
                    end else if (c1 == 1 && c2 != 1) begin
                        display12 <= 6'd61;
                        display34 <= c2;
                    end else if (c1 != 1 && c2 == 1) begin
                        display12 <= c1;
                        display34 <= 6'd61;
                    end else begin
                        display12 <= c1; // display
                        display34 <= c2;
                    end

                    if (next_edge && sum == 21) begin
                        game_phases <= 12; // BlackJack
                        bet_coin <= bet_coin * 2;
                    end else if (next_edge) begin
                        game_phases <= 3; // Player decision
                    end
                end

                3: begin
                    if (hit_edge) begin
                        double_check <= 1;
                        can_split <= 0;
                        c1 <= 5; // Mock card value
                        sum <= sum + c1;
                        display12 <= sum;
                        display34 <= c1;

                        if (sum > 21) begin
                            Lose <= 1;
                            game_phases <= 15; // End phase
                        end
                    end else if (stand_edge) begin
                        double_check <= 1;
                        can_split <= 0;
                        game_phases <= 11;  // Dealer turn
                    end else if (double_edge && !double_check) begin
                        bet_coin <= bet_coin * 2;
                        double_check <= 1;
                        can_split <= 0;

                        c1 <= 5; // Mock card value
                        sum <= sum + c1;
                        display12 <= sum;
                        display34 <= c1;

                        if (sum > 21) begin
                            Lose <= 1;
                            game_phases <= 15; // End phase
                        end else begin
                            game_phases <= 11; // Dealer turn after double
                        end
                    end
                end

                11: begin
                    // Dealer turn
                    dealer_current_score <= dealer_current_score + 2; // Mock value
                    display12 <= dealer_current_score;

                    if (dealer_current_score > 21) begin
                        Win <= 1;
                        game_phases <= 15; // End phase
                    end else if (dealer_current_score > sum) begin
                        Lose <= 1;
                        game_phases <= 15; // End phase
                    end else if (dealer_current_score == sum) begin
                        Draw <= 1;
                        game_phases <= 15; // End phase
                    end 
                end
                
                14: begin
                   if (next_edge) game_phases <= 0;
                end

                15: begin
                    // End phase, adjust coins and reset
                    if (next_edge) begin
                        if (Win) begin
                            current_coin <= current_coin + bet_coin;
                        end else if (Lose) begin
                            current_coin <= current_coin - bet_coin;
                        end

                        display12 <= 0; // Display empty
                        display34 <= 0;
                        Win <= 0;
                        Lose <= 0;
                        Draw <= 0;
                        game_phases <= 14; // Reset to betting phase
                    end
                end
            endcase
        end
    end

endmodule
