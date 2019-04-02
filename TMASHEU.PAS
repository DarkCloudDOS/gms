Var
  MasheuPic : TOpenedFile;

Type
  PMasheu = ^TMasheu;
  TMasheu = Object ( TSprite )
    Constructor Init(X, Y, P : Word);
    Procedure Draw(X, Y : Integer); Virtual;
  End;

  PActiveMasheu = ^TActiveMasheu;
  TActiveMasheu = Object ( TSprite )
    Constructor Init( X, Y, P : Word);
    Procedure Draw(X, Y : Integer); Virtual;
    Procedure Handle; Virtual;
    Destructor Done; Virtual;
  End;

  Constructor TMasheu.Init(X, Y, P : Word);
  Begin
    Inherited Init(X, Y, 32, 32, Masheu, False, True);
    Power:=P
  End;

  Procedure TMasheu.Draw(X, Y : Integer);
  Begin
    ActiveList^.AddObj(New(PActiveMasheu,Init(Where.X,Where.Y,Power)));
    Del:=True
  End;

  Constructor TActiveMasheu.Init(X, Y, P : Word);
  Begin
    Inherited Init(X, Y, 32, 32, Masheu, True, True);
    Power:=P
  End;

  Procedure TActiveMasheu.Handle;
  Begin
    Inherited Handle;
    If Power<1 Then Vanish
  End;

  Procedure TActiveMasheu.Draw(X, Y : Integer);
  Begin
    MClipDrawPic( X, Y, Size.X, Size.Y, MasheuPic.Ptr );
    If @Self=SelectedSprite then
      ShowStat(x,y,Size.X,Size.Y,power,161+power,161+12)
  End;

  Destructor TActiveMasheu.Done;
  Begin
    If Finish Then Exit;
    If Not Explode Then Begin
      SpriteList^.AddObj(New(PMasheu,Init(Where.X,Where.Y,Power)));
      Exit
    End;
    Inc(NewScore,1000);
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertBoom(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertSmoke(Where.X+Random(32),Where.Y+Random(32));
    InsertScore(Where.X,Where.Y,1000,'SCORE +');
    InsertPower(Where.X+8,Where.Y+8)
  End;

Procedure InsertMasheu(X, Y : Integer);
Begin
  SpriteList^.AddObj(New(PMasheu,Init(X,Y,10)))
End;

