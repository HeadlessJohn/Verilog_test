`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module tb_dht11();
    //input은 레지스터로
    reg clk, reset_p;
    
    //inout은 3상태 buffer
    //bufif1 = cntr이 1이면 버퍼로 작동 0이면 Z출력
    //bufif0 = cntr이 0이면 버퍼로 작동 1이면 Z출력
    //TB에서는 tri1 : pullup된 wire,   tri0: pulldown된 wire
    //출력 데이터 3상태
    //신호를 받기전까지는 Z상태 유지해야함
    tri1 dht11_data;
    
    //output은 wire로
    wire [7:0] humidity;
    wire [7:0] temperature;
    
    //design under test
    dht11 DUT(clk, reset_p, dht11_data, humidity, temperature);
    
    //wr이 1이면 dout출력, 0이면 Z상태
    reg dout, wr;
    assign dht11_data = wr? dout : 1'bz;
    
    //checksum = 더한 값
    parameter [7:0] humi_value = 8'd80;
    parameter [7:0] tmpr_value = 8'd25;
    parameter [7:0] check_sum  = humi_value + tmpr_value;
    //데이터 형식 맞춤
    parameter [39:0] data = {humi_value, 8'b0, tmpr_value, {8{1'b0}}/*반복연산자*/, check_sum};
    
    //초기값 설정
    initial begin
        clk     = 0;
        reset_p = 1;
        wr      = 0;
    end
    
    //클록 생성
    // #time 4ns에 반전 = 8ns주기
    always #5 clk = ~clk;
    
    //for문 변수
    integer i;
    
    initial begin
        #10; //10ns 후
        reset_p = 0;
        wait(!dht11_data); // dht11_data가 0이 될 때까지 대기 ()안의 식이 1이면 구문 탈출
        wait(dht11_data); //  dht11_data가 1이 될 때까지 대기 ()안의 식이 0이면 구문 탈출
        #20000; //20us delay
        wr = 1; dout = 0; #80000; // 80us delay
        wr = 0;           #80000; // Z출력
        wr = 1;
        
        // start data trasmit
        for (i = 0; i<40; i = i+1) begin // 40회반복
            $display(i);
            dout = 0; #50000; // 50us low유지
            dout = 1;
            //data[39-i]에 있는 값이 1인지 0인지에 따라 high 유지 시간 조절
            //39~0까지 40회 출력
            if (data[39-i])    #70000; // 70us delay
            else              #27000; // 27us delay
        end
        wr = 1; dout = 0; #10;
        wr = 0;           #10000;
        $display("end");
        $stop;
        
    end
    
endmodule
