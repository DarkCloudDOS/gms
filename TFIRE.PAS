Const
  MaxShots    = 10;
  Shots       : Integer = 0;

Var
  Fire1Pic,
  Fire2Pic    : TOpenedFile;

Type
  TRPoint = Record
    X, Y : Real;
  End;

  PFire1 = ^TFire1;
  TFire1 = Object ( TPlayerSprite )
    Incr,
    RPos    : TRPoint;
    A, B    : Real;
    WhoShot : PSprite;
    Constructor Init( nWhoShot : PSprite; sX, sY : Integer; CanonAngle, JeepAngle : Word; JeepSpeed, FireSpeed : Real);
    Destructor Done; Virtual;
    Procedure Handle; Virtual;
    Procedure Draw(X, Y : Integer); Virtual;
  End;

  PFire2 = ^TFire2;
  TFire2 = OBject ( TFire1 )
    Constructor Init( nWhoShot : PSprite; sX, sY : Integer; CanonAngle, JeepAngle : Word; JeepSpeed, FireSpeed : Real);
    Procedure   Handle; Virtual;
    Procedure   Draw(X, Y : Integer); Virtual;
  End;

    Constructor TFire1.Init( nWhoShot : PSprite; sX, sY : Integer; CanonAngle, JeepAngle : Word; JeepSpeed, FireSpeed : Real);
    Begin
      Inherited Init(sX, sY, 6, 6, Fire1, True, True);
      Inc(Shots);
      RPos.X:=Where.X+CosTable^[CanonAngle]*19;
      RPos.Y:=Where.Y-SinTable^[CanonAngle]*19;
      Where.X:=Round(RPos.X);
      Where.Y:=Round(RPos.Y);
      Incr.X:=FireSpeed*CosTable^[CanonAngle];
      Incr.Y:=FireSpeed*SinTable^[CanonAngle];
      Incr.X:=Incr.X+JeepSpeed*CosTable^[JeepAngle];
      Incr.Y:=Incr.Y+JeepSpeed*SinTable^[JeepAngle];
      WhoShot:=nWhoShot;
      Power:=5+Random(5)
    End;

    Destructor TFire1.Done;
    Begin
      Dec(Shots);
      If Explode Then InsertBoom(Where.X,Where.Y)
    End;

    Procedure TFire1.Handle;
    Begin
      If Power<1 Then Vanish;
      A:=RPos.X+Incr.X;
      B:=RPos.Y-Incr.Y;
      Where.X:=Round(A);
      Where.Y:=Round(B);
      If (WhatOnMask(Where.X,Where.Y)=1) Or
         (WhatOnMask(Where.X+Size.X,Where.Y)=1) Or
         (WhatOnMask(Where.X,Where.Y+Size.Y)=1) Or
         (WhatOnMask(Where.X+Size.X,Where.Y+Size.Y)=1) Then Vanish;
      CheckCollision;
      If (Clist<>Nil) And (CList^.FirstNode^.Collited<>WhoShot) And CList^.FirstNode^.Collited^.CanBeShot then Begin
        Vanish;
        Dec(CList^.FirstNode^.Collited^.Power,Power)
      End;
      If (Clist<>Nil) And (CList^.FirstNode^.Collited^.Kind=Jeep) And (WhoShot<>JO) Then Vanish;
      If Not Del Then Begin
        RPos.X:=A;
        RPos.Y:=B
      End
    End;

    Procedure TFire1.Draw(X, Y : Integer);
    Begin
      MClipDrawPic(X, Y, Size.X, Size.Y, Fire1Pic.Ptr)
    End;

    Constructor TFire2.Init( nWhoShot : PSprite; sX, sY : Integer; CanonAngle, JeepAngle : Word; JeepSpeed, FireSpeed : Real);
    Begin
      Inherited Init( nWhoShot, sX, sY, CanonAngle, JeepAngle, JeepSpeed, FireSpeed);
      Kind:=Fire2;
      Power:=Random(5)+10
    End;

    Procedure TFire2.Handle;
    Begin
      If Power<1 Then Vanish;
      A:=RPos.X+Incr.X;
      Where.X:=Round(A);
      If Not ((WhatOnMask(Where.X,Where.Y)=1) Or
         (WhatOnMask(Where.X+Size.X,Where.Y)=1) Or
         (WhatOnMask(Where.X+Size.X,Where.Y+Size.Y)=1) Or
         (WhatOnMask(Where.X,Where.Y+Size.Y)=1))
           Then RPos.X:=A Else Incr.X:=-Incr.X;
      Where.X:=Round(RPos.X);
      B:=Rpos.Y-Incr.Y;
      Where.Y:=Round(B);
      If Not ((WhatOnMask(Where.X,Where.Y)=1) Or
         (WhatOnMask(Where.X+Size.X,Where.Y)=1) Or
         (WhatOnMask(Where.X+Size.X,Where.Y+Size.Y)=1) Or
         (WhatOnMask(Where.X,Where.Y+Size.Y)=1))
           Then RPos.Y:=B Else Incr.Y:=-Incr.Y;
      Where.Y:=Round(RPos.Y);
      CheckCollision;
      If (CList<>Nil) And (CList^.FirstNode^.Collited<>WhoShot) And CList^.FirstNode^.Collited^.CanBeShot then Begin
        Vanish;
        Dec(CList^.FirstNode^.Collited^.Power,Power)
      End;
      If (Clist<>Nil) And (CList^.FirstNode^.Collited^.Kind=Jeep) And (WhoShot<>JO) Then Vanish
    End;

    Procedure TFire2.Draw;
    Begin
      MClipDrawPic(X, Y, Size.X, Size.Y, Fire2Pic.Ptr)
    End;


