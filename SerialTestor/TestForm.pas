unit TestForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ToolWin, ImgList, StdCtrls, Spin, OoMisc,
  AdPort, OptionUnit, Buttons;

type
  TByteN = array of byte;
  TfrmTest = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    bnComOpen: TToolButton;
    bnComClose: TToolButton;
    bnComOption: TToolButton;
    Panel2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Panel5: TPanel;
    Panel6: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    Label3: TLabel;
    SpinEdit1: TSpinEdit;
    ckComSendTimer: TCheckBox;
    Label5: TLabel;
    SpinEdit3: TSpinEdit;
    ToolButton4: TToolButton;
    bnImportfile: TToolButton;
    bnComSendByHand: TToolButton;
    bnClearText: TToolButton;
    Panel7: TPanel;
    Shape2: TShape;
    Label2: TLabel;
    Shape1: TShape;
    Label1: TLabel;
    ImageList1: TImageList;
    ToolButton8: TToolButton;
    bnCrcText: TToolButton;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    Timer2: TTimer;
    Timer3: TTimer;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    ApdComPort1: TApdComPort;
    procedure ApdComPort1TriggerAvail(CP: TObject; Count: Word);
    procedure bnClearTextClick(Sender: TObject);
    procedure bnComCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bnComOpenClick(Sender: TObject);
    procedure bnComOptionClick(Sender: TObject);
    procedure bnComSendByHandClick(Sender: TObject);
    procedure bnCrcTextClick(Sender: TObject);
    procedure bnImportfileClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ckComSendTimerClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
  private
    FOption: TOption;
    FRecBytes: Integer;
    FSendBytes: Integer;
    function ComClose: Boolean;
    function ComOpen: Boolean;
    procedure DealData(buf: array of byte; len: word);
    procedure DoClearText;
    procedure DoCrcText;
    procedure DoImportFile;
    procedure DoSetButtonByCOMState;
    procedure DoSetCom;
    procedure HexstrToBuf(s: string; var buf: TByteN; var len: word);
    function GetStrByBuf(buf: array of byte; len: word): string;
    function HexstrToASCII(s: string): string;
    procedure SendText(text: string; AIsHex: boolean);
    procedure SetRecBytes(const Value: Integer);
    procedure SetSendBytes(const Value: Integer);
    function TextToHexstr(s: string): string;
    { Private declarations }
  public
    property RecBytes: Integer read FRecBytes write SetRecBytes;
    property SendBytes: Integer read FSendBytes write SetSendBytes;
    { Public declarations }
  end;

var
  frmTest: TfrmTest;

implementation

uses CacForm, crc, Commons;

{$R *.dfm}

procedure TfrmTest.ApdComPort1TriggerAvail(CP: TObject; Count: Word);
var
  aBuf: array of byte;
begin
  if Count<=0 then exit;
  SetLength(aBuf,Count);
  fillchar(aBuf[0],Length(aBuf),0);
  TApdComPort(CP).GetBlock(aBuf[0],Count);
  DealData(aBuf,Count);
end;

procedure TfrmTest.bnClearTextClick(Sender: TObject);
begin
  DoClearText;
end;

procedure TfrmTest.bnComCloseClick(Sender: TObject);
begin
  ComClose;
end;

procedure TfrmTest.FormDestroy(Sender: TObject);
begin
  FOption.Free;
end;

procedure TfrmTest.FormCreate(Sender: TObject);

begin
  FOption:= TOption.Create;

  //表示以 十六进制 码显示
  RadioGroup1.ItemIndex := 1;
  RadioGroup2.ItemIndex := 1;
  Memo1.Tag := 1;
  Memo2.Tag := 1;

  DoSetCom;
  DoSetButtonByCOMState;

end;

procedure TfrmTest.bnComOpenClick(Sender: TObject);
begin
  ComOpen;
end;

procedure TfrmTest.bnComOptionClick(Sender: TObject);
begin
  FOption.ViewForm;

  DoSetCom;
end;

procedure TfrmTest.bnComSendByHandClick(Sender: TObject);
var
  AIsHex: boolean;
