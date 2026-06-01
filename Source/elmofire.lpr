//*****************************************************
//  ElmoFire LibreOffice Add-In
//  Version 0.1.a
//  Rev. 1.05.2026

//  Author: Alexander Torubarov
//  Contact: runfla@yandex.com

//  Filename: elmofire.lpr
//  Source Code: Object Pascal / FreePascal
//  Compatible: Lazarus 4.2 x64 win10

//  Copyright (C) 2026 Alexander Torubarov
//  Licensed under the MIT License.
//  See the LICENSE file in the project root
//  or a copy available at https://opensource.org
//  for full license information.
//*****************************************************

// TODO -oElmo -cRev.2026.06.01:

library elmofire;

{$mode objfpc}{$H+}

uses cmem,          // must be first
  SysUtils, Math,
  RunFormula in 'RunFormula/runformula.pas';

{$B-}                           // do not complete boolean evaluation
{$POINTERMATH ON}               // allow use of pointer math
{$R-}                           // switch off range checking
{$Q-}                           // switch off overflow checking
{$T-}                           // untyped address operator
{$inline on}

const
  SI = SizeOf(SizeInt);
  ArgSpr = #$1F;
  ElmoErr = 'ElmoFire Add-In ERROR';

type
  TDataRec = packed record
    DataType  : Integer;          // 4 bytes ctypes.c_int
    AsSizeInt : Int64;            // 8 bytes ctypes.c_int64
    AsDouble  : Double;           // 8 bytes ctypes.c_double
    AsPChar   : PAnsiChar;        // 8 bytes ctypes.c_char_p
  end;

  PDataRec = ^TDataRec;

procedure CopyMem(Src, Dst:PByte; Lng:SizeInt);        //DONE -oElmo -cRev.2026.05.29: Proc CopyMem
var fin : PByte;
begin
  fin:=Src+Lng-SI;
  while Src<=fin do begin
    PSizeInt(Dst)^:=PSizeInt(Src)^;
    inc(Dst, SI);
    inc(Src, SI);
  end;
  inc(fin, SI);
  while Src<fin do begin
    Dst^:=Src^;
    inc(Dst);
    inc(Src);
  end;
end;

procedure RetStr(constref S:string; P:PDataRec);       //DONE -oElmo -cRev.2026.05.29: Proc RetStr
var ansi : PSizeInt;
    L : SizeInt;
begin
  ansi:=PSizeInt(S);
  if ansi=nil then exit;
  L:=ansi[-1]+1;
  with P^ do begin
    AsPChar:=GetMem(L);
    if AsPChar=nil then exit;
    CopyMem(PByte(ansi), PByte(AsPChar), L);
    DataType:=3;
  end;
end;

function CnvArg(Arg:PChar; out FlaOffs:integer; out Err:boolean):string;
var fq : PChar = nil;                                  //DONE -oElmo -cRev.2026.05.29: Func CnvArg
    larg : PChar = nil;
    acnt : integer = 1;
    L : SizeInt;
    lq, p, d : PChar;
    c : char;
begin
  Err:=true;
  p:=Arg;
  L:=StrLen(p);
  if L=0 then Exit('No parameters');
  SetLength(Result, L);
  d:=PChar(Result);
  repeat
    c:=p^;
    case c of
      #0, ArgSpr : begin
                     if (acnt and 1)<>0 then begin
                       if fq=nil then Exit('Parameter '+IntToStr(acnt)+' must be string');
                       fq^:=#$20;
                       lq^:=#$20;
                     end;
                     if c=#0 then break;
                     if (acnt and 1)=0 then c:=',' else c:='=';
                     fq:=nil;
                     larg:=p;
                     inc(acnt);
                   end;
      '"'        : begin
                     if fq=nil then fq:=d;
                     lq:=d;
                   end;
    end;
    d^:=c;
    inc(d);
    inc(p);
  until false;
  if (acnt and 1)=0 then Exit('Number of parameters must be odd');
  FlaOffs:=0;
  if larg<>nil then FlaOffs:=larg-Arg+1;
  Err:=false;
end;

