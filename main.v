module main(clk_main, switch_inWombat, switch_inDanger, switch_Immobilized, enkoder_A, enkoder_B, LEDs, LCD_E, LCD_RS, LCD_RW, LCD_DB);
    // na 5.5
    input clk_main;           // main clock

    input switch_inWombat;    //switches
    input switch_inDanger;
    input switch_Immobilized;

    input enkoder_A;          // enkoder
	input enkoder_B;
   
    output [7:0] LEDs;        // LEDs

    output LCD_E;             // LCD
	output LCD_RS;
	output LCD_RW; 
	output [7:4] LCD_DB;  
   
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

    wire [7:0] kabel_counter;    // LEDs wire for counter

    divider div_10ms  (clk_main, 250000,  kabel_clk_10ms);   // 0.01 * 50 000 000 / 2
    divider div_333ms (clk_main, 8325000, kabel_clk_333ms);  // 0.333 * 50 000 000 / 2
    divider div_400us (clk_main, 10000,    kabel_clk_400us); // 0.0004 * 50 000 000 / 2 
   
    Debouncer inCombat    (kabel_clk_10ms, switch_inWombat,    kabel_inWombat);
    Debouncer inDanger    (kabel_clk_10ms, switch_inDanger,    kabel_inDanger);
    Debouncer Immobilized (kabel_clk_10ms, switch_Immobilized, kabel_Immobilized);
	
	encoder conder      (kabel_clk_400us, enkoder_A, enkoder_B,  enc_up, enc_down, clk_enc);
	damageStatus status (clk_enc,         enc_up,  enc_down, kabel_Damage_taken);

    LCD                    LSD      (kabel_clk_10ms,  kabel_counter,                LCD_E,               LCD_RS,            LCD_RW, LCD_DB);
    chuckles_i_m_in_danger yes      (kabel_clk_10ms,  kabel_inDanger,               kabel_Damage_taken,  kabel_Immobilized, kabel_chuckles_i_m_in_danger);
    counter                selfBoom (kabel_clk_10ms,  kabel_chuckles_i_m_in_danger, kabel_inWombat,      kabel_counter);
    epilepsy               my_eyes  (kabel_clk_333ms, kabel_inWombat,               kabel_counter,       LEDs);
    

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

module LCD(clk, time_left, LCD_E, LCD_RS, LCD_RW, LCD_DB);
	input clk;
	input time_left;
	output reg LCD_E;  
	output reg LCD_RS;
	output reg LCD_RW; 
	output reg [7:4] LCD_DB;  

    reg [5:0] cnt = 0; 
    reg [6:0] command = 0; 
	reg init_flag = 0;
  
    always @ (posedge clk) begin 
        cnt <= cnt + 1;
		
		if (init_flag == 0) begin
			case (cnt)

			// Initialization
			0: LCD_E <= 1;
			1: command <= 6'b000011;
			2: LCD_E <= 0;
			3: LCD_E <= 1;
			4: command <= 6'b000011; 
			5: LCD_E <= 0;   
			6: LCD_E <= 1;
			7: command <= 6'b000011; 
			8: LCD_E <= 0;  
			9: LCD_E <= 1; 
			10: command <= 6'b000010;   
			11: LCD_E <= 0; 

			// Clear Display
			12: LCD_E <= 1; 
			13: command <= 6'b000000;
			14: LCD_E <= 0;  
			15: LCD_E <= 1; 
			16: command <= 6'b000001;  
			17: LCD_E <= 0; 

			// Function SET
			18: LCD_E <= 1; 
			19: command <= 6'b000010;
			20: LCD_E <= 0;  
			21: LCD_E <= 1; 
			22: command <= 6'b001000;
			23: LCD_E <= 0;  

			// Entry Mode Set
			24: LCD_E <= 1; 
			25: command <= 6'b000000; 
			26: LCD_E <= 0;  
			27: LCD_E <= 1; 
			28: command <= 6'b000110; // 0, 1, I/D, S
			29: LCD_E <= 0;  

			// Display On/Off
			30: LCD_E <= 1; 
			31: command <= 6'b000000;
			32: LCD_E <= 0;  
			33: LCD_E <= 1; 
			34: command <= 6'b001110; // display on, cursor on, bliking off
			35: LCD_E <= 0; 
			
			// Set DD RAM Address to 0
			36: LCD_E <= 1; 
			37: command <= 6'b001000; 
			38: LCD_E <= 0;  
			39: LCD_E <= 1; 
			40: command <= 6'b000000;
			41: LCD_E <= 0; 

			default: begin 
				cnt <= 0;
				init_flag <= 1;
				end
        	endcase
		end
		else begin
			case (cnt)
					
			// Sending UDN
			0: LCD_E <= 1; 
			1: begin 
				case(time_left)
					8'b00000000: command <= 6'b101110; // Suprise Pikachu face
					default: 	 command <= 6'b100011; // It's the final count down! tutu tuuu
				endcase
				end 
			2: LCD_E <= 0;  

			// Sending LDN
			3: LCD_E <= 1; 
			4: begin 
				case (time_left)
				8'b11111111: command <= 6'b101000;
				8'b01111111: command <= 6'b100111;
				8'b00111111: command <= 6'b100110;
				8'b00011111: command <= 6'b100101;
				8'b00001111: command <= 6'b100100;
				8'b00000111: command <= 6'b100011;
				8'b00000011: command <= 6'b100010;
				8'b00000001: command <= 6'b100001;
				8'b00000000: command <= 6'b101111; // Suprise Pikachu face
				endcase
				end
			5: LCD_E <= 0;
				default: cnt <= 0; 
			endcase
		 end

		LCD_RS <= command[5];
		LCD_RW <= command[4];
		LCD_DB[7] <= command[3];
		LCD_DB[6] <= command[2];
		LCD_DB[5] <= command[1];
		LCD_DB[4] <= command[0];
    end
endmodule