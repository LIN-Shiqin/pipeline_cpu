// AP600: Interface between top-moudule of calculator and FPGA board
module AP600 (clk, reset, pswA, pswB, pswC, pswD, dipA, dipB,
	      hexA, hexB, buzzer, ledA, ledB, ledC, ledD, 
             segA, segB, segC, segD, segE, segF, segG, segH) ;

  input      clk, reset;             // Clock, Reset
  input[4:0] pswA, pswB, pswC, pswD; // Push switch
  input[7:0] dipA, dipB;             // DIP switch
  input[3:0] hexA, hexB;             // Rotary switch
  output     buzzer;		     // Buzzer
  output[7:0] ledA, ledB, ledC, ledD;// LED
  output[7:0] segA, segB, segC, segD, segE, segF, segG, segH ; // 7SEG LED

  wire [7:0] ledb,ledc,ledd,lede,ledf,ledg,ledh;
  wire [9:0] push;
  wire overflow, sign, ce, plus, minus, equal;

  // for Debug
  wire [1:0] state;
  wire [24:0] regb;
  wire [24:0] rega;
  wire [3:0] count;
  wire [3:0] opr;

  assign push[0] = pswD[0];
  assign push[1] = pswC[0];
  assign push[2] = pswC[1];
  assign push[3] = pswC[2];
  assign push[4] = pswB[0];
  assign push[5] = pswB[1];
  assign push[6] = pswB[2];
  assign push[7] = pswA[0];
  assign push[8] = pswA[1];
  assign push[9] = pswA[2];
  assign plus    = pswD[3];  //nAk
  assign minus   = pswC[3];  //nCk
  assign mult    = pswB[3];  //x!
  assign div     = pswA[3];  //x^2
  assign ce      = pswA[4];  
  assign equal   = pswD[4];
  assign switch  = pswC[4];
  assign inverse = pswD[2];   //±
  assign game    = pswD[1];   //进入井字棋游玩模式
  
  // Output assignment
  assign buzzer = overflow;

  assign ledA = {overflow,2'b00, count[0],count[1], 
                 opr, state[0], state[1]};
  assign ledB = {regb[8], 7'b0000000};
  assign ledC = {regb[0],regb[1],regb[2],regb[3],
                 regb[4],regb[5],regb[6],regb[7]};
  assign ledD = {rega[0],rega[1],rega[2],rega[3],
                 rega[4],rega[5],rega[6],1'b0};
                 
  //H最低位，B最高位!!!  (A符号位)
  assign segA = {6'b000000,sign,1'b0};
  assign segB = ledb;
  assign segC = ledc;
  assign segD = ledd;
  assign segE = lede;
  assign segF = ledf;
  assign segG = ledg;
  assign segH = ledh;

  calctop calctop(clk, reset, push, ce, plus, minus, mult, div, equal, switch, inverse,
               sign, ledh, ledg, ledf, lede, ledd, ledc, ledb, overflow, state, rega, regb,
               count, opr, game);

endmodule