// Calctop: Calculator top module
module calctop(clk, reset, push, ce, plus, minus, mult, div, equal, switch, inverse,
               sign, ledh, ledg, ledf, lede, ledd, ledc, ledb, overflow, state, rega, regb,
               count, opr, game);
               
  input plus, minus, equal, ce, reset, clk;
  //新增按键
  input mult, div, switch, inverse;
  input game;
  input [9:0] push;
  output overflow, sign;
  //output [7:0] ledh, ledl;
  output [7:0] ledh, ledg, ledf, lede, ledd, ledc, ledb;

  // for Debug
  output [1:0] state;
  output [24:0] regb;
  output [24:0] rega;
  output [3:0] count;
  output [3:0] opr;

  wire plusout, minusout, equalout, ceout;
  // 新增按键
  wire multout, divout;
  wire switchout, inverseout;
  //
  wire [9:0] pushout;
  wire [24:0] wout;

  calc calc(pushout, plusout, minusout, multout, divout, equalout, switchout, inverseout, clk, reset, ceout, 
            sign, overflow, wout, state, rega, regb, count, 
            opr, gameout);

  //binled binled(wout, ledl, ledh);
  binled binled(wout, ledh, ledg, ledf, lede, ledd, ledc, ledb);

  syncro syncroce(ceout, ce, clk, reset);
  syncro syncropuls(plusout, plus, clk, reset);
  syncro syncrominus(minusout, minus, clk, reset);
  syncro syncroequal(equalout, equal, clk, reset);
  //新增按键
  syncro syncromult(multout, mult, clk, reset);
  syncro syncrodiv(divout, div, clk, reset);
  syncro syncroswitch(switchout, switch, clk, reset);
  syncro syncroinverse(inverseout, inverse, clk, reset);
  syncro syncrogame(gameout, game, clk, reset);
  
  syncro10 syncropush(pushout, push, clk, reset);

endmodule