function elmo_str_py(Ptr:PChar; DataRec:PDataRec):integer; cdecl; export;
var err  : TRunFlaError;                               //DONE -oElmo -cRev.2026.05.29: Func elmo_str_py
    mask : TFPUExceptionMask;
    fla  : string;
    ofs  : integer;
    flg  : boolean;
begin
  Result:=0;
  DataRec^.DataType:=0;
  fla:=CnvArg(Ptr, ofs, flg);
  if flg then begin
    RetStr(ElmoErr+': '+fla, DataRec);
    exit;
  end;
  mask:=SetExceptionMask([exDenormalized, exUnderflow, exPrecision]);
  fla:=RunFlaExecStr(RunFlaParse(fla, err), err);
  SetExceptionMask(mask);
  with err do if Code<>OK then begin
    fla:=ElmoErr+' at formula position '+IntToStr(Position-ofs)+': '+RunFlaErrorMsg[Code].ErrMsg;
    // if length(Value)>0 then fla:=fla+' (inf "'+Value+'")';
  end;
  RetStr(fla, DataRec);
end;

function elmo_val_py(Ptr:PChar; DataRec:PDataRec):integer; cdecl; export;
var err  : TRunFlaError;                               //DONE -oElmo -cRev.2026.05.29: Func elmo_val_py
    mask : TFPUExceptionMask;
    fla  : string;
    vrt  : Variant;
    ofs  : integer;
    flg  : boolean;
begin
  Result:=0;
  DataRec^.DataType:=0;
  fla:=CnvArg(Ptr, ofs, flg);
  if flg then begin
    RetStr(ElmoErr+': '+fla, DataRec);
    exit;
  end;
  mask:=SetExceptionMask([exDenormalized, exUnderflow, exPrecision]);
  vrt:=RunFlaExecVrt(RunFlaParse(fla, err), err);
  SetExceptionMask(mask);
  with err do if Code<>OK then begin
    fla:=ElmoErr+' at formula position '+IntToStr(Position-ofs)+': '+RunFlaErrorMsg[Code].ErrMsg;
    // if length(Value)>0 then fla:=fla+' (inf "'+Value+'")';
    RetStr(fla, DataRec);
  end;
  with DataRec^ do case PVarData(@vrt)^.vtype of
    varDouble : begin
                  AsDouble:=PVarData(@vrt)^.vdouble;
                  DataType:=2;
                end;
    varByte   : begin
                  AsSizeInt:=PVarData(@vrt)^.vbyte;
                  DataType:=1;
                end;
    varInt64  : begin
                  AsSizeInt:=PVarData(@vrt)^.vint64;
                  DataType:=1;
                end;
    varString : RetStr(string(PVarData(@vrt)^.vstring), DataRec);
  end;
end;

function elmo_free_py(Ptr:PChar):integer; cdecl; export;       //DONE -oElmo -cRev.2026.06.01: Func elmo_free_py
begin
  FreeMem(Ptr);
  Result:=0;
end;

function elmo_str_vba(Ptr:PChar; DataRec:PDataRec):integer; stdcall; export;
begin                                                          //DONE -oElmo -cRev.2026.06.01: Func elmo_str_vba
  Result:=elmo_str_py(Ptr, DataRec);
end;

function elmo_val_vba(Ptr:PChar; DataRec:PDataRec):integer; stdcall; export;
begin                                                          //DONE -oElmo -cRev.2026.06.01: Func elmo_val_vba
  Result:=elmo_val_py(Ptr, DataRec);
end;

function elmo_free_vba(Ptr:PChar):integer; stdcall; export;    //DONE -oElmo -cRev.2026.06.01: Func elmo_free_vba
begin
  Result:=elmo_free_py(Ptr);
end;

exports
  elmo_str_py name 'elmo_str_py',
  elmo_val_py name 'elmo_val_py',
  elmo_free_py name 'elmo_free_py',
  elmo_str_vba name 'elmo_str_vba',
  elmo_val_vba name 'elmo_val_vba',
  elmo_free_vba name 'elmo_free_vba';

begin
  ReturnNilIfGrowHeapFails:=true;
  IsMultiThread:=true;
end.
