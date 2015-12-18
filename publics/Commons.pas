unit Commons;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, StdCtrls,
  Controls;

type
  TByten = array of byte;

  TCommon = class(TObject)
  private
    procedure crcupdate(data: byte; var accum: byte);
    procedure SearchAllDir1(var FileList: TStringList; SearchDir: String);
  public
    function BoolToString(b: Boolean): String;
    function BufToHexStr(const buf: array of byte; len: word): string;
    function BufToLongWord(PB: PByte): LongWord;
    function Calcsum16(data: pchar; len: integer): word;
    function CreatMultDir(const SDir: string): Boolean;
    function GetFirstToken(var S: string; token: char): string;
    function GetNBit8(flag: byte; n: byte): byte;
    function GetToken(s: string; const delims: string): string;
    function Hrs_Min_Sec(Secs: Extended): string;
    procedure LongWordToBuf(LW: LongWord; PB: PByte);
    procedure ResetNBit8(var flag: byte; n: byte);
    procedure SaveFile(filename: string; buf: array of byte; Offset, Len:
      integer);
    procedure SetNBit8(var flag: byte; n: byte);
    function HexStrToByte(s: string): Byte;
    function ByteToHexStr(value: Byte): string;
    function CalcCRC16(p: pbyte; len: integer): word;
    function CalcCRC8(data: Pointer; len: integer): byte;
    function CalcCRCDnp(data: pointer; len: integer;f:boolean=true): word;
    function Calcsum8(data: pchar; len: integer): byte;
    function Calcxor(data: pchar; len: integer; aBase: byte): byte;
//
    function GetCrcValue(buff: Pointer; len: integer): word;
//  
//获取串口列表

    procedure EnumComPorts(Ports: TStrings);
    function GetBestNewFileName(xPath: string): string;
    function HexstrToASCII(s: string): string;
    function HexstrToBuf(s: string; var aBuf: TByten): Integer;
    function WordToHexStr(value: word): string;
    function HexStrToWord(s: string): word;
    function HexStrToLongWord(s: string): LongWord;
    function HexStrToInteger(s: string): Integer;
    procedure ImageListLoadFile(aImageList: TImageList; aFileName: string);
    function GettoValidIP(xIPStr: string): string;
    function ReverseByte(b : byte): byte;
    function ReverseWord(w: word): word;
    function ReverseLongWord(lw: LongWord): LongWord;
    function SetSystemDateTime(aDateTime: TDateTime): Boolean;
    function SetSystemDateTimeA(yyyy, mm, dd, hh, nn, ss, ms: word): Boolean;
    function LongWordToHexStr(value: LongWord): string;
    function IntegerToHexStr(value: Integer): string;
    function ReadPort(Port:WORD): BYTE;
    procedure SearchAllFile(var FileList: TStringList; SearchDir: String);
    class function Singleton: TCommon;
    procedure WritePort(Port:WORD;ConByte:BYTE);
    //2011.3.14
    function CalcCRC(data: Pointer; len: integer): byte;
    function CalcCRC_wwl(data: array of byte; beginnum: integer; len: integer): byte;
//    function CalcCRC16(data: Pointer; len: integer): word overload;
    function CalcCRC16ForPDA(data: Pointer; len: integer): word;
    function isnum(s: string): boolean;
    procedure SaveFile1(filename: string; buf: array of byte; Offset, Len: integer);
    procedure SearchAllDir(var FileList: TStringList; SearchDir: String);
    procedure SearchAllDirA(var FileList: TStringList; SearchDir: String);
  end;

implementation

