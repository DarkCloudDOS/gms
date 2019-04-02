Unit GMS;

(*
                GMS - Great Map Scroller Engine.
                By dark-cloud, 1997.
                http://www.geocities.com/SiliconValley/Vista/1595/
                dark-cloud@geocities.com
*)

Interface

{$R-} {No range checking}
{$S-} {No stack overflow checking}
{$I-} {No IO checking}
{$Q-} {No overflow checking}
{$G+} {Enable 286 instructions}
{$N+} {Numeric processing 8087/80287}

(**************************** GMS engine stuff ******************************)

Const
  Ver = '1.5';

(***************************** Error handeling ******************************)

{ Terminates the program with the ErrStr message. }
Procedure Error( ErrStr : String );

(******************************* Files stuff ********************************)
Type
  TFileNameString = String[11];

  TOpenedFile     = Record
    FileNum : Byte;
    Ptr     : Pointer;
  End;

  TPXEFileName = Record
    Name     : TFileNameString;
    Where,
    Size     : LongInt;
  End;

  PPXETable = ^TPXETable;
  TPXETable = Array [0..255] Of TPXEFileName;

  TPXEFileTable = Record
    Name    : TFileNameString;
    TAStart : LongInt;
    Files   : Byte;
    Table   : PPXETable;
  End;

Var
  PXEFileTable  : TPXEFileTable;
  PXEFile       : File;

Const
  IDE            : String  = 'PXE';

