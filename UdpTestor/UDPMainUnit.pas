unit UDPMainUnit;

{
　　组播地址的分类：
　　保留——224.0.0.0 - 224.0.0.255
　　用户组播地址——224.0.1.0 - 238.255.255.255
　　本地管理组——239.0.0.0 - 239.255.255.255 （用于私人组播领域，类似私有IP地址）
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, ComCtrls, Buttons, NMUDPEx;

type
  TUDPTestForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Memo2: TMemo;
    Memo1: TMemo;
    Edit3: TEdit;
    Label3: TLabel;
    GroupCastEd: TCheckBox;
    GroupIpEd: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Button3: TButton;
    LocalIpsEd: TComboBox;
    Timer1: TTimer;
    SpinEdit3: TSpinEdit;
    Button8: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Memo2KeyPress(Sender: TObject; var Key: Char);
    procedure Memo2Change(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GroupIpEdExit(Sender: TObject);
    procedure GroupIpEdKeyPress(Sender: TObject; var Key: Char);
    procedure NMUDP1DataReceived(Sender: TComponent; NumberBytes: Integer;
      FromIP: String; Port: Integer);
    procedure NMUDP1InvalidHost(var handled: Boolean);
    procedure NMUDP1Status(Sender: TComponent; status: String);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FBuf: array[0..10000] of byte;
    FBufChar: array[0..10000] of char;
    FMyUDP:TNMUDPEx;
    MaxSendEdCount: Integer;
    SendEdList: TList;
    SendBnList: TList;
    procedure CreateUDP;
    procedure FreeUDP;
    function GetSendBns(Index: Integer): TButton;
    function GetSendEds(Index: Integer): TEdit;
    procedure SendEdEvent(Sender: TObject);
    procedure SettoSendEdit(pSendType: Integer);
    { Private declarations }
  public
    property SendBns[Index: Integer]: TButton read GetSendBns;
    property SendEds[Index: Integer]: TEdit read GetSendEds;
    { Public declarations }
  end;

var
  UDPTestForm: TUDPTestForm;

implementation

uses Commons, CommonsNet, WinSock;

{$R *.DFM}

procedure TUDPTestForm.Button1Click(Sender: TObject);
begin
  if Button1.tag=0 then
  begin
    try
      //创建UDP
      CreateUDP();
    except
      showmessage('创建UD时产生意外错误!');
      exit;
    end;
    Button1.tag:=1;
    Button1.caption:='停止监听';
    button2.Enabled:=true;
    button8.Enabled:=False ;
    self.GroupIpEd.Enabled:=false;
    self.LocalIpsEd.Enabled:=false;
    edit2.Enabled:=false;
    edit3.Enabled:=false;
    GroupCastEd.Enabled := false;
  end
  else
  begin
    //释放UDP
    FreeUDP();
    Button1.tag:=0;
    Button1.caption:='开始监听';
    button2.Enabled:=false;
    button8.Enabled:=True;
    self.GroupIpEd.Enabled:=true;
    self.LocalIpsEd.Enabled:=true;
    edit2.Enabled:=true;
    edit3.Enabled:=true;
    GroupCastEd.Enabled := true;
  end;
end;

procedure TUDPTestForm.FormCreate(Sender: TObject);
var
  i: Integer;
  aEdit: TEdit;
  aButton: TButton;
  sl: TStringList;
begin
  MaxSendEdCount := 10;
  sl := TStringList.Create();
  try
    TCommonNet.SettoIPList(sl);
    sl.Insert(0,'127.0.0.1');
    self.LocalIpsEd.Items.AddStrings(sl);
    Self.LocalIpsEd.ItemIndex := 0;
  finally
    sl.Free;
  end;
  self.GroupIpEd.Text := '127.0.0.1';
  SendEdList := TList.Create();
  SendBnList := TList.Create();
  for i := 0 to MaxSendEdCount-1 do
  begin
    aEdit := TEdit.Create(self);
    aEdit.Parent := Panel4;
    aEdit.Left := 10;
    aEdit.Width := 300;
    aEdit.Height := 21;
    aEdit.Top := 10 + (10+aEdit.Height)*i;
    SendEdList.Add(aEdit);

    aButton := TButton.Create(self);
    aButton.Parent := Panel4;
    aButton.Left := 320;
    aButton.Width := 80;
    aButton.Height := 21;
    aButton.Top := 10 + (10+aButton.Height)*i;
    aButton.Caption := '发送';
    aButton.OnClick := SendEdEvent;
    aButton.Tag := i;
    SendBnList.Add(aButton);
  end;

  SettoSendEdit(Button3.Tag);
  button2.Enabled:=false;
  button8.Enabled:=true;
end;

procedure TUDPTestForm.Button2Click(Sender: TObject);
var
  buf:array of byte;
  i:integer;
  s,s1:string;
  bl:TList;
  cbuf:array [0..10000] of char;
begin
  if not button2.Enabled then
  begin
    exit;
  end;
  s:='';
  for i:=0 to memo2.Lines.count-1 do
  begin
    s1:= trim(memo2.Lines[i]);
    if s1<>'' then
    begin
      s:=s+s1+' ';
    end;
  end;
  if s='' then exit;
  s1:='';
  bl:=TList.Create;
  try
    for i:=1 to length(s) do
    begin
      if s[i]=' ' then
      begin
        s1:=trim(s1);
        if s1<>'' then
        begin
          bl.add(pointer(strtoint('$'+s1)));
          s1:='';
        end;
      end
      else
       s1:=s1+s[i];
    end;
    s1:=trim(s1);
    if s1<>'' then bl.add(pointer(strtoint('$'+s1)));
    setlength(buf,bl.Count);
    for i:=0 to bl.count-1 do
      buf[i]:=byte(bl[i]);
    i:=length(buf);
    move(buf[0],cbuf[0],i);
    FMyUDP.SendBuffer(cbuf,i);
  finally
    bl.free;
  end;
end;

procedure TUDPTestForm.Button3Click(Sender: TObject);
begin
  if Button3.Tag = 0 then
    Button3.Tag := 1
  else
    Button3.Tag := 0;
  SettoSendEdit(Button3.Tag);
end;

procedure TUDPTestForm.Button8Click(Sender: TObject);
var
  s: string;
begin
  s := Edit2.Text;
  self.Edit2.Text := self.Edit3.Text;
  self.Edit3.Text := s;
end;

procedure TUDPTestForm.CreateUDP;
var
  rpo,lpo:integer;
begin
  try
    rpo:=strtoint(edit2.text);
  except
    showmessage('远程端口错误');
    raise;
    exit;
  end;
  try
    lpo:=strtoint(edit3.text);
  except
    showmessage('本地端口错误');
    raise;
    exit;
  end;

  FMyUDP:=TNMUDPEx.Create(self);
        if (LocalIpsEd.Text = '127.0.0.1') then
          FMyUDP.LocalIp := '0.0.0.0'
        else
          FMyUDP.LocalIp := LocalIpsEd.Text;
  FMyUDP.OnDataReceived:=NMUDP1DataReceived;
  FMyUDP.OnInvalidHost:=NMUDP1InvalidHost;
  FMyUDP.OnStatus:=NMUDP1Status;
  FMyUDP.RemoteHost:= self.GroupIpEd.Text;
  FMyUDP.RemotePort:=rpo;
  FMyUDP.LocalPort:=lpo;
  if GroupCastEd.Checked then
  begin
    if not FMyUDP.JionVLan(self.LocalIpsEd.Text, self.GroupIpEd.Text) then
    begin
      showmessage('加入组播网失败...');
    end;
  end;
end;

procedure TUDPTestForm.Memo2KeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9','a'..'f','A'..'F',#8,#13,#32]) then
    key:=#0;
end;

procedure TUDPTestForm.Memo2Change(Sender: TObject);
var
  s:string;
  i,j:integer;
begin
  i:=memo2.Lines.count-1;
  s:=memo2.lines[i];
  j:=length(s);
  if j<1 then exit;
  if s[j]<>' ' then
  begin
    if j>2 then
    begin
      if s[j-1]<>' ' then
      begin
        if s[j-2]<>' ' then
        begin
          setlength(s,j+1);
          s[j+1]:=s[j];
          s[j]:=' ';
          memo2.lines[i]:=s;
        end;
      end;
    end;
  end;
end;

procedure TUDPTestForm.FormDestroy(Sender: TObject);
begin
  FreeUDP();
  SendEdList.Free();
  SendBnList.Free();
end;

procedure TUDPTestForm.FreeUDP;
begin
    if Assigned(FMyUDP) then
    begin
      if FMyUDP.ThisSocket<>0 then
        closesocket(FMyUDP.ThisSocket);
      WSAcleanup;

//    if GroupCastEd.Checked then
//    begin
//      if not FMyUDP.ExitVLan(self.LocalIpEd.Text, self.GroupIpEd.Text) then
//      begin
//        showmessage('离开组播网失败...');
//      end;
//    end;
     freeandnil(FMyUDP);
    end;
end;

function TUDPTestForm.GetSendBns(Index: Integer): TButton;
begin
  Result := SendBnList[Index];
end;

function TUDPTestForm.GetSendEds(Index: Integer): TEdit;
begin
  Result := SendEdList[Index];
end;

procedure TUDPTestForm.GroupIpEdExit(Sender: TObject);
var
  aAddress: string;
  aEdit: TEdit;
begin
  if Sender is TEdit then
    aEdit := TEdit(Sender)
  else
    exit;

  aAddress := trim(aEdit.Text);
  aAddress := TCommon.Singleton.GettoValidIP(aAddress);

  if aAddress = '' then
  begin
    showmessage('IP地址不合法，请重新输入');
    aEdit.SetFocus;
    abort;
  end
  else
    aEdit.Text := aAddress;
end;

procedure TUDPTestForm.GroupIpEdKeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'])
    then
  begin
    if key <> #8 then
      key:= #0;
    exit;
  end;
end;

procedure TUDPTestForm.NMUDP1DataReceived(Sender: TComponent;
  NumberBytes: Integer; FromIP: String; Port: Integer);
var
  i:integer;
  s:string;
begin
  if memo1.Lines.Count>10000 then memo1.clear;
  i:=NumberBytes;
  if (i<=0) or (i>10000) then exit;
  FMyUDP.ReadBuffer(FBufChar , i);
  move(FBufChar[0], FBuf[0], i);
  s:=format('form : %s : %d | ',[FromIP,Port]);
  for i:=0 to NumberBytes-1 do
  begin
    s:=s+inttohex(byte(FBufChar[i]),2)+' ';
  end;
  s:=trim(s);
  memo1.Lines.Add(s);
end;

procedure TUDPTestForm.NMUDP1InvalidHost(var handled: Boolean);
begin
  StatusBar1.SimpleText:='InvalidHost';
end;

procedure TUDPTestForm.NMUDP1Status(Sender: TComponent; status: String);
begin
  StatusBar1.SimpleText:=status;
end;

procedure TUDPTestForm.SendEdEvent(Sender: TObject);
var
  aTag: Integer;
  aEdit: TEdit;

  buf:array of byte;
  i:integer;
  s,s1:string;
  bl:TList;
  cbuf:array [0..10000] of char;
begin
  aTag := TButton(Sender).Tag;
  aEdit := SendEds[aTag];

  s:=trim(aEdit.Text);
  if s='' then exit;

  s1:='';
  bl:=TList.Create;
  try
    for i:=1 to length(s) do
    begin
      if s[i]=' ' then
      begin
        s1:=trim(s1);
        if s1<>'' then
        begin
          bl.add(pointer(strtoint('$'+s1)));
          s1:='';
        end;
      end
      else
       s1:=s1+s[i];
    end;
    s1:=trim(s1);
    if s1<>'' then bl.add(pointer(strtoint('$'+s1)));
    setlength(buf,bl.Count);
    for i:=0 to bl.count-1 do
      buf[i]:=byte(bl[i]);
    i:=length(buf);
    move(buf[0],cbuf[0],i);
    FMyUDP.SendBuffer(cbuf,i);
  finally
    bl.free;
  end;


end;

procedure TUDPTestForm.SettoSendEdit(pSendType: Integer);
var
  i: Integer;
begin
  if pSendType=0 then
  begin
    Button2.Enabled := true;
    Button8.Enabled := False;
    Memo2.Enabled := true;
    Memo2.Visible := true;

    for i := 0 to MaxSendEdCount-1 do
    begin
      SendEds[i].Enabled := false;
      SendEds[i].Visible := false;
      SendBns[i].Enabled := false;
      SendBns[i].Visible := false;
    end;

  end
  else
  begin
    for i := 0 to MaxSendEdCount-1 do
    begin
      SendEds[i].Enabled := true;
      SendEds[i].Visible := true;
      SendBns[i].Enabled := true;
      SendBns[i].Visible := true;
    end;

    Button2.Enabled := false;
    Button8.Enabled := True;
    Memo2.Enabled := false;
    Memo2.Visible := false;
  end;

end;

procedure TUDPTestForm.SpeedButton1Click(Sender: TObject);
begin
  memo1.Clear()
end;

procedure TUDPTestForm.SpeedButton2Click(Sender: TObject);
begin
  memo2.Clear;
end;

procedure TUDPTestForm.SpinEdit3Change(Sender: TObject);
begin
   self.Timer1.Interval := self.SpinEdit3.Value;
   self.Timer1.Enabled := self.SpinEdit3.Value > 10;
end;

procedure TUDPTestForm.Timer1Timer(Sender: TObject);
begin
  Button2Click(nil);
end;

end.
