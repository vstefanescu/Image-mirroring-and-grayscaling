`timescale 1ns / 1ps

module image_processor(
    input clk,                           // semnal de ceas 
    input [23:0] pixel_in,               // valoarea pixelului de la coordonatele [row_pos, col_pos] din imaginea originală (R 23:16; G 15:8; B 7:0)
    output reg [5:0] row_sel, col_sel,   // selectează un rând și o coloană din imagine
    output reg write_enable,             // activează scrierea pentru imaginea de ieșire
    output reg [23:0] pixel_out,         // valoarea pixelului care va fi scrisă în imaginea de ieșire la coordonatele [out_row, out_col] (R 23:16; G 15:8; B 7:0)
    output reg mirror_complete,          // indică finalizarea oglindirii
    output reg grayscale_complete,       // indică finalizarea grayscale-ului
    // output reg sharpness_complete);      // indică finalizarea aplicarii filtrului de sharpness

    // fsm

	reg [5:0] current_row = 0, current_col = 0;
    reg [5:0] current_state = 0, next_state = 0;

	reg [24:0] low_pixel_buffer = 0, high_pixel_buffer = 0;
	reg [23:0] pixel_buffer = 0;
	reg [7:0] max_value = 0, min_value = 0;
	reg [8:0] average_value = 0;
	reg [7:0] red_channel = 0, green_channel = 0, blue_channel = 0;
	
	reg [2:0] sharpness_stage = 0;

	initial begin
		current_row = 0;
		current_col = 0;
		row_sel = 0;
		col_sel = 0;
		mirror_complete = 0;
		grayscale_complete = 0;
       // sharpness_complete = 0;
		write_enable = 0;
	end

	always @(posedge clk) begin
   
		current_state = next_state;

		case(current_state) 
			// oglindire
			0: begin // initializare
				write_enable = 0;    
				row_sel = current_row;
				col_sel = current_col; 
				next_state = 1;
			end 
								
			1: begin // stocheaza valoareaprimului pixel
				low_pixel_buffer = pixel_in;
				next_state = 2;
			end 				

			2: begin // calculare pozitie noua de oglindire 
				row_sel = 63 - current_row;
				next_state = 3;
			end 
			
			3: begin // stocheaza al doilea pixel
				high_pixel_buffer = pixel_in;
				next_state = 4;
			end 
			
			4: begin // scrie prima valoare in imaginea oglindita
				write_enable = 1;
				pixel_out = low_pixel_buffer;
				next_state = 5;
			end 
								
			5: begin // dezactiveaza scrierea si actualizeaza pozitia	
				write_enable = 0;
				row_sel = current_row;
				next_state = 6;
			end 

			6: begin // scrie a doua valoare in imaginea oglindita 
				write_enable = 1;
				pixel_out = high_pixel_buffer;
				next_state = 7;
			end 
								
			7: begin // dezactiveaza scrierea si continua pe coloana
				write_enable = 0;
				current_col = current_col + 1;
				next_state = 8;
			end 
			
			8: begin // verifica daca am ajuns la finalul randului
				if (current_col == 0) begin
					current_row = current_row + 1;
				end
				next_state = 9;
			end 
			
			9: begin // ultima verificare a oglindirii
				if (current_col == 0 && current_row == 32) begin 
					mirror_complete = 1;
					current_col = 0;
					current_row = 0;
					next_state = 10;
				end else begin 
					next_state = 0;
				end 
			end
					
			// conversia la grayscale
			10: begin // init
				row_sel = current_row;
				col_sel = current_col;
				next_state = 11;
			end 
					
			11: begin // stocare pixel pt grayscale
				pixel_buffer = pixel_in;
				next_state = 12;
			end
					
			12: begin // separa canalele de culoare RGB
				red_channel = pixel_buffer >> 16;
				green_channel = pixel_buffer >> 8;
				blue_channel = pixel_buffer;
				next_state = 13;
			end
					
			13: begin // calculeaza valorile minime si maxime ale cananelor rgb
				min_value = (red_channel < green_channel) ? (red_channel < blue_channel) ? red_channel : blue_channel : (green_channel < blue_channel) ? green_channel : blue_channel;
				max_value = (red_channel > green_channel) ? (red_channel > blue_channel) ? red_channel : blue_channel : (green_channel > blue_channel) ? green_channel : blue_channel;
				next_state = 14;
			end
					
			14: begin // calculare medie
				average_value = (max_value + min_value) / 2;
				pixel_buffer = 0;
				next_state = 15;
			end
					
			15: begin // actualizare pixel cu valoarea medie
				pixel_buffer = average_value << 8;
				next_state = 16;
			end
					
			16: begin // inlocuirea pixelilor in imagine
				write_enable = 1;
				pixel_out = pixel_buffer;
				next_state = 17;
			end
					
			17: begin // dezactiveaza scrierea si continuam pe coloana
				write_enable = 0;
				current_col = current_col + 1;
				next_state = 18;
			end 
			
			18: begin // verificam daca am ajuns la capat
				if (current_col == 0) begin
					current_row = current_row + 1;
				end
				next_state = 19;
			end 
			
			19: begin // ultima verificare pt grayscale
				if (current_col == 0 && current_row == 0) begin 
					grayscale_complete = 1;
					current_col = 0;
					current_row = 0;
				end else begin 
					next_state = 10;
				end 
			end
		endcase
	end

endmodule