{ Tell you wether the PXE file is oper or not }
Function PXEFileOpen : Boolean;
{ Load's from the PXE opened file a file named Fn into Fil.Ptr }
Procedure LoadFile2Mem(Fn : TFileNameString; var Fil : TOpenedFile);
{ Free's the memory taken by LoadFile2Mem() }
Procedure DoneFile(var Fil : TOpenedFile);
{ Assigns and reset's the PXE file format named Fn }
Procedure OpenPXEFile(Fn : String);
{ Closed the opened file }
Procedure ClosePXEFile;
{ Fins the file named Fn in the PXE opened file and seeks there }
Function  GotoFile(Fn : TFileNameString) : Byte;

(******************************* Memory stuff *******************************)

{ Allocates memory. If not enough then terminates the program
  with an error message }
Function FindMem( Size : Word ) : Pointer;

Type
  PSinCosLookUpTable = ^TSinCosLookUpTable;
  TSinCosLookUpTable = Array [0..359] Of Real;

Var
  SinTable,
  CosTable      : PSinCosLookUpTable;

{ Initalizes a Sin/Cos Look-Up table }
Procedure InitSinCosLookUpTable;
{ Deallocates the memory the Sin/Cos lookup table used }
Procedure DoneSinCosLookUpTable;

(********************************* Timer stuff ******************************)

Var
  T,
  Count         : LongInt;
  Tm            : LongInt Absolute $40:$6c;

(************************************ OOP ***********************************)

Type
  PBase = ^TBase;
  TBase = Object
    Next : PBase;
    Prev : PBase;
    Del  : Boolean;
    Constructor Init;
    Procedure Handle; Virtual;
    Destructor Done; Virtual;
  End;

  PList = ^TList;
  TList = Object(TBase)
    FirstObj : PBase;
    LastObj  : PBase;
    Constructor Init(Var CallMe : PList);
    Destructor  Done; Virtual;
    Procedure   Handle; Virtual;
    Procedure   AddObj( NewObj : PBase );
    Procedure   DelObj( var Obj : PBase );
  End;

  Procedure InitTaskList;
  Procedure DoneTaskList;

  Var
    TaskList           : PList;

(********************************** Map stuff *******************************)

Type
  PByteArray    = ^TByteArray;
  TByteArray    = Array[0..$FFFF -1] of Byte;

  TMap          = Record
    PicNum      : PByteArray;
    Status      : PByteArray;
  End;

  MapRecord     = Record
    XLen,YLen,
    X,
    Y,
    PicsNumber  : Integer;
    Map         : TMap;
    PicsSeg,
    PicsOfs     : Word;
  End;

Var
  MapInfo                          : MapRecord;
  MapPics                          : Pointer;

Type
  PGeoMap       = ^TGeoMap;
  TGeoMap       = Object ( TBase )
    IncPerY     : Word;
    Constructor Init( MapName : TFileNameString; Var CallMe : PGeoMap );
    Procedure   Handle; Virtual;
    Destructor  Done; Virtual;
  End;

Var
  Map : PGeoMap;

{ Set the map X location, but checks wether it is in the map boundries }
Procedure SetMapX( I : Integer );
{ Set the map Y location, but checks wether it is in the map boundries }
Procedure SetMapY( I : Integer );
{ Returns the map mask value at the cordinates X, Y }
Function WhatOnMask(X, Y : Word) : Byte;
{ Makes a map, called trough MAP^. , which is out of the task list }
Procedure NewMap( MapName : String );
{ Done the map made by newmap }
Procedure DoneMap;

(******************************* Sprites stuff ******************************)
{ Uses OOP }

Type
  TPoint = Record
    x, y: Integer;
  End;

  PSprite = ^TSprite;
  TSprite = Object ( TBase )
    Where       : TPoint;
    Size        : TPoint;
    Power       : Integer;
    Kind        : Word;
    DelWhenOut,
    Explode,
    CanBeShot   : Boolean;
    Constructor Init( AX, AY, LX, LY, AKind : Word; ADelWhenOut, ACanBeShot : Boolean );
    Procedure   Draw(X, Y : Integer); Virtual;
    Procedure   Vanish; Virtual;
    Procedure   Handle; Virtual;
  End;

  PCNode = ^TCNode;
  TCNode = Record
    Next     : PCNode;
    Collited : PSprite;
  End;

  PCList = ^TCList;
  TCList = Record
    FirstNode,
    LastNode    : PCNode;
  End;

  PPlayerSprite = ^TPlayerSprite;
  TPlayerSprite = Object ( TSprite )
    CList       : PCList;
    Constructor Init( AX, AY, LX, LY, AKind : Word; ADelWhenOut, ACanBeShot : Boolean );
    Procedure   CheckCollision;
    Procedure   DelCList;
    Procedure   NewCList;
    Procedure   AddCollision( Col : PSprite );
  End;

  PSprites = ^TSprites;
  TSprites = Object ( TList )
    Procedure   Handle; Virtual;
  End;

Var
  SpriteList                       : PList;
  SelectedSprite                   : PSprite;

{ Inserts the sprite list SList into List }
Procedure InsertSprites( List : PList; Var SList : PList );
{ tests if the two rectangles are touching = coliding }
FUNCTION collision(x1,y1,w1,h1, x2,y2,w2,h2 :integer):boolean;
{ returns true os px,py is in the square }
Function PointinSquare(x1,y1,w,h, px,py : Integer):Boolean;
{ returns the angle (0..360) between point c to point t }
Function GetAngle(cX, cY, tX, tY : Integer) : Integer;

Procedure ShowStat(x,y,w,h,pow : Integer; powcol,col :byte);

(****************************** Keyboard stuff ******************************)

Var
   keydown     : Byte;                       { Number of pressed keys }
   keys        : Array [0..127] of Boolean;  { Each key state }
   scan        : Byte;                       { Current scan code (port[$60]) }
   lastkey     : Byte;                       { Last pressed key scan code }

Procedure Capture_Keyboard;
{ Restors the KeyBoard interrupt }
Procedure DeInitKeys;

(********************************** Graphics stuff **************************)

Const
  ColorWhite = 255;

{ Draws a 32x32 picture on the virtual screen, no masking nor clipping }
Procedure Draw32x32Pic(X,Y : Integer; Pic : Pointer );
{ Draws a XLen*YLen picture on the virtual screen, no masking, clipping }
Procedure ClipDrawPic(X,Y : Integer; Xlen,Ylen : Byte; Pic  : Pointer);
{ Draws a XLen*YLen picture on the virtual screen, masking (ingnores color 0)
  and clipping }
Procedure MClipDrawPic(X,Y : Integer; Xlen,Ylen : Byte; Pic  : Pointer);
{ Draws a XLen*YLen picture on the virtual screen, masking (ignores color 0)
  and clipping, but draw one color picture = ColorWhite }
Procedure MClipDrawBlinkPic(X,Y : Integer; Xlen,Ylen : Byte; Pic  : Pointer);
{ Draws a box }
Procedure Box     (X,Y,XLen : Integer; YLen, Col : Byte);
{ Draws a horizontal line }
Procedure Hline (x1,x2,y: integer;col: byte);
{ ... }
Procedure Vline (y1,y2,x: integer;col: byte);

(**** Pallete stuff ****)
Const
  R = 0;
  G = 1;
  B = 2;

Type
  Paltype           = Array [ 0..255 , 0..2 ] Of Byte;

Var
  Pall              : PalType;

{ Set the color number Col pallete to R, G, and B }
Procedure Pal(Col,R,G,B : Byte);
{ Get's one pal's RG & B }
Procedure GetOnePal(ColourNumber : Byte;
          VAR RedValue, GreenValue, BlueValue : Byte);
{ Gets the current pallete into Pal }
Procedure GetAllPal( Pallete : PalType);
{ Sets Pal to the current pallete }
Procedure SetAllPal(Pallete : Paltype);
{ Loads pal file named F into Pal }
Procedure LoadPal(Fn : String; Pallete : PalType );
{ Fades to pallete Pal }
Procedure Fade2Pal( StartPal, EndPal, D : Word; Pallete : Paltype);
{ Fades the current pallete but maximum 1 step }
Function OneStepFade( StartPal, EndPal : Word; var CurrPal : PalType; Pallete : Paltype) : Boolean;
{ Fades the current pallete to PALLETE, but all colors arrives together. }
Procedure StepFade( StartPal, EndPal, D, MaxTimes : Word; Pallete : PalType );
{ Fills Pal with the RGB given pallete }
Procedure FillPalType(R,G,B : Word; Var Pallete : PalType);
{ Sets the colors in the given pallete to gray GVANIM }
Procedure SetGrayPal(StartPal, EndPal : Byte; Var Pallete : PalType);
{ Sets the colors in the given pallete to red GVANIM }
Procedure SetRedPal(StartPal, EndPal : Byte; Var Pallete : PalType);
{ Sets the colors in the given pallete to green GVANIM }
Procedure SetGreenPal(StartPal, EndPal : Byte; Var Pallete : PalType);
{ Sets the colors in the given pallete to blue GVANIM }
Procedure SetBluePal(StartPal, EndPal : Byte; Var Pallete : PalType);
{ Make colors from one side to the other with constant diference }
Procedure ramp(st,en,r1,g1,b1,r2,g2,b2 : byte);
{ Cycles the pallete beetwen StartPal and EndPal }
Procedure CyclePal(Up: Boolean; StartPal, EndPal : Byte; var Pallete : PalType);

(***** Light Stuff *****)

Const
  LightVals = 15;

Type
  PLightMap = ^TLightMap;
  TLightMap = Array [0..255,-LightVals..LightVals] Of Byte;

Var
  LightMap : PLightMap;

{ Inits the light map using TEMP pallete }
Procedure InitLight(Temp : PalType);
{ DeInits the light map }
Procedure DoneLight;
{ Draws a light box. Level<0 for dark and Level>0 for light }
Procedure DrawLightBox(X, Y, XLen, YLen, Level : Integer);
{ Sets MCGA 320x200x256c and allocates memory for the virtual screen }
Procedure InitVGa;
{ Sets TextMode and deallocates the virtual screen memory (if any) }
Procedure DoneVga;

{ Waits for a vertical retrace}
Procedure WaitRetrace;
{ Flipps the virtual screen to the visual screen}
Procedure ShowBitmap;
{ Clears the virtual screen }
Procedure ClearVirScr;


{ Saves the text screen in order to restore him later }
Procedure PushTXTScr;
{ Restores the text screen if saved }
Procedure PopTXTScr;

(******************************** Font stuff ********************************)

Type
  TFont = Array [#40..#90, 0..7] Of Byte;
  PFont = ^TFont;

Var
  TextColor,
  TextBackColor : Byte;

{ Loads the font, sets the text color and backcolor }
Procedure InitFont(TxtCol, TxtBackCol : Byte; fname : String);
{ Free's the memory used by the font }
Procedure DeInitFont;
{ Writes a string without the background color }
Procedure WriteStr(X,Y : Word; Str:String);
{ Wirtes a string with the background color }
Procedure WriteBackStr(X,Y : Word; Str:String);
{ Turns a number into a string }
Function  Nm2St(nm:LongInt) : string;
{ Turns a string into a number }
Function  St2Nm(st:string) : real;

{---------------------------- Font Object - Uses OOP ------------------------}

Type
  PStr = ^TStr;
  TStr = Object ( TBase )
           X,Y   : Word;
           Str   : String;
           Constructor Init(nX,nY : Word; Msg : String);
           Procedure Handle; Virtual;
  End;

  PBackStr = ^TBackStr;
  TBackStr = Object ( TStr )
           Procedure Handle; Virtual;
  End;

  PBlinkingStr = ^TBlinkingStr;
  TBlinkingStr = Object( TStr )
            Speed        : LongInt;
            Show         : Boolean;
            Constructor Init(nShow : Boolean; nSpeed : LongInt; nX,nY : Word; Msg : String);
            Procedure Handle; Virtual;
  End;

  PBackBlinkingStr = ^TBackBlinkingStr;
  TBackBlinkingStr = Object( TBackStr )
            Speed        : LongInt;
            Show         : Boolean;
            Constructor Init(nShow : Boolean; nSpeed : LongInt; nX,nY : Word; Msg : String);
            Procedure Handle; Virtual;
  End;
(******************************** Mouse stuff *******************************)

Var
  MouseX, MouseY, MouseB : Word;

{ Inits our mouse handler, and it's new exitproc which deinits it }
Procedure InitMouse;
{ DeInits the mouse handler }
Procedure DoneMouse;

(******************************** PictureStuff ******************************)

Type
  TRotatedPicture = Array [0..359] Of Pointer;

  RPic = Record
    Directions,
    LenXY         : Word;
    Rotated       : ^TRotatedPicture
  End;

  { 360 mod Directions Should be 0 !!!!!!!!!!!!!!!!!11 }
  Procedure RotatePic(Directions, aPhase, XLen, YLen : Integer; srcPic : Pointer;
                          Var dstPic : RPic );
  Procedure ReleaseRotatedPic(Var dstPic : RPic);

(********************************** General *********************************)

{ Runs DoneTaskList, DoneSinCosLookUpTable, DoneVGA and more... }
Procedure ShutGMS;

(******************************* Implementation *****************************)

Implementation

Uses
  Crt, Dos;

(***************************** Error handeling ******************************)

Procedure Error( ErrStr : String );
Begin
  DoneVga;
  PopTXTScr;
  WriteLn(ErrStr);
  Halt(1)
End;

(******************************* Files stuff ********************************)

Function PXEFileOpen : Boolean;
Begin
  PXEFileOpen := PXEFileTable.Table<>Nil
End;

Procedure LoadFile2Mem(Fn : TFileNameString; var Fil : TOpenedFile);
Var
  Tmp : Byte;
Begin
  Fil.FileNum:=GotoFile(Fn);
  Fil.Ptr:=FindMem(PXEFileTable.Table^[Fil.FileNum].Size);
  BlockRead(PXEFile,Fil.Ptr^,PXEFileTable.Table^[Fil.FileNum].Size)
End;

Procedure DoneFile(var Fil : TOpenedFile);
Begin
  If Fil.Ptr=Nil Then Exit; { no need to free it }
  If Not PXEFileOpen Then Error('PXE file '+PXEFileTable.Name+' closed.');
  FreeMem(Fil.Ptr,PXEFileTable.Table^[Fil.FileNum].Size);
  Fil.Ptr:=Nil
End;

Procedure OpenPXEFile(Fn : String);
Var
  Str : String;
  Xc,
  Yc  : Byte;
Begin
  PXEFileTable.Name:=Fn;
  If PXEFileOpen Then Error('PXE file '+Fn+' already opened.');
  Assign(PXEFile,Fn);
  Reset(PXEFile,1);
  If IOResult=2 Then Error('PXE file '+Fn+' not found.');
  BlockRead(PXEFile,Str[1],3);
  Str[0]:=IDE[0];
  If Str<>IDE Then Error('File '+Fn+' is not PXE format.');
  Seek(PXEFile,FileSize(PXEFile)-1);
  BlockRead(PXEFile,PXEFileTable.Files,1);
  If PXEFileTable.Files=0 Then Error('No files in the PXE file '+Fn);
  PXEFileTable.TAStart:=FileSize(PXEFile)-PXEFileTable.Files*(11+4)-1;
  PXEFileTable.Table:=FindMem(PXEFileTable.Files*SizeOf(TPXEFileName));
  Seek(PXEFile,PXEFileTable.TAStart);
  For Xc:=0 To PXEFileTable.Files-1 Do Begin
    BlockRead(PXEFile,PXEFileTable.Table^[Xc].Name[1],11);
    For Yc:=1 To 11 Do
      PXEFileTable.Table^[Xc].Name[Yc]:=
        UpCase(PXEFileTable.Table^[Xc].Name[Yc]);
    PXEFileTable.Table^[Xc].Name[0]:=Chr(11);
    BlockRead(PXEFile,PXEFileTable.Table^[Xc].Where,4)
  End;
  Xc:=0;
  Repeat
    If Xc+1<PXEFileTable.Files Then
      PXEFileTable.Table^[Xc].Size:=
        PXEFileTable.Table^[Xc+1].Where-PXEFileTable.Table^[Xc].Where Else
      PXEFileTable.Table^[Xc].Size:=
        FileSize(PXEFile)-15*PXEFileTable.Files-1-PXEFiletable.Table^[Xc].Where;
    Inc(Xc);
  Until (Xc=PXEFileTable.Files)
End;

Procedure ClosePXEFile;
Begin
  If Not PXEFileOpen Then Error('PXE file '+PXEFileTable.Name+' already closed.');
  FreeMem(PXEFileTable.Table,PXEFileTable.Files*(11+4));
  PXEFileTable.Table:=Nil;
  PXEFileTable.Files:=0;
  Close(PXEFile)
End;

Function GotoFile(Fn : TFileNameString) : Byte;
Var
  Xc    : Byte;
  Tmp   : Char;
  Found : Boolean;
Begin
  Tmp:=Fn[0];
  If Ord(Tmp)<>11 Then Begin
    Fn[0]:=Chr(11);
    For Xc:=1 To Ord(Tmp) Do Fn[Xc]:=Upcase(Fn[Xc]);
    For Xc:=Ord(Tmp)+1 To 11 Do Fn[Xc]:=Char(0)
  End;
  Xc:=0;
  Found:=False;
  If Not PXEFileOpen Then Error('PXE file '+PXEFileTable.Name+' not opened.');
  Repeat
    If PXEFileTable.Table^[Xc].Name=Fn Then Found:=True;
    If Not Found Then Inc(Xc);
  Until Found Or (Xc=PXEFileTable.Files);
  If Found Then Begin
    Seek(PXEFile,PXEFileTable.Table^[Xc].Where);
    GotoFile:=Xc
  End
  Else Begin
    Fn[0]:=Tmp;
    Error('File '+Fn+' not found in PXE file '+PXEFileTable.Name)
  End
End;

(******************************* Memory stuff *******************************)

Function FindMem( Size : Word ) : Pointer;
Var
  Temp : Pointer;
Begin
  If MaxAvail<Size Then Error('Not enough free memory.');
  GetMem(Temp,Size);
  FindMem:=Temp
End;

Procedure InitSinCosLookUpTable;
Var
  Xc : Word;
Begin
  If (SinTable<>Nil) Or (CosTable<>Nil) Then Exit; { Already initalized }
  If MaxAvail<SizeOf(TSinCosLookUpTable) Shl 1 Then Error('Not enough free memory.');
  New(SinTable);
  New(CosTable);
  For Xc:=0 To 179 Do Begin
    SinTable^[Xc    ] := Sin(Xc*Pi/180);
    SinTable^[Xc+180] := -SinTable^[Xc];
    CosTable^[Xc    ] := Cos(Xc*Pi/180);
    CosTable^[Xc+180] := -CosTable^[Xc]
  End
End;

Procedure DoneSinCosLookUpTable;
Begin
  If (SinTable=Nil) Or (CosTable=Nil) Then Exit; {Not initalized }
  Dispose(SinTable);
  SinTable:=Nil;
  Dispose(CosTable);
  CosTable:=Nil
End;


(************************************ OOP ***********************************)

  Constructor TBase.Init;
  Begin
    Next:=Nil;
    Prev:=Nil;
    Del:=False
  End;

  Procedure TBase.Handle;
  Begin
  End;

  Destructor TBase.Done;
  Begin
  End;

  Constructor Tlist.Init(Var CallMe : PList);
  Begin
    Inherited Init;
    FirstObj   := nil;
    LastObj    := nil;
    CallMe     := @Self
  End;

  Procedure TList.Handle;
  Var
    Temp : PBase;
  Begin
    Temp := FirstObj;
    While Temp<>Nil Do Begin
        If Not Temp^.Del Then Begin
          Temp^.Handle;
          Temp:=Temp^.Next
        End Else DelObj(Temp)
    End
  End;

  Procedure TList.AddObj( NewObj : PBase );
  Begin
    If MaxAvail<SizeOf(NewObj) Then Error('Not enough free memory.');
    If FirstObj = nil
      Then Begin
             FirstObj:= NewObj;
             LastObj := FirstObj
           End
      Else Begin
             LastObj^.Next:= NewObj;
             NewObj^.Prev:= LastObj;
             LastObj:= NewObj
           End
  End;

  Procedure TList.DelObj( var Obj : PBase );
  Var
    Temp   : PBase;
    _Type  : Byte ;
  Begin
    If Obj^.Prev<>Nil Then _Type:=0 Else Inc(_Type,1);
    If Obj^.Next=Nil Then Inc(_Type,2);
    Case _Type Of
      0 : Begin
            Temp:=Obj^.Next;
            Obj^.Next^.Prev:=Obj^.Prev;
            Obj^.Prev^.Next:=Obj^.Next { = Temp };
            Dispose(Obj,Done);
            Obj:=Temp
          End;
      1 : Begin
            FirstObj:=FirstObj^.Next;
            FirstObj^.Prev:=Nil;
            Dispose(Obj,Done);
            Obj:=FirstObj
          End;
      2 : Begin
            LastObj:=LastObj^.Prev;
            Dispose(Obj,Done);
            LastObj^.Next:=Nil;
            Obj:=Nil
          End;
      3 : Begin
            Dispose(Obj,Done);
            Obj:=Nil;
            FirstObj:=Nil;
            LastObj:=FirstObj
          End
    End
  End;

  Destructor TList.Done;
  Var
    Temp : PBase;
  Begin
    Temp:= FirstObj;
    While Temp<>nil do
      Begin
        FirstObj:= Temp^.Next;
        Dispose( Temp, Done );
        Temp:= FirstObj;
        If Temp<>Nil Then Temp^.Prev:=Nil
      End;
    FirstObj:= Nil;
    LastObj := FirstObj
  End;

Procedure InitTaskList;
Begin
  If TaskList<>Nil Then Exit;
  TaskList:=New(PList,Init(TaskList))
End;

Procedure DoneTaskList;
Begin
  If TaskList=Nil Then Exit; { Not Installed }
  Dispose(TaskList,Done);
  TaskList:=Nil
End;

(********************************** Map stuff *******************************)

Constructor TGeoMap.Init( MapName : TFileNameString; Var CallMe : PGeoMap );
Var
  Temp   : Word;
Begin
  Inherited Init;
  GotoFile(MapName);
  BlockRead(PXEFile,MapInfo.PicsNumber,1);
  If MapInfo.PicsNumber>64 Then Error ('Too many pictures in map file.');
  If (MapInfo.PicsNumber=0) Then Error('No pictures in map file.');
  MapPics:=FindMem(MapInfo.PicsNumber Shl 10);
    { Shl 10 = x2^10 = x1024 = x32x32 }
  BlockRead(PXEFile,MapPics^,MapInfo.PicsNumber Shl 10);
  MapInfo.PicsSeg:=Seg(MapPics^);
  MapInfo.PicsOfs:=Ofs(MapPics^);
  BlockRead(PXEFile,MapInfo.XLen,2);
  BlockRead(PXEFile,MapInfo.YLen,2);
  Temp:=MapInfo.XLen*MapInfo.YLen;
  MapInfo.Map.PicNum:=FindMem(Temp);
  MapInfo.Map.Status:=FindMem(Temp);
  BlockRead(PXEFIle,MapInfo.Map.PicNum^,Temp);
  BlockRead(PXEFile,MapInfo.Map.Status^,Temp);
  BlockRead(PXEFile,Pall,SizeOf(PalType));
  IncPerY:=MapInfo.XLen-9;
  CallMe:=@Self
End;

Procedure TGeoMap.Handle;
Var
  Xc, Yc,
  temp,
  Ofs1,oldofs1      : Word;
  DeltaX,DeltaY     : Integer;
Begin
  Ofs1:=(MapInfo.X Shr 5) + (MapInfo.y Shr 5)*MapInfo.XLen;
  DeltaX:= - (MapInfo.x And 31);
  DeltaY:= - (MapInfo.y And 31);
  temp:=MapInfo.xlen Shl 2 + MapInfo.XLen Shl 1;

  If DeltaY<-24 Then Begin
    temp:=MapInfo.xlen Shl 2 + MapInfo.XLen Shl 1 + MapInfo.XLen;
    For Xc:=0 To 10 Do Begin
          ClipDrawPic(Xc shl 5+deltaX,deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1] Shl 10));
          ClipDrawPic(Xc shl 5+deltaX,224+deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1+temp] Shl 10));
     Inc(Ofs1);
    End;
    temp:=10;

    Ofs1:=MapInfo.x Shr 5 + (MapInfo.y Shr 5)*MapInfo.XLen+MapInfo.Xlen;
    For Yc:= 1 to 6 do Begin
          ClipDrawPic(deltaX,yc shl 5+deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1] Shl 10));

          ClipDrawPic(320+deltaX,yc shl 5+deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1+temp] Shl 10));
       Inc(Ofs1,MapInfo.xlen);
   End;

    Ofs1:=MapInfo.x Shr 5 + (MapInfo.y Shr 5)*MapInfo.XLen+1+MapInfo.Xlen;
    For Yc:=1 To 6 Do Begin
      For Xc:=1 To 9 Do Begin
              Draw32x32Pic(Xc Shl 5+DeltaX,Yc Shl 5+DeltaY,
              Ptr(MapInfo.PicsSeg,
              MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1] Shl 10));
        Inc(ofs1);
        End;
      Inc(Ofs1,IncPerY);
    End;
  End Else Begin
    For Xc:=0 To 10 Do Begin
          ClipDrawPic(Xc shl 5+deltaX,deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1] Shl 10));

          ClipDrawPic(Xc shl 5+deltaX,192+deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1+temp] Shl 10));
          Inc(Ofs1);
    End;
    temp:=10;

    Ofs1:=MapInfo.x Shr 5 + (MapInfo.y Shr 5)*MapInfo.XLen+MapInfo.Xlen;
    For Yc:= 1 to 5 do Begin
          ClipDrawPic(deltaX,yc shl 5+deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1] Shl 10));

          ClipDrawPic(320+deltaX,yc shl 5+deltaY,32,32,Ptr(MapInfo.PicsSeg,
            MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1+temp] Shl 10));
          Inc(Ofs1,MapInfo.xlen);
    End;

    Ofs1:=MapInfo.x Shr 5 + (MapInfo.y Shr 5)*MapInfo.XLen+1+MapInfo.Xlen;
    For Yc:=1 To 5 Do Begin
      For Xc:=1 To 9 Do Begin
              Draw32x32Pic(Xc Shl 5+DeltaX,Yc Shl 5+DeltaY,
                Ptr(MapInfo.PicsSeg,
                MapInfo.PicsOfs+MapInfo.Map.PicNum^[Ofs1] Shl 10));
              Inc(ofs1);
        End;
        Inc(Ofs1,IncPerY);
      End;
  End;
