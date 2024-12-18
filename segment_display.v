`timescale 1ns / 1ps

// fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// FPGA tutorial: seven-segment LED display controller on Basys  3 FPGA
module segment_display(
    input clk, // 100 Mhz clock source on Basys 3 FPGA
    // Buttons
    input reset,
    input next,
    input hit,
    input stand,
    input double,
    // Switches
    input split,   
    input bet_8,
    input bet_4,   
    input bet_2,
    input bet_1,
    input [2:0] test,
    // Outputs
    output [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output [6:0] LED_out,// cathode patterns of the 7-segment LED display
    output LED_split,
    output LED_Win,
    output LED_Lose,
    output LED_Draw
    );
    
    integer onesDigit = 0;
    integer twosDigit = 0;
    integer threesDigit = 0;
    integer foursDigit = 0;
    integer refresh_counter = 0;
    integer LED_activating_counter = 0;
    
    reg [3:0] Anode_Activate_Var;
    reg [6:0] LED_out_Var;
    reg [3:0] LED_BCD;
    reg LED_split_Var;
    reg LED_Win_Var;
    reg LED_Lose_Var;
    reg LED_Draw_Var;
    
    reg [5:0] diplay12;      // display
    reg [5:0] diplay34;
    
    integer total_bet;
    
    localparam D0 = 4'b0000, // "0"     
               D1 = 4'b0001, // "1" 
               D2 = 4'b0010, // "2" 
               D3 = 4'b0011, // "3" 
               D4 = 4'b0100, // "4" 
               D5 = 4'b0101, // "5" 
               D6 = 4'b0110, // "6" 
               D7 = 4'b0111, // "7" 
               D8 = 4'b1000, // "8"     
               D9 = 4'b1001, // "9" 
               Db = 4'b1010, // "b"
               Dd = 4'b1011, // "d"
               DA = 4'b1100, // "A"
               DN = 4'b1101; // None 
  
               
    ///////////////////////////////////////////////////////////////////////////////////////////
    // TODO: Instantiate your top module top.v here so that it works correctly
    // top uut (
    // 
    // );
    top_diplay uut1 (
        .clk(clk),
        .reset(reset),
        .next(next),
        .hit(hit),
        .stand(stand),
        .double(double),
        .split(split),
        .bet_8(bet_8),
        .bet_4(bet_4),
        .bet_2(bet_2),
        .bet_1(bet_1),
        .test(test),
        .display12(display12),
        .display34(display34),
        .can_split(LED_split_Var),
        .Win(LED_Win_Var),
        .Lose(LED_Lose_Var),
        .Draw(LED_Draw_Var) 
    );
    // Activate LEDs (TODO)
    always @(posedge(clk)) begin
        if (split) LED_split_Var = 1;
        else LED_split_Var = 0;
    end

    // Declare the digits for display (TODO)
    always @(posedge(clk)) begin
        if (reset) begin
            onesDigit = DN;
            twosDigit = DN;
            threesDigit = DN;
            foursDigit = DN;
            total_bet = bet_8*8 + bet_4*4 + bet_2*2 + bet_1*1;
        end
        else if (next) begin
            onesDigit = diplay34%10;
            twosDigit = diplay34/10;
            threesDigit = diplay12%10;
            foursDigit = diplay12/10;
        end
    end    
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // You don't have to change it down here
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    // Activate one of four 7-seg displays 
    always @(posedge(clk))
    begin 
        refresh_counter = refresh_counter + 1;      //increment counter
        if(refresh_counter == 5000)                 //at 500
            LED_activating_counter = 0;             //light onesDigit
        if(refresh_counter == 10000)                //at 1,000
            LED_activating_counter = 1;             //light twosDigit
        if(refresh_counter == 15000)                //at 1,500
            LED_activating_counter = 2;             //light threesDigit
        if(refresh_counter == 20000)                //at 20,000
            LED_activating_counter = 3;             //light foursDigit
        if(refresh_counter == 25000)                //at 25,000
            refresh_counter = 0;                    //start over at 0
    end


    always @(LED_activating_counter, foursDigit, threesDigit, twosDigit, onesDigit)                    //when 7-seg digit changes
    begin
        //LED_activating_counter = refresh_counter;
        case(LED_activating_counter)                    //activate the digit
            0: begin
                Anode_Activate_Var = 4'b0111;           //activate LED1 and Deactivate LED2, LED3, LED4
                LED_BCD = foursDigit;                   //the first digit of the 16-bit number
            end
            1: begin
                Anode_Activate_Var = 4'b1011;           //activate LED2 and Deactivate LED1, LED3, LED4
                LED_BCD = threesDigit;                  //the second digit of the 16-bit number
            end
            2: begin
                Anode_Activate_Var = 4'b1101;           // activate LED3 and Deactivate LED2, LED1, LED4
                LED_BCD = twosDigit;                    // the third digit of the 16-bit number
            end
            3: begin
                Anode_Activate_Var = 4'b1110;           // activate LED4 and Deactivate LED2, LED3, LED1
                LED_BCD = onesDigit;                    // the fourth digit of the 16-bit number 
            end
        endcase
    end


    always @(LED_BCD)
    begin
        case(LED_BCD)
            4'b0000: LED_out_Var = 7'b0000001; // "0"     
            4'b0001: LED_out_Var = 7'b1001111; // "1" 
            4'b0010: LED_out_Var = 7'b0010010; // "2" 
            4'b0011: LED_out_Var = 7'b0000110; // "3" 
            4'b0100: LED_out_Var = 7'b1001100; // "4" 
            4'b0101: LED_out_Var = 7'b0100100; // "5" 
            4'b0110: LED_out_Var = 7'b0100000; // "6" 
            4'b0111: LED_out_Var = 7'b0001111; // "7" 
            4'b1000: LED_out_Var = 7'b0000000; // "8"     
            4'b1001: LED_out_Var = 7'b0000100; // "9" 
            4'b1010: LED_out_Var = 7'b1100000; // "b"
            4'b1011: LED_out_Var = 7'b1000010; // "d"
            4'b1100: LED_out_Var = 7'b0001000; // "A"
            4'b1101: LED_out_Var = 7'b1111111; // None
            default: LED_out_Var = 7'b0000001; // "0"
        endcase
    end

    assign Anode_Activate = Anode_Activate_Var;
    assign LED_out = LED_out_Var;
    assign LED_split = LED_split_Var;
    assign LED_Win = LED_Win_Var;
    assign LED_Lose = LED_Lose_Var;
    assign LED_Draw = LED_Draw_Var;
    
 endmodule

