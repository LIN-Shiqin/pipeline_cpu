module binled(in, ledh, ledg, ledf, lede, ledd, ledc, ledb);
  input [24:0] in;
  output [7:0] ledh,ledg,ledf,lede,ledd,ledc,ledb;
  wire [3:0] outh,outg,outf,oute,outd,outc,outb;

  bintobcd bintobcd(in,outh,outg,outf,oute,outd,outc,outb);
  ledout ledouth(outh, ledh);
  ledout ledoutg(outg, ledg);
  ledout ledoutf(outf, ledf);
  ledout ledoute(oute, lede);
  ledout ledoutd(outd, ledd);
  ledout ledoutc(outc, ledc);
  ledout ledoutb(outb, ledb);
  
endmodule