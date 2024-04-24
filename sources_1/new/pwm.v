`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module pwm_cntr #(
    parameter SYS_FREQ = 125 //125MHz
    )(
    input clk, reset_p,
    output reg pwm,
    input [15:0] pwm_freq, // ~65535Hz
    input [9:0] duty     //0.0% ~ 100.0%
    );
    // pwm_freq 가 sysclk의 약수가 되면 정확한 타이밍 가능

    reg [26:0] count;
    always @(posedge reset_p, posedge clk) begin
        if (reset_p) begin
            count <= pwm_freq;
            pwm <= 1;
        end
        else begin
            if (count >= SYS_FREQ*1000*1000) begin
                pwm <= 1;
                count <= pwm_freq;
            end
            else if ( count >= SYS_FREQ*1000*duty) begin 
                pwm <= 0;
                count <= count + pwm_freq;
            end
            else count <= count + pwm_freq;
        end
    end

endmodule


module tb_pwm_test();

    reg clk;
    reg reset_p;
    wire pwm;

    //50hz 7.0%duty
    pwm_cntr pwm0(clk, reset_p, pwm, 1000, 100);


    initial begin
        clk = 0;
        reset_p = 1;
        forever #4 clk = ~clk;
    end

    initial begin
        #10 reset_p = 0;
    end
endmodule 

module pwm_test #(
    parameter SYS_FREQ = 125 //125MHz
    )(
    input clk, reset_p,
    output pwm   );

    wire clk_usec, clk_msec, clk_sec;
    clock_usec clk_us0(clk, reset_p, clk_usec);
    clock_div_1000 clk_div0(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 clk_div1(clk, reset_p, clk_msec, clk_sec);

    wire pwn_0, pwm_1, pwm_2, pwm_3, pwm_4, pwm_5;
    pwm_cntr pwm0(clk, reset_p, pwm_0, 50, 50);
    pwm_cntr pwm1(clk, reset_p, pwm_1, 50, 60);
    pwm_cntr pwm2(clk, reset_p, pwm_2, 50, 70);
    pwm_cntr pwm3(clk, reset_p, pwm_3, 50, 80);
    pwm_cntr pwm4(clk, reset_p, pwm_4, 50, 90);
    pwm_cntr pwm5(clk, reset_p, pwm_5, 50, 100);

    reg [2:0] cnt = 0;
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            cnt = 0;
        end
        else begin
            if (clk_sec) begin
                cnt = cnt + 1;
                if (cnt >= 6) cnt = 0;
            end
        end
    end

    assign pwm = cnt == 0 ? pwm_0 :
                 cnt == 1 ? pwm_1 :
                 cnt == 2 ? pwm_2 :
                 cnt == 3 ? pwm_3 :
                 cnt == 4 ? pwm_4 : pwm_5;
endmodule


module pwm_controller #(
    parameter SYS_FREQ = 125 //125MHz
    )(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_freq,
    output reg pwm    );

    localparam REAL_SYS_FREQ = SYS_FREQ * 1000 * 1000;

    //1000Hz를 만드려면 한번에 sys_clk/1000 을 cnt에 더한다
    //2000Hz를 만드려면 한번에 sys_clk/2000 을 cnt에 더한다
    // nHz를 만드려면 한번에 sys_clk/n 을 cnt에 더한다
    reg [26:0] cnt;
    reg pwm_clk_x100; // 

    always @(posedge reset_p, posedge clk) begin
        if (reset_p) begin
            pwm_clk_x100 <= 0;
            cnt <= 0;
        end
        else begin
            if (cnt >= REAL_SYS_FREQ /pwm_freq /100 - 1) begin
                cnt <= 0;
                pwm_clk_x100 <= 1'b1;
            end
            else begin
                pwm_clk_x100 <= 1'b0;
            end
            cnt = cnt + 1;

        end
    end

    reg [6:0] cnt_duty;
    always @(posedge reset_p, posedge clk) begin
        if (reset_p) begin
            pwm <= 1'b0;
            cnt_duty <= 0;
        end
        else begin
            if (pwm_clk_x100) begin
                if(cnt_duty >= 99) cnt_duty <= 0;
                else cnt_duty <= cnt_duty + 1;

                if(cnt_duty < duty) pwm <= 1'b1;
                else pwm <= 1'b0;
            end
            else begin
                
            end
            
        end
    end
endmodule

module tb_pwm_test_1();

    reg clk;
    reg reset_p;
    wire pwm;

    // 50% duty  10000Hz
    pwm_controller #(125) pwm0(clk, reset_p, 10, 10000, pwm);

    initial begin
        clk = 0;
        reset_p = 1;
        forever #4 clk = ~clk;
    end

    initial begin
        #10 reset_p = 0;
    end
endmodule