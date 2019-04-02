Uses GMS;

Var
  Xc,
  Yc,
  R,
  Seg1,
  Ofs1   : Word;
  P      : Pointer;
  F      : File;

Begin

  Assign(F,'DEFAULT.PIC');
  ReSet(F,1);
  Yc:=FileSize(F);
  GetMem(P,Yc);
  BlockRead(F,P^,Yc);
  Close(F);

  Assign(F,'DEFAULT.MAP');
  ReWrite(F,1);
  Xc:=Yc Shr 10;
  BlockWrite(F,Xc,1);
  BlockWrite(F,P^,Yc);
  FreeMem(P,Yc);

  GetMem(P,255*256+4);
  Seg1:=Seg(P^);
  Ofs1:=Ofs(P^);
  MemW[Seg1:Ofs1  ]:=255;
  MemW[Seg1:Ofs1+2]:=256;
  Randomize;
  For Xc:=0 To 256*255-1 Do Mem[Seg1:Ofs1+4+Xc]:=Random(3);
  For Xc:=0 To 3000 Do Mem[Seg1:Ofs1+4+Random(255)+Random(256)*255]:=3;
  For Xc:=5 To 249 Do
    Mem[Seg1:Ofs1+4+Xc+5*255]:=9;
  For Xc:=5 To 249 Do
    Mem[Seg1:Ofs1+4+Xc+250*255]:=8;
  For Xc:=5 To 250 Do
    Mem[Seg1:Ofs1+4+255*Xc+5]:=11;
  For Xc:=5 To 250 Do
    Mem[Seg1:Ofs1+4+249+Xc*255]:=10;
  Mem[Seg1:Ofs1+4+5+5*255]:=4;
  Mem[Seg1:Ofs1+4+249+5*255]:=5;
  Mem[Seg1:Ofs1+4+5+250*255]:=6;
  Mem[Seg1:Ofs1+4+249+250*255]:=7;
  BlockWrite(F,P^,255*256+4,R);
  WriteLn(R);
  For Xc:=0 To 256*255-1 Do If Mem[Seg1:Ofs1+4+Xc]>2 Then Mem[Seg1:Ofs1+Xc]:=1 Else
    Mem[Seg1:Ofs1+Xc]:=0;
  BlockWrite(F,P^,255*256,R);
  WriteLn(R);
  FreeMem(P,255*256+4);
  Pal(0,0,0,0);
  ramp(1 ,16 ,63,0,0 ,4 ,0 ,0 );
  ramp(97,112 ,0 ,63 ,0 ,0, 4,0);
  ramp(33,48 ,0 ,0 ,63,0 ,0,4);
  ramp(49,64 ,0 ,63,63,0,4 ,4 );
  ramp(65,80 ,63,0,63 ,4,0 ,4 );
  ramp(81,96 ,63,63,0 ,4 ,4,0 );
  ramp(17,32,4,4,4 ,63,63,63);
  ramp(113,128 ,50,32,0 ,8 ,4,0 );
  ramp(129,144,63,60,0 ,12,6,0 );
  ramp(145,160,63,63,0,63,0,0);
  ramp(161,169,63,0,0,63,63,0);
  ramp(170,176,63,63,0,0,63,0);


  Pal(255,63,63,63);
  GetAllPal(Pall);
  BlockWrite(F,Pall,SizeOf(PalType));
  Close(F);
End.
