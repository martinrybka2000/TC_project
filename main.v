module main(clk_main, switch_inWombat, switch_inDanger, switch_Immobilized, enkoder_A, enkoder_B, LEDs);

    input clk_main;           // main clock

    input switch_inWombat;    //switches
    input switch_inDanger;
    input switch_Immobilized;

    input enkoder_A;          // enkoder
	input enkoder_B;
   
    output [7:0] LEDs;
   
	wire kabel_clk_400us;     // divider wires
    wire kabel_clk_10ms;    
    wire kabel_clk_333ms;
 
    wire kabel_inWombat;      // status wires
    wire kabel_inDanger;
    wire [6:0] kabel_Damage_taken;
    wire kabel_Immobilized;

    wire enc_up;              // enkoder wires
	wire enc_down;
	wire clk_enc;
	
    wire kabel_chuckles_i_m_in_danger;

    wire [7:0] kable_LEDs;    // LEDs wire for cunter

    divider div_10ms  (clk_main, 250000,  kabel_clk_10ms);   // 0.01 * 50 000 000 / 2
    divider div_333ms (clk_main, 8325000, kabel_clk_333ms);  // 0.333 * 50 000 000 / 2
    divider div_400us (clk_main, 10000,    kabel_clk_400us); // 0.0004 * 50 000 000 / 2 
   
    Debouncer inCombat    (kabel_clk_10ms, switch_inWombat,    kabel_inWombat);
    Debouncer inDanger    (kabel_clk_10ms, switch_inDanger,    kabel_inDanger);
    Debouncer Immobilized (kabel_clk_10ms, switch_Immobilized, kabel_Immobilized);
	
	encoder conder      (kabel_clk_400us, enkoder_A, enkoder_B,  enc_up, enc_down, clk_enc);
	damageStatus status (clk_enc,         enc_up,  enc_down, kabel_Damage_taken);

    chuckles_i_m_in_danger yes      (kabel_clk_10ms,  kabel_inDanger,               kabel_Damage_taken,  kabel_Immobilized, kabel_chuckles_i_m_in_danger);
    counter                selfBoom (kabel_clk_10ms,  kabel_chuckles_i_m_in_danger, kabel_inWombat, kable_LEDs);
    epilepsy               my_eyes  (kabel_clk_333ms, kabel_inWombat,               kable_LEDs,     LEDs);

endmodule

module chuckles_i_m_in_danger(clk, danger ,damage, immobilized, i_m_in_danger);
    input clk;
    input danger; 
    input [6:0] damage; // damage input in procentage
    input immobilized;
    output reg i_m_in_danger;
   
    // checking for 2 of 3 inputs
    always @(posedge clk) begin
        
        if((danger && (damage > 50)) || (danger && immobilized) || ((damage > 50) && immobilized)) begin
            i_m_in_danger <= 1; // yes
        end
        else begin
            i_m_in_danger <= 0; // no
        end
    end
endmodule

module epilepsy(clk_3Hz, enable, in_cnt, display);
    input clk_3Hz;
    input enable;
    input[7:0] in_cnt;
    output reg[7:0] display = 0;

    reg CHADflag = 0; // blocking all inputs on purpose to symulate not working robot

    always @(posedge clk_3Hz) begin
      if((enable && CHADflag == 0)) begin
        display <= (8'b11111111 ^ display) & in_cnt;    // blinking leds
      end
      else begin
        display <= 0;  // if robot goes out of combat then reset
      end

      if(in_cnt == 8'b00000000 || CHADflag == 1) begin  // if dead then light up all LEDs and block changing its state
        CHADflag <= 1;
        display <= 8'b11111111;
      end  
    end
endmodule

module divider(clk, bicycles, out); //just one divider module, reqiurs how many cycles to wait
    input clk;
    input [24:0] bicycles; // defing input and its limitation
    output out;

    reg flag = 0;
    reg [24:0] cnt = 0;

    assign out = flag;

    always @(posedge clk) begin
        cnt <= (cnt + 1);
        if(cnt > bicycles) begin
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
    output[7:0] cnt_out;
   
    reg [6:0] cnt1s = 0;
    reg [7:0] cnt = 255;

    assign cnt_out = cnt;

    always @(posedge clk) begin

        if(enable && reset && cnt > 0) begin  // couting from 8s to 0s
            cnt1s <= cnt1s + 1;
            if(cnt1s >= 100) begin  // couting to 1s from the 10ms timer
                cnt <= cnt >> 1;
                cnt1s <= 0;
            end
        end

        if(!reset) begin // reseting the counter
            cnt <= 255;
            cnt1s <= 0;
        end

    end
endmodule

module damageStatus(clk, add, minus, cnt);
	input clk;
	input add;
	input minus;
	output reg [6:0] cnt = 0;


	always @ (posedge clk) begin 
		if( cnt < 100 && add == 1) cnt <= cnt + 1; // if enkoder up then add damage
		else if(cnt != 0 && minus == 1) cnt <= cnt - 1; // else lower
	end

endmodule

module encoder(clk, A, B, up, down, out_clk);
	input clk;
	input A;
	input B;

	output reg up = 0;
	output reg down = 0;
	output reg out_clk = 0;

	wire [2:0] q;
	reg [2:0] j;
	reg [2:0] k;

	jk_flip_flop jk0(clk, j[0], k[0], q[0]);
	jk_flip_flop jk1(clk, j[1], k[1], q[1]);
	jk_flip_flop jk2(clk, j[2], k[2], q[2]);

	always @ (posedge clk) begin 
		up <= q[2] * ~q[1] * q[0];
		down <= ~q[2] * q[1] * ~q[0];
		out_clk <= up | down;		
	end

	always @ (posedge clk) begin 
		j[0] <= (~A)*q[2] + A*(~B)*q[1];
		j[1] <= (~A)*B*q[0] + (~A)*(~B)*(~q[2])*q[0];
		j[2] <= (~A)*B*(~q[1])*(~q[0]);

		k[0] <= A*B + B*(~q[2]) + (~A)*q[2]*(~q[1]);
		k[1] <= A + (~B)*(~q[2])*q[0];
		k[2] <= B + (~A)*(~q[1]) + A*q[0];
	end

endmodule

module jk_flip_flop (clk, j, k, q);
	input j; 
    input k;
    input clk;
	output reg q = 0;

	always @ (posedge clk) begin
		case ({j,k})        // true table 
			2'b00: q = q;
			2'b01: q = 1'b0;
			2'b10: q = 1'b1;
			2'b11: q = ~q;
		endcase
	end
endmodule