`define DECIMAL 0
`define OPE 1
`define HALT 2

`define XY 3         //运算x^y
`define DOUBLEJC 4   //运算x!!
`define GCD 5       //最大公因数
`define LCM 6       //最小公倍数
`define MatPre 7    //预处理
`define MatPlus 8  //矩阵加
`define MatHLS 9   //行列式的值
`define MatMult 10  //矩阵乘
`define Cov1D 11 //1维序列线性卷积

`define P1  12 //玩家一按
`define P2  13 //玩家二按
`define Judge 14 //判断输赢

// Calc: Calculator main module
module calc(decimal, plus, minus, mult, div, equal, switch, inverse, clk, reset, 
            ce, sign, overflow, out, state, REGA, REGB, count, opr, game);
  input [9:0] decimal;
  input clk, ce, reset, plus, minus, equal;
  input mult,div;
  input switch, inverse;
  input game;
  output sign, overflow;
  output [24:0] out;

  // for Debugging
  output [3:0] state;
  output [24:0] REGB;
  output [24:0] REGA;
  output [3:0] count;   //0-7bit
  //output add_or_sub;
  output [3:0] opr;

  wire [3:0] d;
  //wire [8:0] alu_out;
  reg  [3:0] state;
  //七位数:-9999999~9999999//
  reg  [24:0] REGB;   //七位数最多9999999=24bit ，开设25bit寄存器，最高位是负数指示位//
  reg  [24:0] REGA;   
  reg  [3:0] count;
  //reg        add_or_sub ;
  reg  [3:0] opr;

  function [3:0] dectobin;
   input [9:0] in;
    if(in[9])
     dectobin = 9;
    else if(in[8])
     dectobin = 8;
    else if(in[7])
     dectobin = 7;
    else if(in[6])
     dectobin = 6;
    else if(in[5])
     dectobin = 5;
    else if(in[4])
     dectobin = 4;
    else if(in[3])
     dectobin = 3;
    else if(in[2])
     dectobin = 2;
    else if(in[1])
     dectobin = 1;
    else if(in[0])
     dectobin = 0;
   endfunction

  assign d=dectobin(decimal);

//阶乘表JC_MAP
wire[24:0] JC_MAP[10:0];
assign JC_MAP[0] = 25'd1;          // 0! = 1
assign JC_MAP[1] = 25'd1;          // 1! = 1
assign JC_MAP[2] = 25'd2;          // 2! = 2
assign JC_MAP[3] = 25'd6;          // 3! = 6
assign JC_MAP[4] = 25'd24;         // 4! = 24
assign JC_MAP[5] = 25'd120;        // 5! = 120
assign JC_MAP[6] = 25'd720;        // 6! = 720
assign JC_MAP[7] = 25'd5040;       // 7! = 5040
assign JC_MAP[8] = 25'd40320;      // 8! = 40320
assign JC_MAP[9] = 25'd362880;     // 9! = 362880
assign JC_MAP[10] = 25'd3628800;   // 10! = 3628800

reg[3:0] s_cnt;   //switch按下计数
reg[24:0] x,y;
reg[24:0] a,b;
reg  BranchFSM_running;   //正在运算旁支FSM：XY
integer i;
integer DOUBLE_JC_MAX = 16;
integer XY_MAX = 10;   //x^y中y的最大值
//矩阵运算
reg[2:0] Mat_weishu;
reg      over;
reg[3:0] Mnumber6A,Mnumber5A,Mnumber4A,Mnumber3A,Mnumber2A,Mnumber1A;   //矩阵A
reg[3:0] Mnumber6B,Mnumber5B,Mnumber4B,Mnumber3B,Mnumber2B,Mnumber1B;   //矩阵B
reg[3:0] Mnumber7R,Mnumber6R,Mnumber5R,Mnumber4R,Mnumber3R,Mnumber2R,Mnumber1R;   //结果矩阵R
//井字棋
reg[2:0] L_1,M_1,H_1;   //玩家一的三行输入情况[H,M,L]
reg[2:0] L_2,M_2,H_2;   //玩家二的三行输入情况
reg[3:0] Pcnt;      //玩家步数计数
reg[1:0] winner;


  always @(posedge clk or negedge reset)
    begin
     if(!reset)
       begin
         REGA <= 0; REGB <= 0; count <= 0;   
         x <= 0; y <= 0; a <= 0; b <= 0;
         BranchFSM_running <= 0;
         Mat_weishu <= 0;  
         over <= 0;
         Mnumber6A <= 0; Mnumber5A<= 0; Mnumber4A<= 0; Mnumber3A<= 0; Mnumber2A<= 0; Mnumber1A<= 0; 
         Mnumber6B <= 0; Mnumber5B<= 0; Mnumber4B<= 0; Mnumber3B<= 0; Mnumber2B<= 0; Mnumber1B<= 0; 
         Mnumber7R <= 0; Mnumber6R <= 0; Mnumber5R<= 0; Mnumber4R<= 0; Mnumber3R<= 0; Mnumber2R<= 0; Mnumber1R<= 0;
         L_1 <= 0;  M_1 <= 0;  H_1 <= 0;
         L_2 <= 0;  M_2 <= 0;  H_2 <= 0;
         Pcnt <= 0;
         winner <= 0;
         opr <= 0;
         s_cnt <= 0;
         state<= `DECIMAL;
       end
     else
       begin
        case (state)
         `DECIMAL :
            begin
             //switch计数:0 -> 1 -> 2
             s_cnt <= (switch==1) ? (s_cnt+1) : s_cnt;
                
             if((decimal != 0) && (count < 7))    //修改位数
               begin
                 count <= count + 1;
                 REGA <= REGA * 10 + d;
               end
             else if(ce)
               begin
                 REGA <= 0; 
                 count <= 0;
               end
             else if(inverse)   //±
               begin
                 REGA <= ~REGA + 1;
               end
             else if (game)  begin   //按下game按键
                 state <= `P1;
                 REGA <= 1234321;
                 REGB <= 1234321;
             end
             //A: 7  8  9  /   CE
             //B: 4  5  6  *   C
             //C: 1  2  3  -   S
             //D: 0    ±  +   =      switch=0  4  8
             //-----------------------------
             //A: 7  8  9  x^2   CE
             //B: 4  5  6  x!    C
             //C: 1  2  3  mCn   S
             //D: 0    ±  mAn   =    switch=1  5  9
             //-----------------------------
             //A: 7  8  9  x^y   CE
             //B: 4  5  6  x!!   C
             //C: 1  2  3  GCD   S
             //D: 0    ±  LCM   =    switch=2  6  10
             //-----------------------------
             //A: 7  8  9  Mat+   CE
             //B: 4  5  6  |Mat|  C
             //C: 1  2  3  Mat*   S
             //D: 0    ± 1D-cov  =   switch=3  7  11
             //-----------------------------                         
             else if(plus || minus || mult || div || equal)  
               begin 
                   if(s_cnt == 0 || s_cnt % 4 == 0) begin  
                        case(opr)
                        4'b0000: REGB <= REGB + REGA;
                        4'b0001: REGB <= REGB - REGA;
                        4'b0010: REGB <= REGB * REGA;
                        4'b0011: REGB <= REGB / REGA;
                        endcase
                        
                        if(plus)         opr <= 4'b0000;
                        else if(minus)   opr <= 4'b0001;
                        else if(mult)    opr <= 4'b0010;
                        else if(div)     opr <= 4'b0011;
                        else             opr <= opr;
                   end  //
                   else if(s_cnt % 4 == 1) begin  
                        case(opr)
                        4'b0000: REGB <= REGB + REGA;
                        4'b0001: REGB <= JC_MAP[REGB] / JC_MAP[REGB - REGA];                   //nAk: n个里选择k个  n!/(n-k)!
                        4'b0010: REGB <= JC_MAP[REGB] / (JC_MAP[REGA] * JC_MAP[REGB - REGA]);    //nCk
                        4'b0011: REGB <= JC_MAP[REGB];  
                        4'b0100: REGB <= REGB * REGB;
                        endcase
                        
                        if(plus)         opr <= 4'b0001;   //nAk   
                        else if(minus)   opr <= 4'b0010;   //nCk 
                        else if(mult)    opr <= 4'b0011;   //x!   
                        else if(div)     opr <= 4'b0100;   //x^2 
                        else             opr <= opr;
                   end              
                   else if(s_cnt % 4 == 2) begin 
                        case(opr)
                        4'b0000: REGB <= REGB + REGA;
                        4'b0100: begin  //x^y
                                x <= REGB;
                                y <= REGA;
                                state <= `XY;
                        end
                        4'b0011: begin   //x!!  输入必须按两次一样的数， 比如5!!就要按5!!5
                                x <= REGB; 
                                y <= REGB; 
                                state <= `DOUBLEJC;
                        end
                        4'b0010: begin   //GCD辗转相除法: x=max(REGA,REGB),y=min(REGA,REGB), (x,y)<-(y,x % y)
                                x <= (REGA > REGB) ? REGA : REGB;
                                y <= (REGA < REGB) ? REGA : REGB;
                                state <= `GCD;
                        end
                        4'b0001: begin  //LCM = (a * b) /GCD
                                x <= (REGA > REGB) ? REGA : REGB;
                                y <= (REGA < REGB) ? REGA : REGB;
                                state <= `LCM;            
                        end
                        endcase
                        
                        if(plus)         opr <= 4'b0001;    //LCM
                        else if(minus)   opr <= 4'b0010;    //GCD
                        else if(mult)    opr <= 4'b0011;    //x!!
                        else if(div)     opr <= 4'b0100;    //x^y
                        else             opr <= opr;
                   end
                   else if(s_cnt % 4 == 3)  begin
                        case(opr)
                        4'b0000: REGB <= REGB + REGA;
                        //支持的矩阵大小： 1*2  2*2  3*2
                        //逐行展平：比如矩阵[ [2,3,1] ; [1,4,8] ]即输入231148
                        //首先前往MatPre状态预处理，然后分别前往MatPlus,MatMult和hls
                        4'b0001: begin  //一维离散序列线性卷积
                            //state <= `Cov1D;                 
                            state <= `MatPre;             
                        end
                        4'b0010: begin
                            //state <= `MatMult;
                            state <= `MatPre;
                        end
                        4'b0011: begin
                            //state <= `MatHLS;
                            state <= `MatPre;
                        end
                        4'b0100: begin
                            //state <= `MatPlus;
                            state <= `MatPre;
                        end
                        endcase
                   
                        if(plus)         opr <= 4'b0001;    //1D-cov
                        else if(minus)   opr <= 4'b0010;    //Mat*
                        else if(mult)    opr <= 4'b0011;    //|Mat|
                        else if(div)     opr <= 4'b0100;    //Mat+
                        else             opr <= opr;
                   end
                       
                                   
                   if(BranchFSM_running == 0)  begin  //!!!!!!!!!!!!!!!!!!!!!!!!!
                        state <= `OPE;
                        REGA <= 0;
                   end
               end
            end
            
         `OPE:  begin
            if (((REGB[24]==1)&&(REGB<16777216))    //最大负数：1+ 24个0 是能表示的最大负数
                || ((REGB[24]==0)&&(REGB>9999999)))
               state<=`HALT;
            else if(inverse)
                REGB <= ~REGB + 1;
            else if(decimal) begin
                REGA <= d;   //新输入
                count <= 1;
                state <= `DECIMAL;
               end
               
            if(s_cnt % 4 == 2 || s_cnt % 4 == 3)    //正在执行DECIMAL->XY/lcm/gcd/Mat的旁支FSM，运算未结束时暂时不要跳转到OPE!!!!!!!!!
                BranchFSM_running <= 1;  
          end
          
         `HALT:
            if(ce) begin
                REGA <= 0; 
                REGB <= 0;
                opr <= 0;
                count <= 0;
                state <= `DECIMAL;
               end
          
          //旁支FSM：负责运算X^Y,x!!,GCD,LCM ----------------------------------------------------------------------------------------------------
          `XY: begin
                y <= y - 1;
                REGB <= (y == 1) ? REGB : REGB * x;               
                state <= (y == 1) ? `OPE : `XY;
           end
          `DOUBLEJC: begin
                y <= y - 2;
                if(y == REGB) //第一次
                    REGB <= REGB;
                else
                    REGB <= (y <= 1) ? REGB : REGB * y;
       
                state <= (y <= 1) ? `OPE : `DOUBLEJC;
          end
          `GCD:  begin     //GCD辗转相除法: x=max(REGA,REGB),y=min(REGA,REGB), (x,y)<-(y,x % y)
                if(x % y == 0) begin
                    REGB <= y;
                    state <= `OPE;
                end
                else begin
                    x <= y;
                    y <= x % y;
                    state <= `GCD;
                end            
          end
          `LCM: begin    //LCM = (a * b) /GCD
                if(x % y == 0) begin
                    REGB <= (REGA * REGB) / y;
                    state <= `OPE;
                end
                else begin
                    x <= y;
                    y <= x % y;
                    state <= `LCM;
                end            
          end
          //矩阵操作----------------------------------
          `MatPre: begin
                //检测位数 
                if(REGB> 99999) begin    //六位数：2*3
                    Mat_weishu <= 6;                   
                end
                else if(REGB > 9999 && REGB < 100000) begin //五位数：2*3，最高位补零
                    Mat_weishu <= 5;                   
                end
                else if(REGB > 999 && REGB < 10000) begin //四位数： 2*2
                    Mat_weishu <= 4;                   
                end
                else if(REGB > 99 && REGB < 1000)  begin  //三位数： 2*2, 最高位补零
                    Mat_weishu <= 3;
                end
                else if(REGB >9 && REGB < 100) begin  //二位数：1*2
                    Mat_weishu <= 2;                    
                end
                else if(REGB >=0 && REGB < 10) begin //一位数： 1*2 ，最高位补0
                    Mat_weishu <= 1;                   
                end
                else begin
                    Mat_weishu <= 0;    
                end  
                //分割数字
                Mnumber6B <= REGB / 100000;
                Mnumber6A <= REGA / 100000;
                Mnumber5B <= (REGB % 100000) / 10000;
                Mnumber5A <= (REGA % 100000) / 10000;
                Mnumber4B <= (REGB % 10000) / 1000;
                Mnumber4A <= (REGA % 10000) / 1000;
                Mnumber3B <= (REGB % 1000) / 100;
                Mnumber3A <= (REGA % 1000) / 100;
                Mnumber2B <= (REGB % 100) / 10;
                Mnumber2A <= (REGA % 100) / 10;
                Mnumber1B <= (REGB % 10) / 1;
                Mnumber1A <= (REGA % 10) / 1;
                //预处理结束，进入对应运算FSM
                case(opr)
                4'b0001:   state <= `Cov1D;
                4'b0010:   state <= `MatMult;
                4'b0011:   state <= `MatHLS;
                4'b0100:   state <= `MatPlus;
                endcase      
          end
          
          `MatPlus: begin
                case(Mat_weishu)
                6: begin    //M2*3
                    Mnumber1R <= Mnumber1A + Mnumber1B;
                    Mnumber2R <= Mnumber2A + Mnumber2B;
                    Mnumber3R <= Mnumber3A + Mnumber3B;
                    Mnumber4R <= Mnumber4A + Mnumber4B;
                    Mnumber5R <= Mnumber5A + Mnumber5B;
                    Mnumber6R <= Mnumber6A + Mnumber6B;
                    over <= 1;
                end
                5: begin
                   //最高位补0，但不用写
                    Mnumber1R <= Mnumber1A + Mnumber1B;
                    Mnumber2R <= Mnumber2A + Mnumber2B;
                    Mnumber3R <= Mnumber3A + Mnumber3B;
                    Mnumber4R <= Mnumber4A + Mnumber4B;
                    Mnumber5R <= Mnumber5A + Mnumber5B;
                    over <= 1;
                end
                4: begin   //M2*2
                    Mnumber1R <= Mnumber1A + Mnumber1B;
                    Mnumber2R <= Mnumber2A + Mnumber2B;
                    Mnumber3R <= Mnumber3A + Mnumber3B;
                    Mnumber4R <= Mnumber4A + Mnumber4B;
                    over <= 1;
                end
                3: begin
                    Mnumber1R <= Mnumber1A + Mnumber1B;
                    Mnumber2R <= Mnumber2A + Mnumber2B;
                    Mnumber3R <= Mnumber3A + Mnumber3B;
                    over <= 1;
                end
                2: begin   //M1*2
                    Mnumber1R <= Mnumber1A + Mnumber1B;
                    Mnumber2R <= Mnumber2A + Mnumber2B;
                    over <= 1;
                end
                1: begin
                    Mnumber1R <= Mnumber1A + Mnumber1B;
                    over <= 1;
                end
                endcase
                
                if(over == 1) begin
                    REGB <= Mnumber6R * 100000 + Mnumber5R * 10000 + Mnumber4R * 1000 + Mnumber3R * 100 + Mnumber2R * 10 + Mnumber1R * 1;
                    state <= `OPE;
                    over <= 0;
                end
                else
                    state <= `MatPlus;
          end
          
           `MatHLS: begin
           //只有2*2方阵有行列式：|abcd| = ad - bc
                if(Mat_weishu != 4 && Mat_weishu != 3) begin                    
                    REGB <= 9999999;  //没有逆矩阵显示9999999
                    state <= `OPE;
                end
                else begin
                    REGB <= Mnumber4B * Mnumber1B - Mnumber2B * Mnumber3B;
                    state <= `OPE;
                end
          end
          
          `MatMult: begin
                //运算
                //1*2-REGB[a,b] 与 2*1-REGA[c;d] 相乘为 1*1[ac+bd]
                if(Mat_weishu == 2) begin
                    Mnumber1R <= Mnumber2B * Mnumber2A + Mnumber1B * Mnumber1A;
                    over <= 1;
                    //REGB <= Mnumber1R;
                end
                //2*2-REGB[[a,b];[c,d]] 与 2*2-REGA[[e,f];[g,h]] 相乘为 2*2[[ae+bg],[af+bh];[ce+dg],[cf+dh]]
                else if(Mat_weishu == 4 || Mat_weishu == 3) begin 
                    Mnumber4R <= Mnumber4B * Mnumber4A + Mnumber3B * Mnumber2A;  //ae+bg
                    Mnumber3R <= Mnumber4B * Mnumber3A + Mnumber3B * Mnumber1A;  //af+bh
                    Mnumber2R <= Mnumber2B * Mnumber4A + Mnumber1B * Mnumber2A;  //ce+dg
                    Mnumber1R <= Mnumber2B * Mnumber3A + Mnumber1B * Mnumber1A;  //cf+dh
                    over <= 1;
                    //REGB <= Mnumber4R * 1000 + Mnumber3R * 100 + Mnumber2R * 10 + Mnumber1R * 1;
                end
                //2*3-REGB[[a,b,c];[d,e,f]] 与 3*2-REGA[[g,h];[i,j];[k,l]] 相乘为 2*2[[ag+bi+ck,ah+bj+cl];[dg+ei+fk,dh+ej+fl]]
                else if(Mat_weishu == 6 || Mat_weishu == 5) begin
                    Mnumber4R <= Mnumber6B * Mnumber6A + Mnumber5B * Mnumber4A + Mnumber4B * Mnumber2A;  //ag+bi+ck
                    Mnumber3R <= Mnumber6B * Mnumber5A + Mnumber5B * Mnumber3A + Mnumber4B * Mnumber1A;  //ah+bj+cl
                    Mnumber2R <= Mnumber3B * Mnumber6A + Mnumber2B * Mnumber4A + Mnumber1B * Mnumber2B;  //dg+ei+fk
                    Mnumber1R <= Mnumber3B * Mnumber5A + Mnumber2B * Mnumber3A + Mnumber1B * Mnumber1B;  //dh+ej+fl
                    over <= 1;
                    //REGB <= Mnumber4R * 1000 + Mnumber3R * 100 + Mnumber2R * 10 + Mnumber1R * 1;
                end
                else  //不支持的运算
                    REGB <= 9999999;
                    
                //结果赋予REGB
                if(over == 1) begin
                    REGB <= Mnumber4R * 1000 + Mnumber3R * 100 + Mnumber2R * 10 + Mnumber1R * 1;
                    over <= 0;
                    state <= `OPE;
                end
                else begin
                    state <= `MatMult;
                end               
          end         
          
          `Cov1D: begin
                //N长序列 和 M长序列 卷积结果是 M+N-1。最高不能超过7，否则无法显示
                //直接规定最大 N=4 * M=4
                if(Mat_weishu > 4)  begin
                    REGB <= 9999999;
                    over <= 1;
                end
                else begin
                    Mnumber7R <= Mnumber4B * Mnumber1A;
                    Mnumber6R <= Mnumber3B * Mnumber1A + Mnumber4B * Mnumber2A;
                    Mnumber5R <= Mnumber2B * Mnumber1A + Mnumber3B * Mnumber2A + Mnumber4B * Mnumber3A;
                    Mnumber4R <= Mnumber1B * Mnumber1A + Mnumber2B * Mnumber2A + Mnumber3B * Mnumber3A + Mnumber4B * Mnumber4A;
                    Mnumber3R <= Mnumber3B * Mnumber4A + Mnumber2B * Mnumber3A + Mnumber1B * Mnumber2A;
                    Mnumber2R <= Mnumber2B * Mnumber4A + Mnumber1B * Mnumber3A;
                    Mnumber1R <= Mnumber1B * Mnumber4A;
                    over <= 1;
                end
                
                if(over == 1) begin
                    REGB <= Mnumber7R * 1000000 + Mnumber6R * 100000 + Mnumber5R * 10000 + Mnumber4R * 1000 + Mnumber3R * 100 + Mnumber2R * 10 + Mnumber1R * 1;
                    state <= `OPE;
                end
                else  begin
                    state <= `Cov1D;
                end
          end
          
          //井字棋--------------------------------------------------
          `P1: begin
                if((decimal != 0))   begin //键入
                    H_1[0] <= (d == 7) ? (H_1[0]+ 1) : H_1[0];
                    H_1[1] <= (d == 8) ? (H_1[1]+ 1) : H_1[1];
                    H_1[2] <= (d == 9) ? (H_1[2]+ 1) : H_1[2];
                    M_1[0] <= (d == 4) ? (M_1[0]+ 1) : M_1[0];
                    M_1[1] <= (d == 5) ? (M_1[1]+ 1) : M_1[1];
                    M_1[2] <= (d == 6) ? (M_1[2]+ 1) : M_1[2];
                    L_1[0] <= (d == 1) ? (L_1[0]+ 1) : L_1[0];
                    L_1[1] <= (d == 2) ? (L_1[1]+ 1) : L_1[1];
                    L_1[2] <= (d == 3) ? (L_1[2]+ 1) : L_1[2];
                    Pcnt <= Pcnt + 1;
                    state <= `Judge;
                end
                else begin
                    state <= `P1;
                end
                REGB <= 1110000;
          end
          `P2: begin
                if((decimal != 0))   begin //键入
                    H_2[0] <= (d == 7) ? (H_2[0]+1) : H_2[0];
                    H_2[1] <= (d == 8) ? (H_2[1]+1) : H_2[1];
                    H_2[2] <= (d == 9) ? (H_2[2]+1) : H_2[2];
                    M_2[0] <= (d == 4) ? (M_2[0]+1) : M_2[0];
                    M_2[1] <= (d == 5) ? (M_2[1]+1) : M_2[1];
                    M_2[2] <= (d == 6) ? (M_2[2]+1) : M_2[2];
                    L_2[0] <= (d == 1) ? (L_2[0]+1) : L_2[0];
                    L_2[1] <= (d == 2) ? (L_2[1]+1) : L_2[1];
                    L_2[2] <= (d == 3) ? (L_2[2]+1) : L_2[2];
                    Pcnt <= Pcnt + 1;
                    state <= `Judge;
                end
                else begin
                    state <= `P2;
                end
                REGB <= 111;
          end
          `Judge: begin
                if( H_1 == 3'b111 || M_1 == 3'b111 || L_1 == 3'b111 ||
                   {H_1[0],M_1[0],L_1[0]} == 3'b111 || {H_1[1],M_1[1],L_1[1]} == 3'b111 || {H_1[2],M_1[2],L_1[2]} == 3'b111 || 
                   {H_1[0],M_1[1],L_1[2]} == 3'b111 || {H_1[2],M_1[1],L_1[0]} == 3'b111 )  begin
                    winner <= 1;   //玩家一胜利       
                    REGB <= 1111111;
                    state <= `OPE;            
                end
                else if( H_2 == 3'b111 || M_2 == 3'b111 || L_2 == 3'b111 ||
                        {H_2[0],M_2[0],L_2[0]} == 3'b111 || {H_2[1],M_2[1],L_2[1]} == 3'b111 || {H_2[2],M_2[2],L_2[2]} == 3'b111 || 
                        {H_2[0],M_2[1],L_2[2]} == 3'b111 || {H_2[2],M_2[1],L_2[0]} == 3'b111 )  begin
                    winner <= 2;   //玩家二胜利
                    REGB <= 2222222;
                    state <= `OPE;
                end
                else  begin   //目前没决出胜负或者平
                    if(Pcnt == 9)  begin  //下完了但是平局
                        winner <= 0;
                        REGB <= 5555555;  
                        state <= `OPE;
                    end
                    else begin   //未决出胜负，继续下
                        state <= (Pcnt % 2 == 0) ? `P1 : `P2;
                    end
                end
          end
          
          //More States 》》》
          
         endcase
       end
    end

  assign overflow=(state==`HALT)?1:0;
  //assign sign=(state==`DECIMAL)? 0: ((state==`OPE)?(REGB[24]) :0);
  assign sign=(state==`DECIMAL)? REGA[24]: ((state==`OPE)?(REGB[24]) :0);
  assign out=out_func (state, REGA, REGB);

  function [24:0] out_func;
    input [1:0] s; input [24:0] a; input [24:0] b;
    case(s)
      `DECIMAL :
        out_func = a;

      `OPE :
        if(b[24]==1)    //负数：检查最高位
          out_func = ~b + 1;
        else
          out_func = b;
    endcase
  endfunction

endmodule