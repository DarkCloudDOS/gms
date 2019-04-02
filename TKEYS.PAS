Type
  PKeys = ^TKeys;
  TKeys = Object ( TBase )
    Procedure Handle; Virtual;
  End;

  Procedure TKeys.Handle;
  Begin
    If Keys[01] Then Finish:=True;
    If Keys[2] Then OneStepFade(0,255,CurrPal,GrayPal);
    If Keys[3] Then OneStepFade(0,255,CurrPal,Pall);
    If Keys[4] Then OneStepFade(0,255,CurrPal,BlackPal)
  End;

Procedure InsertKeys;
Begin
  TaskList^.AddObj(New(PKeys,Init))
End;