`timescale 1ns/1ns

`include "./binary2bcd.v"
`include "./keypad.v"
`include "./pedge_det.v"
`include "./vending_machine.v"
`include "./vending_machine_top.v"

module Vending_Machine_TB();


//output port declaration  

reg 	   clk; 
reg 	   rstn;
reg [3:0 ] row;
reg [31:0] actual_amount;
reg [31:0] expected_amount;

/*
key_value_in = 9'b00000_000_1 -> 01 -> Trans_cancel ; 
key_value_in = 9'b00000_001_0 -> 02 -> Money   -> 1 ;
key_value_in = 9'b00000_010_0 -> 03 -> Money   -> 5 ;
key_value_in = 9'b00000_100_0 -> 04 -> Money   -> 10;
key_value_in = 9'b00001_000_0 -> 05 -> Produce -> 1 ; 
key_value_in = 9'b00010_000_0 -> 06 -> Product -> 2 ;
key_value_in = 9'b00100_000_0 -> 07 -> Product -> 3 ;
key_value_in = 9'b01000_000_0 -> 08 -> Product -> 4 ;
key_value_in = 9'b10000_000_0 -> 09 -> Product -> 5 ;
	
*/
reg [8:0] key_value_in;
  
//input port declaration  
wire [3:0] col;
wire [7:0] seven_seg0;
wire [7:0] seven_seg1;
wire [7:0] seven_seg2;
wire [7:0] seven_seg3;
wire [7:0] seven_seg4;
wire [7:0] seven_seg5;
  
//Instantiation of design module
  vending_machine_top vm_inst (
    .clk(clk),
    .rstn(rstn),
    .row(row),
    .col(col),
    .key_value_in(key_value_in),
    .seven_seg0  (seven_seg0  ),
    .seven_seg1  (seven_seg1  ),
    .seven_seg2  (seven_seg2  ),
    .seven_seg3  (seven_seg3  ),
    .seven_seg4  (seven_seg4  ),
    .seven_seg5  (seven_seg5  )
    );  
  
parameter CLK_LOW_PERIOD  =  10;
parameter CLK_HIGH_PERIOD =  10;  
  
//initial block to initialize all variables
initial begin
    clk      	          = 0;
    rstn	   	  = 0;
end 

// Task for initializing local variables of testbench
task variable_initialization();
  begin
    actual_amount	  = 0;
    expected_amount       = 0;
    key_value_in	  = 0;
  end
endtask 

// Parameterized clock
always begin
  #(CLK_LOW_PERIOD)  clk = 0;
  #(CLK_HIGH_PERIOD) clk = 1;
end 
  

// This task drive reset
task drive_reset(input count);
  begin	
  $display($time,"drive_reset : count =%d",count);
    repeat (count)begin
      rstn = 0;
      #(CLK_LOW_PERIOD + CLK_HIGH_PERIOD);
    end
    rstn = 1;
  end
endtask


// Task for random product selection
task product_selection();

reg [8:0] selection;

begin
  selection      = $random & 32'h7; 
  case(selection) 
  3'b001  : key_value_in = 9'b00001_000_0;
  3'b010  : key_value_in = 9'b00010_000_0;
  3'b011  : key_value_in = 9'b00100_000_0;
  3'b100  : key_value_in = 9'b01000_000_0;
  3'b101  : key_value_in = 9'b10000_000_0;
  default : key_value_in = 9'b00001_000_0;
  endcase

  repeat(50) begin
  #(CLK_HIGH_PERIOD + CLK_LOW_PERIOD); 
  end 

  $display($time,"product selection : selection = %0d key_value : %b",selection,key_value_in);
end
endtask

/*
* This task generate random money selection 
*/
task money_selection();

reg [1:0] rand1; 
reg [8:0] rand_value;

begin
  case(key_value_in) 
    9'b00001_000_0 : expected_amount = 2;
    9'b00010_000_0 : expected_amount = 5;
    9'b00100_000_0 : expected_amount = 7;
    9'b01000_000_0 : expected_amount = 15;
    9'b10000_000_0 : expected_amount = 18;
  endcase 
  $display($time," START : money_selection key_value_in=%b,actual_amount=%0d,expected_amount=%0d",key_value_in,actual_amount,expected_amount);
  
  while(!(expected_amount <= actual_amount))begin
    rand1 = $random & 32'h0000_0003;

    case (rand1) 
      2'b00   : rand_value = 9'b00000_001_0;	    
      2'b01   : rand_value = 9'b00000_010_0;	    
      2'b10   : rand_value = 9'b00000_100_0;	    
      default : rand_value = 9'b00000_001_0;	    
    endcase 
     	    
    
    if(rand_value == 9'b00000_001_0)
    begin
      actual_amount = actual_amount + 1;
    end 
    else if (rand_value == 9'b00000_010_0)
    begin
      actual_amount = actual_amount + 5;
    end else if (rand_value == 9'b00000_100_0)
    begin
      actual_amount = actual_amount + 10;
    end 
    key_value_in = rand_value;	    
    
    repeat(50) begin
      #(CLK_LOW_PERIOD + CLK_HIGH_PERIOD);	    
    end
    $display($time," END : money_selection key_value_in=%b,  actual_amount=%0d,   expected_amount=%0d , rand_value=%b",key_value_in,actual_amount,expected_amount,rand_value);
  end //whie end
end 
endtask
  
  

// Main block to generate different operation
initial begin
    variable_initialization();
    #20;	
    drive_reset(10);
    #100;
    repeat(20)begin	
      variable_initialization();
      product_selection();
      money_selection();
      #1000;
  end
end 
  
initial begin
#50000 $finish;
end

initial begin
  $vcdpluson(0,Vending_Machine_TB);
end 

endmodule 
