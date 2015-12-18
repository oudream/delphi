unit SysConfigs;

interface

uses IniFiles;

type
  TSysConfig = class(TObject)
  private
    FHasAutoStart: Boolean;
    FHasLogFile: Boolean;
    FHasTester: Boolean;
    FHasYXPiror: Boolean;
    FHasWatchDog: Boolean;
    FYKSentToSourceOne: Boolean;
    FInif: TIniFile;
    FLConfigurePort: word;
    FYXSourcePresetMDId: Integer;
    FOutInfoComNumberRec: Integer;
    FOutInfoSerialReviceOutSend: Boolean;
    FOutInfoComNumberSend: Integer;
    FOutInfoTCPReviceOutSend: Boolean;
    FTXServerFileName: string;
    FVersion: double;
    FWatchDogType: byte;
    procedure DoLoad;
    procedure DoSave;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Save;
    class function Singleton: TSysConfig;
    property HasAutoStart: Boolean read FHasAutoStart write FHasAutoStart;
    property HasLogFile: Boolean read FHasLogFile write FHasLogFile;
    property HasTester: Boolean read FHasTester;
    property HasYXPiror: Boolean read FHasYXPiror write FHasYXPiror;
    property HasWatchDog: Boolean read FHasWatchDog write FHasWatchDog;
    property YKSentToSourceOne: Boolean read FYKSentToSourceOne write
        FYKSentToSourceOne;
    property LConfigurePort: word read FLConfigurePort;
    property YXSourcePresetMDId: Integer read FYXSourcePresetMDId write
        FYXSourcePresetMDId;
    property OutInfoComNumberRec: Integer read FOutInfoComNumberRec write
        FOutInfoComNumberRec;
    property OutInfoSerialReviceOutSend: Boolean read FOutInfoSerialReviceOutSend
        write FOutInfoSerialReviceOutSend;
    property OutInfoComNumberSend: Integer read FOutInfoComNumberSend write
        FOutInfoComNumberSend;
    property OutInfoTCPReviceOutSend: Boolean read FOutInfoTCPReviceOutSend write
        FOutInfoTCPReviceOutSend;
    property TXServerFileName: string read FTXServerFileName;
    property Version: double read FVersion write FVersion;
    property WatchDogType: byte read FWatchDogType;
  end;

implementation

uses Systems;

var
  FSysConfig: TSysConfig ;
  
constructor TSysConfig.Create;
begin
  FOutInfoComNumberRec := -1;
  FOutInfoComNumberSend := -1;
  FOutInfoSerialReviceOutSend := false;
  FOutInfoTCPReviceOutSend := false;

  FInif := TIniFile.Create(TSystem.Singleton.ExePath + 'Configs.inf');

  DoLoad();
end;

destructor TSysConfig.Destroy;
begin
  DoSave();
  
  FInif.Free;
  
  inherited;
end;

procedure TSysConfig.DoLoad;
begin
  FVersion := FInif.ReadFloat('system', 'Version', 0);
  FYKSentToSourceOne := FInif.ReadBool('system', 'YKSentToSourceOne', false);
  FHasYXPiror := FInif.ReadBool('system', 'HasYXPiror', false);
  FHasTester := FInif.ReadBool('system', 'HasTester', false);
  FLConfigurePort := FInif.ReadInteger('system', 'LConfigurePort', 5566);
  FTXServerFileName := FInif.ReadString('system', 'TXServerFileName', 'TXServer.exe');
  FHasWatchDog := FInif.ReadBool('system', 'HasWatchDog', true);
  FHasAutoStart := FInif.ReadBool('system', 'HasAutoStart', true);
  FHasLogFile := FInif.ReadBool('system', 'HasLogFile', false);
  FWatchDogType := FInif.ReadInteger('system', 'WatchDogType', 1);
  FYXSourcePresetMDId := FInif.ReadInteger('system', 'YXSourcePresetMDId', -1);
end;

procedure TSysConfig.DoSave;
begin
  FInif.WriteFloat('system', 'Version', FVersion);
  FInif.WriteBool('system', 'YKSentToSourceOne', FYKSentToSourceOne);
  FInif.WriteBool('system', 'HasYXPiror', FHasYXPiror);
  FInif.WriteBool('system', 'HasTester', FHasTester);
  FInif.WriteInteger('system', 'LConfigurePort', FLConfigurePort);
  FInif.WriteString('system', 'TXServerFileName', FTXServerFileName);
  FInif.WriteBool('system', 'HasWatchDog', FHasWatchDog);
  FInif.WriteBool('system', 'HasAutoStart', FHasAutoStart);
  FInif.WriteBool('system', 'HasLogFile', FHasLogFile);
  FInif.WriteInteger('system', 'WatchDogType', FWatchDogType);
  FInif.WriteInteger('system', 'YXSourcePresetMDId', FYXSourcePresetMDId);
end;

procedure TSysConfig.Save;
begin
  DoSave();
end;

class function TSysConfig.Singleton: TSysConfig;
begin
  if FSysConfig=nil then
    FSysConfig := TSysConfig.Create;
  Result := FSysConfig;
end;

initialization

finalization
  if FSysConfig <> nil then
  begin
    FSysConfig.Free;
    FSysConfig := nil;
  end;

end.

