unit WatchDog;

interface

uses
  Windows, OutTime;

type
  TWatchDog = class(TObject)
  private
  protected
    FIsRunning: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Start; virtual; abstract;
    procedure Stop; virtual; abstract;
    property IsRunning: Boolean read FIsRunning;
  end;

  TWatchDogManager = class(TObject)
  private
    FWatchDog: TWatchDog;
    function GetIsRunning: Boolean;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    class function Singleton: TWatchDogManager;
    procedure StartDog;
    procedure StopDog;
    property IsRunning: Boolean read GetIsRunning;
  end;

implementation

uses WatchDogEMB_3680, WatchDogEC3_1566, SysConfigs;

var
  FWatchDogManager: TWatchDogManager;

constructor TWatchDog.Create;
begin
  FIsRunning := false;
end;

destructor TWatchDog.Destroy;
begin
  inherited;
end;

constructor TWatchDogManager.Create;
begin
  case TSysConfig.Singleton.WatchDogType of
    1: FWatchDog := TWatchDogEC3_1566.Create();
    2: FWatchDog := TWatchDogEMB_3680.Create();
  else FWatchDog := TWatchDogEC3_1566.Create();
  end;
end;

destructor TWatchDogManager.Destroy;
begin
  FWatchDog.Stop();

  inherited;

  FWatchDog.Free();
end;

function TWatchDogManager.GetIsRunning: Boolean;
begin
  Result := FWatchDog.IsRunning;
end;

class function TWatchDogManager.Singleton: TWatchDogManager;
begin
  if FWatchDogManager = nil then
    FWatchDogManager := TWatchDogManager.Create();

  Result := FWatchDogManager;
end;

procedure TWatchDogManager.StartDog;
begin
  FWatchDog.Start();
end;

procedure TWatchDogManager.StopDog;
begin
  FWatchDog.Stop();
end;

initialization

finalization
  if FWatchDogManager<>nil then
  begin
    FWatchDogManager.Free();
    FWatchDogManager := nil;
  end;

end.
