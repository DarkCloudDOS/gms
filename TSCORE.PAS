Type
  PScore = ^TScore;
  TScore = Object( TSprite )
    SCount   :  Word;
    S        :  String;
    Constructor Init( X, Y, Num : Integer; aStr : String );
    procedure Handle; Virtual;
    Procedure Draw( X, Y : Integer); Virtual;
  End;

  Constructor TScore.Init( X, Y, Num : Integer; aStr : String);
  Begin
    Str(Num,S);
    S:=aStr+S;
    Inherited Init(X, Y, 8*Ord(S[0])+4, 12, Score, True, False);
    SCount:=300+Random(100)
  End;

  Procedure TScore.Handle;
  Begin
    Dec(SCount);
    If SCount=0 Then Del:=True;
    If SCount Mod 3 = 0 Then Dec(Where.Y);
  End;

  Procedure TScore.Draw(X, Y : Integer);
  Begin
      DrawLightBox(X-2,Y-2,Size.X,Size.Y,-6);
      WriteStr(X,Y,S)
  End;

Procedure InsertScore(X, Y, P : Integer; S : String);
Begin
  SpriteList^.AddObj(New(PScore,Init(X,Y,P,S)))
End;
