module main(clk_main, switch_inWombat, switch_inDanger, switch_Damaged, switch_Immobilized, LEDs);

    input clk_main;
    input switch_Damaged;
    input switch_Immobilized;
    input switch_inWombat;
    input switch_inDanger;
    
    output [3:0] LEDs;
    
    wire kabel_clk_1s;
    wire kabel_clk_10ms;

    wire kabel_inWombat;
    wire kabel_inDanger;
    wire kabel_Damaged;
    wire kabel_Immobilized;

    wire kabel_I_am_fucked;
    wire [3:0] kable_LEDs;

    // divider_1s div_1s(clk_main, kabel_clk_1s);
    divider_10ms div_10ms(clk_main, kabel_clk_10ms);
    
    Debouncer inCombat(kabel_clk_10ms, switch_inWombat, kabel_inWombat);
    Debouncer inDanger(kabel_clk_10ms, switch_inDanger, kabel_inDanger);
    Debouncer Damaged(kabel_clk_10ms, switch_Damaged, kabel_Damaged);
    Debouncer Immobilized(kabel_clk_10ms, switch_Immobilized, kabel_Immobilized);

    amIfucked doI(kabel_clk_10ms, kabel_inDanger, kabel_Damaged, kabel_Immobilized, kabel_I_am_fucked);
    
    counter selfBoom(kabel_clk_10ms, kabel_I_am_fucked, kabel_inWombat, kable_LEDs);
    
    dead isdead(kabel_clk_10ms , kable_LEDs, LEDs);

endmodule

module amIfucked(clk, danger ,damaged, immobilized, i_m_fucked);
    input clk;
    input danger;
    input damaged;
    input immobilized;
    output reg i_m_fucked;
    
    // checking for 2 of 3 inputs
    always @(posedge clk) begin
        if((danger && damaged) || (danger && immobilized) || (damaged && immobilized)) begin
            i_m_fucked <= 1;
        end
        else begin
            i_m_fucked <= 0;
        end
    end
    
endmodule

// if the couter hits 11 turn all leds on
module dead(clk, in_cnt, display); 
    input clk;
    input[3:0] in_cnt;
    output reg[3:0] display;

    always @(posedge clk) begin    
        if(in_cnt == 4'b1011) begin 
            display <= 4'b1111; 
        end
        else begin
            display <= in_cnt;
        end
    end
endmodule

// module divider_1s(clk, out);
// 	input clk;
// 	reg flag = 0;
// 	output out;

// 	reg[24:0] cnt = 0;

//     assign out = flag;
    
// 	always @(posedge clk) begin
// 		cnt <= (cnt + 1);
// 		if(cnt > 6000000) begin // for 12MHz 
// 			flag <= !flag;
// 			cnt <= 0;
// 		end
// 	end
// endmodule

module divider_10ms(clk, out);
	input clk;
	reg flag = 0;
	output out;

	reg[15:0] cnt = 0;

    assign out = flag;

	always @(posedge clk) begin
		cnt <= (cnt + 1);
		if(cnt > 60000) begin // for 12MHz
			flag <= !flag;
			cnt <= 0;
		end
	end
endmodule

module Debouncer(clk, in, out);
    input clk;
    input in;
    reg [3:0] cnt = 0;
    reg [3:0] cnt2 = 0;
    reg flag = 1;
    reg flag2 = 0;
    output reg out;

    always @(posedge clk) begin

        if(in == 1) begin
            cnt <= cnt + 1;
            if((cnt >= 3) & flag) begin // 30ms
                out <= 1;
                flag <= 0;
            end
            cnt2 <= 0;
            flag2 <= 1;
        end

        else begin
            cnt2 <= cnt2 + 1;
            if((cnt2 >= 3) & flag2) begin
                out <= 0;
                flag2 <= 0;
            end
            cnt <= 0;
            flag <= 1;
        end
    end
endmodule

module counter(clk, enable, reset, cnt_out);
    input clk;
    input enable;
    input reset;
    output[3:0] cnt_out;
	reg [6:0] cnt1s = 0;
    reg [3:0] cnt = 0;

    assign cnt_out = cnt;

    always @(posedge clk) begin

        if(enable && reset && cnt <= 10) begin // couting to 10 sec
			cnt1s <= cnt1s + 1;
			if(cnt1s >= 100) begin
				cnt <= cnt + 1;
				cnt1s <= 0;
			end
        end

        if(!reset) begin 
            cnt <= 0;
				cnt1s <= 0;
        end

    end
endmodule