module keypad(clk,reset,row,col,key_value);
//------------------------------------------------------- 
parameter S0 = 3'b000;
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;
//------------------------------------------------------- 
input clk,reset; 
input [3:0] row;
//-------------------------------------------------------
output reg[3:0] col;
output reg[9:0] key_value;
//-------------------------------------------------------
reg key_flag;     
reg [2:0] state;
reg [3:0] col_reg;  
reg [3:0] row_reg;  
//-------------------------------------------------------
 
//-------------------------------------------------------
always @(posedge clk or negedge reset)
begin
	if(!reset) 
	begin 
		row_reg	<= 4'b0000;
		col_reg	<= 4'b0000;
		col		<= 4'b0000;
		state		<= S0;
		key_flag	<= 1'b0;
	end
	else 
	begin 
		case (state)
        S0:begin
			col[3:0]	<= 4'b0000;
			key_flag	<= 1'b0;
			
			if(row[3:0]!=4'b1111)
			begin 
				state		<= S1;
				col[3:0]	<= 4'b1110;
			end 
			else
				state	<= S0;
		  end
		  
        S1:begin
			if(row[3:0]!=4'b1111) 
			begin 
				state	<= S5;
			end   
			else  
			begin 
				state		<= S2;
				col[3:0]	<= 4'b1101;
			end  
        end
		
        S2:begin    
			if(row[3:0]!=4'b1111) 
				state	<= S5;
			else  
			begin 
				state		<= S3;
				col[3:0]	<= 4'b1011;
			end  
		  end
		
        S3:begin    
			if(row[3:0]!=4'b1111)
				state	<= S5;
			else  
			begin 
				state		<= S4;
				col[3:0]	<= 4'b0111;
			end  
        end
		
        S4:begin    
			if(row[3:0]!=4'b1111) 
				state	<= S5;
			else
				state	<= S0;
        end
		
        S5:begin  
			if(row[3:0]!=4'b1111) 
			begin
				col_reg	<= col;  
				row_reg	<= row;  
				state		<= S5;
				key_flag	<= 1'b1;  
			end             
			else
				state	<= S0;
		  end    
      endcase 
   end           
end
//-------------------------------------------------------

//-------------------------------------------------------
always @(clk, col_reg, row_reg, key_flag)
begin
	if(key_flag==1'b1) 
	begin
		case ({col_reg,row_reg})
			//--------------------------------------------------//
			8'b1110_1110:key_value <= {1'b0,5'b00000,3'b000,1'b1};
			//--------------------------------------------------//
			8'b1110_1101:key_value <= {1'b1,5'b00000,3'b000,1'b0};
			//--------------------------------------------------//
			8'b1101_1110:key_value <= {1'b0,5'b00000,3'b001,1'b0};
			8'b1101_1101:key_value <= {1'b0,5'b00000,3'b010,1'b0};
			8'b1101_1011:key_value <= {1'b0,5'b00000,3'b100,1'b0};
			//--------------------------------------------------//
			8'b1011_1110:key_value <= {1'b0,5'b10000,3'b000,1'b0};
			8'b0111_1110:key_value <= {1'b0,5'b01000,3'b000,1'b0};
			8'b0111_1101:key_value <= {1'b0,5'b00100,3'b000,1'b0};
			8'b0111_1011:key_value <= {1'b0,5'b00010,3'b000,1'b0};
			8'b0111_0111:key_value <= {1'b0,5'b00001,3'b000,1'b0};
			//--------------------------------------------------//
         default		:key_value <= 'b0;
		endcase 
   end
	 else 
		key_value <= 'b0;
end       
//-------------------------------------------------------

endmodule