var
  FCommon: TCommon;

  //用CCITT X16+X12+X5+1得到的CRC表
  CRC16Table: array[0..255] of word = (
    $0000, $1021, $2042, $3063, $4084, $50A5, $60C6, $70E7,
    $8108, $9129, $A14A, $B16B, $C18C, $D1AD, $E1CE, $F1EF,
    $1231, $0210, $3273, $2252, $52B5, $4294, $72F7, $62D6,
    $9339, $8318, $B37B, $A35A, $D3BD, $C39C, $F3FF, $E3DE,
    $2462, $3443, $0420, $1401, $64E6, $74C7, $44A4, $5485,
    $A56A, $B54B, $8528, $9509, $E5EE, $F5CF, $C5AC, $D58D,
    $3653, $2672, $1611, $0630, $76D7, $66F6, $5695, $46B4,
    $B75B, $A77A, $9719, $8738, $F7DF, $E7FE, $D79D, $C7BC,
    $48C4, $58E5, $6886, $78A7, $0840, $1861, $2802, $3823,
    $C9CC, $D9ED, $E98E, $F9AF, $8948, $9969, $A90A, $B92B,
    $5AF5, $4AD4, $7AB7, $6A96, $1A71, $0A50, $3A33, $2A12,
    $DBFD, $CBDC, $FBBF, $EB9E, $9B79, $8B58, $BB3B, $AB1A,
    $6CA6, $7C87, $4CE4, $5CC5, $2C22, $3C03, $0C60, $1C41,
    $EDAE, $FD8F, $CDEC, $DDCD, $AD2A, $BD0B, $8D68, $9D49,
    $7E97, $6EB6, $5ED5, $4EF4, $3E13, $2E32, $1E51, $0E70,
    $FF9F, $EFBE, $DFDD, $CFFC, $BF1B, $AF3A, $9F59, $8F78,
    $9188, $81A9, $B1CA, $A1EB, $D10C, $C12D, $F14E, $E16F,
    $1080, $00A1, $30C2, $20E3, $5004, $4025, $7046, $6067,
    $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
    $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
    $B5EA, $A5CB, $95A8, $8589, $F56E, $E54F, $D52C, $C50D,
    $34E2, $24C3, $14A0, $0481, $7466, $6447, $5424, $4405,
    $A7DB, $B7FA, $8799, $97B8, $E75F, $F77E, $C71D, $D73C,
    $26D3, $36F2, $0691, $16B0, $6657, $7676, $4615, $5634,
    $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
    $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
    $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
    $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
    $FD2E, $ED0F, $DD6C, $CD4D, $BDAA, $AD8B, $9DE8, $8DC9,
    $7C26, $6C07, $5C64, $4C45, $3CA2, $2C83, $1CE0, $0CC1,
    $EF1F, $FF3E, $CF5D, $DF7C, $AF9B, $BFBA, $8FD9, $9FF8,
    $6E17, $7E36, $4E55, $5E74, $2E93, $3EB2, $0ED1, $1EF0);

  //用 X8+X2+X+1计算得到的CRC表
  crc8Table: array[0..255] of byte = (
    $00, $07, $0E, $09, $1C, $1B, $12, $15,
    $38, $3F, $36, $31, $24, $23, $2A, $2D,
    $70, $77, $7E, $79, $6C, $6B, $62, $65,
    $48, $4F, $46, $41, $54, $53, $5A, $5D,
    $E0, $E7, $EE, $E9, $FC, $FB, $F2, $F5,
    $D8, $DF, $D6, $D1, $C4, $C3, $CA, $CD,
    $90, $97, $9E, $99, $8C, $8B, $82, $85,
    $A8, $AF, $A6, $A1, $B4, $B3, $BA, $BD,
    $C7, $C0, $C9, $CE, $DB, $DC, $D5, $D2,
    $FF, $F8, $F1, $F6, $E3, $E4, $ED, $EA,
    $B7, $B0, $B9, $BE, $AB, $AC, $A5, $A2,
    $8F, $88, $81, $86, $93, $94, $9D, $9A,
    $27, $20, $29, $2E, $3B, $3C, $35, $32,
    $1F, $18, $11, $16, $03, $04, $0D, $0A,
    $57, $50, $59, $5E, $4B, $4C, $45, $42,
    $6F, $68, $61, $66, $73, $74, $7D, $7A,
    $89, $8E, $87, $80, $95, $92, $9B, $9C,
    $B1, $B6, $BF, $B8, $AD, $AA, $A3, $A4,
    $F9, $FE, $F7, $F0, $E5, $E2, $EB, $EC,
    $C1, $C6, $CF, $C8, $DD, $DA, $D3, $D4,
    $69, $6E, $67, $60, $75, $72, $7B, $7C,
    $51, $56, $5F, $58, $4D, $4A, $43, $44,
    $19, $1E, $17, $10, $05, $02, $0B, $0C,
    $21, $26, $2F, $28, $3D, $3A, $33, $34,
    $4E, $49, $40, $47, $52, $55, $5C, $5B,
    $76, $71, $78, $7F, $6A, $6D, $64, $63,
    $3E, $39, $30, $37, $22, $25, $2C, $2B,
    $06, $01, $08, $0F, $1A, $1D, $14, $13,
    $AE, $A9, $A0, $A7, $B2, $B5, $BC, $BB,
    $96, $91, $98, $9F, $8A, $8D, $84, $83,
    $DE, $D9, $D0, $D7, $C2, $C5, $CC, $CB,
    $E6, $E1, $E8, $EF, $FA, $FD, $F4, $F3);

  crcDnpTable: array[0..511] of byte =
  (
    $00, $00, $5E, $36, $BC, $6C, $E2, $5A, $78, $D9, $26, $EF, $C4, $B5, $9A,
    $83, $89, $FF, $D7, $C9, $35, $93, $6B, $A5, $F1, $26, $AF, $10, $4D, $4A,
    $13, $7C, $6B, $B2, $35, $84, $D7, $DE, $89, $E8, $13, $6B, $4D, $5D, $AF,
    $07, $F1, $31, $E2, $4D, $BC, $7B, $5E, $21, $00, $17, $9A, $94, $C4, $A2,
    $26, $F8, $78, $CE, $AF, $29, $F1, $1F, $13, $45, $4D, $73, $D7, $F0, $89,
    $C6, $6B, $9C, $35, $AA, $26, $D6, $78, $E0, $9A, $BA, $C4, $8C, $5E, $0F,
    $00, $39, $E2, $63, $BC, $55, $C4, $9B, $9A, $AD, $78, $F7, $26, $C1, $BC,
    $42, $E2, $74, $00, $2E, $5E, $18, $4D, $64, $13, $52, $F1, $08, $AF, $3E,
    $35, $BD, $6B, $8B, $89, $D1, $D7, $E7, $5E, $53, $00, $65, $E2, $3F, $BC,
    $09, $26, $8A, $78, $BC, $9A, $E6, $C4, $D0, $D7, $AC, $89, $9A, $6B, $C0,
    $35, $F6, $AF, $75, $F1, $43, $13, $19, $4D, $2F, $35, $E1, $6B, $D7, $89,
    $8D, $D7, $BB, $4D, $38, $13, $0E, $F1, $54, $AF, $62, $BC, $1E, $E2, $28,
    $00, $72, $5E, $44, $C4, $C7, $9A, $F1, $78, $AB, $26, $9D, $F1, $7A, $AF,
    $4C, $4D, $16, $13, $20, $89, $A3, $D7, $95, $35, $CF, $6B, $F9, $78, $85,
    $26, $B3, $C4, $E9, $9A, $DF, $00, $5C, $5E, $6A, $BC, $30, $E2, $06, $9A,
    $C8, $C4, $FE, $26, $A4, $78, $92, $E2, $11, $BC, $27, $5E, $7D, $00, $4B,
    $13, $37, $4D, $01, $AF, $5B, $F1, $6D, $6B, $EE, $35, $D8, $D7, $82, $89,
    $B4, $BC, $A6, $E2, $90, $00, $CA, $5E, $FC, $C4, $7F, $9A, $49, $78, $13,
    $26, $25, $35, $59, $6B, $6F, $89, $35, $D7, $03, $4D, $80, $13, $B6, $F1,
    $EC, $AF, $DA, $D7, $14, $89, $22, $6B, $78, $35, $4E, $AF, $CD, $F1, $FB,
    $13, $A1, $4D, $97, $5E, $EB, $00, $DD, $E2, $87, $BC, $B1, $26, $32, $78,
    $04, $9A, $5E, $C4, $68, $13, $8F, $4D, $B9, $AF, $E3, $F1, $D5, $6B, $56,
    $35, $60, $D7, $3A, $89, $0C, $9A, $70, $C4, $46, $26, $1C, $78, $2A, $E2,
    $A9, $BC, $9F, $5E, $C5, $00, $F3, $78, $3D, $26, $0B, $C4, $51, $9A, $67,
    $00, $E4, $5E, $D2, $BC, $88, $E2, $BE, $F1, $C2, $AF, $F4, $4D, $AE, $13,
    $98, $89, $1B, $D7, $2D, $35, $77, $6B, $41, $E2, $F5, $BC, $C3, $5E, $99,
    $00, $AF, $9A, $2C, $C4, $1A, $26, $40, $78, $76, $6B, $0A, $35, $3C, $D7,
    $66, $89, $50, $13, $D3, $4D, $E5, $AF, $BF, $F1, $89, $89, $47, $D7, $71,
    $35, $2B, $6B, $1D, $F1, $9E, $AF, $A8, $4D, $F2, $13, $C4, $00, $B8, $5E,
    $8E, $BC, $D4, $E2, $E2, $78, $61, $26, $57, $C4, $0D, $9A, $3B, $4D, $DC,
    $13, $EA, $F1, $B0, $AF, $86, $35, $05, $6B, $33, $89, $69, $D7, $5F, $C4,
    $23, $9A, $15, $78, $4F, $26, $79, $BC, $FA, $E2, $CC, $00, $96, $5E, $A0,
    $26, $6E, $78, $58, $9A, $02, $C4, $34, $5E, $B7, $00, $81, $E2, $DB, $BC,
    $ED, $AF, $91, $F1, $A7, $13, $FD, $4D, $CB, $D7, $48, $89, $7E, $6B, $24,
    $35, $12
    );
