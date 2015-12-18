unit OptionForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TfrmOption = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    RadioGroup5: TRadioGroup;
    RadioGroup6: TRadioGroup;
    RadioGroup7: TRadioGroup;
    GroupBox1: TGroupBox;
    PortsComboBox: TComboBox;
    RS485ModeEd: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function SelectedCom: String;
    function SelectedComNum: Word;
    { Public declarations }
  end;

implementation

uses
  OoMisc,
  AwUser,
  AwWin32;

{$R *.dfm}

const
  {True to create a dispatcher to validate the port; false to open the
   port using direct API calls}
  UseDispatcherForAvail : Boolean = True;
  {True to return True even if the port is in use; False to return False
   if the port is in use}
  ShowPortsInUse : Boolean = True;                                  

function IsPortAvailable(ComNum : Cardinal) : Boolean;
  function MakeComName(const Dest : PChar; const ComNum : Cardinal) : PChar;
    {-Return a string like 'COMXX'}
  begin
    {$IFDEF WIN32}
    StrFmt(Dest,'\\.\COM%d',[ComNum]);
    {$ELSE}
    StrFmt(Dest,'COM%d',[ComNum]);
    {$ENDIF}
    MakeComName := Dest;
  end;

var
  ComName : array[0..12] of Char;
  Res : Integer;
  DeviceLayer : TApdBaseDispatcher;
begin
  DeviceLayer := nil;
  try
    if (ComNum = 0) then
      Result := False
    else begin
      if UseDispatcherForAvail then begin
        {$IFDEF Win32}
        DeviceLayer  := TApdWin32Dispatcher.Create(nil);
        {$ELSE}
        DeviceLayer := TApdCommDispatcher.Create(nil);
        {$ENDIF}
        Res := DeviceLayer.OpenCom(MakeComName(ComName,ComNum), 64, 64);
        if (Res < 0) then
          if ShowPortsInUse then
            {$IFDEF Win32}
            Result := GetLastError = DWORD(Abs(ecAccessDenied))
            {$ELSE}
            Result := Res = ie_Open
            {$ENDIF}
          else
            Result := False
        else begin
          Result := True;
          DeviceLayer.CloseCom;
        end;
      end else begin
        {$IFDEF Win32}
        Res := CreateFile(MakeComName(ComName, ComNum),
                 GENERIC_READ or GENERIC_WRITE,
                 0,
                 nil,
                 OPEN_EXISTING,
                 FILE_ATTRIBUTE_NORMAL or
                 FILE_FLAG_OVERLAPPED,
                 0);
        {$ELSE}
        Res := OpenComm(MakeComName(ComName, ComNum), 64, 64);
        {$ENDIF}

        if Res > 0 then begin
          {$IFDEF Win32}
          CloseHandle(Res);
          {$ELSE}
          CloseComm(Res);
          {$ENDIF}
          Result := True;
        end else begin
          if ShowPortsInUse then
            {$IFDEF Win32}
            Result := GetLastError = DWORD(Abs(ecAccessDenied))
            {$ELSE}
            Result := Res = ie_Open
            {$ENDIF}
          else
            Result := False;
        end;
      end;
    end;
  finally
    if UseDispatcherForAvail then                                  
      DeviceLayer.Free;
  end;
end;

procedure TfrmOption.FormCreate(Sender: TObject);
var
  I : Integer;
  S : string;
begin
  for I := 1 to MaxComHandles do
    if IsPortAvailable(I) then begin
      S := Format('COM%d', [I]);
      PortsComboBox.Items.Add(S);
    end;
  PortsComboBox.ItemIndex := 0;
end;

function TfrmOption.SelectedCom: String;
begin
  Result := PortsComboBox.Items[PortsComboBox.ItemIndex];
end;

function TfrmOption.SelectedComNum: Word;
var
  S : String;
begin
  S := PortsComboBox.Items[PortsComboBox.ItemIndex];
  S := Copy(S, 4, 255);
  Result := StrToInt(S);
end;

end.
