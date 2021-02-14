module vending_machine_top #(
parameter   NUM_OF_PRODUCTS   = 5,
            MONEY_BUTTONS     = 3,
            PRODUCT0_PRICE    = 2,
            PRODUCT1_PRICE    = 5,
            PRODUCT2_PRICE    = 7,
            PRODUCT3_PRICE    = 15,
            PRODUCT4_PRICE    = 18,
            DISPLAY_TIME      = 2,
            DISPLAY_TIME_TEST = 0)
(
clk,
rstn,

row,
col,

seven_seg0,
seven_seg1,
seven_seg2,
seven_seg3,
seven_seg4,
seven_seg5
);

input  clk;
input  rstn;

input  [3:0] row;
output [3:0] col;

output [7:0] seven_seg0;
output [7:0] seven_seg1;
output [7:0] seven_seg2;
output [7:0] seven_seg3;
output [7:0] seven_seg4;
output [7:0] seven_seg5;

wire [NUM_OF_PRODUCTS-1:0] product_pulse;
wire [MONEY_BUTTONS-1:0]   money_pulse;
wire                       tran_cancel_pulse;
wire                       product_refill_pulse;

wire [9:0] key_value;

// Vending Machine FSM
vending_machine
#( .NUM_OF_PRODUCTS   (NUM_OF_PRODUCTS),
   .MONEY_BUTTONS     (MONEY_BUTTONS),
   .PRODUCT0_PRICE    (PRODUCT0_PRICE),
   .PRODUCT1_PRICE    (PRODUCT1_PRICE),
   .PRODUCT2_PRICE    (PRODUCT2_PRICE),
   .PRODUCT3_PRICE    (PRODUCT3_PRICE),
   .PRODUCT4_PRICE    (PRODUCT4_PRICE),
   .DISPLAY_TIME      (DISPLAY_TIME),
   .DISPLAY_TIME_TEST (DISPLAY_TIME_TEST)
) u_vending_machine (
   .clk                  (clk               ),
   .rstn                 (rstn              ),

   .product_pulse        (product_pulse     ),
   .money_pulse          (money_pulse       ),

   .tran_cancel_pulse    (tran_cancel_pulse ),
   .product_refill_pulse (product_refill_pulse),

   .seven_seg0           (seven_seg0        ),
   .seven_seg1           (seven_seg1        ),
   .seven_seg2           (seven_seg2        ),
   .seven_seg3           (seven_seg3        ),
   .seven_seg4           (seven_seg4        ),
   .seven_seg5           (seven_seg5        )
);

keypad u_keypad(clk,rstn,row,col,key_value);

// pedge_det will remove the debouncing of keypad input and by cascaded flops
// an convert input to a pulse at posedge of key input
genvar i;
generate
for (i=4;i<4+NUM_OF_PRODUCTS;i=i+1)
begin: product_gen
   pedge_det u_product_pulse_det
   (
   .clk    (clk),
   .rstn   (rstn),
   .signal (key_value[i]),
   .pedge_pulse (product_pulse[i-4])
   );
end
endgenerate

genvar j;
generate
for (j=1;j<(1+MONEY_BUTTONS);j=j+1)
begin: money_gen
   pedge_det u_money_pulse_det
   (
   .clk    (clk),
   .rstn   (rstn),
   .signal (key_value[j]),
   .pedge_pulse (money_pulse[j-1])
   );
end
endgenerate

pedge_det u_tran_cancel_pulse_det
(
.clk    (clk),
.rstn   (rstn),
.signal (key_value[0]),
.pedge_pulse (tran_cancel_pulse)
);

pedge_det u_product_refill_pulse_det
(
.clk    (clk),
.rstn   (rstn),
.signal (key_value[9]),
.pedge_pulse (product_refill_pulse)
);
endmodule
