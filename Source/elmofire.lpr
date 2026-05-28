library elmofire;

{$mode objfpc}{$H+}

uses cmem, // СТРОГО ПЕРВЫМ!
  SysUtils,
  RunFormula in 'RunFormula/runformula.pas';

{$B-}                           // do not complete boolean evaluation
{$POINTERMATH ON}               // allow use of pointer math
{$R-}                           // switch off range checking
{$Q-}                           // switch off overflow checking
{$T-}                           // untyped address operator
{$inline on}

type
  TDataRec = packed record
    DataType: Integer;         // 4 bytes ctypes.c_int
    AsSizeInt: Int64;          // 8 bytes ctypes.c_int64
    AsDouble: Double;          // 8 bytes ctypes.c_double
    AsPChar: PAnsiChar;        // 8 bytes ctypes.c_char_p
  end;

  PDataRec = ^TDataRec;

function CnvArg(Prm:PChar; out FlaOffs:integer; out Err:boolean):string;
const Spr = #$1F;
var fq : PChar = nil;
    lprm : PChar = nil;
    acnt : integer = 1;
    L : SizeInt;
    lq, p, d : PChar;
    c : char;
begin
  Err:=true;
  p:=Prm;
  L:=StrLen(p);
  if L=0 then Exit('no parameters');
  SetLength(Result, L);
  d:=PChar(Result);
  repeat
    c:=p^;
    case c of
      #0, Spr : begin
                  if (acnt and 1)<>0 then begin
                    if fq=nil then Exit('invalid type of parameter '+IntToStr(acnt));
                    fq^:=#$20;
                    lq^:=#$20;
                  end;
                  if c=#0 then break;
                  if (acnt and 1)=0 then c:=',' else c:='=';
                  fq:=nil;
                  lprm:=p;
                  inc(acnt);
                end;
      '"'     : begin
                  if fq=nil then fq:=d;
                  lq:=d;
                end;
      ','     : if ((acnt and 1)=0) and (fq=nil) then c:='.';
    end;
    d^:=c;
    inc(d);
    inc(p);
  until false;
  if (acnt and 1)=0 then Exit('number of parameters must be odd');
  FlaOffs:=-1;
  if lprm<>nil then FlaOffs:=lprm-Prm;
  Err:=false;
end;

procedure RetString(S:string; P:PDataRec);
var L : SizeInt;
begin
  L:=length(S)+1;
  P^.AsPChar:=GetMem(L);
  move(PByte(S), P^.AsPChar, L);
  P^.DataType:=3;
end;

function elmo_str_py(Ptr:PChar; DataRec:PDataRec):integer; cdecl; export;
var fla : string;
    ofs : integer;
    err : boolean;
begin
  DataRec^.DataType:=0;
  Result:=0;
  fla:=CnvArg(Ptr, ofs, err);
  if err then begin
    RetString(fla, DataRec);
    exit;
  end;

  RetString(fla, DataRec);
end;

function elmo_val_py(Ptr:PChar; ResStruct:PDataRec):integer; cdecl; export;
var s : string;
                          tt : pointer;
  StrLen: Integer;


begin
  Result := 0;

  ResStruct^.DataType:=0;
  if Ptr=nil then exit;
  s:=SysUtils.StrPas(Ptr); // s может оказаться пустой      Result^.Value.AsPChar := StrNew(PChar(s));

  s := 'Lazarus получил:' + s;

//  s:=#$d0+#$bc+#$d0+#$b0+#$d0+#$bc+#$d0+#$b0;

  s:='0123456789'+s;

  StrLen := Length(s) + 1;
  ResStruct^.AsPChar := GetMem(StrLen);

  tt:=@s[1];

  Move(tt, ResStruct^.AsPChar, StrLen);
  ResStruct^.DataType := 3;


end;

function elmo_free_str(Ptr:PChar):integer; cdecl; export;
begin
  FreeMem(Ptr);
  Result:=0;
end;

exports
  elmo_str_py,
  elmo_val_py,
  elmo_free_str;

begin
  IsMultiThread:=true;
end.