//添加CRC检验 GYCZP 校验应用
    CRCtableHi: array[0..255] of byte = (
    $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81,
    $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0,
    $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01,
    $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41,
    $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81,
    $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0,
    $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $01,
    $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40,
    $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81,
    $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0,
    $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01,
    $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41,
    $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81,
    $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0,
    $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $01,
    $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
    $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81,
    $40);

    CRCtableLo: array[0..255] of byte = (
    $00, $C0, $C1, $01, $C3, $03, $02, $C2, $C6, $06, $07, $C7, $05, $C5, $C4,
    $04, $CC, $0C, $0D, $CD, $0F, $CF, $CE, $0E, $0A, $CA, $CB, $0B, $C9, $09,
    $08, $C8, $D8, $18, $19, $D9, $1B, $DB, $DA, $1A, $1E, $DE, $DF, $1F, $DD,
    $1D, $1C, $DC, $14, $D4, $D5, $15, $D7, $17, $16, $D6, $D2, $12, $13, $D3,
    $11, $D1, $D0, $10, $F0, $30, $31, $F1, $33, $F3, $F2, $32, $36, $F6, $F7,
    $37, $F5, $35, $34, $F4, $3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE, $FA, $3A,
    $3B, $FB, $39, $F9, $F8, $38, $28, $E8, $E9, $29, $EB, $2B, $2A, $EA, $EE,
    $2E, $2F, $EF, $2D, $ED, $EC, $2C, $E4, $24, $25, $E5, $27, $E7, $E6, $26,
    $22, $E2, $E3, $23, $E1, $21, $20, $E0, $A0, $60, $61, $A1, $63, $A3, $A2,
    $62, $66, $A6, $A7, $67, $A5, $65, $64, $A4, $6C, $AC, $AD, $6D, $AF, $6F,
    $6E, $AE, $AA, $6A, $6B, $AB, $69, $A9, $A8, $68, $78, $B8, $B9, $79, $BB,
    $7B, $7A, $BA, $BE, $7E, $7F, $BF, $7D, $BD, $BC, $7C, $B4, $74, $75, $B5,
    $77, $B7, $B6, $76, $72, $B2, $B3, $73, $B1, $71, $70, $B0, $50, $90, $91,
    $51, $93, $53, $52, $92, $96, $56, $57, $97, $55, $95, $94, $54, $9C, $5C,
    $5D, $9D, $5F, $9F, $9E, $5E, $5A, $9A, $9B, $5B, $99, $59, $58, $98, $88,
    $48, $49, $89, $4B, $8B, $8A, $4A, $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
    $44, $84, $85, $45, $87, $47, $46, $86, $82, $42, $43, $83, $41, $81, $80,
    $40);
    
