`timescale 10ns / 1ps
 
// ------- Debounce Module ------- //
module debouncer(
    input pb_1,          // 버튼 입력
    input clk,           // 100MHz 클럭
    output pb_out        // 안정화된 출력
    );

    reg [19:0] counter;  // 20비트 카운터 (10ms 기준)
    reg pb_sync_0, pb_sync_1; // 동기화 레지스터
    reg pb_state;        // 버튼의 최종 안정화된 상태
    reg pb_out_reg;      // Debouncing된 출력 레지스터

    // 동기화 (버튼 입력을 100MHz 클럭으로 샘플링)
    always @(posedge clk) begin
        pb_sync_0 <= pb_1;
        pb_sync_1 <= pb_sync_0;
    end

    // Debouncing 타이머 로직
    always @(posedge clk) begin
        if (pb_sync_1 != pb_state) begin
            // 버튼 상태 변화 감지 시 타이머 증가
            counter <= counter + 1;
            if (counter >= 1_000_000) begin // 1_000_000 클럭 = 10ms
                pb_state <= pb_sync_1;     // 안정화된 상태로 변경
                counter <= 0;             // 타이머 초기화
            end
        end else begin
            counter <= 0; // 상태 변화가 없으면 타이머 리셋
        end
    end

    // 출력 상태 결정
    always @(posedge clk) begin
        pb_out_reg <= pb_state;
    end

    assign pb_out = pb_out_reg;

endmodule
