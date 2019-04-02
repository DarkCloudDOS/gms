Var
  JeepPics     : Array [0..1,0..1] Of RPic;
  JeepCanonPic : RPic;

Type
  PJeep = ^TJeep;
  TJeep = Object ( TPlayerSprite )
    Angle,
    RAngle,
    BPower,
    DA,
    DShot,
    MaxShots,
    Blk,
    OldP,
    SmokeCount     : Integer;
    X,
    Y,
    Accel,
    Deccel,
    Brecks,
    MaxSpeed,
    MinSpeed,
    Speed,
    Pic            : Real;
    Blinking,
    Advance        : Boolean;
    Car            : Byte;
    Constructor Init(aX, aY, nAngle, aDA : Integer;
    nAccel, nDeccel, nBrecks, nSpeed : Real; Var CallMe : Pjeep);
    Procedure Handle; Virtual;
    Procedure Draw(aX, aY : Integer); Virtual;
    Destructor Done; Virtual;
  End;

  Constructor TJeep.Init(aX, aY, nAngle, aDA : Integer;
  nAccel, nDeccel, nBrecks, nSpeed : Real; Var CallMe : PJeep);
  Var
    srcPic : array[0..1] of TOpenedFile;
  Begin
    Inherited Init(aX,aY,24,24, Jeep, False, False);
    Car:=1;
    CallMe:=@Self;
    JO:=CallMe;
    Blk:=700;
    Pic:=0;
    If Paramstr(1)='MORESHIELD' Then Power:=$FF Else Power:=160;
    OldP:=Power;
    BPower:=0;
    X:=Where.X;
    Y:=Where.Y;
    MaxSpeed:=+2;
    MinSpeed:=-2;
    Accel:=nAccel;
    Speed:=nSpeed;
    Deccel:=nDeccel;
    Brecks:=nBrecks;
    RAngle:=nAngle;
    Angle:=RAngle Div Directions;
    DA:=aDA;

    LoadFile2Mem(JeepFileName1,srcPic[0]);
    LoadFile2Mem(JeepFileName2,srcPic[1]);

    RotatePic(Directions, 0, 32, 32, srcPic[0].Ptr, JeepPics[0,0]);
    RotatePic(Directions, 0, 32, 32, Ptr(Seg(srcPic[0].Ptr^),Ofs(srcPic[0].Ptr^)+1024), JeepPics[0,1]);
    RotatePic(Directions, 0, 32, 32, srcPic[1].Ptr, JeepPics[1,0]);
    RotatePic(Directions, 0, 32, 32, Ptr(Seg(srcPic[1].Ptr^),Ofs(srcPic[1].Ptr^)+1024), JeepPics[1,1]);
    DoneFile(srcPic[0]);
    DoneFile(srcPic[1]);
    SmokeCount:=0;
  End;

  Procedure TJeep.Handle;
  Var
    A, B         : Real;
  Begin
    If BPower<Power Then Inc(BPower);
    If BPower>Power Then Dec(BPower);
    Pic:=Pic+Speed/(2*MaxSpeed);

    SetMapX(Where.X -160 + Size.X Shr 1);
    SetMapY(Where.Y -100 + Size.Y Shr 1);
    Map^.Handle;

    A:=X+Speed*CosTable^[RAngle];
    B:=Y-Speed*SinTable^[RAngle];

    Where.X:=Round(A);
    Where.Y:=Round(B);

    CheckCollision;
    Advance:=True;
    If Clist<>Nil Then
    Case CList^.FirstNode^.Collited^.Kind Of
      Masheu  : Begin
                  If Abs(Speed)>=MaxSpeed/2 Then CList^.FirstNode^.Collited^.Vanish;
                  Speed:=-Speed/2;
                  Advance:=False;
                  If Car=1 Then Begin
                    Car:=0;
                    MaxSpeed:=+4;
                    MinSpeed:=-4 End Else Begin
                    MaxSpeed:=+2;
                    MinSpeed:=-2; Car:=1 End
                End;
      _Power : Begin Clist^.FirstNode^.Collited^.Vanish; Power:=Power+Clist^.FirstNode^.Collited^.Power End;
      _Mine  : Begin Clist^.FirstNode^.Collited^.Vanish; Power:=Power-Clist^.FirstNode^.Collited^.Power End;
      BadCannon:Begin
                  If abs(Speed)>=MaxSpeed/2 Then Dec(Clist^.FirstNode^.Collited^.Power,random(10)+25);
                    Speed:=-Speed/2;
                    Advance:=False
                End
    End;
    If Not ((WhatOnMask(Where.X,Where.Y)=0) And (WhatOnMask(Where.X+Size.X,Where.Y)=0)
    And(WhatOnMask(Where.X,Where.Y+Size.Y)=0) And (WhatOnMask(Where.X+Size.X,Where.Y+Size.Y)=0))
    Then Begin
       If (Speed>MaxSpeed/1.7)  And (Car=0) Then Power:=Power-10;
       Speed:=-Speed/2;
       Advance:=False
    End;
    If Advance Then Begin
      X:=A;
      Y:=B
    End;
    If (Blk>0) And (OldP>Power) Then Power:=OldP;
    If OldP<>Power Then Begin
      If OldP>Power Then Begin
        CanBeShot:=False;
        Blk:=(OldP-Power)*14;
        InsertScore(Where.X,Where.Y,power-oldP,'SHIELD ')
      End Else
        InsertScore(Where.X,Where.Y,Power-OldP,'SHIELD +');
      If Power<160 Then
        SmokeCount:=(Power Mod 160) Div 2
    End;
    Where.X:=Round(X);
    Where.Y:=Round(Y);

    If Keys[75] Then Begin
      Inc(RAngle,DA);
      If RAngle>359 Then RAngle:=0;
      Angle:=RAngle Div OneAngSize;
    End;
    If Keys[77] Then Begin
      Dec(RAngle,DA);
      If RAngle<0 Then RAngle:=359;
      Angle:=RAngle Div OneAngSize;
    End;
    If Keys[72] Then Begin
      If Speed<MaxSpeed Then
        Speed:=Speed+Accel;
    End Else
    If Keys[80] Then Begin
      If Speed>MinSpeed Then
        Speed:=Speed-Brecks;
    End Else
    If Abs(Speed)>Deccel Then Begin
      If Speed<0 Then Speed:=Speed+Deccel;
      If Speed>0 Then Speed:=Speed-DecCel
    End Else Speed:=0;
    If Power<1 Then Begin
      Del:=True;
      Finish:=True
    End;
    OldP:=Power
  End;

  Procedure TJeep.Draw(aX, aY : Integer);
  Begin
    If Blk>0 Then Begin
      If Blinking Then
        MClipDrawBlinkPic(137,77,45,45,JeepPics[Car,Trunc(Pic) and 1].Rotated^[Angle])
      Else
        MClipDrawPic(137,77,45,45,JeepPics[Car,Trunc(Pic) and 1].Rotated^[Angle]);
      If Count Mod 17 = 0 Then Blinking := Not Blinking;
      Dec(Blk)
    End Else Begin
      MClipDrawPic(137,77,45,45,JeepPics[Car,Trunc(Pic) and 1].Rotated^[Angle]);
      CanBeShot:=True
    End;
    If Power>0 Then Begin
      DrawLightBox(5,3,BPower Shr 1,10,8);
      DrawLightBox(5,1,Round(Abs(Speed+0.05)*20),14,-8)
    End;
    If (SmokeCount>0) And (Count Mod SmokeCount=0) Then
      InsertSmoke(Where.X,Where.Y)
  End;

  Destructor TJeep.Done;
  Begin
    ReleaseRotatedPic(JeepPics[0,0]);
    ReleaseRotatedPic(JeepPics[0,1]);
    ReleaseRotatedPic(JeepPics[1,0]);
    ReleaseRotatedPic(JeepPics[1,1])
  End;

Var
  JeepObj : PJeep;