function TCommon.BoolToString(b: Boolean): String;
begin
  if b then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

function TCommon.BufToLongWord(PB: PByte): LongWord;
var
  LW: LongWord;
begin
  LW := (PB^ shl 0);
  inc(PB);
  LW := LW or (PB^ shl 8);
  inc(PB);
  LW := LW or (PB^ shl 16);
  inc(PB);
  LW := LW or (PB^ shl 24);

  Result := LW;
end;

//16位校验和
function TCommon.Calcsum16(data: pchar; len: integer): word;
var
  i: integer;
  aSum: word;
begin
  aSum := 0;
  for i := 0 to len - 1 do
    aSum := word(aSum + byte(data[i]));
  Result := asum;
end;

function TCommon.CreatMultDir(const SDir: string): Boolean;
var
  i: integer;
  sCreateDir: string;
  OrgDir: string;
begin
  OrgDir := SDir;

  if copy(OrgDir, length(SDir), 1) <> '\' then
    OrgDir := OrgDir + '\';

  for i := 4 to length(OrgDir) do
  begin
    if copy(OrgDir, i, 1) = '\' then
    begin
      sCreateDir := copy(OrgDir, 1, i);
      if DirectoryExists(sCreateDir) = false then
        if CreateDir(sCreateDir) = false then
        begin
          result := false;
          exit;
        end;
    end;
  end;

  result := true;
end;

//ex s:='112=32'   s1:=getfirsttoken(s,'=')
//则 s1:='112',  s:='32',如token不在s中,返回空字符串
//例如：s := '2265 : 4, 0!'; token := ':'；时，返回结果：'2265'
function TCommon.GetFirstToken(var S: string; token: char): string;
var
  i, Size: Integer;
  S1: string;
begin
  i := Pos(token, S);
  if i = 0 then
  begin
    Result := '';
    Exit;
  end;
  SetLength(S1, i);
  Move(S[1], S1[1], i);
  SetLength(S1, i - 1);
  Size := (Length(S) - i);
  if Size > 0 then
    Move(S[i + 1], S[1], Size);
  SetLength(S, Size);
  s := trim(s);
  Result := trim(S1);
end;

//位数从0开始
//取一字节中 n 位的值

function TCommon.GetNBit8(flag: byte; n: byte): byte;
begin
  result := (flag shr n) and $01;
end;

function TCommon.BufToHexStr(const buf: array of byte; len: word): string;
var
  i: Integer;
  s: string;
  b: byte;
begin
  s := '';
  for i := 0 to len - 1 do
  begin
    b := buf[i];
    s := s + inttohex(b, 2) + ' ';
  end;

  Result := s;
end;

//得到由Delims分隔的符号
// ex s='300,'   delims=','  300
function TCommon.GetToken(s: string; const delims: string): string;
var
  i: integer;
begin
  result := '';
  s := Trim(s);
  for i := 1 to Length(s) do
  begin
    if pos(s[i], Delims) > 0 then
      break;
    result := result + s[i];
  end;
  result := trim(result);
end;

function TCommon.Hrs_Min_Sec(Secs: Extended): string;
const
  OneSecond = 1 / 24 / 3600;
var
  Total: Extended;
begin
  Total := Secs * OneSecond;
  Result := FormatDateTime('hh:nn:ss', Frac(total));
end;

procedure TCommon.LongWordToBuf(LW: LongWord; PB: PByte);
begin
  PB^ := byte((LW and ($FF shl 0)) shr 0);
  inc(PB);
  PB^ := byte((LW and ($FF shl 8)) shr 8);
  inc(PB);
  PB^ := byte((LW and ($FF shl 16)) shr 16);
  inc(PB);
  PB^ := byte((LW and ($FF shl 24)) shr 24);

end;

//位数是从0开始

procedure TCommon.ResetNBit8(var flag: byte; n: byte);
begin
  flag := byte(not ((not flag) or (1 shl n)));
end;

procedure TCommon.SaveFile(filename: string; buf: array of byte; Offset, Len:
  integer);
var
  f: file;
begin
  assignFile(f, filename);
  rewrite(f, 1);
  blockWrite(f, buf[Offset], Len);
  CloseFile(f);
end;

procedure TCommon.SetNBit8(var flag: byte; n: byte);
begin
  flag := byte(flag or (1 shl n));
