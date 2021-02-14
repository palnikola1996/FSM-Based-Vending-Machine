module pedge_det (clk, rstn, signal, pedge_pulse);
input      clk;
input      rstn;
input      signal;
output reg pedge_pulse;

reg [2:0] sync;

always @(posedge clk or negedge rstn)
begin
  if(!rstn) begin
     sync        <= 'b0;
     pedge_pulse <= 'b0;
  end
  else begin
    sync        <= {sync[1:0],signal}; // Remove Debouncing
    pedge_pulse <= ~sync[2] & sync[1]; // Detect positive edge of signal
  end
end
endmodule
