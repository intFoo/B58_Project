// Part 2 skeleton

module project
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
	HEX0,
	HEX1,
	HEX5,
	KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input    [17:0] SW;
	input	 [3:0] KEY;
	output [6:0] HEX0, HEX1, HEX5;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = SW[10];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire [7:0] score;
	wire [3:0] draw;
	wire [2:0] select;
	wire [2:0] level;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	datapath d0(.level(level), .inscore(score), .select(SW[2:0]), .draw(draw),.go(KEY[0]), .set(KEY[2]), .clk(CLOCK_50), .resetn(resetn), .x_out(x), .y_out(y), .colour(colour), .res_score(score));
	
    // Instansiate FSM control
	control c0(.level(level), .select(SW[2:0]), .clk(CLOCK_50), .resetn(resetn), .go(KEY[2]), .draw(draw), .plot(writeEn), .levelout(level));

    hex_decoder H0(
        .hex_digit(score[3:0]), 
        .segments(HEX0)
        );

    hex_decoder H1(
        .hex_digit(score[7:4]), 
        .segments(HEX1)
        );

    hex_decoder H2(
        .hex_digit(SW[2:0]), 
        .segments(HEX5)
        );
    
endmodule

module datapath(
	input [2:0] level,
	input [2:0] select,
	input [3:0] draw,
	input [6:0] inscore,
	input go,
	input clk,
	input set,
	input resetn,
	output reg [6:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] colour,
	output reg [6:0] res_score
	);
	reg [2:0] box1, box2, box3, box4, box5, box6, black, res, c;
	reg [6:0] score, x, y, box1_x, box1_y, box2_x, box2_y, box3_x, box3_y, box4_x, box4_y, box5_x, box5_y, box6_x, box6_y;

	always@(posedge clk) 
	begin: LVL
		case(level)
			3'b000: begin
				box1_x <= 7'b110010;
				box1_y <= 7'b110010;
				box1 <= 3'b001;

				box2_x <= 7'b110010;
				box2_y <= 7'b110100;
				box2 <= 3'b010;

				box3_x <= 7'b110010;
				box3_y <= 7'b110110;
				box3 <= 3'b001;

				box4_x <= 7'b110100;
				box4_y <= 7'b110010;
				box4 <= 3'b010;

				box5_x <= 7'b110100;
				box5_y <= 7'b110100;
				box5 <= 3'b100;

				box6_x <= 7'b110100;
				box6_y <= 7'b110110;
				box6 <= 3'b100;
		
				black <= 3'b0;
			end
			3'b001: begin
				box1_x <= 7'b110010;
				box1_y <= 7'b110010;
				box1 <= 3'b100;

				box2_x <= 7'b110010;
				box2_y <= 7'b110100;
				box2 <= 3'b010;

				box3_x <= 7'b110010;
				box3_y <= 7'b110110;
				box3 <= 3'b010;

				box4_x <= 7'b110100;
				box4_y <= 7'b110010;
				box4 <= 3'b001;

				box5_x <= 7'b110100;
				box5_y <= 7'b110100;
				box5 <= 3'b100;

				box6_x <= 7'b110100;
				box6_y <= 7'b110110;
				box6 <= 3'b001;
		
				black <= 3'b0;
			end
			3'b010: begin
				box1_x <= 7'b110010;
				box1_y <= 7'b110010;
				box1 <= 3'b010;

				box2_x <= 7'b110010;
				box2_y <= 7'b110100;
				box2 <= 3'b010;

				box3_x <= 7'b110010;
				box3_y <= 7'b110110;
				box3 <= 3'b001;

				box4_x <= 7'b110100;
				box4_y <= 7'b110010;
				box4 <= 3'b100;

				box5_x <= 7'b110100;
				box5_y <= 7'b110100;
				box5 <= 3'b100;

				box6_x <= 7'b110100;
				box6_y <= 7'b110110;
				box6 <= 3'b001;
		
				black <= 3'b0;
			end
			3'b011: begin
				box1_x <= 7'b110010;
				box1_y <= 7'b110010;
				box1 <= 3'b001;

				box2_x <= 7'b110010;
				box2_y <= 7'b110100;
				box2 <= 3'b100;

				box3_x <= 7'b110010;
				box3_y <= 7'b110110;
				box3 <= 3'b010;

				box4_x <= 7'b110100;
				box4_y <= 7'b110010;
				box4 <= 3'b010;

				box5_x <= 7'b110100;
				box5_y <= 7'b110100;
				box5 <= 3'b100;

				box6_x <= 7'b110100;
				box6_y <= 7'b110110;
				box6 <= 3'b001;
		
				black <= 3'b0;
			end
			3'b100: begin
				box1_x <= 7'b110010;
				box1_y <= 7'b110010;
				box1 <= 3'b010;

				box2_x <= 7'b110010;
				box2_y <= 7'b110100;
				box2 <= 3'b100;

				box3_x <= 7'b110010;
				box3_y <= 7'b110110;
				box3 <= 3'b100;

				box4_x <= 7'b110100;
				box4_y <= 7'b110010;
				box4 <= 3'b010;

				box5_x <= 7'b110100;
				box5_y <= 7'b110100;
				box5 <= 3'b001;

				box6_x <= 7'b110100;
				box6_y <= 7'b110110;
				box6 <= 3'b001;
		
				black <= 3'b0;
			end
			default: begin
				box1_x <= 7'b110010;
				box1_y <= 7'b110010;
				box1 <= 3'b001;

				box2_x <= 7'b110010;
				box2_y <= 7'b110100;
				box2 <= 3'b010;

				box3_x <= 7'b110010;
				box3_y <= 7'b110110;
				box3 <= 3'b001;

				box4_x <= 7'b110100;
				box4_y <= 7'b110010;
				box4 <= 3'b010;

				box5_x <= 7'b110100;
				box5_y <= 7'b110100;
				box5 <= 3'b100;

				box6_x <= 7'b110100;
				box6_y <= 7'b110110;
				box6 <= 3'b100;
		
				black <= 3'b0;
			end
		endcase
	end


	always @(negedge set)
	begin: SCORE_ALU
		case (select)
			3'd1:begin
				if (res == box1) begin
					score <= inscore + 1'b1;
				end
			end
			3'd2: begin
				if (res == box2) begin
					score <= inscore + 1'b1;
				end
			end
			3'd3: begin
				if (res == box3) begin
					score <= inscore + 1'b1;
				end
			end
			3'd4: begin
				if (res == box4) begin
					score <= inscore + 1'b1;
				end
			end
			3'd5: begin
				if (res == box5) begin
					score <= inscore + 1'b1;
				end
			end
			3'd6: begin
				if (res == box6) begin
					score <= inscore + 1'b1;
				end
			end
			default: begin
				 score <= 1'b0;
			end
		endcase
	end
		
	always @(posedge set)
	begin: ALU
		case (select)
			3'd1:begin
				res <= box1;
			end
			3'd2: begin
				res <= box2;
			end
			3'd3: begin
				res <= box3;
			end
			3'd4: begin
				res <= box4;
			end
			3'd5: begin
				res <= box5;
			end
			3'd6: begin
				res <= box6;
			end
			default: begin
				 res <= 3'b0;
			end
		endcase
	end
	
	always @(*)
	begin: DRAW
		case (draw)
			4'd1: begin
				x = box1_x;
				y = box1_y;
				c = box1;
			end
			4'd2: begin
				x = box2_x;
				y = box2_y;
				c = box2;
			end
			4'd3: begin
				x = box3_x;
				y = box3_y;
				c = box3;
			end
			4'd4: begin
				x = box4_x;
				y = box4_y;
				c = box4;
			end
			4'd5: begin
				x = box5_x;
				y = box5_y;
				c = box5;
			end
			4'd6: begin
				x = box6_x;
				y = box6_y;
				c = box6;
			end
			4'd7: begin
				x = box1_x;
				y = box1_y;
				c = black;
			end
			4'd8: begin
				x = box2_x;
				y = box2_y;
				c = black;
			end
			4'd9: begin
				x = box3_x;
				y = box3_y;
				c = black;
			end
			4'd10: begin
				x = box4_x;
				y = box4_y;
				c = black;
			end
			4'd11: begin
				x = box5_x;
				y = box5_y;
				c = black;
			end
			4'd12: begin
				x = box6_x;
				y = box6_y;
				c = black;
			end
			default: begin
				 x = 7'b0;
				 y = 7'b0;
				 c = 3'b0;
			end
		endcase
	end

	always@(posedge go) begin
		if(!resetn) begin
			res_score <= 7'b0;
		end
		else begin
			res_score <= score;
		end
	end

	always@(posedge clk) begin
		if(!resetn) begin
			x_out <= 7'b0;
			y_out <= 7'b0;
			colour <= 3'b0;
		end
		else begin
			x_out <= x;
			y_out <= y;
			colour <= c;
		end
	end

