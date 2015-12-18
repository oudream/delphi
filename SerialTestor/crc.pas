unit crc;

interface

function CalcCRC8(data : Pointer;len : integer) :byte;
function CalcCRC16(p:pbyte;len:integer):word;

implementation

uses sysutils;

var
 //用CCITT X16+X12+X5+1得到的CRC表
 CRC16Table : array[0..255] of word=(
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
  crcTable : array[0..255] of byte=(
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


procedure crcupdate(data : byte;var accum : byte);
begin
 accum:=crctable[accum xor data];
end;

function CalcCRC8(data : Pointer;len : integer) :byte;
var
 i : integer;
begin
 result:=0;
 for i:=0 to len-1 do
  crcupdate(pbytearray(data)[i],result);
 result:=not result;
end;

function CalcCRC16(p:pbyte;len:integer):word;
var
  i: Integer;
  e: pbyte;
  Buf: byte;
begin
  Result := 0;
  e:=p;
  for i := 0 to len-1 do
  begin
    buf:=e^;
    inc(e);
    Result := Hi(Result) xor CRC16Table[ Buf xor Lo(Result)];
  end;
end;

end.