begin
  AIsHex := (RadioGroup2.ItemIndex = 1);
  try
    SendText(Memo2.Lines.Text, AIsHex);
  except
    on e: Exception do
    begin
      Application.MessageBox(pchar(e.Message), '发送数据时发生错误', MB_ICONWARNING or MB_OK);
    end;
  end;
end;

procedure TfrmTest.bnCrcTextClick(Sender: TObject);
begin
  DoCrcText;
end;

procedure TfrmTest.bnImportfileClick(Sender: TObject);
begin
  DoImportFile;
end;

procedure TfrmTest.Button2Click(Sender: TObject);
const
  buf: array[0..107] of Byte = (
  $EB ,$90 ,$EB ,$90 ,$EB ,$90
 ,$71 ,$F4 ,$10 ,$00 ,$00 ,$FA
 ,$F0 ,$FF ,$FF ,$FF ,$FF ,$28
 ,$F1 ,$FF ,$FF ,$FF ,$FF ,$4A
 ,$F2 ,$FF ,$FF ,$FF ,$FF ,$EC
 ,$F3 ,$FF ,$FF ,$FF ,$FF ,$8E
 ,$F4 ,$FF ,$FF ,$FF ,$FF ,$A7
 ,$F5 ,$FF ,$FF ,$FF ,$FF ,$C5
 ,$F6 ,$FF ,$FF ,$FF ,$FF ,$63
 ,$F7 ,$FF ,$FF ,$FF ,$FF ,$01
 ,$F8 ,$FF ,$FF ,$FF ,$FF ,$31
 ,$F9 ,$FF ,$FF ,$FF ,$FF ,$53
 ,$FA ,$FF ,$FF ,$FF ,$FF ,$F5
 ,$FB ,$FF ,$FF ,$FF ,$FF ,$97
 ,$FC ,$FF ,$FF ,$FF ,$FF ,$BE
 ,$FD ,$FF ,$FF ,$FF ,$FF ,$DC
 ,$FE ,$FF ,$FF ,$FF ,$FF ,$7A
 ,$FF ,$FF ,$FF ,$FF ,$7F ,$91
  )    ;
begin
  Timer3.Enabled := true;

  try
    ApdComPort1.PutBlock(buf[0], 108);
    Memo2.Text := TCommon.Singleton.BufToHexStr(buf, 108);
    SendBytes := SendBytes + 108;
  except
    on e: Exception do
    begin
      e.Message := '发送数据时发生错误；' + e.Message;
      raise;
    end;
  end;
end;

procedure TfrmTest.Button3Click(Sender: TObject);
const
  buf: array[0..107] of Byte = (
  $EB ,$90 ,$EB ,$90 ,$EB ,$90
 ,$71 ,$F4 ,$10 ,$00 ,$00 ,$FA
 ,$F0 ,$00 ,$00 ,$00 ,$00 ,$F6
 ,$F1 ,$00 ,$00 ,$00 ,$00 ,$94
 ,$F2 ,$00 ,$00 ,$00 ,$00 ,$32
 ,$F3 ,$00 ,$00 ,$00 ,$00 ,$50
 ,$F4 ,$00 ,$00 ,$00 ,$00 ,$79
 ,$F5 ,$00 ,$00 ,$00 ,$00 ,$1B
 ,$F6 ,$00 ,$00 ,$00 ,$00 ,$BD
 ,$F7 ,$00 ,$00 ,$00 ,$00 ,$DF
 ,$F8 ,$00 ,$00 ,$00 ,$00 ,$EF
 ,$F9 ,$00 ,$00 ,$00 ,$00 ,$8D
 ,$FA ,$00 ,$00 ,$00 ,$00 ,$2B
 ,$FB ,$00 ,$00 ,$00 ,$00 ,$49
 ,$FC ,$00 ,$00 ,$00 ,$00 ,$60
 ,$FD ,$00 ,$00 ,$00 ,$00 ,$02
 ,$FE ,$00 ,$00 ,$00 ,$00 ,$A4
 ,$FF ,$00 ,$00 ,$00 ,$00 ,$C6
 )        ;