End;

Destructor TGeoMap.Done;
Var Temp :  Word;
Begin
  FreeMem(MapPics,MapInfo.PicsNumber shl 10);
  Temp := MapInfo.XLen*MapInfo.YLen;
  FreeMem(MapInfo.Map.PicNum ,Temp);
  FreeMem(MapInfo.Map.Status   ,Temp)
End;

Procedure SetMapX( I : Integer );
Begin
  MapInfo.X:=I;
  If MapInfo.X<0 Then MapInfo.X:=0 Else
  If MapInfo.X>(MapInfo.XLen-1) Shl 5-320 Then MapInfo.X:=(MapInfo.XLen-1) Shl 5-320;
End;

Procedure SetMapY( I : Integer );
Begin
  MapInfo.Y:=I;
  If MapInfo.Y<0 Then MapInfo.Y:=0 Else
  If MapInfo.Y>(MapInfo.YLen-1) Shl 5-200 Then MapInfo.Y:=(MapInfo.YLen-1) Shl 5-200;
End;

Function WhatOnMask(X, Y : Word) : Byte; Assembler;
Asm
   LES DI, MapInfo.Map.Status
   Mov Bx, X
   Mov Ax, Y
   Shr Ax, 5
   Shr Bx, 5
   Mov Cx, MapInfo.XLen
   Mul Cx
   Add Ax, Bx
   Add Di, Ax
   Mov Al, Es:[Di]
End;

Procedure NewMap( MapName : String );
Begin
  If Map<>Nil Then Exit;        { map already installed }
  Map:=New(PGeoMap,Init(MapName,Map))
End;

Procedure DoneMap;
Begin
  If Map=Nil Then Exit;          { map not installed }
  Dispose(Map,Done);
  Map:=Nil
End;

(******************************* Sprites stuff ******************************)

Constructor TSprite.Init( AX, AY, LX, LY, AKind : Word; ADelWhenOut, ACanBeShot : Boolean );
Begin
  Inherited Init;
  Where.X:= AX;
  Where.Y:= AY;
  Size.X :=LX;
  Size.Y :=LY;
  Kind:=AKind;
  DelWhenOut:=ADelWhenOut;
  CanBeShot:=ACanBeShot;
  Explode:=False
End;

Procedure TSprite.Draw( x, y : Integer );
Begin
End;

Procedure TSprite.Vanish;
Begin
  Del:=True;
  Explode:=True
End;

Procedure TSprite.Handle;
Begin
  If (SelectedSprite=Nil) And PointInSquare(Where.x-MapInfo.X,Where.y-MapInfo.Y,Size.X,Size.Y,MouseX,MouseY)
    Then SelectedSprite:=@Self
End;

Procedure TSprites.Handle;
Var
  Temp : PSprite;
Begin
  Inherited Handle;
  Temp := PSprite(FirstObj);
  While Temp<>nil do
    Begin
      With Temp^ do
        If (Where.X+Size.X>=MapInfo.X) and (Where.Y+Size.Y>=MapInfo.Y) and
           (Where.X<MapInfo.X+320) and (Where.Y<MapInfo.Y+200)
           Then Draw(Where.X-MapInfo.X, Where.Y-MapInfo.Y) Else If DelWhenOut Then Del:=True;
      Temp := PSprite(Temp^.Next)
    End
End;

Procedure InsertSprites( List : PList; Var SList : PList );
Begin
  List^.AddObj(New(PSprites,Init(SList)));
End;

FUNCTION collision(x1,y1,w1,h1, x2,y2,w2,h2 :integer):boolean;
VAR xd,yd : boolean;
BEGIN
 ASM
  mov xd,false
  mov yd,false
 END;

 if ((x1 <=x2) and (x1+w1>=x2)) then xd:=true else
    if ((x1 <=x2+w2) and (x1+w1>=x2+w2)) then xd:=true else
       if ((x1 >=x2) and (x1+w1<=x2+w2)) then xd:=true;
 if ((y1 <=y2) and (y1+h1>=y2)) then yd:=true else
    if ((y1 <=y2+h2) and (y1+h1>=y2+h2)) then  yd:=true else
       if ((y1 >=y2) and (y1+h1<=y2+h2)) then yd:=true;
 collision:=xd and yd
END;

Function PointinSquare(x1,y1,w,h, px,py : Integer):Boolean;
Begin
  PointinSquare:= (px<=x1+w) and (px>=x1) and (py>=y1) and (py<=y1+h)
End;

Function GetAngle(cX, cY, tX, tY : Integer) : Integer;
Var Dx,Dy : Integer;
    Alfa  : Real;
Begin
  If tX=cX then begin    { out of arctan range }
    If tY>cY then GetAngle:=270 else GetAngle:=90;
    Exit;
  End;
  If tY=cY Then Begin    { faster than trigo }
    If tX>cX then GetAngle:=0 else GetAngle:=180;
    Exit;
  End;
  Dy:=tY-cY;
  Dx:=tX-cX;
  Alfa:=-ArcTan(Dy/Dx)*180/Pi;
  If Dx<0 then Alfa:=180+Alfa;
  Alfa:=Abs(Alfa);
  If (Dy>0) And (Dx>0) Then Alfa:=360-Alfa;
  GetAngle:=Round(Alfa) Mod 360
End;


