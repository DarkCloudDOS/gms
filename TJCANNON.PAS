Var
  JeepCannonPic : RPic;
Type
  PJeepCanon = ^TJeepCanon;
  TJeepCanon = Object ( TBase )
    Where       : TPoint;
    RAngle,
    Angle,
    DTurn,
    odTurn,
    DShot2,
    oDshot2,
    DShot1,
    oDShot1      : Integer;
    Constructor Init( aDShot1, adshot2, aDTurn : Integer);
    Procedure Handle; Virtual;
  End;

  Constructor TJeepCanon.Init( aDShot1, adshot2, aDTurn: Integer);
  Begin
    Inherited Init;
    ODturn:=aDturn;
    dturn:=Odturn;
    DShot1:=aDShot1;
    oDShot1:=DShot1;
    DShot2:=aDShot2;
    oDShot2:=DShot2;
    RAngle:=45;
    Angle:=RAngle Div OneAngSize
  End;

  Procedure TJeepCanon.Handle;
  var
    deltaAngle    : Integer;
  Begin
   DeltaAngle:=RAngle-GetAngle(160,100,Mousex,MouseY);

    If (Dturn=0) then Begin
      DTurn:=oDturn;
      If Abs(DeltaAngle)>4 then Begin
        If DeltaAngle>180 then Inc(rangle,4) Else
        If DeltaAngle>0 then Dec(rangle,4) Else
        If DeltaAngle>-180 then Inc(rangle,4) Else Dec(rangle,4);
      End Else If DeltaAngle<>0 then Begin
        If DeltaAngle>180 then Inc(rangle) Else
        If DeltaAngle>0 then Dec(rangle) Else
        If DeltaAngle>-180 then Inc(rangle) Else Dec(rangle);
      End;

      rangle:=rangle mod 360; if rangle<0 then inc(rangle,360);
      Angle:=RAngle Div OneAngSize;
    End;(**)

    If (MouseB and 1>0) And (DShot1=0) Then Begin
      ActiveList^.AddObj(New(PFire1,Init(JeepObj,MapInfo.X+157,MapInfo.Y+97,
      RAngle,JeepObj^.RAngle,JeepObj^.Speed,6)));
      DShot1:=oDShot1
    End;
    If (MouseB and 2>0)  And (DShot2=0) Then Begin
      ActiveList^.AddObj(New(PFire2,Init(JeepObj,MapInfo.X+157,MapInfo.Y+97,
      RAngle,JeepObj^.RAngle,JeepObj^.Speed,1.3)));
      DShot2:=oDShot2
    End;
    IF DShot1>0 Then Dec(DShot1);    IF DShot2>0 Then Dec(DShot2);
    If DTurn>0 then Dec(DTurn);

    MClipDrawPic(137,77,45,45 , JeepCannonPic.Rotated^[Angle])
  End;

  Procedure LoadCanonPic(Var RotatedPics : RPic; Name : String);
  Var
    Pic : TOpenedFile;
  Begin
    LoadFile2Mem(Name,Pic);
    RotatePic(Directions,-45,32,32,Pic.Ptr,RotatedPics);
    DoneFile(Pic)
  End;
