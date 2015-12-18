unit TCPMainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, StdCtrls, Spin, ExtCtrls, ComCtrls;

type
  TTCPTestForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    CheckBox1: TCheckBox;
    StatusBar1: TStatusBar;
    ClientSocket1: TClientSocket;
    Edit1: TEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    CheckBox2: TCheckBox;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo2KeyPress(Sender: TObject; var Key: Char);
    procedure Memo2Change(Sender: TObject);
    procedure ServerSocket1ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure CheckBox2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TCPTestForm: TTCPTestForm;

implementation

uses Systems;

{$R *.DFM}

procedure TTCPTestForm.Button1Click(Sender: TObject);
var
  po:integer;
begin
  if Button1.tag=0 then
  begin
    try
      po:=strtoint(edit2.text);
    except
      showmessage('端口错误');
      exit;
    end;
    try
      ClientSocket1.port:=po;
      ClientSocket1.Address:=edit1.text;
      ClientSocket1.Active:=true;
    except
      showmessage('意外错误!');
      exit;
    end;
    Button1.tag:=1;
    Button1.caption:='断开连接';
  end
  else
  begin
    Button1.tag:=0;
    Button1.caption:='连接主机';
    ClientSocket1.Active:=false;
  end;
end;

procedure TTCPTestForm.FormCreate(Sender: TObject);
begin
  memo1.clear;
  memo2.clear;
  button2.Enabled:=false;
end;

procedure TTCPTestForm.Button2Click(Sender: TObject);
var
  buf:array of byte;
  i:integer;
  s,s1:string;
  bl:TList;
begin
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
  finally
    bl.free;
  end;

  ClientSocket1.Socket.SendBuf(buf[0],length(buf));
end;

procedure TTCPTestForm.Memo2KeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9','a'..'f','A'..'F',#8,#13,#32]) then
    key:=#0;
end;

procedure TTCPTestForm.Memo2Change(Sender: TObject);
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

procedure TTCPTestForm.ServerSocket1ClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  case ErrorEvent of
    eeGeneral: StatusBar1.SimpleText:='General Err';
    eeSend : StatusBar1.SimpleText:='Send Err';
    eeReceive : StatusBar1.SimpleText:='Receive Err';
    eeConnect : StatusBar1.SimpleText:='Connect Err';
    eeDisconnect : StatusBar1.SimpleText:='Disconnect Err';
    eeAccept : StatusBar1.SimpleText:='Disconnect Err';
  end;
  Socket.Close;
  ErrorCode:=0;
end;

procedure TTCPTestForm.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Button1.tag:=0;
  Button1.caption:='连接主机';
  button2.Enabled:=self.ClientSocket1.Active;
end;

procedure TTCPTestForm.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  button2.Enabled:=true;
end;

procedure TTCPTestForm.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
var
  buf:array of byte;
  i:integer;
  s:string;
begin
  if memo1.Lines.Count>10000 then memo1.clear;
  i:=Socket.ReceiveLength;
  if i<=0 then exit;
  setlength(buf,i);
  Socket.ReceiveBuf(buf[0],i);
  if not CheckBox1.Checked then exit;
  s:=format('form : %s : %d | ',[socket.RemoteAddress,socket.RemotePort]);
  for i:=0 to length(buf)-1 do
  begin
    s:=s+inttohex(buf[i],2)+' ';
  end;
  s:=trim(s);
  memo1.Lines.Add(s);
end;

procedure TTCPTestForm.CheckBox2Click(Sender: TObject);
var
  sInterval : string;
begin
  if checkbox2.Checked then
  begin
    if (TSystem.Singleton.DialogInput('请输入要时间间隔：', sInterval)) then
    begin
      Timer1.Interval := StrToInt(sInterval);
      Timer1.Enabled:=true;
    end;
  end
  else
  begin
    Timer1.Enabled:=false;
  end;
end;

procedure TTCPTestForm.Timer1Timer(Sender: TObject);
begin
  if ClientSocket1.Active then
  begin
    Button2Click( Sender);
  end;
end;

end.

