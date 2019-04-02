Var
  PowerPic : TOpenedFile;

Type
  PPower = ^TPower;
  TPower = Object ( TSprite )
    Constructor Init(X, Y, P : Word);
    Procedure Draw(X, Y : Integer); Virtual;
  End;

  PActivePower = ^TActivePower;
  TActivePower = Object ( TSprite )
    Constructor Init( X, Y, P : Word);
    Procedure Draw(X, Y : Integer); Virtual;
    Destructor Done; Virtual;
  End;

  Constructor TPower.Init(X, Y, P : Word);
  Begin
    Inherited Init(X, Y, 16, 16, _Power, False, False);
    Power:=P
  End;

  Procedure TPower.Draw(X, Y : Integer);
  Begin
    ActiveList^.AddObj(New(PActivePower,Init(Where.X,Where.Y,Power)));
    Del:=True
  End;

  Constructor TActivePower.Init(X, Y, P : Word);
  Begin
    Inherited Init(X, Y, 16, 16, _Power, True, False);
    Power:=Random(5)+5
  End;

  Procedure TActivePower.Draw(X, Y : Integer);
  Begin
    MClipDrawPic( X, Y, Size.X, Size.Y, PowerPic.Ptr );
    If @Self=SelectedSprite then
      ShowStat(x-5,y-5,Size.X+10,Size.Y+10,Power,161+15,161+15)
  End;

  Destructor TActivePower.Done;
  Begin
    If Not Explode Then SpriteList^.AddObj(New(PPower,Init(Where.X,Where.Y,Power)))
  End;

Procedure InsertPower(X, Y : Integer);
Begin
  SpriteList^.AddObj(New(PPower,Init(X,Y,Random(5)+5)))
End;


