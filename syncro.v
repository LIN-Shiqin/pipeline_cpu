// Syncro: Asyncronous to Syncronous (1-bit width)
module syncro(out, in, clk, reset);
  parameter WIDTH = 1;
  input    [WIDTH-1:0] in ;
  output   [WIDTH-1:0] out;
  input     clk,reset;
  reg      [WIDTH-1:0] qO,q1,q2;

  always @(posedge clk or negedge reset)
   begin
    if(!reset)
     begin
       qO <= 0;
       q1 <= 0;
       q2 <= 0;
     end
    else
     begin
       qO <= ~in;
       q1 <= qO;
       q2 <= q1;
     end
   end
  assign out=q1 & (~q2) ;
endmodule