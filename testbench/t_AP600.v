// Project #1: Calculator
// Test pattern file for "System LSI design"
// Sequence: "1 + 5 - 9 ="
//                                                  2024.10  T. Ikenaga
// 
`timescale 1ns / 10ps

module t_AP600;

  reg clk ,reset;                   // clock, reset
  reg [4:0] pswA, pswB, pswC, pswD; // push switch(NEG)
  reg [7:0] dipA, dipB;             // dip switch(NEG)
  reg [3:0] hexA, hexB;             // rotary switch
  wire buzzer;			    // buzzer
  wire [7:0] ledA, ledB, ledC, ledD;// LED
  wire [7:0] segA, segB, segC, segD, segE, segF, segG, segH; // 7SEG

  // Clock
  initial clk = 0;
  always
    #5 clk = ~clk;

  //A: 7  8  9  /   CE
  //B: 4  5  6  *   C
  //C: 1  2  3  -   S
  //D: 0  . ¡À  +   = 
  //-----------------------------
  //A: 7  8  9  x^2   CE
  //B: 4  5  6  x!    C
  //C: 1  2  3  mCn   S
  //D: 0  . ¡À  mAn   = 
  //-----------------------------
  //A: 7  8  9  x^y   CE
  //B: 4  5  6  x!!   C
  //C: 1  2  3  GCD   S
  //D: 0  . ¡À  LCM   =   
  //-----------------------------  
  //A: 7  8  9  Mat+   CE
  //B: 4  5  6  |Mat|  C
  //C: 1  2  3  Mat*   S
  //D: 0    ¡À 1D-cov  =   
  //-----------------------------     
  initial
    begin
      $monitor("REGA=%b, REGB=%b, SEGF=%b, SEGG=%b, SEGH=%b",
               AP600.rega, AP600.regb, segF, segG, segH);
      reset <= 1; pswA <= 5'b11111; pswB <= 5'b11111; pswC <= 5'b11111; 
      pswD <= 5'b11111;
      dipA <=8'b11111111; dipB <=8'b11111111; hexA <=4'b1111; hexB <=4'b1111;
      #10 reset <= 0;
      #10 reset <= 1;
        //TEST: 1 2 2 1 Mat* 1 1 2 2 = 5 5 4 4
      // input: 1
      #10 pswC[0] <= 0;
      #10 pswC[0] <= 1;    
      // input: 2
      #10 pswC[1] <= 0;
      #10 pswC[1] <= 1;    
      // input: 2
      #10 pswC[1] <= 0;
      #10 pswC[1] <= 1;
      // input: 1
      #10 pswC[0] <= 0;
      #10 pswC[0] <= 1;
      // input: s
      #10 pswC[4] <= 0;
      #10 pswC[4] <= 1;
      // input: s
      #10 pswC[4] <= 0;
      #10 pswC[4] <= 1;
      // input: s
      #10 pswC[4] <= 0;
      #10 pswC[4] <= 1;
      //input:Mat*
      #10 pswC[3] <= 0;
      #10 pswC[3] <= 1;     
      // input: 1
      #10 pswC[0] <= 0;
      #10 pswC[0] <= 1; 
      // input: 1
      #10 pswC[0] <= 0;
      #10 pswC[0] <= 1; 
      // input: 2
      #10 pswC[1] <= 0;
      #10 pswC[1] <= 1;   
      // input: 2
      #10 pswC[1] <= 0;
      #10 pswC[1] <= 1;  
      // input: =
      #10 pswD[4] <= 0;
      #10 pswD[4] <= 1;        
      
      
//      //TEST: 2^3 = 8  -----------------------------------------------------------------------------
//      // input: 2
//      #10 pswC[1] <= 0;
//      #10 pswC[1] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: x^y
//      #10 pswA[3] <= 0;
//      #10 pswA[3] <= 1;
//      // input: 3
//      #10 pswC[2] <= 0;
//      #10 pswC[2] <= 1;
//      // input: =
//      #10 pswD[4] <= 0;
//      #10 pswD[4] <= 1;
      
//      //TEST: 10!!  -----------------------------------------------------------------------------
//      // input: 1
//      #10 pswC[0] <= 0;
//      #10 pswC[0] <= 1;
//      // input: 0
//      #10 pswD[0] <= 0;
//      #10 pswD[0] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: x!!
//      #10 pswB[3] <= 0;
//      #10 pswB[3] <= 1;
//      // input: 1
//      #10 pswC[0] <= 0;
//      #10 pswC[0] <= 1;
//      // input: =
//      #10 pswD[4] <= 0;
//      #10 pswD[4] <= 1;      
      
//      //TEST: 7!! -----------------------------------------------------------------------------
//      // input: 7
//      #10 pswA[0] <= 0;
//      #10 pswA[0] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: x!!
//      #10 pswB[3] <= 0;
//      #10 pswB[3] <= 1;
//      // input: 1
//      #10 pswC[0] <= 0;
//      #10 pswC[0] <= 1;
//      // input: =
//      #10 pswD[4] <= 0;
//      #10 pswD[4] <= 1;      

//      //TEST: 56 GCD 98 = 14 -----------------------------------------------------------------------------
//      // input: 5
//      #10 pswB[1] <= 0;
//      #10 pswB[1] <= 1;    
//      // input: 6
//      #10 pswB[2] <= 0;
//      #10 pswB[2] <= 1;  
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: s
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      // input: GCD
//      #10 pswC[3] <= 0;
//      #10 pswC[3] <= 1;
//      // input: 9
//      #10 pswA[2] <= 0;
//      #10 pswA[2] <= 1;
//      // input: 8
//      #10 pswA[1] <= 0;
//      #10 pswA[1] <= 1;
//      // input: =
//      #10 pswD[4] <= 0;
//      #10 pswD[4] <= 1;  

//      //TEST: 1 1 + 5 5 5 - 9 9 9 =  ------------------------------------------------------ 
//      // input: 1
//      #10 pswC[0] <= 0;
//      #10 pswC[0] <= 1;
//      // input: 1
//      #10 pswC[0] <= 0;
//      #10 pswC[0] <= 1;

//      // input: +
//      #10 pswD[3] <= 0;
//      #10 pswD[3] <= 1;

//      // input: 5
//      #10 pswB[1] <= 0;
//      #10 pswB[1] <= 1;
//      // input: 5
//      #10 pswB[1] <= 0;
//      #10 pswB[1] <= 1;
//      // input: 5
//      #10 pswB[1] <= 0;
//      #10 pswB[1] <= 1;
      
//      // input: -
//      #10 pswC[3] <= 0;
//      #10 pswC[3] <= 1;

//      // input: 9
//      #10 pswA[2] <= 0;
//      #10 pswA[2] <= 1;
//      // input: 9
//      #10 pswA[2] <= 0;
//      #10 pswA[2] <= 1;
//      // input: 9
//      #10 pswA[2] <= 0;
//      #10 pswA[2] <= 1;

//      // input: =
//      #10 pswD[4] <= 0;
//      #10 pswD[4] <= 1;
      
      
//      //input£º4
//      #10 pswB[0] <= 0;
//      #10 pswB[0] <= 1;
//      //input£ºs
//      #10 pswC[4] <= 0;
//      #10 pswC[4] <= 1;
//      //input: nCk
//      #10 pswC[3] <= 0;
//      #10 pswC[3] <= 1;
//      //input£º2
//      #10 pswC[1] <= 0;
//      #10 pswC[1] <= 1;
//      //input: =
//      #10 pswD[4] <= 0;
//      #10 pswD[4] <= 1;
      
      #100
      $finish;
    end

   AP600 AP600(clk, reset, pswA, pswB, pswC, pswD, dipA, dipB,
	      hexA, hexB, buzzer, ledA, ledB, ledC, ledD, 
              segA, segB, segC, segD, segE, segF, segG, segH);

endmodule
