Var
  NewScore  : LongInt;

Type
  PNikud = ^TNikud;
  TNikud = Object(TBase)
    S         : String;
    MyScore   : LongInt;
    Power     : Integer;
    Constructor Init( nP : Integer );
    Procedure Handle; Virtual;
  End;

  Constructor TNikud.Init;
  Begin
    Inherited Init;
    MyScore:=100;
    Power:=nP
  End;

  Procedure TNikud.Handle;
  Var
    OldCol : Byte;
  Begin
    If NewScore<>MyScore Then Begin
      If Abs(NewScore-MyScore)>Power Then Begin
        If NewScore>MyScore Then Inc(MyScore,Power) Else Dec(MyScore,Power);
        Str(MyScore,S)
      End Else Begin
        MyScore:=NewScore;
        Str(MyScore,S)
      End
    End;
    OldCol:=TextColor;
    TextColor:=0;
    WriteStr(7,3,S);
    WriteStr(7,4,S);
    TextColor:=OldCol
  End;

Procedure InsertNikud;
Begin
  TaskList^.AddObj(New(PNikud,Init(11)))
End;