end;

function TCommon.HexStrToByte(s: string): Byte;
var
  str: string;
begin
  str := trim(s);
  if (Length(str) > 0) and (Length(str) <= 2) then
  begin
    Result := byte(StrToIntDef('$' + str, 0));
  end
  else
  begin
    Result := 0;
  end;
end;

function TCommon.ByteToHexStr(value: Byte): string;
begin
  Result := IntToHex(value, 2);
end;

function TCommon.CalcCRC16(p: pbyte; len: integer): word;
var
  i: Integer;
  e: pbyte;
  Buf: byte;
begin
  Result := 0;
  e := p;
  for i := 0 to len - 1 do
  begin
    buf := e^;
    inc(e);
    Result := Hi(Result) xor CRC16Table[Buf xor Lo(Result)];
  end;
end;

function TCommon.CalcCRC8(data: Pointer; len: integer): byte;
var
  i: integer;
begin
  result := 0;
  for i := 0 to len - 1 do
    crcupdate(pbytearray(data)[i], result);
  result := not result;
end;

{$R-}
var
  DnpArryTab: array[0..255] of byte;

procedure DnpMakeBttab;

  function mybtbitchang(b: byte): byte; overload; //交换字节的位
  var
    xorbyte: byte;
    tmpbit: array[0..7] of byte;
    loop: integer;
  begin
    xorbyte := 1;
    for loop := 0 to 7 do
      begin
        tmpbit[loop] := (b and xorbyte) shr loop;
        xorbyte := xorbyte shl 1;
      end;
    xorbyte := 0;
    for loop := 0 to 6 do
      begin
        if tmpbit[loop] <> 0 then xorbyte := xorbyte or 1;
        xorbyte := xorbyte shl 1;
      end;
    if tmpbit[7] <> 0 then xorbyte := xorbyte or 1;
    result := xorbyte;
  end;
var
  loop: integer;
begin
  for loop := 0 to 255 do
    DnpArryTab[loop] := mybtbitchang(loop);
end;

function TCommon.CalcCRCDnp(data: pointer; len: integer;f:boolean=true): word;
var
  byte1, byte2, crchi, crclo: byte;
  index, loop: integer;
  sc: pchar;
begin
  sc := data;
  crchi := 0;
  crclo := 0;
  byte1 := byte(sc^);
  byte1 := DnpArryTab[byte1];
  byte2 := 0;
  inc(sc);
  for loop := 1 to len do
    begin
      if loop = len then
        byte2 := 0
      else
        begin
          byte2 := byte(sc^);
          inc(sc);
          byte2 := DnpArryTab[byte2];
        end;
      crchi := DnpArryTab[crchi xor byte1];
      byte1 := crclo xor byte2;
      index := crchi * 2;
      crchi := DnpArryTab[crcDnpTable[index]];
      crclo := DnpArryTab[crcDnpTable[index + 1]];
    end;
  crclo:= not DnpArryTab[crclo xor byte2];
  crchi:= not DnpArryTab[crchi xor byte1];
  if f then
  result:=crchi shl 8 +crclo
  else result:=crclo shl 8+crchi;
end;
{$R+}

//8位校验和
function TCommon.Calcsum8(data: pchar; len: integer): byte;
var
  i: integer;
  aSum: byte;
begin
  aSum := 0;
  for i := 0 to len - 1 do
    aSum := byte(aSum + byte(data[i]));
  Result := asum;
end;

//16位XOR
function TCommon.Calcxor(data: pchar; len: integer; aBase: byte): byte;
var
  i: integer;
begin
  result := 0;
  if len > 0 then
    result := aBase xor byte(data[0]);
  for i := 1 to len - 1 do
  begin
    result := result xor byte(data[i]);
  end;
end;

procedure TCommon.crcupdate(data: byte; var accum: byte);
begin
  accum := crc8Table[accum xor data];
end;

{*********************************
函数功能：生成CRC效验值
参数1：需要生成CRC效验值的buf
参数2：参与CRC效验的个数
返回值：双字节的整型值
*********************************}
function TCommon.GetCrcValue(buff: Pointer; len: integer): word;
var
  crcbyteHi: byte;
  crcbyteLo: byte;
  uIndex: integer;
  i: integer;
begin
  crcbyteHi := $FF;
  crcbyteLo := $FF;
  for i := 0 to len - 1 do
  begin
    uIndex := crcbyteHi xor (pbytearray(buff)[i]);
    crcbyteHi := crcbyteLo xor CRCtableHi[uIndex];///CRCtableHi为高位的效验表
    crcbyteLo := CRCtableLo[uIndex];///CRCtableLo为低位的效验表
  end;
  Result := ((crcbyteLo shl 8) + crcbyteHi);
end;

//获取串口列表

procedure TCommon.EnumComPorts(Ports: TStrings);
var
  KeyHandle: HKEY;
  ErrCode, Index: Integer;
  ValueName, Data: string;
  ValueLen, DataLen, ValueType: DWORD;
  TmpPorts: TStringList;
  i: Integer;