Constructor TPlayerSprite.Init( AX, AY, LX, LY, AKind : Word; ADelWhenOut, ACanBeShot : Boolean );
Begin
  Inherited Init( AX, AY, LX, LY, AKind, ADelWhenOut, ACanBeShot );
  CList:=Nil
End;

Procedure TPlayerSprite.AddCollision( Col : PSprite );
Begin
  If CList=Nil Then NewCList;
  With CList^ Do Begin
    If FirstNode=Nil Then Begin
      New(LastNode);
      LastNode^.Collited:=Col;
      FirstNode:=LastNode
    End Else Begin
      New(LastNode^.Next);
      LastNode:=LastNode^.Next;
      LastNode^.Collited:=Col
    End;
    LastNode^.Next:=Nil
  End
End;

Procedure TPlayerSprite.NewCList;
Begin
  DelCList;
  New(CList);
  Clist^.FirstNode:=Nil;
  CList^.LastNode :=CList^.FirstNode
End;

Procedure TPlayerSprite.DelCList;
Var
  Temp : PCNode;
Begin
  If CList = Nil Then Exit; { a void collition list }
  Temp:=CList^.FirstNode;
  While Temp<>Nil Do Begin
    CList^.FirstNode:=CList^.FirstNode^.Next;
    Dispose(Temp);
    Temp:=CList^.FirstNode
  End;
  Dispose(CList);
  CList:=Nil
End;

Procedure TPlayerSprite.CheckCollision;
Var
  Temp : PSprite;
Begin
  DelCList;
  Temp:=PSprite(@Self);
  Temp:=Psprite(Temp^.Prev);
  While Temp<>Nil Do Begin
    If Collision(Where.X,Where.Y,Size.X,Size.Y,Temp^.Where.X,Temp^.Where.Y,Temp^.Size.X,Temp^.Size.Y)
    Then AddCollision(Temp);
    Temp:=PSprite(Temp^.Prev)
  End;
  Temp:=PSprite(@Self);
  Temp:=PSprite(Temp^.Next);
  While Temp<>Nil Do Begin
    If Collision(Where.X,Where.Y,Size.X,Size.Y,Temp^.Where.X,Temp^.Where.Y,Temp^.Size.X,Temp^.Size.Y)
    Then AddCollision(Temp);
    Temp:=PSprite(Temp^.Next)
  End
End;

(****************************** Keyboard stuff ******************************)

Var
  ExitSaveKey : Pointer;           { Exitproc }
  Oldint      : Procedure;         { Old interrupt number 9 }

 Procedure INT9; Interrupt;
 Begin
   Scan := port[$60];
   if scan > $7F then Begin
     if keys[scan xor $80] then Dec(keydown);
     keys[scan xor $80] := false;
   End else begin
     if not keys[scan] then Inc(keydown);
     keys[scan] := true;
     lastkey := scan;
   End;
{   oldInt;}
   port[$20] := $20;
 End;

  Procedure KeyExitProc; Far;
  Begin
    Setintvec(9, @oldint);
    ExitProc := ExitSaveKey;
    ExitSaveKey:=Nil
  End;

  Procedure DeInitKeys;
  Begin
    Setintvec(9, @oldint);
    ExitProc := ExitSaveKey;
    ExitSaveKey:=Nil
  End;

  Procedure Capture_Keyboard;
  Var Index1 : Word;
  Begin
    If ExitSaveKey<>Nil Then Exit; {Already installed}
    FillChar(Keys,128,False);
    Keydown := 0;
    Getintvec(9, @oldint);
    Setintvec(9, @INT9);
    ExitSaveKey := ExitProc;
    ExitProc := @KeyExitProc
  End;


(********************************** Graphics stuff **************************)

Var
  VirPage,
  TXTScr      : Pointer;
  VirPageSeg,
  VirPageOfs,
  OX,
  OY          : Word;

Procedure ShowStat(x,y,w,h,pow : Integer; powcol,col:byte);
var wdiv3,hdiv3,c,ofs : integer;
Begin
  wdiv3:=w div 3; hdiv3:= h div 3;
  Hline(x,x+wdiv3,y,col);
  Hline(x+wdiv3 shl 1,x+w,y,col);
  Vline(y+1,y+hdiv3,x,col);
  Vline(y+hdiv3 shl 1,y+h-1,x,col);
  Hline(x,x+wdiv3,y+h,col);
  Hline(x+wdiv3 shl 1,x+w,y+h,col);
  Vline(y+1,y+hdiv3,x+w,col);
  Vline(y+hdiv3 shl 1,y+h-1,x+w,col);

  Hline(x+2,x+pow+2,y+2,powcol);
End;


Procedure Draw32x32Pic (X,Y : Integer; Pic : Pointer ); Assembler;
Asm
        Mov     Bx,     DS
        Mov     Dx,     288 {320-32}
        MOV     ES,     VirPageSeg
        MOV     DI,     Y
        MOV     AX,     DI
        SHL     DI,     8
        SHL     AX,     6
        ADD     DI,     AX
        MOV     AX,     X
        MOV     CX,     AX
        ADD     DI,     AX
        Mov     Ax,     VirPageOfs
        Add     DI,     Ax
        LDS     SI,     PIC
        Mov     ax,     33
        And     Cx,     3
        jz      @Loop
        Cmp     Cx,     1
        je      @Loop1
        cmp     Cx,     2
        je      @Loop2
@LOOP3: dec     ax
        Jz      @END
        MOVSB
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        MOVSW
        MOVSB
        ADD     DI,     DX
        JMP     @LOOP3
@LOOP:  dec     ax
        Jz      @END
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        ADD     DI,     DX
        JMP     @LOOP
@LOOP1: dec     ax
        Jz      @END
        MOVSB
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        MOVSB
        ADD     DI,     DX
        JMP     @LOOP1
@LOOP2: dec     ax
        Jz      @END
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        DB      $66
        MOVSW
        MOVSW
        ADD     DI,     DX
        JMP     @LOOP2
@END:   Mov     DS,     Bx
End;

