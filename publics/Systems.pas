unit Systems;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Forms, Dialogs, IniFiles;

type
  //为DLL兼容
  TOutInfoType = (itSystem, itSerialReceive, itSerialSend, itTCPReceive,
    itTCPSend,
    itUdpReceive, itUdpSend, itCanInfo);

  TOutInfoEvent = function(AInfo: string; aOutInfoType: TOutInfoType): Integer
    of
    object;

  TOutInfoCanEvent = function(aOutInfoType: TOutInfoType): Boolean of object;

  // TSystem 系统类 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  TSystem = class(TObject)
  private
    FOnOutInfoCanOut: TOutInfoCanEvent;
    FOnOutInfo: TOutInfoEvent;
    FOpenDialog: TOpenDialog;
    FSaveDialog: TSaveDialog;
    function GetExePath: string;
  public
    constructor Create;
    destructor Destroy; override;
    function OutInfoCanOut(aOutInfoType: TOutInfoType): Boolean;
    function OutInfoCanScroll(aOutInfoType: TOutInfoType): Boolean;
    function DialogOpen(aExtension: string; out aFileName: string): Boolean;
    function DialogSave(aExtension: string; out aFileName: string): Boolean;
    function DialogInput(aPrompt: string; var aVaule: string): Boolean;
    procedure MarkError(errStr: string);
    procedure ShowInfo(sInfo: string);
    function OutInfo(AInfo: string; aOutInfoType: TOutInfoType): Integer;
    function OutSystemInfo(aInfo: string): Integer;
    function OutErrorInfo(aInfo: string): Integer;
    procedure ShowErrorInfo(sInfo: string);
    function ShowQuery(sQuery: string): boolean;
    function ShowQuery3(sQuery: string): Integer;
    procedure ShowTerminate(ErrStr: string);
    class function Singleton: TSystem;
    property ExePath: string read GetExePath;
    property OpenDialog: TOpenDialog read FOpenDialog;
    property SaveDialog: TSaveDialog read FSaveDialog;
    property OnOutInfoCanOut: TOutInfoCanEvent read FOnOutInfoCanOut write
        FOnOutInfoCanOut;
    property OnOutInfo: TOutInfoEvent read FOnOutInfo write FOnOutInfo;
  end;

var
  gCompleteInited: boolean; //全局初始化完成
  globeTXExecPath: string; //系统运行路径

const
  SUTXSYSTEM_Sorry: string = '对不起';
  SUTXSYSTEM_Title: string = '提示';
  PROJECT_TYPE = 'TEST';
//  PROJECT_TYPE = 'RUN';

implementation

uses Commons;

var
  FTXSystem: TSystem;

constructor TSystem.Create;
begin
  FOpenDialog := TOpenDialog.Create(nil);
  FSaveDialog := TSaveDialog.Create(nil);
end;

destructor TSystem.Destroy;
begin
  FOpenDialog.Free();
  FSaveDialog.Free();

  inherited;
end;

function TSystem.OutInfoCanOut(aOutInfoType: TOutInfoType): Boolean;
begin
  Result := false;
  if Assigned(FOnOutInfoCanOut) then
    Result := FOnOutInfoCanOut(aOutInfoType);
end;

function TSystem.OutInfoCanScroll(aOutInfoType: TOutInfoType): Boolean;
begin
  Result := false;
  if Assigned(FOnOutInfoCanOut) then
    Result := FOnOutInfoCanOut(aOutInfoType);
end;

function TSystem.DialogOpen(aExtension: string; out aFileName: string): Boolean;
begin
  OpenDialog.DefaultExt := format('*%s', [aExtension]);
  OpenDialog.FileName := format('*%s', [aExtension]);
  OpenDialog.Filter := format('*%s|*%s', [aExtension, aExtension]);

  OpenDialog.Options := [ofHideReadOnly, ofFileMustExist, ofEnableSizing];

  Result := OpenDialog.Execute;

  if Result then
    aFileName := OpenDialog.FileName;
end;

function TSystem.DialogSave(aExtension: string; out aFileName: string): Boolean;
begin
  SaveDialog.DefaultExt := format('*%s', [aExtension]);
  SaveDialog.FileName := format('*%s', [aExtension]);
  SaveDialog.Filter := format('*%s|*%s', [aExtension, aExtension]);

  SaveDialog.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing];

  Result := SaveDialog.Execute;

  if Result then
    aFileName := SaveDialog.FileName;
end;

function TSystem.DialogInput(aPrompt: string; var aVaule: string): Boolean;
begin
  Result := InputQuery('请输入', aPrompt + '　　', aVaule);
end;

function TSystem.OutInfo(AInfo: string; aOutInfoType: TOutInfoType): Integer;
begin
  Result := -1;
  if Assigned(FOnOutInfo) then
    Result := FOnOutInfo(AInfo, aOutInfoType);
end;

function TSystem.GetExePath: string;
begin
  Result := globeTXExecPath;
end;

procedure TSystem.MarkError(errStr: string);
var
  f: TextFile;
  filename: string;
begin
  if directoryexists(FTXSystem.ExePath) = false then
    if TCommon.Singleton.CreatMultDir(FTXSystem.ExePath) = false then
      EXIT;

  filename := FTXSystem.ExePath + 'Error.ini';

  if FILEexists(filename) = false then
  begin
    Assignfile(f, filename);
    Rewrite(f);
  end
  else
    AssignFile(f, filename);

  Append(f);
  Writeln(f, errStr + '出错时间：' + FormatDateTime('hh:nn:ss:zzz', Now));
  Flush(f); { ensures that the text was actually written to file }
  CloseFile(f);
end;

function TSystem.OutSystemInfo(aInfo: string): Integer;
begin
  Result := -1;
  if OutInfoCanOut(itSystem) then
    Result := OutInfo(aInfo, itSystem);
end;

function TSystem.OutErrorInfo(aInfo: string): Integer;
begin
  Result := OutSystemInfo(aInfo);
end;

procedure TSystem.ShowInfo(sInfo: string);
begin
  Application.MessageBox(PChar(sInfo), PChar(SUTXSYSTEM_TITLE), MB_OK +
    MB_ICONINFORMATION);
end;

procedure TSystem.ShowErrorInfo(sInfo: string);
begin
  Application.MessageBox(PChar(sInfo), PChar(SUTXSYSTEM_TITLE), MB_OK +
    MB_ICONERROR);
end;

function TSystem.ShowQuery(sQuery: string): boolean;
var
  iresult: integer;
begin
  iresult := Application.MessageBox(PChar(sQuery), PChar(SUTXSYSTEM_TITLE),
    MB_YESNO);
  if iresult = IDYES then
    result := true
  else
    result := false;
end;

function TSystem.ShowQuery3(sQuery: string): Integer;
begin
  result := MessageDlg(sQuery, mtConfirmation, [mbYes, mbNo, mbCancel], 0);
end;

procedure TSystem.ShowTerminate(ErrStr: string);
begin
  showmessage(SUTXSYSTEM_SORRY + #13 + ErrStr + '[系统即将关闭]');
  application.Terminate;
end;

class function TSystem.Singleton: TSystem;
begin
  if FTXSystem = nil then
    FTXSystem := TSystem.Create;
  Result := FTXSystem;
end;

initialization

finalization
  if FTXSystem <> nil then
  begin
    FTXSystem.Free();
    FTXSystem := nil;
  end;

end.