begin
  ErrCode := RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\SERIALCOMM',
    0,
    KEY_READ, KeyHandle);

  if ErrCode <> ERROR_SUCCESS then
    raise Exception.Create('打开串口列表的注册表项出错');

  TmpPorts := TStringList.Create;
  try
    Index := 0;
    repeat
      ValueLen := 256;
      DataLen := 256;
      SetLength(ValueName, ValueLen);
      SetLength(Data, DataLen);
      ErrCode := RegEnumValue(KeyHandle, Index, PChar(ValueName),
        Cardinal(ValueLen), nil, @ValueType, PByte(PChar(Data)), @DataLen);

      if ErrCode = ERROR_SUCCESS then
      begin
        SetLength(Data, DataLen);
        TmpPorts.Add(Data);
        Inc(Index);
      end
      else if ErrCode <> ERROR_NO_MORE_ITEMS then
        raise Exception.Create('打开串口列表的注册表项出错');

    until (ErrCode <> ERROR_SUCCESS);

    TmpPorts.Sort;

    Ports.Clear();
    for i := 0 to TmpPorts.Count - 1 do
    begin
      if Ports.IndexOf(TmpPorts[i]) < 0 then
        Ports.Add(TmpPorts[i]);
    end;
//  Ports.Assign(TmpPorts);
  finally
    RegCloseKey(KeyHandle);
    TmpPorts.Free;
  end;
end;

{$WARNINGS OFF}
function TCommon.GetBestNewFileName(xPath: string): string;
var
  BestNewFileName: string;
  Found: Integer;
  SearchRec: TSearchRec;
  BestNew: TFiletime;
  d: TFiletime;
begin
  BestNewFileName := '';
  Found := FindFirst(xPath + '\*.*', faAnyFile, SearchRec);
  try
    if Found=0 then
    begin
      BestNew := SearchRec.FindData.ftLastWriteTime;
      BestNewFileName := SearchRec.Name;
      Found := FindNext(SearchRec);
    end;
    while Found = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        d := SearchRec.FindData.ftLastWriteTime;
        if CompareFileTime(d, BestNew) > 0 then
        begin
          BestNew := d;
          BestNewFileName := SearchRec.Name;
        end;
      end;
      Found := FindNext(SearchRec);
    end
  finally
    FindClose(SearchRec);
  end;
  Result := BestNewFileName;
end;
{$WARNINGS ON}

function TCommon.HexstrToASCII(s: string): string;
var
  slen: integer;
  b: byte;
  i: integer;
  str: string;
  rs: string;
begin
  Result := '';

  str := '';
  for i := 1 to length(s) do
  begin
    if s[i] in ['1' , '2', '3', '4', '5', '6', '7', '8', '9', '0'
      , 'a', 'b', 'c', 'd', 'e', 'f'
      , 'A', 'B', 'C', 'D', 'E', 'F']
    then
      str := str + s[i];
  end;

  slen := length(str);
  if (slen mod 2) <> 0 then
    exit;

  rs := '';
  i := 1;
  while i < slen do
  begin
    try
      b := StrToInt('$'+copy(str,i,2));
      rs := rs + char(b);
    except
      exit;
    end;
    inc(i, 2);
  end;

  Result := rs;
end;

function TCommon.HexstrToBuf(s: string; var aBuf: TByten): Integer;
var
  slen: integer;
  b: byte;
  i: integer;
  aIndex: integer;
  str: string;
begin
  Result := -1;

  str := '';
  for i := 1 to length(s) do
  begin
    if s[i] in ['1' , '2', '3', '4', '5', '6', '7', '8', '9', '0'
      , 'a', 'b', 'c', 'd', 'e', 'f'
      , 'A', 'B', 'C', 'D', 'E', 'F']
    then
      str := str + s[i];
  end;

  slen := length(str);
  if (slen mod 2) <> 0 then
    exit;

  setLength(aBuf, slen div 2);
  i := 1;
  aIndex := 0;
  while i < slen do
  begin
    try
      b := StrToInt('$'+copy(str,i,2));
      inc(i, 2);

      aBuf[aIndex] := b;
      inc(aIndex);
    except
      exit;
    end;
  end;

  Result := slen div 2;
end;

function TCommon.ReverseByte(b : byte): byte;
var
  i : integer;
  a : byte;
begin
  a := 0;
  for i := 0 to 7 do
  begin
    a := a or (((b shr i) and 1) shl (7 - i));
  end;
  result := a;
end;

function TCommon.WordToHexStr(value: word): string;
begin
  Result := IntToHex(value, 1);
end;

function TCommon.HexStrToWord(s: string): word;
var
  str: string;
begin
  str := trim(s);
  if (Length(str) > 0) and (Length(str) <= 4) then
  begin
    Result := word(StrToIntDef('$' + str, 0));
  end
  else
  begin
    Result := 0;
  end;
end;

function TCommon.HexStrToLongWord(s: string): LongWord;
var
  str: string;
begin
  str := trim(s);
  if (Length(str) > 0) and (Length(str) <= 8) then
  begin
    Result := LongWord(StrToIntDef('$' + str, 0));
  end
  else
  begin
    Result := 0;
  end;
end;

function TCommon.HexStrToInteger(s: string): Integer;
var
  str: string;
begin
  str := trim(s);
  if (Length(str) > 0) and (Length(str) <= 8) then
  begin
    Result := Integer(StrToIntDef('$' + str, 0));
  end
  else
  begin
    Result := 0;
  end;