PROCEDURE ClipDrawPic(X,Y : Integer; Xlen,Ylen : Byte; Pic  : Pointer); Assembler;
VAR TempREG : word;
ASM
{-=-=-=-=-=-=-=-=- Do clip calculations =-=-=-=-=-=-=-=-=-=-=-=-=-}

   Mov Ax,X
   Mov Bx,Y
   LES DI, Pic
   Sub Di,2

   cmp bx,199              { Y > 199 ? }
   jg @ExitSprite          { JG is for SIGNED integers. If Y pos is
                             > 199 then no blit }
   cmp ax,319              { X > 319 ? }
   jg @ExitSprite          { Yes, Do not do any blits at all }

   mov si,di
   add si,2                { Make SI point to actual sprite data }

   xor ch,ch
   mov cl,XLen          { CL holds Clipwidth }

   cmp ah,$80              { Quick test if X position is negative }
   jb @XNotNegative        { If not then check if image is off right hand
                             of screen }
   neg ax                  { Make X position positive }

   cmp ax,cx               { If Abs(X) >= Image Width Then Don't Draw }
   ja @ExitSprite

   sub cx,ax               { Dec(ClipWidth, Abs(X)) }
   add si,ax               { Inc(DataStart, Abs(X)) }
   xor ax,ax               { Set X to 0 }
   jmp @NowDoY             { Do Y portion of data now. }

 @XNotNegative:
   mov dx,cx               { Set DX to clipwidth }
   add dx,ax               { If X + ClipWidth < 320 Then }
   cmp dx,320
   jb @NowDoY              { Do Y part (No need to clip width) }
   mov cx,320
   sub cx,ax               { ClipWidth = 320 - X }

{  At this point:

      AX is the X position of the Shape
      BX is the Y position of the Shape
      CL is the clipped width of the Shape.

      Now it is time to do the height part and set the result in CH.
}

 @NowDoY:
   xor dh,dh               { Make DX the height of image }
   mov dl,YLen
   mov ch,dl               { Set CH also to height for main blit routine }

   cmp bh,$80              { Quick test if Y position is negative }
   jb @YNotNegative

   neg bx                  { Make Y a positive number }

   cmp bx,dx               { If Y > ClipHeight }
   ja @NoDraw
   sub dx,bx               { Dec(ClipHeight, Abs(Y) ) }
   mov ch,dl               { As an image can only be 255 bytes high
                             this works fine.. }
   mov TEMPREG,AX          { Save X Coord in variable }
   xor ah,ah
   mov al,XLen          { AX = Width }
   mul bx                  { Calculate Y * Width }
   add si,ax               { Inc(DataStart, Abs(Y) * Width ) }
   mov AX,TEMPREG
   xor bx,bx               { Set Y to 0 }
   jmp @NowDoBlit          { NOW do the blit work. Whew! }

 @YNotNegative:
   add dx,bx               { If Y + ClipHeight > 199 Then }
   cmp dx,200
   jb @NowDoBlit
   mov dx,200
   sub dx,bx               { ClipHeight = 200 - Y }
   mov ch,dl

{
        At this point AX is the X position
                      BX is the Y position
                      CL is the ClipWidth and
                      CH is the ClipHeight.

        As the width/height of an Shape can only be an 8 bit
        quantity (i.e. < 256) I can discard the H portions of
        the registers. Whew!

        Now follows some weird code.. I'm going to make :

        DX = Modulo for datastart (which is the width in bytes of Shape.
        And yes, I do know that Width could be held in DL but adding extra
        code just to satisfy you optimisation junkies is v. boring.)

        DS:SI already points to data
        ES:DI points to active (source) Bitmap

}
  @NowDoBlit:
    or ch,0
    jz @ExitSprite
    or cl,0
    jz @ExitSprite
    mov TEMPREG,CX              { Save ClipWidth & ClipHeight on stack }

{=-=-=-=-=-=-=-=-=-=-=-= Calculate Offset =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
     cmp ax,319         { Is X> 319 ? }
     ja @OutOfBounds    { Yes }
     cmp bx,199         { Is Y> 199 ?. Do not use BL instead as this is
                          when problems will occur.}
     ja @OutOfBounds    { Yes }

     xor ch,ch                  { CX = Y }
     mov cl,bl
     shl cx,6                   { Y * 64 }
     mov bh,bl                  { BX = Y * 256 }
     xor bl,bl
     add bx,cx                  { BX = BX + CX, which gives Y * 320 }
     add bx,ax                  { Add the X position to offset in BX }
     Mov Ax,VirPageOfs
     Add Bx,Ax


     jmp @EndCalcOffset         { And exit. }

@OutOfBounds:
     jmp @ExitSprite            { Signal that coordinates were not within
                                  the screen limits }
@EndCalcOffset:

{=-=-=-=-=-=-=-=-=-=-=-= End Calculate Offset =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
    mov CX,TEMPREG              { Restore ClipWidth and ClipHeight }

    xor dh,dh
    mov dl,XLen             { DX = Modulo }
    mov di,bx               { Ahhh. Now DI points to the screen offset }
    jmp @EndClipCalc
  @NoDraw:
    jmp @ExitSprite            { Indicate no blit possible }
  @EndClipCalc:
{-=-=-=-=-=-=-=-=- End clip calculations =-=-=-=-=-=-=-=-=-=-=-=-=-}
   PUSH DS
   PUSH BP

   MOV AX,VirPageSeg
   MOV BX,ES
   MOV DS,BX                   { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                   { BX to be used to reload SI (+Image Width) }
   MOV BP,DI                   { And BP to reload DI (+Screen Width) }

 @Outer:
   PUSH CX
   MOV CH,CL                   { CH is set to ClipWidth }

   MOV SI,BX
   MOV DI,BP

   CMP CH,4                     { Bytes left < 4 ? }
   JB @CantDoLongWordBlit       { Yeah, so can't do the 4 byte blit }

   SHR CH,2                     { Divide Bytes left by 4 }

 @CopyLong:
   DB $66                       { Otherwise, store longword to [ES:DI] ! }
   MOVSW
   DEC CH                       { Reduce long word count }
   JNZ @CopyLong

   MOV CH,CL                    { Restore CL }
   AND CH,3
   OR CH,CH
   JZ @NoBytesLeft


 @CantDoLongWordBlit:
   CMP CH,2                     { Byte count < 2 ? }
   JB @CheckDoByteBlit          { Yes, can't do a word blit (Shit !)
                                  so that means that there's only
                                  1 byte left. }
 @CopyWord:
   MOVSW                        { Otherwise, write word }


 @CheckDoByteBlit:
   TEST CH,1                    { Is there a byte left ? }
   JZ @NoBytesLeft              { No, so no more blits this line }

 @DoByteBlit:
   MOVSB                        { Store the last byte }

 @NoBytesLeft:
   ADD BX,DX                    { BP to next byte of image to read }
   ADD BP,320                   { Advance BX to next scan line }

   POP CX
   DEC CH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }

   POP BP                       { Restore base pointer and }
   POP DS                       { Data Segment }

 @ExitSprite:
END;

PROCEDURE MClipDrawBlinkPic(X,Y : Integer; Xlen,Ylen : Byte; Pic  : Pointer); Assembler;
VAR TempREG       : word;
ASM
{-=-=-=-=-=-=-=-=- Do clip calculations =-=-=-=-=-=-=-=-=-=-=-=-=-}
   Les Di,Pic
   Mov Ax,X
   Mov Bx,Y
   Sub Di,2

   cmp bx,199              { Y > 199 ? }
   jg @ExitSprite          { JG is for SIGNED integers. If Y pos is
                             > 199 then no blit }
   cmp ax,319              { X > 319 ? }
   jg @ExitSprite          { Yes, Do not do any blits at all }

   mov si,di
   add si,2                { Make SI point to actual sprite data }

   xor ch,ch
   mov cl,XLen             { CL holds Clipwidth }

   cmp ah,$80              { Quick test if X position is negative }
   jb @XNotNegative        { If not then check if image is off right hand
                             of screen }
   neg ax                  { Make X position positive }

   cmp ax,cx               { If Abs(X) >= Image Width Then Don't Draw }
   ja @ExitSprite

   sub cx,ax               { Dec(ClipWidth, Abs(X)) }
   add si,ax               { Inc(DataStart, Abs(X)) }
   xor ax,ax               { Set X to 0 }
   jmp @NowDoY             { Do Y portion of data now. }

 @XNotNegative:
   mov dx,cx               { Set DX to clipwidth }
   add dx,ax               { If X + ClipWidth < 320 Then }
   cmp dx,320
   jb @NowDoY              { Do Y part (No need to clip width) }
   mov cx,320
   sub cx,ax               { ClipWidth = 320 - X }

{  At this point:

      AX is the X position of the Shape
      BX is the Y position of the Shape
      CL is the clipped width of the Shape.

      Now it is time to do the height part and set the result in CH.
}

 @NowDoY:
   xor dh,dh               { Make DX the height of image }
   mov dl,YLen
   mov ch,dl               { Set CH also to height for main blit routine }

   cmp bh,$80              { Quick test if Y position is negative }
   jb @YNotNegative

   neg bx                  { Make Y a positive number }

   cmp bx,dx               { If Y > ClipHeight }
   ja @NoDraw
   sub dx,bx               { Dec(ClipHeight, Abs(Y) ) }
   mov ch,dl               { As an image can only be 255 bytes high
                             this works fine.. }
   mov TEMPREG,AX          { Save X Coord on stack }
   xor ah,ah
   mov al,XLen             { AX = Width }
   mul bx                  { Calculate Y * Width }
   add si,ax               { Inc(DataStart, Abs(Y) * Width ) }
   mov AX,TEMPREG
   xor bx,bx               { Set Y to 0 }
   jmp @NowDoBlit          { NOW do the blit work. Whew! }

 @YNotNegative:
   add dx,bx               { If Y + ClipHeight > 199 Then }
   cmp dx,200
   jb @NowDoBlit
   mov dx,200
   sub dx,bx               { ClipHeight = 200 - Y }
   mov ch,dl

{
        At this point AX is the X position
                      BX is the Y position
                      CL is the ClipWidth and
                      CH is the ClipHeight.

        As the width/height of an Shape can only be an 8 bit
        quantity (i.e. < 256) I can discard the H portions of
        the registers. Whew!

        Now follows some weird code.. I'm going to make :

        DX = Modulo for datastart (which is the width in bytes of Shape.
        And yes, I do know that Width could be held in DL but adding extra
        code just to satisfy you optimisation junkies is v. boring.)

        DS:SI already points to data
        ES:DI points to active (source) Bitmap

}
  @NowDoBlit:
    or ch,0
    jz @ExitSprite
    or cl,0
    jz @ExitSprite
    mov TEMPREG,CX        { Save ClipWidth & ClipHeight on stack }

{=-=-=-=-=-=-=-=-=-=-=-= Calculate Offset =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
     cmp ax,319         { Is X> 319 ? }
     ja @OutOfBounds    { Yes }
     cmp bx,199         { Is Y> 199 ?. Do not use BL instead as this is
                          when problems will occur.}
     ja @OutOfBounds    { Yes }

     xor ch,ch                  { CX = Y }
     mov cl,bl
     shl cx,6                   { Y * 64 }
     mov bh,bl                  { BX = Y * 256 }
     xor bl,bl
     add bx,cx                  { BX = BX + CX, which gives Y * 320 }
     add bx,ax                  { Add the X position to offset in BX }
     Mov Ax,VirPageOfs
     Add Bx,Ax

     jmp @EndCalcOffset         { And exit. }

@OutOfBounds:
     jmp @ExitSprite            { coordinates are not within screen limites,
                                  so exit blitting }
@EndCalcOffset:

{=-=-=-=-=-=-=-=-=-=-=-= End Calculate Offset =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
    mov CX,TEMPREG              { Restore ClipWidth and ClipHeight }

    xor dh,dh
    mov dl,XLen                 { DX = Modulo }
    mov di,bx                   { Ahhh. Now DI points to the screen offset }
    jmp @EndClipCalc
  @NoDraw:
    jmp @ExitSprite             { no blit is possible }
  @EndClipCalc:
{-=-=-=-=-=-=-=-=- End clip calculations =-=-=-=-=-=-=-=-=-=-=-=-=-}

   PUSH DS
   PUSH BP

   MOV AX,VirPageSeg
   MOV BX,ES
   MOV DS,BX                   { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                   { BX to be used to reload SI }
   MOV BP,DI                   { And the screen modulo }

   MOV AH,CL                   { AH = Width }
   CLD                         { Make sure LODSB works OK }

@Outer:
   MOV CL,AH                   { Re-load CL }
   MOV SI,BX                   { And SI with address of next sprite row }
   MOV DI,BP                   { And DI with address of next scan line }


@WriteByte:
   LODSB                       { Read byte from DS:SI }
   OR AL,AL                    { Is byte 0 (transparent) ? }
   JZ @NoBlit                  { yes, so don't blit }
   MOV AL,ColorWhite           { set the color to white }
   MOV [ES:DI],al              { Otherwise store byte }

@NoBlit:
   INC DI                       { Move DI to next pos. on screen }
   DEC CL                       { Reduce shape width count }
   JNZ @WriteByte               { If not zero, end of shape not reached }

   ADD BX,DX                    { BX = BX + Modulo, so BX now points
                                  to first byte of next sprite line
                                  to blit }
   ADD BP,320                   { Make BP point to next line. Note :
                                  If you are going to add some extra
                                  stuff here make sure you're not
                                  accessing local variables! }


   DEC CH
   JNZ @Outer

   POP BP
   POP DS

 @ExitSprite:
END;

PROCEDURE MClipDrawPic(X,Y : Integer; Xlen,Ylen : Byte; Pic  : Pointer); Assembler;
VAR TempREG       : word;
ASM
{-=-=-=-=-=-=-=-=- Do clip calculations =-=-=-=-=-=-=-=-=-=-=-=-=-}
   Les Di, Pic
   Mov Ax,X
   Mov Bx,Y
   Sub Di,2

   cmp bx,199              { Y > 199 ? }
   jg @ExitSprite          { JG is for SIGNED integers. If Y pos is
                             > 199 then no blit }
   cmp ax,319              { X > 319 ? }
   jg @ExitSprite          { Yes, Do not do any blits at all }

   mov si,di
   add si,2                { Make SI point to actual sprite data }

   xor ch,ch
   mov cl,XLen             { CL holds Clipwidth }

   cmp ah,$80              { Quick test if X position is negative }
   jb @XNotNegative        { If not then check if image is off right hand
                             of screen }
   neg ax                  { Make X position positive }

   cmp ax,cx               { If Abs(X) >= Image Width Then Don't Draw }
   ja @ExitSprite

   sub cx,ax               { Dec(ClipWidth, Abs(X)) }
   add si,ax               { Inc(DataStart, Abs(X)) }
   xor ax,ax               { Set X to 0 }
   jmp @NowDoY             { Do Y portion of data now. }

 @XNotNegative:
   mov dx,cx               { Set DX to clipwidth }
   add dx,ax               { If X + ClipWidth < 320 Then }
   cmp dx,320
   jb @NowDoY              { Do Y part (No need to clip width) }
   mov cx,320
   sub cx,ax               { ClipWidth = 320 - X }

{  At this point:

      AX is the X position of the Shape
      BX is the Y position of the Shape
      CL is the clipped width of the Shape.

      Now it is time to do the height part and set the result in CH.
}

 @NowDoY:
   xor dh,dh               { Make DX the height of image }
   mov dl,YLen
   mov ch,dl               { Set CH also to height for main blit routine }

   cmp bh,$80              { Quick test if Y position is negative }
   jb @YNotNegative

   neg bx                  { Make Y a positive number }

   cmp bx,dx               { If Y > ClipHeight }
   ja @NoDraw
   sub dx,bx               { Dec(ClipHeight, Abs(Y) ) }
   mov ch,dl               { As an image can only be 255 bytes high
                             this works fine.. }
   mov TEMPREG,AX          { Save X Coord on stack }
   xor ah,ah
   mov al,XLen             { AX = Width }
   mul bx                  { Calculate Y * Width }
   add si,ax               { Inc(DataStart, Abs(Y) * Width ) }
   mov AX,TEMPREG
   xor bx,bx               { Set Y to 0 }
   jmp @NowDoBlit          { NOW do the blit work. Whew! }

 @YNotNegative:
   add dx,bx               { If Y + ClipHeight > 199 Then }
   cmp dx,200
   jb @NowDoBlit
   mov dx,200
   sub dx,bx               { ClipHeight = 200 - Y }
   mov ch,dl

{
        At this point AX is the X position
                      BX is the Y position
                      CL is the ClipWidth and
                      CH is the ClipHeight.

        As the width/height of an Shape can only be an 8 bit
        quantity (i.e. < 256) I can discard the H portions of
        the registers. Whew!

        Now follows some weird code.. I'm going to make :

        DX = Modulo for datastart (which is the width in bytes of Shape.
        And yes, I do know that Width could be held in DL but adding extra
        code just to satisfy you optimisation junkies is v. boring.)

        DS:SI already points to data
        ES:DI points to active (source) Bitmap

}
  @NowDoBlit:
    or ch,ch
    jz @ExitSprite
    or cl,cl
    jz @ExitSprite

    mov TEMPREG,CX        { Save ClipWidth & ClipHeight on stack }

{=-=-=-=-=-=-=-=-=-=-=-= Calculate Offset =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
     cmp ax,319         { Is X> 319 ? }
     ja @OutOfBounds    { Yes }
     cmp bx,199         { Is Y> 199 ?. Do not use BL instead as this is
                          when problems will occur.}
     ja @OutOfBounds    { Yes }

     xor ch,ch                  { CX = Y }
     mov cl,bl
     shl cx,6                   { Y * 64 }
     mov bh,bl                  { BX = Y * 256 }
     xor bl,bl
     add bx,cx                  { BX = BX + CX, which gives Y * 320 }
     add bx,ax                  { Add the X position to offset in BX }
     Mov Ax,VirPageOfs
     Add Bx,Ax


     jmp @EndCalcOffset         { And exit. }

@OutOfBounds:
     jmp @ExitSprite            { coordinates are not within screen limites,
                                  so exit blitting }
@EndCalcOffset:

{=-=-=-=-=-=-=-=-=-=-=-= End Calculate Offset =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
    mov CX,TEMPREG              { Restore ClipWidth and ClipHeight }

    xor dh,dh
    mov dl,XLen                 { DX = Modulo }
    mov di,bx                   { Ahhh. Now DI points to the screen offset }
    jmp @EndClipCalc
  @NoDraw:
    jmp @ExitSprite             { no blit is possible }
  @EndClipCalc:
{-=-=-=-=-=-=-=-=- End clip calculations =-=-=-=-=-=-=-=-=-=-=-=-=-}

   PUSH DS
   PUSH BP

   MOV AX,VirPageSeg
   MOV BX,ES
   MOV DS,BX                   { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                   { BX to be used to reload SI }
   MOV BP,DI                   { And the screen modulo }

   MOV AH,CL                   { AH = Width }
   CLD                         { Make sure LODSB works OK }

@Outer:
   MOV CL,AH                   { Re-load CL }
   MOV SI,BX                   { And SI with address of next sprite row }
   MOV DI,BP                   { And DI with address of next scan line }


@WriteByte:
   LODSB                       { Read byte from DS:SI }
   OR AL,AL                    { Is byte 0 (transparent) ? }
   JZ @NoBlit                  { yes, so don't blit }
   MOV [ES:DI],AL              { Otherwise store byte }

@NoBlit:
   INC DI                       { Move DI to next pos. on screen }
   DEC CL                       { Reduce shape width count }
   JNZ @WriteByte               { If not zero, end of shape not reached }

   ADD BX,DX                    { BX = BX + Modulo, so BX now points
                                  to first byte of next sprite line
                                  to blit }
   ADD BP,320                   { Make BP point to next line. Note :
                                  If you are going to add some extra
                                  stuff here make sure you're not
                                  accessing local variables! }


   DEC CH
   JNZ @Outer

   POP BP
   POP DS

 @ExitSprite:
END;

Procedure Box     (X,Y,XLen : Integer; YLen, Col : Byte); Assembler;
Asm
  MOV  DX,  320
  MOV  BX,  XLen
  SUB  DX,  BX
  MOV  ES,  VirPageSeg
  MOV  DI,  Y
  MOV  AX,  DI
  SHL  DI,  8
  SHL  AX,  6
  ADD  DI,  AX
  MOV  AX,  X
  ADD  DI,  AX
  MOV  AX,  VIRPAGEOFS
  ADD  DI,  AX
  MOV  Al,  Col
  XOR  BL,  BL
@LOOP:
  INC  BL
  CMP  BL,  YLen
  JNB  @END
  MOV  CX,  XLen
  REP  STOSB
  ADD  DI,  DX
  JMP  @LOOP
@END:
END;

(*Procedure Hline (x1,x2,y: integer;col: byte); assembler;
  { This draws a horizontal line from x1 to x2 on line y in color col }
asm
  mov   es,VirPageSeg
{  mov   ax,cx1
  cmp   x1,ax
  jg    @next
  mov   x1,ax
@next:
  mov   ax,cx2
  cmp   x2,ax
  jl    @next1
  mov   x2,ax
@next1:}
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1
  add   di,VirPageOfs

  mov   al,col
  mov   ah,al
  mov   cx,x2
  sub   cx,x1
  inc   cx
  shr   cx,1
  jnc   @start
  stosb
@Start :
  rep   stosw
end;*)

Procedure Hline (x1,x2,y: integer;col: byte);
Var Count, Temp: Integer;
Begin
  If (Y<0) or (Y>199) or (x1>319) or (x2<0) then Exit;
  If x1<0 then x1:=0;
  If x2>319 then x2:=319;
  temp:=y shl 8 + y shl 6 +x1;
  For Count := x1 TO x2 Do begin
    Mem[VirPageSeg:VirPageOfs+temp] := col;
    inc(temp);
  End;
End;


Procedure Vline (y1,y2,x: integer;col: byte);
Var Count, Temp, tempy: Integer;
Begin
  If (X<0) or (X>319) or (y1>199) or (y2<0) then Exit;
  If Y1<0 then Y1:=0;
  If Y2>199 then y2:=199;
  temp:=y1 shl 8 + y1 shl 6 +x;
  For TempY := Y1 TO Y2 Do begin
    Mem[VirPageSeg:VirPageOfs+temp] := col;
    inc(temp,320);
  End;
End;


(**** Pallete stuff ****)

Procedure Pal(Col,R,G,B : Byte); Assembler;
asm
  mov    dx,3c8h
  mov    al,[col]
  out    dx,al
  inc    dx
  mov    al,[r]
  out    dx,al
  mov    al,[g]
  out    dx,al
  mov    al,[b]
  out    dx,al
End;

Procedure GetOnePal(ColourNumber : Byte;
          VAR RedValue, GreenValue, BlueValue : Byte); Assembler;
Asm
   MOV DX,$3C7          { $3C7 is colour ** READ ** select port. }
   MOV AL,ColourNumber   { Select colour to read }
   OUT DX,AL
   ADD DL,2             { DX now = $3C9, which must be read 3 times
                          in order to obtain the Red, Green and
                          Blue values of a colour }

   IN AL,DX             { Read red amount. Don't use IN AX,DX as
                          for some strange reason it doesn't work ! }
   LES DI,RedValue
   MOV [ES:DI],AL       { Techie saddos note : STOSB is approx 4 cycles
                          slower and requires double cache multiplex,
                          which basically means "who gives a shit ?". :-)
                        }

   IN AL,DX
   LES DI,GreenValue
   MOV [ES:DI],AL

   IN AL,DX             { Read blue }
   LES DI,BlueValue
   MOV [ES:DI],AL
End;

Procedure GetAllPal( Pallete : PalType); Assembler;
Asm
  Mov Al, $FF
  Mov DX, $C6
  Out DX, Al
  Mov DX, $3C7
  Mov Al, 0
  Out DX, Al
  Mov DX, $3C9
  Les di, Pallete
  Mov CX, 768
@B2:
  In Al, DX
  Mov ES:[di], Al
  Inc di
  Loop @B2
End;

Procedure SetAllPal( Pallete : PalType ); Assembler;
Asm
   push   ds
   lds    si, Pallete
   mov    dx, 3c8h
   mov    al, 0
   out    dx, al
   inc    dx
   mov    cx, 768
   rep    outsb
   pop    ds
End;

Procedure LoadPal (Fn : String; Pallete : PalType );
Var
  F : File;
Begin
  Assign (F, Fn);
  Reset (F, 1);
  If IOResult <> 0 then Exit;
  If FIlesize (F) < 768 then Exit;
  Blockread (F, Pallete, 768);
  Close (F);
End;

Procedure Fade2Pal( StartPal, EndPal, D : Word; Pallete : PalType);
Var
  Temp : PalType;
  Done : Boolean;
Begin
  GetAllPal(Temp);
  Repeat
    Delay(D);
    WaitRetrace;
    Done:=OneStepFade(StartPal, EndPal, Temp, Pallete);
  Until Done
End;

Function OneStepFade( StartPal, EndPal : Word; var CurrPal : PalType; Pallete : Paltype) : Boolean;
VAR
  Xc, Yc      : Byte;
  Temp        : Boolean;
BEGIN
  Temp:=True;
  For Xc:=StartPal To EndPal Do
    For Yc:=0 To 2 Do Begin
      If CurrPal[Xc,Yc]<Pallete[Xc,Yc] Then Begin Inc(CurrPal[Xc,Yc]); Temp:=False End;
      If CurrPal[Xc,Yc]>Pallete[Xc,Yc] Then Begin Dec(CurrPal[Xc,Yc]); Temp:=False End
  End;
  SetAllPal(CurrPal);
  OneStepFade:=Temp
End;

{ MaxTimes should be equal or greater then 63. }
Procedure StepFade( StartPal, EndPal, D, MaxTimes : Word; Pallete : PalType );
VAR
  Xc, Yc, Zc  : Byte;
  Temp, Temp2 : PalType;
BEGIN
  GetAllPal(Temp);
  For Xc:=StartPal To EndPal Do
    For Yc:=0 To 2 Do
      If Temp[Xc,Yc]<>Pallete[Xc,Yc] Then Temp2[Xc,Yc]:=MaxTimes Div Abs(Temp[Xc,Yc]-Pallete[Xc,Yc]);
  For Zc:=1 To MaxTimes Do Begin
    For Xc:=StartPal To EndPal Do
      For Yc:=0 To 2 Do Begin
        If (Temp[Xc,Yc]<Pallete[Xc,Yc]) And ((Zc Mod Temp2[Xc,Yc]<>0) Or (Temp2[Xc,Yc]=1)) Then Inc(Temp[Xc,Yc]);
        If (Temp[Xc,Yc]>Pallete[Xc,Yc]) And ((Zc Mod Temp2[Xc,Yc]<>0) Or (Temp2[Xc,Yc]=1)) Then Dec(Temp[Xc,Yc])
      End;
    Delay(D);
    WaitRetrace;
    SetAllPal(Temp)
  End;
  SetAllPal(Pallete)
End;

Procedure FillPalType(R,G,B : Word; Var Pallete : Paltype);
Var
  Count : Byte;
Begin
  For Count:=0 To 255 Do
    Begin
      Pallete[Count,0]:=R;
      Pallete[Count,1]:=G;
      Pallete[Count,2]:=B
    End
End;

Procedure SetGrayPal(StartPal, EndPal : Byte; Var Pallete : PalType);
Var
  Count : Byte;
Begin
  For Count:=StartPal To EndPal Do
    Begin
      Pallete[Count,0]:=(Pallete[Count,0]+Pallete[Count,1]+Pallete[Count,2]) Div 3;
      Pallete[Count,1]:=Pallete[Count,0];
      Pallete[Count,2]:=Pallete[Count,0]
    End
End;

Procedure SetRedPal(StartPal, EndPal : Byte; Var Pallete : PalType);
Var
  Count : Byte;
Begin
  For Count:=StartPal To EndPal Do
    Begin
      Pallete[Count,0]:=(Pallete[Count,0]+Pallete[Count,1]+Pallete[Count,2]) Div 3;
      Pallete[Count,1]:=0;
      Pallete[Count,2]:=0
    End
End;

Procedure SetGreenPal(StartPal, EndPal : Byte; Var Pallete : PalType);
Var
  Count : Byte;
Begin
  For Count:=StartPal To EndPal Do
    Begin
      Pallete[Count,0]:=0;
      Pallete[Count,1]:=(Pallete[Count,0]+Pallete[Count,1]+Pallete[Count,2]) Div 3;
      Pallete[Count,2]:=0
    End
End;

Procedure SetBluePal(StartPal, EndPal : Byte; Var Pallete : PalType);
Var
  Count : Byte;
Begin
  For Count:=StartPal To EndPal Do
    Begin
      Pallete[Count,0]:=0;
      Pallete[Count,1]:=0;
      Pallete[Count,2]:=(Pallete[Count,0]+Pallete[Count,1]+Pallete[Count,2]) Div 3
    End
End;

Procedure ramp(st,en,r1,g1,b1,r2,g2,b2 : byte);
Var
  rinc,ginc,binc : real;
  xc : byte;
Begin
  rinc:=(r2-r1)/(en-st+1);  ginc:=(g2-g1)/(en-st+1);  binc:=(b2-b1)/(en-st+1);
  For xc:= 1 to en-st+1 do
    Pal(xc+st-1,round(r1+rinc*xc),round(g1+ginc*xc),round(b1+binc*xc));
End;

Procedure CyclePal(Up: Boolean; StartPal, EndPal : Byte; var Pallete : PalType);
Var
  cR, cG, cB : Byte;
Begin
  If up
    Then Begin
           cR:= Pallete[EndPal][R];
           cG:= Pallete[EndPal][G];
           cB:= Pallete[EndPal][B];
           Move( Pallete[StartPal], Pallete[StartPal+1], (EndPal-StartPal)*3 );
           Pallete[StartPal][R]:= cR;
           Pallete[StartPal][G]:= cG;
           Pallete[StartPal][B]:= cB;
         End
    Else Begin
           cR:= Pallete[StartPal][R];
           cG:= Pallete[StartPal][G];
           cB:= Pallete[StartPal][B];
           Move( Pallete[StartPal+1], Pallete[StartPal], (EndPal-StartPal)*3 );
           Pallete[EndPal][R]:= cR;
           Pallete[EndPal][G]:= cG;
           Pallete[EndPal][B]:= cB;
         End
End;

(***** Light Stuff *****)

Procedure InitLight(Temp : PalType);
Var
  _L       : Real;
  NDelta,
  CDelta,
  SCol,
  BCol,
  IR,
  IG,
  IB,
  Col,
  Level    : Integer;
Begin
  If LightMap<>Nil Then Exit;   { LightMap already installed }
  If MaxAvail<SizeOf(TLightMap) Then Error('Not enough free memory.');
  New(LightMap);

  For Level:=-LightVals To LightVals Do Begin
    _L:=Level/LightVals+1;
    For Col:=0 To 255 Do Begin
      IR:=Round(Temp[Col, R]*_L);
      IG:=Round(Temp[Col, G]*_L);
      IB:=Round(Temp[Col, B]*_L);
      CDelta:=Abs(IR-Temp[0,R])+
              Abs(IG-Temp[0,G])+
              Abs(IB-Temp[0,B]);
      For SCol:=0 To 255 Do Begin
        NDelta:=Abs(IR-Temp[SCol,R])+
                Abs(IG-Temp[SCol,G])+
                Abs(IB-Temp[SCol,B]);
        If NDelta<CDelta Then Begin
          BCol:=SCol;
          CDelta:=NDelta
        End
      End;
      LightMap^[Col,Level]:=BCol
    End
  End
End;

Procedure DoneLight;
Begin
  If LightMap=Nil Then Exit; { LightMap not installed }
  Dispose(LightMap)
End;

Procedure DrawLightBox(X, Y, XLen, YLen, Level : Integer);
Var
  Xc, Yc,
  Delta   : Integer;
  Temp    : Word;
Begin
  If LightMap=Nil Then Exit; { LightMap not installed }

{ Clipping calculations }

  If X>319 Then Exit;
  If Y>199 Then Exit;
  If X+XLen>319 Then XLen:=320-X;
  If Y+YLen>199 Then YLen:=200-Y;
  If X<0   Then Begin
    XLen:=XLen+X;
    If XLen<=0 Then Exit;
    X:=0
  End;
  If Y<0   Then Begin
    YLen:=YLen+Y;
    If YLen<=0 Then Exit;
    Y:=0
  End;

{ Draw it }

  Delta:=320-XLen;
  Temp:=X + (Y Shl 6) + (Y Shl 8) + VirPageOfs;
  For Yc:= 1 To YLen Do Begin
    For Xc := 1 To XLen Do Begin
      Mem[VirPageSeg : Temp ] := LightMap^[ Mem[VirPageSeg : Temp], Level ];
      Inc(Temp)
    End;
    Inc(Temp,Delta)
  End

End;

(**** End of pallete stuff ****)

Procedure InitVGA;
Begin
  If Virpage<>Nil Then Exit;
  VirPage   := FindMem(64000);
  VirPageSeg:=Seg(VirPage^);
  VirPageOfs:=Ofs(VirPage^);
  Asm
    XOR         AH,     AH
    MOV         AL,     $13
    INT         $10
  End
End;

Procedure DoneVga;
Begin
  TextMode(c80);
  If Virpage=Nil Then Exit;
  FreeMem(VirPage,64000);
  VirPage:=Nil
End;

procedure WaitRetrace; assembler;
Asm
  Mov Dx,03Dah
  @P: In al,dx
  Test al,8
  Jz @P
End;

Procedure ShowBitmap; Assembler;
Asm
  Mov Dx,Ds
  Xor Di,Di
  Mov Es,SegA000
  Mov SI,VirPageOfs
  Mov Ds,VirPageSeg
  Mov Cx,16000
  DB  $66
  Rep MovSW
  Mov Ds,Dx
End;

Procedure ClearVirScr; Assembler;
Asm
  DB  $66
  XOR AX, AX
  Mov ES,VirPageSeg
  Mov DI,VirPageOfs
  Mov Cx,16000
  DB  $66
  Rep STOSW
End;


Procedure PushTXTScr;
Begin
  If TXTScr<>Nil Then Exit; {Already pushed}
  TXTScr:=FindMem(4000);
  Move(Mem[SegB800:000],TXTScr^,4000);
  OX:=WhereX;
  OY:=WhereY
End;

Procedure PopTXTScr;
Begin
  If TXTScr=Nil Then Exit; {Not pushed}
  Move(TXTScr^,Mem[SegB800:000],4000);
  GotoXY(OX,OY);
  FreeMem(TXTScr,4000);
  TXTScr:=Nil
End;

(******************************** Font stuff ********************************)

Var
  Font          : PFont;
  FntName       : String;
  FontSeg,
  FontOfs       : Word;

Procedure LoadFont;
Var
  Xc    : Char;
  Yc    : Byte;
  xx,yy : Word;
Begin
  GotoFile(FntName);
  For Xc:=#40 To #90 Do
    For Yc := 0 To 7 Do
      BlockRead(PXEFile,Font^[Xc,Yc],1)
End;

Procedure InitFont(TxtCol, TxtBackCol : Byte; fname : String);
Begin
  If Font<>Nil Then Exit; {Already installed}
  TextColor:=TxtCol;
  TextBackColor:=TxtBackCol;
  FntName:=Fname;
  If MaxAvail<SizeOf(TFont) Then Error('Not enough memory.');
  New(Font);
  LoadFont;
  FontSeg:=Seg(Font^);
  FontOfs:=Ofs(Font^)
End;

Procedure DeInitFont;
Begin
  If Font = Nil Then Exit; { Not installed }
  Dispose(Font);
  Font:=Nil
End;

Procedure DrawChar(X,Y : Word; Chr : Char); Assembler;
Asm
  Cmp Chr,32
  Je @Sof                    {We wont draw the space...}
  Push Ds


  Mov Di,Y
  Mov Ax,Di
  Shl Di,6
  Shl Ax,8
  Add Di,Ax
  Mov Ax,X
  Add Di,Ax                  {Es:[Di] is the place in the virPage}

  Mov Bx,VirPageOfs
  Add Di,Bx

  Mov Dl,TextColor
  Mov Es,VirPageSeg
  Mov Si,FontOfs
  Mov Ds,FontSeg

  Xor Ax,Ax
  Mov Al,Chr
  Sub Al,40
  Shl Ax,3

  Add Si,Ax                  {Ds:[Si] Points to the char}

  Mov Bx,8

@LoopY:
  Mov Cl,Ds:[si]             {Get the byte we are gonna check...}
  Mov Ch,8
@LoopX:
  RCR Cl,1
  Jnc @Next
  Mov Es:[Di],Dl
@Next:
  Inc Di
  Dec Ch
  Jnz @LoopX
  Add Di,312
  Inc Si
  Dec Bx
  Jnz @LoopY
  Pop Ds
@Sof:
End;

Procedure DrawBackChar(X,Y : Word; Chr : Char); Assembler;
Asm
  Cmp Chr,32
  Je @Sof

  Push Ds

  Mov Di,Y
  Mov Ax,Di
  Shl Di,6
  Shl Ax,8
  Add Di,Ax
  Mov Ax,X
  Add Di,Ax                  {Es:[Di] is the place in the virPage}

  Mov Al,TextBackColor

  Mov Bx,VirPageOfs
  Add Di,Bx

  Cmp Chr, $FF
  Je @Box

  Mov Dl,TextColor
  Mov Es,VirPageSeg
  Mov Si,FontOfs
  Mov Ds,FontSeg

  Xor Bx,Bx
  Mov Bl,Chr
  Sub Bl,40
  Shl Bx,3

  Add Si,Bx                  {Ds:[Si] Points to the char}

  Mov Bx,8

@LoopY:
  Mov Cl,Ds:[si]             {Get the byte we are gonna check...}
  Mov Ch,8
@LoopX:
  RCR CL,1
  Jnc @Back
  Mov Es:[Di],Dl
  Jmp @Next
@Back:
  Mov Es:[Di],Al
@Next:
  Inc Di
  Dec Ch
  Jnz @LoopX
  Add Di,312
  Inc Si
  Dec Bx
  Jnz @LoopY
  Jmp @SOF_KVAR
@Box:
  Mov Cx,8
  Mov Bl,Al
  Mov Ah,Al
  Db $66
  Shl Ax,16
  Mov Al,Bl
  Mov Ah,Al
@Loop1:
  DB $66
    StosW
  DB $66
    StosW
  Add Di,312
  Loop @Loop1

@Sof_Kvar:
  Pop Ds
@Sof:
End;

Procedure WriteStr(X,Y : Word; Str:String);
Var
  Xc : Byte;
Begin
   For Xc:=1 To Ord(Str[0]) Do
      If (X+(Xc-1) Shl 3>0) And (Y>0) And (Y<192) And (X+(Xc-1) Shl 3<312) Then DrawChar(X+(Xc-1) Shl 3,Y,Str[Xc])
End;

Procedure WriteBackStr(X,Y : Word; Str:String);
Var
  Xc : Byte;
Begin
   For Xc:=1 To Ord(Str[0]) Do
      If (X+(Xc-1) Shl 3>0) And (Y>0) And (Y<192) And (X+(Xc-1) Shl 3<312) Then DrawBackChar(X+(Xc-1) Shl 3,Y,Str[Xc])
End;

Function  Nm2St(nm:LongInt) : string;
var S: string[11];
Begin
 Str(nm, S);
 Nm2St := S;
End;

Function  St2Nm(st:string) : real;
var v : real; code : integer;
Begin
  Val(st, V, Code);
  if code=0 then st2nm:=v;
End;

{---------------------------- Font Object - Uses OOP ------------------------}

  Constructor TStr.Init(nX,nY : Word; Msg : String);
  Begin
    Inherited Init;
    X:=nX;
    Y:=nY;
    Str:=Msg
  End;

  Procedure TStr.Handle;
  Begin
    WriteSTR(X,Y,STR)
  End;

  Procedure TBackStr.Handle;
  Begin
    WriteBackSTR(X,Y,Str)
  End;

  Constructor TBlinkingStr.Init(nShow : Boolean; nSpeed : LongInt; nX,nY : Word; Msg : String);
  Begin
    Inherited Init(nX, nY, MSG);
    Speed:=nSpeed;
    Show:=nShow
  End;

  Procedure TBlinkingStr.Handle;
  Begin
    If Count Mod Speed = 0 Then Show:=Not Show;
    If Show Then
      Inherited Handle
  End;

  Procedure TBackBlinkingStr.Handle;
  Begin
    If Count Mod Speed = 0 Then Show:=Not Show;
    If Show Then
      Inherited Handle
  End;

  Constructor TBackBlinkingStr.Init(nShow : Boolean; nSpeed : LongInt; nX,nY : Word; Msg : String);
  Begin
    Inherited Init(nX, nY, MSG);
    Speed:=nSpeed;
    Show:=nShow
  End;

(******************************** Mouse stuff *******************************)

Var
  OldExitProc : Pointer;

Procedure MouseHandler(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
Interrupt;
Begin
  MouseX:= CX div 2;
  MouseY:= DX;
  MouseB:= BX;

  InLine ($8B/$E5/$5D/$07/$1F/$5F/$5E/$5A/$59/$5B/$58/$CB)
End;

Procedure NewExitProc; Far;
Begin
  Asm
    mov ax, SEG MouseHandler
    mov es, ax
    mov dx, OFFSet MouseHandler
    mov ax, 12
    mov cx, $0
    int $33
  End;
  ExitProc:=OldExitProc;
  OldExitProc:=Nil
End;

Procedure InitMouse;
Var
  Inited : Boolean;
Begin
  If OldExitProc<>Nil Then Exit; { Already installed }
  Asm
    Mov Inited,True
    Xor Ax,Ax
    Int 33h
    Cmp Ax,$FFFF
    Je  @Sof
    Mov Inited,False
    JMP @1
@Sof:
    mov ax, SEG MouseHandler
    mov es, ax
    mov dx, OFFSet MouseHandler
    mov ax, 0CH
    mov cx, $7F
    int $33
    Mov Ax,03h
    Int 33h
    shr Cx,1
    Mov Mousex,Cx
    Mov MouseY,Dx
    Mov MouseB,Bx

@1  :
  End;
  If Not Inited Then Error('Mouse hardware/software not found.');
  OldExitProc:=ExitProc;
  ExitProc:=@NewExitProc
End;

Procedure DoneMouse;
Begin
  Asm
    mov ax, SEG MouseHandler
    mov es, ax
    mov dx, OFFSet MouseHandler
    mov ax, 12
    mov cx, $0
    int $33
  End;
  ExitProc:=OldExitProc;
  OldExitProc:=Nil
End;

(******************************** PictureStuff ******************************)

  Procedure RotatePic(Directions, aPhase, XLen, YLen : Integer; srcPic : Pointer;
                          Var dstPic : RPic );
  Var
    A,
    B,
    Angle,
    Phase,
    NewX,
    NewY        : Integer;
    sSeg,
    sOfs,
    dSeg,
    dOfs,
    NewPicX,
    NewPicSize,
    mdX,
    msX,
    msY,
    AngInc,
    Xc,
    Yc,
    Zc           : Word;
  Begin
    If (SinTable=Nil) Or (CosTable=Nil) Then Exit; {Can't rotate if not
    installed sin/cos lookup table ! }
    If srcPic=Nil Then Exit; { rotate what ? }
    If dstPic.Rotated<>Nil Then Exit; { into what ? }

    { now everything is O.K, so we may continue }

    dstPic.Directions:=Directions;
    dstPic.Rotated:=FindMem( SizeOf(Pointer)*Directions );
    {NewPicY:=}NewPicX:=Round( Sqrt( Sqr(XLen) + Sqr(YLen) ) );
    dstPic.LenXY:=NewPicX;
    NewPicSize:=Sqr(NewPicX);
    mdX := NewPicX Shr 1;
    msX := XLen Shr 1;
    msY := YLen Shr 1;

    sSeg:=Seg(srcPic^);
    sOfs:=Ofs(srcPic^);

    AngInc:=360 Div Directions;
    Phase:=Round(aPhase/AngInc)*AngInc;
    For Zc:=0 To Directions-1 do Begin
      dstPic.Rotated^[Zc]:=FindMem(NewPicSize);
      dSeg:=Seg(dstPic.Rotated^[Zc]^);
      dOfs:=Ofs(dstPic.Rotated^[Zc]^);
      FillChar(Mem[dSeg:dOfs],NewPicSize,0);
      Angle:=Zc*AngInc;
      Angle:=Angle+Phase;
      If Angle<0 Then Angle:=360+Angle;
      If Angle>359 Then Angle:=Angle-360;
      For Xc:=0 To NewPicX-1 Do Begin
        A:=Xc-mdX;
        For Yc:=0 To NewPicX { = NewPicY } -1 Do Begin
          B:=Yc-mdX { = mdY } ;
          NewX:=msX+Round(CosTable^[Angle]*A-SinTable^[Angle]*B);
          NewY:=msY+Round(CosTable^[Angle]*B+SinTable^[Angle]*A);
          If (NewX>=0) And (NewY>=0) And (NewX<XLen) And (NewY<YLen) Then
            Mem[dSeg:dOfs+Xc+NewPicX*Yc]:=Mem[sSeg:sOfs+NewX+XLen*NewY]
        End;
      End
    End
  End;

  Procedure ReleaseRotatedPic(Var dstPic : RPic);
  Var
    Xc : Byte;
  Begin
    If dstPic.Rotated=Nil Then Exit; { there is nothing to release... }
    For Xc:=0 To dstPic.Directions-1 Do
      FreeMem(dstPic.Rotated^[Xc], Sqr(dstPic.LenXY) );
    FreeMem( dstPic.Rotated, dstPic.Directions*SizeOf(Pointer) );
    dstPic.Rotated:=Nil
  End;

(********************************** General *********************************)

Procedure ShutGMS;
Begin
  DoneVga;
  PopTXTScr;
  DoneTaskList;
  DoneSinCosLookUpTable;
  DoneMap;
  DoneLight;
  DeInitFont
End;


(****************************************************************************)

FUNCTION VGACard : Boolean; ASSEMBLER;
ASM
  mov ah,$1a
  xor al,al
  int 10h
  cmp al,$1a
  jne @NoVGAdetected
  cmp bl,$08
  jne @NoVGAdetected
  mov al,true
  jmp @Exit
@NoVGAdetected:
  mov al,false
@Exit:
END;

{ Returns: TRUE if running under windows, (not DOS!) }
FUNCTION OSWindows : boolean;  Assembler;
ASM
  mov    ax,1600h
  int    2Fh
  cmp    al,1
  jbe    @@CheckRealStd
  cmp    al,80h
  jae    @@CheckRealStd
  mov    al,true
  jmp    @@ExitPoint
@@CheckRealStd:
  mov    ax,4680h
  int    2Fh
  or     ax,ax
  jnz    @@notWin
  mov    al,true
  jmp    @@ExitPoint
@@notWin:
  xor    al,al
@@ExitPoint:
END;

Begin
  SinTable:=Nil;
  CosTable:=Nil;
  TaskList:=Nil;
  TXTScr:=Nil;
  VirPage:=Nil;
  ExitSaveKey:=Nil;{====================> Keyboard stuff = Old ExitProc}
  Map:=Nil;
  Font:=Nil;
  SelectedSprite:=Nil;
  OldExitProc:=Nil;
  PXEFileTable.Table:=Nil;
  PXEFileTable.Table:=Nil;

  WriteLn('Powered by the GMS v',ver,' by');
  WriteLn;
  WriteLn('±≤€€€€≤±∞∞±≤€€€≤±∞±≤€€€€≤±∞±≤€≤±≤€≤±∞±≤€€€€≤±±≤€≤±∞∞∞±≤€€€≤±∞±≤€≤±≤€≤±±≤€€€€≤±∞');
  WriteLn('±≤€≤±≤€≤±±≤€≤±≤€≤±±≤€≤±≤€≤±±≤€≤±≤€≤±±≤€≤±∞   ±≤€≤±∞∞±≤€≤±≤€≤±±≤€≤±≤€≤±±≤€≤±≤€≤±');
  WriteLn('±≤€≤±≤€≤±±≤€€€€€≤±±≤€€€€≤±∞±≤€€€€≤±∞±≤€≤±∞  ˙±≤€≤±∞∞±≤€≤±≤€≤±±≤€≤±≤€≤±±≤€≤±≤€≤±');
  WriteLn('±≤€€€€≤±∞±≤€≤±≤€≤±±≤€≤±≤€≤±±≤€≤±≤€≤±∞±≤€€€€≤±±≤€€€€≤±±≤€€€≤±∞∞±≤€€€≤±∞±≤€€€€≤±∞');
  WriteLn;
  Write  ('Running under ');
  If OSWindows Then
    WriteLn('Windows.') Else Begin
    WriteLn('DOS.');
    {$IFDEF DPMI}
      Write('Protected');
    {$ELSE}
      Write('Real');
    {$ENDIF}
      WriteLn(' mode.')
  End;
  WriteLn('Free memory : ',MemAvail Shr 10,'KB');
  If VGACard Then WriteLn('VGA card detected.') Else Error('VGA card not detected, '#13#10+
                                                           'but must be present in order to run GMS.')
End.

                Visit us at

                http://www.geocities.com/SiliconValley/Vista/1595/
                dark-cloud@geocities.com