begin
  Timer3.Enabled := true;

  try
    ApdComPort1.PutBlock(buf[0], 108);
    Memo2.Text := TCommon.Singleton.BufToHexStr(buf, 108);
    SendBytes := SendBytes + 108;
  except
    on e: Exception do
    begin
      e.Message := '发送数据时发生错误；' + e.Message;
      raise;
    end;
  end;

end;

procedure TfrmTest.ckComSendTimerClick(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
  begin
    Timer1.Interval := SpinEdit3.Value;
    Timer1.Enabled := true;
    SpinEdit3.Enabled := false;
  end
  else
  begin
    SpinEdit3.Enabled := true;
    Timer1.Enabled := false;
  end;
end;

function TfrmTest.ComClose: Boolean;
begin
  try
    ApdComPort1.Open := false;
    Result := true;
  except
    showmessage('错误：串口关闭时发生错误');
    Result := false;
  end;

  DoSetButtonByCOMState;
end;

function TfrmTest.ComOpen: Boolean;
begin
  try
    ApdComPort1.Open:=true;
    Result := true;
  except
    showmessage('错误：串口配置错误，请重新配置程序');
    Result := false;
  end;

  DoSetButtonByCOMState;
end;

procedure TfrmTest.DealData(buf: array of byte; len: word);
var
  s : string;
begin
  if len <= 0 then exit;

  Timer2.Enabled := true;
//SetLength(Rbuf,Count);
//fillchar(Rbuf[0],Length(Rbuf),0);
//TApdComPort(CP).GetBlock(Rbuf[0],Count);
  RecBytes := RecBytes + len;

  s := GetStrByBuf(buf, len);

  if RadioGroup1.ItemIndex = 0 then
  begin
    s := HexstrToASCII(s);
    Memo1.Lines.Text := Memo1.Lines.Text + s;
  end
  else
    Memo1.Lines.Text := Memo1.Lines.Text + s;
end;

procedure TfrmTest.DoClearText;
begin
  if self.ActiveControl is TMemo then
  begin
    TMemo(self.ActiveControl).Clear;
  end
  else
    Memo1.Clear;
end;

procedure TfrmTest.DoCrcText;
var
  s, rs: string;
  buf : array of byte;
  len : word;

  i2 : word;
  b : byte;
  frm: TfrmCac;
begin
  s := trim(Memo2.SelText);
  if Length(s) <= 0 then exit;

  if Memo2.Tag = 0 then
  begin
    showmessage('非法字符');
    exit;
  end;

  HexstrToBuf(s, TByteN(buf), len);

  frm:= TfrmCac.Create(nil);
  try
    rs := '';
    if frm.ShowModal = mrOk then
    begin
      case frm.cgCrc.ItemIndex of
        0:
        begin
          i2 := CalcCRC16(@buf[0], len);//16
          b := lo(i2);
          rs := inttohex(b, 2);
          b := hi(i2);
          rs := rs + ' ' + inttohex(b, 2);
        end;
        1:
        begin
          b := CalcCRC8(@buf[0], len);;//8
          rs := inttohex(b, 2);
        end;
      end;

      Memo2.SelText := s + ' ' + rs;
    end;
  finally
    frm.Free;
  end;
end;

procedure TfrmTest.DoImportFile;
var
  dl: TOpenDialog;
begin
  dl:= TOpenDialog.Create(self);
  try
    dl.Options := [ofHideReadOnly, ofFileMustExist, ofEnableSizing];
    if dl.Execute then
    begin
      Memo2.Lines.LoadFromFile(dl.FileName);
    end;
  finally
    dl.Free;
  end;
end;

procedure TfrmTest.DoSetButtonByCOMState;
begin
  bnComOpen.Enabled := not ApdComPort1.Open;
  bnComClose.Enabled := ApdComPort1.Open;
  bnComSendByHand.Enabled := ApdComPort1.Open;
  ckComSendTimer.Enabled := ApdComPort1.Open;
  RecBytes := 0;
  SendBytes := 0;

  if ApdComPort1.Open then
  begin
    Shape1.Brush.Color := clGreen;
    Shape2.Brush.Color := clGreen;
    StatusBar1.Panels[1].Text := '状态：打开';
  end
  else
  begin
    Shape1.Brush.Color := clWhite;
    Shape2.Brush.Color := clWhite;
    StatusBar1.Panels[1].Text := '状态：关闭';
  end;
end;

procedure TfrmTest.DoSetCom;
begin
  if
  (ApdComPort1.ComNumber <> FOption.ComNumber) or
  (ApdComPort1.Baud <> FOption.Baud) or
  (ApdComPort1.RS485Mode <> FOption.RS485Mode)
  then
  begin
    COMClose;
    ApdComPort1.ComNumber:= FOption.ComNumber;
    ApdComPort1.Baud:= FOption.Baud;
    ApdComPort1.RS485Mode := FOption.RS485Mode;

    StatusBar1.Panels[0].Text := '端口：' + inttostr(FOption.ComNumber);
  end;
end;

procedure TfrmTest.HexstrToBuf(s: string; var buf: TByteN; var len: word);
var
  slen: integer;
  b: byte;
  i: integer;

  newBuf : TByteN;
  newLen : integer;
  str: string;
begin
  str := '';
  for i := 1 to length(s) do
  begin
    if s[i] in ['1' , '2', '3', '4', '5', '6', '7', '8', '9', '0'
      , 'a', 'b', 'c', 'd', 'e', 'f'
      , 'A', 'B', 'C', 'D', 'E', 'F']
    then
    str := str + s[i];
  end;

//s := StringReplace(s, ' ', '', [rfReplaceAll]);
  slen := length(str);
  if (slen mod 2) > 0 then
    raise Exception.Create('不合法十六进制字符串。提示：数量要为双');

  i := 1;
  newLen := 0;
  while i < slen do
  begin
    try
      b := StrToInt('$'+copy(str,i,2));
      inc(i, 2);

      inc(newLen);
      setLength(newBuf, newLen);
      newBuf[newLen-1] := b;
    except
      raise Exception.Create('包含不合法十六进制字符。');
    end;
  end;

  buf := newBuf;
  len := newLen;
end;

function TfrmTest.GetStrByBuf(buf: array of byte; len: word): string;
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

function TfrmTest.HexstrToASCII(s: string): string;
var
  rs: string;
  len: integer;
  b: byte;
  i: Integer;
begin
  s := StringReplace(s, ' ', '', [rfReplaceAll]);

  len := length(s);
  if (len mod 2) > 0 then
    raise Exception.Create('不合法十六进制字符串。提示：数量要为双');

  rs := '';
  i := 1;
  while i < len do
  begin
    try
      b := StrToInt('$'+copy(s,i,2));
      rs := rs + char(b);
    except
      raise Exception.Create('包含不合法十六进制字符。');
    end;
    inc(i, 2);
  end;

  Result := rs;
end;

procedure TfrmTest.Memo1Change(Sender: TObject);
var
  len , max: integer;
  s : string;
begin
  s := Memo1.Text;
  len :=  Length(s);
  max := SpinEdit1.Value;
  if len > max then
  begin
    delete(s, 1, len - max);
    Memo1.Text := s;
  end;
end;

procedure TfrmTest.RadioGroup1Click(Sender: TObject);
var
  s: string;
  mo: TMemo;
begin
  if not (Sender is TRadioGroup) then exit;

  mo := nil;
  case TRadioGroup(Sender).Tag of
    0: mo := Memo1;
    1: mo := Memo2;
  end;
  if mo = nil then exit;

  //16-->ASCII (1-->0)
  if (mo.Tag = 1) and (TRadioGroup(Sender).ItemIndex = 0) then
  begin
    s := mo.Text;
    try
      s := HexstrToASCII(s);
      mo.Tag := 0;
      mo.Text := s;
    except
      on e: Exception do
      begin
        self.ActiveControl := mo;
        TRadioGroup(Sender).ItemIndex := 1;
        Application.MessageBox(pchar(e.Message), '十六进制转ASCII时发生错误', MB_ICONWARNING or MB_OK);
      end;
    end;
  end
  else
    //ASCII-->16 (0-->1)
    if (mo.Tag = 0) and (TRadioGroup(Sender).ItemIndex = 1) then
    begin
      s := mo.Text;
      try
        s := TextToHexstr(s);
        mo.Tag := 1;
        mo.Text := s;
      except
        on e: Exception do
        begin
          self.ActiveControl := mo;
          TRadioGroup(Sender).ItemIndex := 0;
          Application.MessageBox(pchar(e.Message), 'ASCII转十六进制转时发生错误', MB_ICONWARNING or MB_OK);
        end;
      end;
    end;
end;

procedure TfrmTest.SendText(text: string; AIsHex: boolean);
var
  s : string;
  buf : array of byte;
  len : word;
begin
  s := text;
  if Length(s)<=0 then exit;

  Timer3.Enabled := true;

  try
    if not AIsHex then
      s := TextToHexstr(s);

    HexstrToBuf(s, TByteN(buf), len);

    ApdComPort1.PutBlock(buf[0], len);
    SendBytes := SendBytes + len;
  except
    on e: Exception do
    begin
      e.Message := '发送数据时发生错误；' + e.Message;
      raise;
    end;
  end;
end;

procedure TfrmTest.SetRecBytes(const Value: Integer);
begin
  FRecBytes := Value;
  StatusBar1.Panels[2].Text := '接收字节：' + inttostr(Value);
end;

procedure TfrmTest.SetSendBytes(const Value: Integer);
begin
  FSendBytes := Value;
  StatusBar1.Panels[3].Text := '发送字节：' + inttostr(Value);
end;

//设为最上
procedure TfrmTest.SpeedButton1Click(Sender: TObject);
begin
  SetWindowPos(self.Handle, HWND_TOPMOST, self.Left, self.Top,
    self.Width, self.Height, 0);
  SpeedButton1.Visible := false;
  SpeedButton2.Visible := true;
end;

//取消最上
procedure TfrmTest.SpeedButton2Click(Sender: TObject);
begin
  SetWindowPos(self.Handle, HWND_NOTOPMOST, self.Left, self.Top,
    self.Width, self.Height, 0);
  SpeedButton2.Visible := false;
  SpeedButton1.Visible := true;
end;

function TfrmTest.TextToHexstr(s: string): string;
var
  i: Integer;
  b: byte;
begin
  Result := '';
  for i := 1 to length(s) do
  begin
    b := byte(char(s[i]));
    Result := Result + inttohex(b,2) + ' ';
  end;
end;

procedure TfrmTest.Timer1Timer(Sender: TObject);
var
  AIsHex: boolean;
begin
  if ApdComPort1.Open then
  begin
    AIsHex := (RadioGroup2.ItemIndex = 1);
    try
      SendText(Memo2.Lines.Text, AIsHex);
    except
      on e: Exception do
      begin
        ckComSendTimer.Checked := false;
        ckComSendTimerClick(ckComSendTimer);
        Application.MessageBox(pchar(e.Message), '连续发送时发生错误', MB_ICONWARNING or MB_OK);
      end;
    end;
  end;
end;

procedure TfrmTest.Timer2Timer(Sender: TObject);
begin
  if shape1.Tag = 0 then
  begin
    shape1.Tag := 1;
    Shape1.Brush.Color := clLime;
  end
  else
  begin
    shape1.Tag := 0;
    if ApdComPort1.Open then
      Shape1.Brush.Color := clGreen
    else
      Shape1.Brush.Color := clWhite;

    Timer2.Enabled := false;
  end;
end;

procedure TfrmTest.Timer3Timer(Sender: TObject);
begin
  if shape2.Tag = 0 then
  begin
    shape2.Tag := 1;
    Shape2.Brush.Color := clLime;
  end
  else
  begin
    shape2.Tag := 0;
    if ApdComPort1.Open then
      Shape2.Brush.Color := clGreen
    else
      Shape2.Brush.Color := clWhite;

    Timer3.Enabled := false;
  end;
end;

end.
