`timescale 1ns / 1ps


module tb_pwm_test_1();

    reg clk;
    reg reset_p;
    wire pwm;

    // 50% duty  10000Hz
    pwm_controller #(125) pwm0(clk, reset_p, 50, 10000, pwm);

    initial begin
        clk = 0;
        reset_p = 1;
        forever #4 clk = ~clk;
    end

    initial begin
        #10 reset_p = 0;
    end
endmodule