endmodule


module control(
	input [2:0] level,
	input [2:0] select,
	input clk,
	input resetn,
	input go,

	output reg [2:0] levelout,
	output reg [3:0] draw,
	output reg plot
	);

	reg [6:0] current_state, next_state;
	reg [2:0] temp;

	localparam 
			DRAW1	= 7'd0,
		   DRAW2 = 7'd1,
	      DRAW3	= 7'd2,
		   DRAW4	= 7'd3,
		   DRAW5	= 7'd4,
		   DRAW6	= 7'd5,
		   WAIT		= 7'd6,
		   WAIT_WAIT    = 7'd7,
		   HIDE1	= 7'd8,
		   HIDE2	= 7'd9,
		   HIDE3	= 7'd10,
		   HIDE4	= 7'd11,
		   HIDE5	= 7'd12,
		   HIDE6	= 7'd13,
		   SHOW1	= 7'd14,
		   SHOW1_WAIT	= 7'd15,
		   SHOW2	= 7'd16,
		   SHOW2_WAIT	= 7'd17,
		   SHOW3	= 7'd18,
		   SHOW3_WAIT	= 7'd19,
		   SHOW4	= 7'd20,
		   SHOW4_WAIT	= 7'd21,
		   SHOW5	= 7'd22,
		   SHOW5_WAIT	= 7'd23,
		   SHOW6	= 7'd24,
		   SHOW6_WAIT	= 7'd25,
		   END 		= 7'd26,
		   END_WAIT 	= 7'd27,
			HIDE_WAIT	= 7'd28,
		   PLOT1        = 7'd29,
		   PLOT2        = 7'd30,
		   PLOT3        = 7'd31,
		   PLOT4        = 7'd32,
		   PLOT5        = 7'd33,
		   PLOT6        = 7'd34,
			SET			 = 7'd35,
			SET_WAIT			 = 7'd36,
		   PLOT_H1        = 7'd37,
		   PLOT_H2        = 7'd38,
		   PLOT_H3        = 7'd39,
		   PLOT_H4        = 7'd40,
		   PLOT_H5        = 7'd41,
		   PLOT_H6        = 7'd42,
			WDRAW1         = 7'd43,
			WPLOT1         = 7'd44,
			WDRAW2         = 7'd45,
			WPLOT2         = 7'd46,
			HIDE_WAIT_W    = 7'd47,
			CLEAR1			= 7'd48,
			P_CLEAR1			= 7'd49,
			CLEAR2			= 7'd50,
			P_CLEAR2			= 7'd51,
			CLEAR3			= 7'd52,
			P_CLEAR3			= 7'd53,
			CLEAR4			= 7'd54,
			P_CLEAR4			= 7'd55,
			CLEAR5			= 7'd56,
			P_CLEAR5			= 7'd57,
			CLEAR6			= 7'd58,
			P_CLEAR6			= 7'd59;

	always@(*)
	begin: state_table
		case (current_state)
			SET: next_state = go ? SET_WAIT : SET;
			SET_WAIT: next_state = go ? SET_WAIT : DRAW1;
			DRAW1: next_state = PLOT1;
			PLOT1: next_state = DRAW2;
			DRAW2: next_state = PLOT2;
			PLOT2: next_state = DRAW3;
			DRAW3: next_state = PLOT3;
			PLOT3: next_state = DRAW4;
			DRAW4: next_state = PLOT4;
			PLOT4: next_state = DRAW5;
			DRAW5: next_state = PLOT5;
			PLOT5: next_state = DRAW6;
			DRAW6: next_state = PLOT6;
			PLOT6: next_state = WAIT;
			WAIT: next_state = go ? WAIT_WAIT : WAIT;
			WAIT_WAIT: next_state = go ? WAIT_WAIT : HIDE1;
			HIDE1: next_state = PLOT_H1;
			PLOT_H1: next_state = HIDE2;
			HIDE2: next_state = PLOT_H2;
			PLOT_H2: next_state = HIDE3;
			HIDE3: next_state = PLOT_H3;
			PLOT_H3: next_state = HIDE4;
			HIDE4: next_state = PLOT_H4;
			PLOT_H4: next_state = HIDE5;
			HIDE5: next_state = PLOT_H5;
			PLOT_H5: next_state = HIDE6;
			HIDE6: next_state = PLOT_H6;
			PLOT_H6: next_state = HIDE_WAIT;
			HIDE_WAIT: next_state = go ? HIDE_WAIT_W : HIDE_WAIT;
			HIDE_WAIT_W: next_state = go ? HIDE_WAIT_W : SHOW1;
			SHOW1: next_state = go ? SHOW1_WAIT : SHOW1;
			SHOW1_WAIT: next_state = go ? SHOW1_WAIT : SHOW2;
			SHOW2: next_state = go ? SHOW2_WAIT : SHOW2;
			SHOW2_WAIT: next_state = go ? SHOW2_WAIT : SHOW3;
			SHOW3: next_state = go ? SHOW3_WAIT : SHOW3;
			SHOW3_WAIT: next_state = go ? SHOW3_WAIT : SHOW4;
			SHOW4: next_state = go ? SHOW4_WAIT : SHOW4;
			SHOW4_WAIT: next_state = go ? SHOW4_WAIT : SHOW5;
			SHOW5: next_state = go ? SHOW5_WAIT : SHOW5;
			SHOW5_WAIT: next_state = go ? SHOW5_WAIT : SHOW6;
			SHOW6: next_state = go ? SHOW6_WAIT : SHOW6;
			SHOW6_WAIT: next_state = go ? SHOW6_WAIT : CLEAR1;
			CLEAR1: next_state = P_CLEAR1;
			P_CLEAR1: next_state = CLEAR2;
			CLEAR2: next_state = P_CLEAR2;
			P_CLEAR2: next_state = CLEAR3;
			CLEAR3: next_state = P_CLEAR3;
			P_CLEAR3: next_state = CLEAR4;
			CLEAR4: next_state = P_CLEAR4;
			P_CLEAR4: next_state = CLEAR5;
			CLEAR5: next_state = P_CLEAR5;
			P_CLEAR5: next_state = CLEAR6;
			CLEAR6: next_state = P_CLEAR6;
			P_CLEAR6: next_state = END;
			END: next_state = go ? END_WAIT : END;
			END_WAIT: next_state = go ? END_WAIT : SET;
		default:	next_state = SET;
		endcase
	end

	always @(*)
	begin: enable_signals
		draw = 3'd0;
		plot = 1'b0;

		case (current_state)
			SET: begin
				if(level == 3'b101)
				begin
					levelout <= 3'b000;
				end
			end
			PLOT1:begin
				plot = 1'b1;
			      end
			PLOT2:begin
				plot = 1'b1;
			      end
			PLOT3:begin
				plot = 1'b1;
			      end
			PLOT4:begin
				plot = 1'b1;
			      end
			PLOT5:begin
				plot = 1'b1;
			      end
			PLOT6:begin
				plot = 1'b1;
			      end
			PLOT_H1:begin
				plot = 1'b1;
			      end
			PLOT_H2:begin
				plot = 1'b1;
			      end
			PLOT_H3:begin
				plot = 1'b1;
			      end
			PLOT_H4:begin
				plot = 1'b1;
			      end
			PLOT_H5:begin
				plot = 1'b1;
			      end
			PLOT_H6:begin
				plot = 1'b1;
			      end

			SHOW1_WAIT:begin
				plot = 1'b1;
			      end
			SHOW2_WAIT:begin
				plot = 1'b1;
			      end
			SHOW3_WAIT:begin
				plot = 1'b1;
			      end
			SHOW4_WAIT:begin
				plot = 1'b1;
			      end
			SHOW5_WAIT:begin
				plot = 1'b1;
			      end
			SHOW6_WAIT:begin
				plot = 1'b1;
			      end
					
			DRAW1: begin
				draw = 4'd1;
				end
			DRAW2: begin
				draw = 4'd2;
				end
			DRAW3: begin
				draw = 4'd3;
				end
			DRAW4: begin
				draw = 4'd4;
				end
			DRAW5: begin
				draw = 4'd5;
				end
			DRAW6: begin
				draw = 4'd6;
				end
				
			CLEAR1: begin
				draw = 4'd7;
				end
			CLEAR2: begin
				draw = 4'd8;
				end
			CLEAR3: begin
				draw = 4'd9;
				end
			CLEAR4: begin
				draw = 4'd10;
				end
			CLEAR5: begin
				draw = 4'd11;
				end
			CLEAR6: begin
				draw = 4'd12;
				end
			P_CLEAR1:begin
				plot = 1'b1;
			      end
			P_CLEAR2:begin
				plot = 1'b1;
			      end
			P_CLEAR3:begin
				plot = 1'b1;
			      end
			P_CLEAR4:begin
				plot = 1'b1;
			      end
			P_CLEAR5:begin
				plot = 1'b1;
			      end
			P_CLEAR6:begin
				plot = 1'b1;
			end
				
			HIDE1: begin
				draw = 4'd7;
				end
			HIDE2: begin
				draw = 4'd8;
				end
			HIDE3: begin
				draw = 4'd9;
				end
			HIDE4: begin
				draw = 4'd10;
				end
			HIDE5: begin
				draw = 4'd11;
				end
			HIDE6: begin
				draw = 4'd12;
				end
			SHOW1: begin
				if(select == 3'd1)
					draw = 4'd1;
				if(select == 3'd2)
					draw = 4'd2;
				if(select == 3'd3)
					draw = 4'd3;
				if(select == 3'd4)
					draw = 4'd4;
				if(select == 3'd5)
					draw = 4'd5;
				if(select == 3'd6)
					draw = 4'd6;
			end
			SHOW2: begin
				if(select == 3'd1)
					draw = 4'd1;
				if(select == 3'd2)
					draw = 4'd2;
				if(select == 3'd3)
					draw = 4'd3;
				if(select == 3'd4)
					draw = 4'd4;
				if(select == 3'd5)
					draw = 4'd5;
				if(select == 3'd6)
					draw = 4'd6;
			end
			SHOW3: begin
				if(select == 3'd1)
					draw = 4'd1;
				if(select == 3'd2)
					draw = 4'd2;
				if(select == 3'd3)
					draw = 4'd3;
				if(select == 3'd4)
					draw = 4'd4;
				if(select == 3'd5)
					draw = 4'd5;
				if(select == 3'd6)
					draw = 4'd6;
			end
			SHOW4: begin
				if(select == 3'd1)
					draw = 4'd1;
				if(select == 3'd2)
					draw = 4'd2;
				if(select == 3'd3)
					draw = 4'd3;
				if(select == 3'd4)
					draw = 4'd4;
				if(select == 3'd5)
					draw = 4'd5;
				if(select == 3'd6)
					draw = 4'd6;
			end
			SHOW5: begin
				if(select == 3'd1)
					draw = 4'd1;
				if(select == 3'd2)
					draw = 4'd2;
				if(select == 3'd3)
					draw = 4'd3;
				if(select == 3'd4)
					draw = 4'd4;
				if(select == 3'd5)
					draw = 4'd5;
				if(select == 3'd6)
					draw = 4'd6;
			end
			SHOW6: begin
				if(select == 3'd1)
					draw = 4'd1;
				if(select == 3'd2)
					draw = 4'd2;
				if(select == 3'd3)
					draw = 4'd3;
				if(select == 3'd4)
					draw = 4'd4;
				if(select == 3'd5)
					draw = 4'd5;
				if(select == 3'd6)
					draw = 4'd6;
			end
			END: begin
				levelout <= level + 3'b001;
			end
		endcase
	end

	always @(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= SET;
		else
			current_state <= next_state;
	end
endmodule

module p1_counter (clock, reset_n, q);
	
   input clock;
   input reset_n;
   output [3:0] q;

   wire q0;
   wire o0;
   Tflipflop t1(.e(enable), .c(clock), .r(reset_n), .q(q0));
   assign o0 = q0 && enable;

   wire q1;
   wire o1;
   Tflipflop t2(.e(o0), .c(clock), .r(reset_n), .q(q1));
   assign o1 = q1 && o0;

   assign q = {q1,q0};

endmodule


module Tflipflop (e, c, r, q);
   input e;
   input c;
   input r;
	 
   output reg q;

   always @(posedge c, negedge r)
   begin
		if(r == 1'b0)
			q <= 0;
		else
			q <= e^q;
   end
endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule