Var
  MinePic : TOpenedFile;

Type
  PMine = ^TMine;
  TMine = Object ( TSprite )
    Constructor Init(X, Y, P : Integer);
    Procedure Draw(X, Y : Integer); Virtual;
  End;

  PActiveMine   = ^TActiveMine;
  TActiveMine   = Object (TSprite)
    Constructor Init(X, Y, P : Integer);
    Procedure  Draw(X, Y : Integer); Virtual;
    Procedure Handle; Virtual;
    Destructor Done; Virtual;
  End;

  Constructor TMine.Init(X, Y, P : Integer);
  Begin
    Inherited Init(X, Y, 16, 16, _Mine, False, True);
    Power:=P
  End;

  Procedure TMine.Draw(X, Y : Integer);
  Begin
    ActiveList^.AddObj(New(PActiveMine,Init(Where.X,Where.Y,Power)));
    Del:=True
  End;

  Constructor TActiveMine.Init(X, Y, P : Integer);
  Begin
    Inherited Init(X, Y, 16, 16, _Mine, True, True);
    Power:=P
  End;

  Procedure TActiveMine.Handle;
  Begin
    Inherited Handle;
    If Power<1 Then Vanish
  End;

  Procedure TActiveMine.Draw(X, Y : Integer);
  Begin
    MClipDrawPic( X, Y, Size.X, Size.Y, MinePic.Ptr );
    If @Self=SelectedSprite then
      ShowStat(x-5,y-5,Size.X+10,Size.Y+10,Power div 3,168-Power div 40,161)
  End;

  Destructor TActiveMine.Done;
  Begin
    If Finish Then Exit;
    IF Not Explode Then Begin
      SpriteList^.AddObj(New(PMine,Init(Where.X,Where.Y,Power)));
      Exit
    End;
    InsertBoom(Where.X+Random(17)-8,Where.Y+Random(17)-8);
    InsertBoom(Where.X+Random(17)-8,Where.Y+Random(17)-8);
    InsertBoom(Where.X+Random(17)-8,Where.Y+Random(17)-8);
    InsertBoom(Where.X+Random(17)-8,Where.Y+Random(17)-8)
  End;

Procedure InsertMine(X, Y : Integer);
Begin
    SpriteList^.AddObj(New(PMine,Init(X,Y,Random(35)+5)))
End;



