{
  Programmed by dark-cloud, 1997
  url   ==>     http://www.geocities.com/SiliconValley/Vista/1595/
  email ==>     dark-cloud@geocities.com
}

Program Main;

{$D A great game by dark-cloud, powered by GMS, by dark-cloud.}

Uses GMS;

{$I Const     }
{$I Var       }
{$I TBoom     }
{$I TSmoke    }
{$I TScore    }
{$I TMouse    }
{$I TNikud    }
{$I TPower    }
{$I TMine     }
{$I TFire     }
{$I TJeep     }
{$I TKeys     }
{$I TMasheu   }
{$I TBCannon  }  { bad(evil) cannon}
{$I TJCannon  }

Type
  JeepGame = Object
    Constructor Init;
    Destructor Done;
    Procedure Play;
  End;

  Constructor JeepGame.Init;
  Begin
    Write('Installing GMS.......');
      InitTaskList;
      Randomize;
      InitSinCosLookUpTable;
      OpenPXEFile(PXEFileName);
    WriteLn('Done.');
    Write('Installing Font......'); InitFont(31,72,FontFile); WriteLn('Done.');
    Write('Loading graphics.....');
      LoadFile2Mem(Fire1FileName,Fire1Pic);
      LoadFile2Mem(Fire2FileName,Fire2Pic);
      LoadFile2Mem(MasheuFileName,MasheuPic);
      LoadCanonPic(JeepCannonPic, JeepCanonFileName);
      LoadCanonPic( BadCannonPic, BadCannonFileName);
      LoadFile2Mem( BCannonBaseFileName,BasePic);
      LoadFile2Mem(PowerFileName, PowerPic);
      LoadBoomPics(BoomFileName);
      LoadSmokePics(SmokeFileName);
      LoadFile2Mem(MineFileName, MinePic);
      NewMap(MapFileName);
    WriteLn('Done.');
    Write('Calculating light....'); InitLight(Pall); WriteLn('Done.');
    Write('Installing mouse.....'); InitMouse;       WriteLn('Done.');
    Write('Initalizing game.....');
      InsertKeys;
      InsertSprites(TaskList,ActiveList);
      InsertSprites(TaskList,SpriteList);
      TaskList^.AddObj(New(PJeepCanon,Init(10,50, 1   )));
      InsertNikud;
      InsertMouse;
      For Xc:=0 To 500 Do Begin
        InsertMine(Random(7500)+200,Random(7500)+200);
        InsertPower(Random(7500)+200,Random(7500)+200);
        InsertMasheu(Random(7500)+200,Random(7500)+200);
        InsertBCannon(Random(7500)+200,Random(7500)+200);
      End;
      ActiveList^.AddObj(New(PJeep,Init(900,900,0,5,0.05,0.025,0.05,0,JeepObj)));
    WriteLn('Done.');
    Write('Capturing keyboard...'); Capture_KeyBoard; WriteLn('Done.');
    WriteLn('Free memory : ',MemAvail Shr 10,'KB');
    FillPalType(0,0,0,BlackPal);
    WriteLn(#13,#10,'Press any key to continue.');
    Repeat Until KeyDown>0;
    PushTXTScr;
    Stepfade(0,255,10,63,BlackPal);
    InitVga;
    GetAllPal(CurrPal);
    GetAllPal(GrayPal);
    SetGrayPal(0,255,GrayPal);
    SetAllPal(Pall);
  End;

  Procedure JeepGame.Play;
  Begin
    Count:=0;
    T:=Tm;
    Repeat
      SelectedSprite:=Nil;
      TaskList^.Handle;
      WaitRetrace;
      ShowBitmap;
      Inc(Count);
    Until Finish;
    T:=Tm-T
  End;

  Destructor JeepGame.Done;
  Begin
    FillPalType(0,0,0,Pall);
    Stepfade(0,255,10,63,Pall);
    DoneMap;
    ShutGMS;
    ReleaseRotatedPic(JeepCannonPic);
    ReleaseRotatedPic(BadCannonPic);
    DoneFIle(Fire1Pic);
    DoneFIle(Fire2Pic);
    DoneFIle(MasheuPic);
    DoneFile(PowerPic);
    DoneFile(BoomPics);
    DoneFile(BoomPics);
    DoneFile(MinePic);
    DoneFile(BasePic);
    ClosePXEFile;

    Writeln;
    WriteLn('Playing data :');
    WriteLn('----------------');
    Writeln('  Seconds played  - ',(T/18.2) : 4 : 3);
    Writeln('  Time played     - ',trunc((T/18.2)/3600) : 2,':',trunc((T/18.2)/60) mod 60 : 2,':',round(T/18.2) mod 60: 2);
    WriteLn('  Frames  seen    - ',Count  : 4);
    WriteLn('  AVERAGE FPS     - ',Count*18.2/T : 4 : 3 );
    WriteLn;
    WriteLn('------------------------------------------------------------------');
    WriteLn('"dark-cloud" programming team.');
    WriteLn('URL   ==> http://www.geocities.com/SiliconValley/Vista/1595/');
    WriteLn('EMAIL ==> dark-cloud@geocities.com');
    WriteLn('------------------------------------------------------------------')
  End;


{
******************************************************************************
 Finally......


      The MAIN program !!!!!!!!!!!!
******************************************************************************
}


Var
  JG : JeepGame;

Begin
  JG.Init;
  JG.Play;
  JG.Done
End.

