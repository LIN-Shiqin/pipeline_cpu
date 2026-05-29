module bintobcd(in,outh,outg,outf,oute,outd,outc,outb) ;
  input [24:0] in;
  output [3:0] outh,outg,outf,oute,outd,outc,outb;
  wire [24:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11, temp12,
              temp13, temp14, temp15, temp16, temp17, temp18, temp19, temp20, temp21, temp22, temp23, temp24;
    
    //百万位b
    assign outb[3] = (in >= 8000000) ? 1 : 0;
    assign temp1 = (in >= 8000000) ? in - 8000000 : in;
    assign outb[2] = (temp1 >= 4000000) ? 1 : 0;
    assign temp2 = (temp1 >= 4000000) ? temp1 - 4000000 : temp1;
    assign outb[1] = (temp2 >= 2000000) ? 1 : 0;
    assign temp3 = (temp2 >= 2000000) ? temp2 - 2000000 : temp2;
    assign outb[0] = (temp3 >= 1000000) ? 1 : 0;
    assign temp4 = (temp3 >= 1000000) ? temp3 - 1000000 : temp3;
    //十万位c
    assign outc[3] = (temp4 >= 800000) ? 1 : 0;
    assign temp5 = (temp4 >= 800000) ? temp4 - 800000 : temp4;
    assign outc[2] = (temp5 >= 400000) ? 1 : 0;
    assign temp6 = (temp5 >= 400000) ? temp5 - 400000 : temp5;
    assign outc[1] = (temp6 >= 200000) ? 1 : 0;
    assign temp7 = (temp6 >= 200000) ? temp6 - 200000 : temp6;
    assign outc[0] = (temp7 >= 100000) ? 1 : 0;
    assign temp8 = (temp7 >= 100000) ? temp7 - 100000 : temp7;
    //万位计算d
    assign outd[3] = (temp8 >= 80000) ? 1 : 0;
    assign temp9 = (temp8 >= 80000) ? temp8 - 80000 : temp8;
    assign outd[2] = (temp9 >= 40000) ? 1 : 0;
    assign temp10 = (temp9 >= 40000) ? temp9 - 40000 : temp9;
    assign outd[1] = (temp10 >= 20000) ? 1 : 0;
    assign temp11 = (temp10 >= 20000) ? temp10 - 20000 : temp10;
    assign outd[0] = (temp11 >= 10000) ? 1 : 0;
    assign temp12 = (temp11 >= 10000) ? temp11 - 10000 : temp11;
    // 千位计算e
    assign oute[3] = (temp12 >= 8000) ? 1 : 0;
    assign temp13 = (temp12 >= 8000) ? temp12 - 8000 : temp12;
    assign oute[2] = (temp13 >= 4000) ? 1 : 0;
    assign temp14 = (temp13 >= 4000) ? temp13 - 4000 : temp13;
    assign oute[1] = (temp14 >= 2000) ? 1 : 0;
    assign temp15 = (temp14 >= 2000) ? temp14 - 2000 : temp14;
    assign oute[0] = (temp15 >= 1000) ? 1 : 0;
    assign temp16 = (temp15 >= 1000) ? temp15 - 1000 : temp15;
    // 百位计算f
    assign outf[3] = (temp16 >= 800) ? 1 : 0;
    assign temp17 = (temp16 >= 800) ? temp16 - 800 : temp16;
    assign outf[2] = (temp17 >= 400) ? 1 : 0;
    assign temp18 = (temp17 >= 400) ? temp17 - 400 : temp17;
    assign outf[1] = (temp18 >= 200) ? 1 : 0;
    assign temp19 = (temp18 >= 200) ? temp18 - 200 : temp18;
    assign outf[0] = (temp19 >= 100) ? 1 : 0;
    assign temp20 = (temp19 >= 100) ? temp19 - 100 : temp19;
    // 十位计算g
    assign outg[3] = (temp20 >= 80) ? 1 : 0;
    assign temp21 = (temp20 >= 80) ? temp20 - 80 : temp20;
    assign outg[2] = (temp21 >= 40) ? 1 : 0;
    assign temp22 = (temp21 >= 40) ? temp21 - 40 : temp21;
    assign outg[1] = (temp22 >= 20) ? 1 : 0;
    assign temp23 = (temp22 >= 20) ? temp22 - 20 : temp22;
    assign outg[0] = (temp23 >= 10) ? 1 : 0;
    assign temp24 = (temp23 >= 10) ? temp23 - 10 : temp23;
    // 个位计算h
    assign outh = (temp24 >= 10) ? temp24 -10 : temp24;
    
endmodule