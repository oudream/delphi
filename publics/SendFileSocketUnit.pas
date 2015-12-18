unit SendFileSocketUnit;

interface

uses ScktComp;

type
  TSendFileBySocket = class(TObject)
  private
    FSocket: TCustomWinSocket;
  public
    constructor Create(pSocket: TCustomWinSocket);
    function SendFile(pFileName: string): integer;
    procedure SocketRead(Sender: TObject; Socket: TCustomWinSocket);
    property Socket: TCustomWinSocket read FSocket;
  end;

function gSendFileBySocket: TSendFileBySocket;

const
  MaxSizeSendFile = 300 * 1024;

implementation

uses Classes;

var
  FSendFileBySocket: TSendFileBySocket;
function gSendFileBySocket: TSendFileBySocket;
begin
  if FSendFileBySocket=nil then
    FSendFileBySocket := TSendFileBySocket.Create;
  Result := FSendFileBySocket;
end;

constructor TSendFileBySocket.Create(pSocket: TCustomWinSocket);
begin
  FSocket := pSocket;
end;

function TSendFileBySocket.SendFile(pFileName: string): integer;
var
  fs: TFileStream;
begin
  result := -1;

  if FSocket=nil then
    exit;

  aFilename := pFileName;
  if not FileExists(aFilename) then
    exit;

  //file 内容存放
  fs := TFileStream.Create(aFilename, fmOpenRead);
  try
    if fs.Size > MaxSizeSendFile then
      exit;
    fs.Position := 0;
    if FSocket.SendStream(fs) then
      Result := fs.Size;
  except
    Result := -1;
  end;

end;

procedure TSendFileBySocket.SocketRead(Sender: TObject; Socket:
    TCustomWinSocket);
var
  s,s1:string;
  desk:tcanvas;
  bitmap:tbitmap;
  jpg:tjpegimage;
begin
  s:=socket.ReceiveText;
  if s='gets' then //file://客户端发出申请
  begin
   try
    m1:=tmemorystream.Create;
    bitmap:=tbitmap.Create;
    jpg:=tjpegimage.Create;
    desk:=tcanvas.Create; //以下代码为取得当前屏幕图象
    desk.Handle:=getdc(hwnd_desktop);
    with bitmap do
    begin
        width:=screen.Width;
        height:=screen.Height;
        canvas.CopyRect(canvas.cliprect,desk,desk.cliprect);
    end;
    jpg.Assign(bitmap); //file://将图象转成JPG格式
    jpg.CompressionQuality:=10;//文件压缩大小设置
    //m1.clear;
    jpg.SaveToStream(m1); //file://将JPG图象写入流中
    jpg.free;
    m1.Position:=0;
    s1:=inttostr(m1.size);
    Socket.sendtext(s1); //file://发送图象大小
   finally
    bitmap.free;
    desk.free;
   end;
  end;
  if s='okok' then //file://客户端已准备好接收图象
  begin
    m1.Position:=0;
    Socket.SendStream(m1); //file://发送JPG图象
  end;
end;

initialization

finalization
  if FSendFileBySocket<>nil then
  begin
    FSendFileBySocket.Free();
    FSendFileBySocket := nil;
  end;

end.