end;

procedure TCommon.ImageListLoadFile(aImageList: TImageList; aFileName: string);
var
  Picture: TPicture;
  I, X, Y: Integer;
  IWidth, IHeight: Integer;
  NewBitmap: TBitmap;
  SubDivideX, SubDivideY: Boolean;
  DivideX, DivideY: Integer;
begin
  if not FileExists(aFileName) then
    exit;

  Picture := TPicture.Create;
  Picture.LoadFromFile(aFileName);
  NewBitmap := TBitmap.Create;

  try
    IWidth := aImageList.Width;
    IHeight := aImageList.Height;

    SubDivideX := (Picture.Graphic.Width > IWidth) and
      (Picture.Graphic.Width mod IWidth = 0);
    SubDivideY := (Picture.Graphic.Height > IHeight) and
      (Picture.Graphic.Height mod IHeight = 0);
    if SubDivideX then
      DivideX := Picture.Graphic.Width div IWidth
    else
      DivideX := 1;
    if SubDivideY then
      DivideY := Picture.Graphic.Height div IHeight
    else
      DivideY := 1;

    I := 0;
    for Y := 0 to DivideY - 1 do
      for X := 0 to DivideX - 1 do
      begin
        NewBitmap.Assign(nil);
        NewBitmap.Height := IHeight;
        NewBitmap.Width := IWidth;
        NewBitmap.Canvas.CopyRect(Rect(0, 0, NewBitmap.Width,
          NewBitmap.Height), Picture.Bitmap.Canvas,
          Rect(X * IWidth, Y * IHeight, (X + 1) * IWidth,
          (Y + 1) * IHeight));
        aImageList.Add(NewBitmap, nil);
        aImageList.ReplaceMasked(I, NewBitmap, clFuchsia);
        Inc(I);
      end;
  finally
    Picture.Free;
    NewBitmap.Free;
  end;
end;

function TCommon.GettoValidIP(xIPStr: string): string;
const
  iplen = 15;
var
  i: integer;
  s: string;
  sl: TStrings;
  strIP: string;
  bt: byte;
begin
  result := '';
  s := trim(xIPStr);
  if s = '' then
    exit;
  if Length(s) > ipLen then
    exit;

  strIP := '';
  sl := TStringList.Create();
  try
    sl.Delimiter := '.';
    sl.DelimitedText := s;
    if sl.Count <> 4 then
      exit;
    for i := 0 to sl.Count - 1 do
    begin
      s := sl.Strings[i];
      try
        bt := strToInt(s);
        strIP := strIP + inttostr(bt) + '.';
      except
        exit;
      end;
    end;
    Delete(strIP, Length(strIP), 1);
    Result := strIP;
  finally
    sl.Free();
  end;
end;

function TCommon.ReverseWord(w: word): word;
var
  i : integer;
  a : byte;
begin
  a := 0;
  for i := 0 to 15 do
  begin
    a := a or (((w shr i) and 1) shl (15 - i));
  end;
  result := a;
end;

function TCommon.ReverseLongWord(lw: LongWord): LongWord;
var
  i : integer;
  a : byte;
begin
  a := 0;
  for i := 0 to 31 do
  begin
    a := a or (((lw shr i) and 1) shl (31 - i));
  end;
  result := a;
end;

function TCommon.SetSystemDateTime(aDateTime: TDateTime): Boolean;
var
  dt: TSYSTEMTIME;
  yyyy, mm, dd, hh, _hh, nn, ss, ms: word;
begin
  DeCodeDate(aDateTime, yyyy, mm, dd);
  DeCodeTime(aDateTime, hh, nn, ss, ms);
  if hh < 8 then
    _hh := 16 + hh
  else
    _hh := hh - 8;

  dt.wYear := yyyy;
  dt.wMonth := mm;
  dt.wDay := dd;
  dt.wHour := _hh;
  dt.wMinute := nn;
  dt.wSecond := ss;
  dt.wMilliseconds := ms;

  try
    setSystemTime(dt);

    Result := true;
  except
    Result := false;
  end;
end;

function TCommon.SetSystemDateTimeA(yyyy, mm, dd, hh, nn, ss, ms: word):
    Boolean;
var
  dt: TSYSTEMTIME;
  _hh: word;
begin
  if hh < 8 then
    _hh := 16 + hh
  else
    _hh := hh - 8;

  dt.wYear := yyyy;
  dt.wMonth := mm;
  dt.wDay := dd;
  dt.wHour := _hh;
  dt.wMinute := nn;
  dt.wSecond := ss;
  dt.wMilliseconds := ms;

  try
    setSystemTime(dt);

    Result := true;
  except
    Result := false;
  end;
end;

function TCommon.LongWordToHexStr(value: LongWord): string;
begin
  Result := IntToHex(value, 1);
end;

function TCommon.IntegerToHexStr(value: Integer): string;
begin
  Result := IntToHex(value, 1);
end;

function TCommon.ReadPort(Port:WORD): BYTE;
var
  B:BYTE;
begin
  ASM
    MOV DX, Port;
    IN AL, DX;
    MOV B, AL;
  END;
  Result:=B;
end;

