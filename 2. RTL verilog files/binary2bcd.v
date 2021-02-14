module binary2bcd (bi,h,t,o);

input [7:0]bi;
output reg [3:0]h,t,o;

	// Internal variable for storing bits
   reg [19:0] shift;
   reg [3:0] i;
   
   always @(bi)
   begin
      // Clear previous number and store new number in shift register
      shift[19:8] = 0;
      shift[7:0] = bi;
      
      // Loop eight times
      for (i=0; i<4'h8; i=i+1) begin
         if (shift[11:8] >= 5)
            shift[11:8] = shift[11:8] + 4'h3;
            
         if (shift[15:12] >= 5)
            shift[15:12] = shift[15:12] + 4'h3;
            
         if (shift[19:16] >= 5)
            shift[19:16] = shift[19:16] + 4'h3;
         
         // Shift entire register left once
         shift = shift << 1;
      end
      
      // Push decimal numbers to output
      h = shift[19:16];
      t = shift[15:12];
      o = shift[11:8];
   end
endmodule


