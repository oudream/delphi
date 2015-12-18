unit WatchDogEC3_1566;

interface

uses
  Windows, OutTime, WatchDog;

type
  TWatchDogEC3_1566 = class(TWatchDog)
  private
    FFeedDogTm: TOutTime;
    FPortEnable: Boolean;
    function EnablePort: Boolean;
    function DisablePort: Boolean;
    procedure DogOff;
    procedure DogOn;
    procedure FeedDog(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

uses gwiopm, gwportio, Systems;

//const
//State_Success : set of byte = [ERROR_SUCCESS, ERROR_SERVICE_ALREADY_RUNNING, ERROR_SERVICE_EXISTS];

constructor TWatchDogEC3_1566.Create;
begin
  inherited;
  FPortEnable := false;

  FFeedDogTm := TOutTime.Create();
  FFeedDogTm.Interval := 5000;
  FFeedDogTm.OnOutTime := FeedDog;
  FFeedDogTm.Enabled := false;
end;

destructor TWatchDogEC3_1566.Destroy;
begin
  FFeedDogTm.Enabled := false;

  inherited;

  FFeedDogTm.Free();
end;

procedure TWatchDogEC3_1566.DogOn;
begin
  PortOutW($110,$8A0B);  // enable dog
  FFeedDogTm.Enabled := true;
  TSystem.Singleton.OutSystemInfo('7) DogOn');
end;

procedure TWatchDogEC3_1566.DogOff;
begin
  PortOutW($110,$0000);  // enable dog
  FFeedDogTm.Enabled := false;
end;

function TWatchDogEC3_1566.EnablePort: Boolean;
var
  Status: DWORD;
begin
  Result := false;
  Status := GWIOPM_Driver.LIOPM_Set_Ports($110, $111, true);
  TSystem.Singleton.OutSystemInfo('5) EnablePort : '+GWIOPM_Driver.ErrorLookup(Status));
  if (Status = ERROR_SUCCESS) then
  begin
    Status := GWIOPM_Driver.IOCTL_IOPMD_ACTIVATE_KIOPM;
    TSystem.Singleton.OutSystemInfo('6) ActivePort : '+GWIOPM_Driver.ErrorLookup(Status));
    Result := Status = ERROR_SUCCESS;
  end;
  
  FPortEnable := Result;
end;

function TWatchDogEC3_1566.DisablePort: Boolean;
var
  Status: DWORD;
begin
  Result := false;
  Status := GWIOPM_Driver.LIOPM_Set_Ports($110, $111, false);
  if (Status = ERROR_SUCCESS) then
  begin
    Status := GWIOPM_Driver.IOCTL_IOPMD_ACTIVATE_KIOPM;
    Result := Status = ERROR_SUCCESS;
  end;

  FPortEnable := not Result;
end;

procedure TWatchDogEC3_1566.FeedDog(Sender: TObject);
begin
  TSystem.Singleton.OutSystemInfo('8) FeedDog');
  PortOut($110,$0B);  // feed dog
end;

procedure TWatchDogEC3_1566.Start;
var
  Status: DWORD;
begin
  if IsRunning then
    exit;

  try
    //1
    Status := GWIOPM_Driver.OpenSCM();
    TSystem.Singleton.OutSystemInfo('1) OpenSCM : '+GWIOPM_Driver.ErrorLookup(Status));
    if (Status <> ERROR_SUCCESS) then
    begin
      exit;
    end;

    try
      //2
      Status := GWIOPM_Driver.Install('');
      TSystem.Singleton.OutSystemInfo('2) Install : '+GWIOPM_Driver.ErrorLookup(Status));
      if ((Status <> ERROR_SUCCESS) and (Status <> ERROR_SERVICE_EXISTS)) then
      begin
        GWIOPM_Driver.CloseSCM();
        exit;
      end;

      try
        //3
        Status := GWIOPM_Driver.Start();
        TSystem.Singleton.OutSystemInfo('3) Start : '+GWIOPM_Driver.ErrorLookup(Status));
        if ((Status <> ERROR_SUCCESS) and (Status <> ERROR_SERVICE_ALREADY_RUNNING)) then
        begin
          GWIOPM_Driver.Remove();
          GWIOPM_Driver.CloseSCM();
          exit;
        end;

        try
          Status := GWIOPM_Driver.DeviceOpen();
          TSystem.Singleton.OutSystemInfo('4) DeviceOpen : '+GWIOPM_Driver.ErrorLookup(Status));
          if (Status <> ERROR_SUCCESS) then
          begin
            GWIOPM_Driver.Stop();
            GWIOPM_Driver.Remove();
            GWIOPM_Driver.CloseSCM();
            exit;
          end
          else
          begin
            FIsRunning := true;
          end;
        except
          GWIOPM_Driver.Stop();
          GWIOPM_Driver.Remove();
          GWIOPM_Driver.CloseSCM();
        end;

      except
        GWIOPM_Driver.Remove;
        GWIOPM_Driver.CloseSCM();
      end;

    except
      GWIOPM_Driver.CloseSCM();
    end;

  except

  end;

  if IsRunning then
  begin
    if EnablePort then
    begin
      DogOn();
    end;
  end;
end;

procedure TWatchDogEC3_1566.Stop;
begin
  if IsRunning then
  begin
    if FPortEnable then
    begin
      DogOff();
      DisablePort();
    end;

    GWIOPM_Driver.DeviceClose();
    GWIOPM_Driver.Stop();
    GWIOPM_Driver.Remove();
    GWIOPM_Driver.CloseSCM();

    FIsRunning := false;
  end;
end;

end.


