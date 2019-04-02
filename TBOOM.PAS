Var
  BoomPics    : TOpenedFile;
  BoomPicsSeg,
  BoomPicsOfs  : Word;

Type
  PBoom =   ^TBoom;
  TBoom = Object (TSprite)
    speed,
    PicNum     : word;
    Constructor Init(x,y: integer);
    Procedure Handle; virtual;
    Procedure draw(x,y : integer); virtual;
  End;

  Constructor TBoom.Init(x,y : integer);
  Begin
    Inherited init(x,y,16,16,boom,true,False);
    PicNum:=0;
    speed:=random(10)+5
  End;

  Procedure TBoom.Handle;
  Begin
    If count mod speed = 0 then inc(PicNum)
  End;

  Procedure TBoom.Draw(x,y : Integer);
  Begin
    MClipDrawPic(X,Y,16,16,ptr(Boompicsseg,BoomPicsofs+picnum shl 8));
    If PicNum = 3 then del:=true
  End;

Procedure LoadBoomPics(fn : string);
Begin
  LoadFile2Mem(fn,boompics);
  BoomPicsSeg:=Seg(boomPics.Ptr^);
  BoomPicsOfs:=Ofs(boomPics.Ptr^)
End;

Procedure InsertBoom(X, Y : Integer);
Begin
  SpriteList^.AddObj(New(PBoom,Init(X,Y)));
End;