procedure TCommon.SearchAllFile(var FileList: TStringList; SearchDir: String);
var
 Found: Integer; 
 SearchResult: TSearchRec; 
 FDir: String;
begin
  {$WARNINGS OFF}
 if FileGetAttr(SearchDir) <> faDirectory then
 begin
   FileList.Add(SearchDir);
   Exit;
 end;
  {$WARNINGS ON}

 Found := FindFirst(SearchDir + '\*.*', faAnyFile, SearchResult);
 while Found = 0 do
 begin
   if (SearchResult.Name <> '.' )and(SearchResult.Name <> '..') then
   begin
     FDir := SearchDir + '\' + SearchResult.Name;
     SearchAllFile(FileList, FDir);
   end;
   Found := FindNext(SearchResult);
 end;

 if (SearchResult.Name <> '.')and(SearchResult.Name <> '..') then
   FindClose(SearchResult);
end;

//2011.3.14 add new code(新代码)
function TCommon.CalcCRC(data: Pointer; len: integer): byte;
var
  i: integer;
begin
  result := 0;
  for i := 0 to len - 1 do
    crcupdate(pbytearray(data)[i], result);
  result := not result;
end;

function TCommon.CalcCRC_wwl(data: array of byte; beginnum: integer; len: integer): byte;
var
  i: integer;
begin
  result := 0;
  for i := 0 to len - 1 do
    crcupdate(data[i + beginnum], result);
  result := not result;
end;

//function TCommon.CalcCRC16(data: Pointer; len: integer): word;
//var
//  p: ^byte;
//  i: integer;
//begin
//  result := 0;
//  p := data;
//  if p <> nil then
//    for i := 0 to len - 1 do
//    begin
//      result := (result shl 8) xor CRC16Table[(result shr 8) xor p^];
//      inc(p);
//    end;
//  result := not result;
//end;

function TCommon.CalcCRC16ForPDA(data: Pointer; len: integer): word;
var
  p: ^byte;
  i: integer;
begin
  result := 0;
  p := data;
  if p <> nil then
    for i := 0 to len - 1 do
    begin
      result := word((result shl 8) xor CRC16Table[(result shr 8) xor p^]);
      inc(p);
    end;
  result := word(not result);
end;

function TCommon.isnum(s: string): boolean;
var
  i: integer;
begin
  if trim(s) = '' then
  begin
    result := false;
    exit;
  end;

  for i := 1 to Length(s) do
  begin
    if pos(s[i], '0123456789') = 0 then
    begin
      result := false;
      Exit;
    end;
  end;
  result := true;
end;

procedure TCommon.SaveFile1(filename: string; buf: array of byte; Offset, Len:
    integer);
var
  f: file;
begin
  assignFile(f, filename);
  rewrite(f, 1);
  blockWrite(f, buf[Offset], Len);
  CloseFile(f);
end;

procedure TCommon.SearchAllDir(var FileList: TStringList; SearchDir: String);
var
  i: Integer;
  s: string;
begin
  SearchAllDir1(FileList, SearchDir);
  for i := FileList.Count - 1 downto 0 do
  begin
    s := FileList[i];
    if FileGetAttr(s) <> faDirectory then
    begin
      FileList.Delete(i);
    end;
  end;

end;

procedure TCommon.SearchAllDir1(var FileList: TStringList; SearchDir: String);
var
 Found: Integer; 
 SearchResult: TSearchRec; 
 FDir: String;
begin
  {$WARNINGS OFF}
   FileList.Add(SearchDir);
// if FileGetAttr(SearchDir) <> faDirectory then
// begin
//   Exit;
// end;
  {$WARNINGS ON}

 Found := FindFirst(SearchDir + '\*.*', faAnyFile, SearchResult);
 while Found = 0 do
 begin
   if (SearchResult.Name <> '.' )and(SearchResult.Name <> '..') then
   begin
     FDir := SearchDir + '\' + SearchResult.Name;
     SearchAllDir1(FileList, FDir);
   end;
   Found := FindNext(SearchResult);
 end;

 if (SearchResult.Name <> '.')and(SearchResult.Name <> '..') then
   FindClose(SearchResult);
end;

procedure TCommon.SearchAllDirA(var FileList: TStringList; SearchDir: String);
var
 Found: Integer; 
 SearchResult: TSearchRec; 
 FDir: String;
begin
 Found := FindFirst(SearchDir + '\*.*', faAnyFile, SearchResult);
 while Found = 0 do
 begin
   if (FileGetAttr(SearchResult.Name) = faDirectory) then
   begin
     FileList.Add(SearchResult.Name);
//     FileList.Add(SearchDir + '\' + SearchResult.Name);
   end;
   Found := FindNext(SearchResult);
 end;
end;

//end

class function TCommon.Singleton: TCommon;
begin
  if FCommon = nil then
    FCommon := TCommon.Create;
  Result := FCommon;
end;

procedure TCommon.WritePort(Port:WORD;ConByte:BYTE);
begin
  ASM
    MOV DX, Port;
    MOV AL, ConByte;
    OUT DX, AL;
  END;
end;

initialization
{$R-}
  DnpMakeBttab();
{$R+}

finalization
  if FCommon <> nil then
  begin
    FCommon.Free();
    FCommon := nil;
  end;

end.


