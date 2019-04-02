Var
  SmokePics    : TOpenedFile;
  SmokePicsSeg,
  SmokePicsOfs  : Word;

Type
  PSmoke = ^TSmoke;
  TSmoke = Object(TBoom)
    Procedure Draw(X, Y : Integer); Virtual;
  End;

  Procedure TSmoke.Draw(X, Y : Integer);
  Begin
    MClipDrawPic(X,Y,16,16,ptr(Smokepicsseg,SmokePicsofs+picnum shl 8));
    If PicNum = 3 then del:=true
  End;

Procedure LoadSmokePics(fn : string);
Begin
  LoadFile2Mem(fn,Smokepics);
  SmokePicsSeg:=Seg(SmokePics.Ptr^);
  SmokePicsOfs:=Ofs(SmokePics.Ptr^)
End;

Procedure InsertSmoke(X, Y : Integer);
Begin
  SpriteList^.AddObj(New(PSmoke,Init(X,Y)))
End;

