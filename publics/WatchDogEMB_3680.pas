unit WatchDogEMB_3680;

interface

uses
  Windows, OutTime, WatchDog;

type
  TWatchDogEMB_3680 = class(TWatchDog)
  private
    FFeedDogTm: TOutTime;
    FPortEnable: Boolean;
    function EnablePort: Boolean;
    function DisablePort: Boolean;
    procedure DogOff;
    procedure DogOn;
    procedure FeedDog(Sender: TObject);
    procedure Func_Win627(counts: byte);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

uses gwiopm, gwportio, Systems;

const
  C_RegisterAddress = $2E;
  C_RegisterData = $2F;


//const
//State_Success : set of byte = [ERROR_SUCCESS, ERROR_SERVICE_ALREADY_RUNNING, ERROR_SERVICE_EXISTS];

constructor TWatchDogEMB_3680.Create;
begin
  inherited;
  
  FPortEnable := false;

  FFeedDogTm := TOutTime.Create();
  FFeedDogTm.Interval := 5000;
  FFeedDogTm.OnOutTime := FeedDog;
  FFeedDogTm.Enabled := false;
end;

destructor TWatchDogEMB_3680.Destroy;
begin
  FFeedDogTm.Enabled := false;

  inherited;

  FFeedDogTm.Free();
end;

procedure TWatchDogEMB_3680.DogOn;
begin
  Func_Win627(19);  // enable dog
  FFeedDogTm.Enabled := true;
  TSystem.Singleton.OutSystemInfo('7) DogOn');
end;

procedure TWatchDogEMB_3680.DogOff;
begin
  Func_Win627(0);  // off dog
  FFeedDogTm.Enabled := false;
end;

function TWatchDogEMB_3680.EnablePort: Boolean;
var
  Status: DWORD;
begin
  Result := false;
  Status := GWIOPM_Driver.LIOPM_Set_Ports(C_RegisterAddress, C_RegisterData, true);
  TSystem.Singleton.OutSystemInfo('5) EnablePort : '+GWIOPM_Driver.ErrorLookup(Status));
  if (Status = ERROR_SUCCESS) then
  begin
    Status := GWIOPM_Driver.IOCTL_IOPMD_ACTIVATE_KIOPM;
    TSystem.Singleton.OutSystemInfo('6) ActivePort : '+GWIOPM_Driver.ErrorLookup(Status));
    Result := Status = ERROR_SUCCESS;
  end;
  
  FPortEnable := Result;
end;

function TWatchDogEMB_3680.DisablePort: Boolean;
var
  Status: DWORD;
begin
  Result := false;
  Status := GWIOPM_Driver.LIOPM_Set_Ports(C_RegisterAddress, C_RegisterData, false);
  if (Status = ERROR_SUCCESS) then
  begin
    Status := GWIOPM_Driver.IOCTL_IOPMD_ACTIVATE_KIOPM;
    Result := Status = ERROR_SUCCESS;
  end;

  FPortEnable := not Result;
end;

procedure TWatchDogEMB_3680.FeedDog(Sender: TObject);
begin
  TSystem.Singleton.OutSystemInfo('8) FeedDog');
  Func_Win627(19);  // feed dog
end;

procedure TWatchDogEMB_3680.Func_Win627(counts: byte);
begin
  asm
    mov DX, $2E;
    mov AL, $87;
    out DX, AL;
    mov DX, $2E;
    mov AL, $87;
    out DX, AL;

    mov DX, $2E;
    mov AL, $2B;
    out DX, AL;
    mov DX, $2F;
    mov AL, $C0;
    out DX, AL;

    mov DX, $2E;
    mov AL, $07;
    out DX, AL;
    mov DX, $2F;
    mov AL, $08;
    out DX, AL;

    mov DX, $2E;
    mov AL, $30;
    out DX, AL;
    mov DX, $2F;
    mov AL, $01;
    out DX, AL;

    mov DX, $2E;
    mov AL, $F5;
    out DX, AL;
    mov DX, $2F;
    mov AL, $00;
    out DX, AL;

    mov DX, $2E;
    mov AL, $F6;
    out DX, AL;
    mov DX, $2F;
    mov AL, counts;
    out DX, AL;

    mov DX, $2E;
    mov AL, $AA;
    out DX, AL;
  end; {asm}
{
  PortOut(C_RegisterAddress, $87);    //unlock
  PortOut(C_RegisterAddress, $87);

//DP_OutpB(indexp,0x2b);
//temp = DP_InpB(datap);	//set pin for watchdog
//temp &= 0xef;
//DP_OutpB(indexp,0x2b);
//DP_OutpB(datap, temp);	//set pin for watchdog

  PortOut(C_RegisterAddress, $2B);    //set pin for watchdog
  pin := PortIn(C_RegisterData);
  pin := pin and $EF;
  PortOut(C_RegisterAddress, $2B);
  PortOut(C_RegisterData, pin);
//PortOut(C_RegisterAddress, $2B);    //set pin for watchdog
//PortOut(C_RegisterData, $C0);

  PortOut(C_RegisterAddress, $07);    //select logical device
  PortOut(C_RegisterData, $08);

  PortOut(C_RegisterAddress, $30);    //enable logical device
  PortOut(C_RegisterData, $01);

  PortOut(C_RegisterAddress, $F5);
  //PortOut(C_RegisterData, $08);       //set minute ----------------------------------------------£¨1£©
  PortOut(C_RegisterData, $00);       //set second ----------------------------------------------£¨1£©

  PortOut(C_RegisterAddress, $F6);    //set counts------------------------------------------£¨2£©
  PortOut(C_RegisterData, counts);

  PortOut(C_RegisterAddress, $F7);
  PortOut(C_RegisterData, $00);

  PortOut(C_RegisterAddress, $AA);    //lockend
}
{
	int	indexp = 0x2e,datap = 0x2f;
unsigned char  temp;

	DP_OutpB(indexp,0x87);
	DP_OutpB(indexp,0x87);	//unlock

DP_OutpB(indexp,0x2b);
	temp = DP_InpB(datap);	//set pin for watchdog
  temp &= 0xef;
	DP_OutpB(indexp,0x2b);
	DP_OutpB(datap, temp);	//set pin for watchdog

	DP_OutpB(indexp,0x7);
	DP_OutpB(datap,0x8);	//select logical device

	DP_OutpB(indexp,0x30);
	DP_OutpB(datap,0x1);	//enable logical device

	DP_OutpB(indexp,0xf5);
//	DP_OutpB(datap,0x8);	//set minute ------------------------------------------.---£¨1£©
	DP_OutpB(datap,0x0);	//set second ----------------------------------------------£¨1£©

	DP_OutpB(indexp,0xf6);
	DP_OutpB(datap,counts);	//set counts------------------------------------------£¨2£©

DP_OutpB(indexp,0xf7);
	DP_OutpB(datap,0);

	DP_OutpB(indexp,0xaa);	//lockend;
  }
end;

procedure TWatchDogEMB_3680.Start;
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

procedure TWatchDogEMB_3680.Stop;
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


