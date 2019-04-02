Var
  MousePic    : TOpenedFile;

Type
  PMouse = ^Tmouse;
  TMouse = Object ( TBase )
    Constructor Init(FName : String);
    Procedure Handle; Virtual;
  End;

  Constructor TMouse.Init(FName : String);
  Var
    F : File;
  Begin
    Inherited Init;
    LoadFile2Mem(FName,MousePic)
  End;

  Procedure TMouse.Handle;
  Begin
    MClipDrawPic(MouseX,MouseY,16,16,MousePic.Ptr)
  End;

Procedure InsertMouse;
Begin
  TaskList^.AddObj(New(PMouse,Init(MousePicsFile)))
End;


