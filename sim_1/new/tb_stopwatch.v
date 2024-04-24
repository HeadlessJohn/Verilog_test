`timescale 1ns / 1ps
 
//////////////////////////////////////////////////////////////////////////////////


module tb_stopwatch();

    //input은 reg
    reg clk, reset_p;
    reg [3:0]btn;
    //output은 wire
    wire [15:0] time_digit;

    //초기화 블럭
    initial begin
        clk = 0;
        reset_p = 1;
        btn = 0;
    end

    //8ns주기 클록 생성
    always #4 clk = ~clk;

    //테스트 모듈 인스턴스 선언
    stop_watch_core DUT(clk, reset_p, btn, time_digit);

    initial begin
        #10;             reset_p = 0;
        #10;             btn[0]  = 1; 
        #10;             btn[0]  = 0;
        #500_000_000;    btn[1]  = 1; //0.5sec         
        #10              btn[1]  = 0;
        #500_000_000; 

        $stop;                   

    end


endmodule
