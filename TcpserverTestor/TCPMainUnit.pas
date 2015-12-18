unit TCPMainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  NMTCPEx, StdCtrls, Spin, ExtCtrls, ComCtrls;

type
  TTCPTestForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    SpinEdit1: TSpinEdit;
    Button2: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    CheckBox1: TCheckBox;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    SpinEdit2: TSpinEdit;
    LocalIpsEd: TComboBox;
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo2KeyPress(Sender: TObject; var Key: Char);
    procedure Memo2Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FTcpServer: TServerSocket;

    procedure ShowCaption(NewParam: Integer);

    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
      
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TCPTestForm: TTCPTestForm;

implementation

{$R *.DFM}

uses Commons, CommonsNet;

var
  f_recCount : integer;
  
procedure TTCPTestForm.FormCreate(Sender: TObject);
var
  sl: TStringList;
begin
  f_recCount := 0;

  FTcpServer := TServerSocket.Create(nil);
  FTcpServer.ServerType := stNonBlocking;
  FTcpServer.OnClientConnect := ServerSocket1ClientConnect;
  FTcpServer.OnClientDisconnect := ServerSocket1ClientDisconnect;
  FTcpServer.OnClientRead := ServerSocket1ClientRead             ;
  FTcpServer.OnClientWrite := ServerSocket1ClientWrite            ;
  FTcpServer.OnClientError := ServerSocket1ClientError             ;

  memo1.clear;
  memo2.clear;
  button2.Enabled:=false;

  sl := TStringList.Create;
  try
    TCommonNet.SettoIPList(sl);
    sl.Insert(0,'127.0.0.1');
    Self.LocalIpsEd.Items.AddStrings(sl);
    Self.LocalIpsEd.ItemIndex := 0;
  finally
    sl.Free;
  end;  // try
end;

procedure TTCPTestForm.FormDestroy(Sender: TObject);
begin
  FTcpServer.Active := False;
  FTcpServer.Free;
end;

procedure TTCPTestForm.Button1Click(Sender: TObject);
begin
  if Button1.tag=0 then
  begin
    try
      FTcpServer.port:=SpinEdit1.Value;
      if (LocalIpsEd.Text = '127.0.0.1') then
        FTcpServer.Address := ''
      else
        FTcpServer.Address := LocalIpsEd.Text;
        
      FTcpServer.Active:=true;
    except
      exit;
    end;
    Button1.tag:=1;
    Button1.caption:='停止监听';
  end
  else
  begin
    Button1.tag:=0;
    Button1.caption:='开始监听';
    FTcpServer.Active:=false;
  end;
end;

procedure TTCPTestForm.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  button2.Enabled:=true;
  ShowCaption(FTcpServer.Socket.ActiveConnections);
  Memo1.Lines.Add(Format('%s - %d', [Socket.RemoteAddress, Socket.RemotePort]));
  Memo1.Lines.Add(Format('%s', [Socket.RemoteHost]));
end;

procedure TTCPTestForm.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  iConnectedCount: Integer;
begin
  iConnectedCount := FTcpServer.Socket.ActiveConnections - 1;
  if iConnectedCount<=0 then
  begin
    button2.Enabled:=false;
  end;
  ShowCaption(iConnectedCount);
end;

procedure TTCPTestForm.Button2Click(Sender: TObject);
var
  buf:array of byte;
  i:integer;
  Socket: TCustomWinSocket;
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

  for i:=0 to FTcpServer.Socket.ActiveConnections-1 do
  begin
    Socket:=FTcpServer.Socket.Connections[i];
    socket.SendBuf(buf[0],length(buf));
  end;
end;

procedure TTCPTestForm.Memo2KeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9','a'..'f','A'..'F',#8,#13,#32]) then
    key:=#0;
end;

procedure TTCPTestForm.ServerSocket1ClientWrite(Sender: TObject;
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

procedure TTCPTestForm.ShowCaption(NewParam: Integer);
begin
  caption :='TCP连接测试工具'+'       连接数量:'+inttostr(NewParam);
end;


procedure TTCPTestForm.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  buf:array of byte;
  i:integer;
  s:string;
begin
  if ( sametext(Socket.RemoteAddress, Socket.LocalAddress) ) then
    self.StatusBar1.SimpleText := 'Local communication'
  else
    self.StatusBar1.SimpleText := 'Remote communication';

  f_recCount := f_recCount + Socket.ReceiveLength;
  self.StatusBar1.SimpleText := IntToStr(f_recCount);

  i:=Socket.ReceiveLength;
  if i<=0 then exit;
  setlength(buf,i);
  Socket.ReceiveBuf(buf[0],i);
  if memo1.Lines.Count>10000 then memo1.clear;
  if not CheckBox1.Checked then exit;
  s:=format('form : %s : %d | ',[socket.RemoteAddress,socket.RemotePort]);
  for i:=0 to length(buf)-1 do
  begin
    s:=s+inttohex(buf[i],2)+' ';
  end;
  s:=trim(s);
  memo1.Lines.Add(s);

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
  ErrorCode:=0;
end;

procedure TTCPTestForm.SpinEdit2Change(Sender: TObject);
begin
  self.Timer1.Interval := self.SpinEdit2.Value;
  self.Timer1.Enabled := self.Timer1.Interval > 0;
end;

procedure TTCPTestForm.Timer1Timer(Sender: TObject);
begin
  Button2Click(nil);  
end;

end.

