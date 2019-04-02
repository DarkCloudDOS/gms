Var
  BadCannonPic : RPic;
  BasePic      : TOpenedFile;

Type
  PBCannon = ^TBCannon;
  TBCannon = Object(TSprite)
    A,
    B  : Integer;
    Constructor Init(X,Y,aDShot,adturn, P : Word);
    Procedure Draw(X, Y : Integer); Virtual;
  End;

  PActiveBCannon = ^TActiveBCannon;
  TActiveBCannon = Object(TSprite)
    Angle,
    RAngle,
    DTurn,oDTurn,
    DShot,oDShot    : Integer;
    Constructor Init(X,Y,aDShot,aDTurn, P : Word);
    Procedure Handle; Virtual;
    Procedure Draw(X,Y:Integer); Virtual;
    Destructor Done; virtual;
  End;

  Constructor TBCannon.Init(X,Y,aDShot,adturn, P : Word);
  Begin
    Inherited Init(X,Y,32,32,badcannon,False, True);
    A:=aDShot;
    B:=aDTurn;
    Power:=P
  End;

  Procedure TBCannon.Draw(X, Y : Integer);
  Begin
    ActiveList^.AddObj(New(PActiveBCannon,Init(Where.X,Where.Y,A,B,Power)));
    Del:=True
  End;

  Constructor TActiveBCannon.Init(X,Y,aDShot,aDTurn, P : Word);
  Begin
    Inherited Init(X,Y,32,32,badcannon,True, True);
    DShot:=ADShot;
    oDShot:=ADShot;
    DTurn:=aDTurn;
    oDTurn:=aDTurn;
    RAngle:=GetAngle(Where.X+16,Where.Y+16,MapInfo.X+160,MapInfo.Y+100);
    Angle:=RAngle Div OneAngSize;
    Power:=P
  End;

  Procedure   TActiveBCannon.Handle;
  var
    deltaAngle    : Integer;
  Begin
    Inherited Handle;
    If Power<1 Then Vanish;
    DeltaAngle:=(RAngle-GetAngle(Where.X+16,Where.Y+16,MapInfo.X+160,MapInfo.Y+100));
    If (Dturn=0) and (DeltaAngle<>0) then Begin
      DTurn:=oDturn;
      If DeltaAngle>180 then Inc(rangle) Else
      If DeltaAngle>0 then Dec(rangle) Else
      If DeltaAngle>-180 then Inc(rangle) Else Dec(rangle);

      rangle:=rangle mod 360; if rangle<0 then inc(rangle,360);
      Angle:=RAngle Div OneAngSize;
    End;(**)
    If DShot = 0 Then Begin
      If Random(2)=1 Then
        ActiveList^.AddObj(New(PFire2,Init(@Self,Where.X+15,Where.Y+15,
        RAngle,0,0,2+(random(10)/10))))
      Else
        ActiveList^.AddObj(New(PFire1,Init(@Self,Where.X+15,Where.Y+15,
        RAngle,0,0,2+(random(10)/10))));
      DShot:=oDShot
    End;
    If DShot>0 then Dec(DShot);
    If Dturn>0 then Dec(Dturn);
  End;

  Procedure TActiveBCannon.Draw(x,y:Integer);
  Begin
    MClipDrawPic(x,y,32,32 , BasePic.Ptr);
    MClipDrawPic(x-6,y-6,45,45 , BadCannonPic.Rotated^[Angle]);
    If @Self=SelectedSprite then
      ShowStat(x,y,32,32,Power,161+power shr 1,161)
  End;

  Destructor  TActiveBCannon.Done;
  Begin
    If Finish Then Exit;
    If Not Explode Then Begin
      SpriteList^.AddObj(New(PBCannon,Init(Where.X,Where.Y,oDShot,oDTurn,Power)));
      Exit
    End;
    Inc(NewScore,1500);
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertScore(Where.X,Where.Y,1500,'SCORE +');
  End;

Procedure InsertBCannon(X, Y : Integer);
Begin
  SpriteList^.AddObj(New(PBCannon,Init(X,Y,20,1,25+Random(5))))
End;

