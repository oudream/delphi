unit SerialConfigure;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TComConfigure = class(TObject)
  private
    FBaud: Integer;
    FComNumber: Word;
    FDataBits: Word;
    FParity: Word;
    FStopBits: Word;
    FStreamControl: byte;
    function GetComName: string;
  public
    function IsSame(pFilename: string): Boolean;
    procedure Load(pFilename: string);
    procedure Save(pFilename: string);
    function ShowConfigure: Boolean;
    property Baud: Integer read FBaud;
    property ComName: string read GetComName;
    property ComNumber: Word read FComNumber;
    property DataBits: Word read FDataBits;
    property Parity: Word read FParity;
    property StopBits: Word read FStopBits;
    property StreamControl: byte read FStreamControl;
  end;

  TSerialConfigureFrm = class(TForm)
    BaudRateRG: TRadioGroup;
    ByteSizeRG: TRadioGroup;
    StopBitsRG: TRadioGroup;
    CommNameGB: TGroupBox;
    CommNameCB: TComboBox;
    ParityRG: TRadioGroup;
    StreamControlGB: TGroupBox;
    StreamControlCB: TComboBox;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses IniFiles;

{$R *.dfm}

//获取串口列表

const
  DefaultBaud = 9600;
  DefaultComNumber = 7;
  DefaultDataBits = 8;
  DefaultParity = 0;
  DefaultStopBits = 1;
  DefaultStreamControl = 0;

procedure TComConfigure.Load(pFilename: string);
var
  aSectionName: string;
  aInif: TIniFile;
begin
  aInif := TIniFile.Create(pFilename);
  try
    aSectionName := 'Channel';

    FBaud := aInif.ReadInteger(aSectionName, 'Baud', DefaultBaud);
    FComNumber := aInif.ReadInteger(aSectionName, 'ComNumber', DefaultComNumber);
    FDataBits := aInif.ReadInteger(aSectionName, 'DataBits', DefaultDataBits);
    FParity := aInif.ReadInteger(aSectionName, 'Parity', DefaultParity);
    FStopBits := aInif.ReadInteger(aSectionName, 'StopBits', DefaultStopBits);
    FStreamControl := byte(aInif.ReadInteger(aSectionName, 'StreamControl', DefaultStreamControl));
  finally
    aInif.Free();
  end;
end;

procedure TComConfigure.Save(pFilename: string);
var
  aSectionName: string;
  aInif: TIniFile;
begin
  aInif := TIniFile.Create(pFilename);
  try
    aSectionName := 'Channel';

    aInif.WriteInteger(aSectionName, 'Baud', FBaud);
    aInif.WriteInteger(aSectionName, 'ComNumber', FComNumber);
    aInif.WriteInteger(aSectionName, 'DataBits', FDataBits);
    aInif.WriteInteger(aSectionName, 'Parity', FParity);
    aInif.WriteInteger(aSectionName, 'StopBits', FStopBits);
    aInif.WriteInteger(aSectionName, 'StreamControl', FStreamControl);
  finally
    aInif.Free();
  end;
end;

function TComConfigure.GetComName: string;
begin
  Result := 'COM' + inttostr(FComNumber);
end;

function TComConfigure.IsSame(pFilename: string): Boolean;
var
  aSectionName: string;
  aInif: TIniFile;
begin
  aInif := TIniFile.Create(pFilename);
  try
    aSectionName := 'Channel';

    Result := false;
    if aInif.ReadInteger(aSectionName, 'Baud', DefaultBaud) <> FBaud then
    begin
      exit;
    end;
    if aInif.ReadInteger(aSectionName, 'ComNumber', DefaultComNumber) <> FComNumber then
    begin
      exit;
    end;
    if aInif.ReadInteger(aSectionName, 'DataBits', DefaultDataBits) <> FDataBits then
    begin
      exit;
    end;
    if aInif.ReadInteger(aSectionName, 'Parity', DefaultParity) <> FParity then
    begin
      exit;
    end;
    if aInif.ReadInteger(aSectionName, 'StopBits', DefaultStopBits) <> FStopBits then
    begin
      exit;
    end;
    if byte(aInif.ReadInteger(aSectionName, 'StreamControl', DefaultStreamControl)) <> FStreamControl then
    begin
      exit;
    end;
    Result := true;
  finally
    aInif.Free();
  end;
end;

function TComConfigure.ShowConfigure: Boolean;
var
  frm: TSerialConfigureFrm;

  function MyViewIn: Boolean;
  var
    s: string;
  begin
    Result := false;

    if frm = nil then
      exit;

    try
      //波
      if FBaud <> strtoint(frm.BaudRateRG.Items[frm.BaudRateRG.ItemIndex]) then
      begin
        FBaud := strtoint(frm.BaudRateRG.Items[frm.BaudRateRG.ItemIndex]);
      end;
      //
      s := frm.CommNameCB.Items[frm.CommNameCB.ItemIndex];
      if ComName <> s then
      begin
        if s = '' then
          FComNumber := DefaultComNumber
        else
          FComNumber := strtoint(copy(s, 4, length(s) - 3));
      end;
      //
      if FStopBits <> strtoint(frm.StopBitsRG.Items[frm.StopBitsRG.ItemIndex])
        then
      begin
        FStopBits := strtoint(frm.StopBitsRG.Items[frm.StopBitsRG.ItemIndex]);
      end;
      //
      if FDataBits <> strtoint(frm.ByteSizeRG.Items[frm.ByteSizeRG.ItemIndex])
        then
      begin
        FDataBits := strtoint(frm.ByteSizeRG.Items[frm.ByteSizeRG.ItemIndex]);
      end;
      //
      if FParity <> frm.ParityRG.ItemIndex then
      begin
        FParity := frm.ParityRG.ItemIndex;
      end;
      //
      if FStreamControl <> frm.StreamControlCB.ItemIndex then
      begin
        FStreamControl := frm.StreamControlCB.ItemIndex;
      end;

      Result := true;
    except
      Result := false;
    end;

  end;

  procedure MyViewOut;
  var
    aIndex: Integer;
  begin
    if frm = nil then
      exit;

    frm.BaudRateRG.ItemIndex := frm.BaudRateRG.Items.IndexOf(IntToStr(FBaud));

    aIndex := frm.CommNameCB.Items.IndexOf(ComName);
    if aIndex > 0 then
      frm.CommNameCB.ItemIndex := aIndex
    else if frm.CommNameCB.Items.Count > 0 then
      frm.CommNameCB.ItemIndex := 0
    else
      frm.CommNameCB.ItemIndex := -1;

    frm.StopBitsRG.ItemIndex :=
      frm.StopBitsRG.Items.IndexOf(IntToStr(FStopBits));
    frm.ByteSizeRG.ItemIndex :=
      frm.ByteSizeRG.Items.IndexOf(IntToStr(FDataBits));
    frm.ParityRG.ItemIndex := FParity;
    frm.StreamControlCB.ItemIndex := FStreamControl;
  end;

begin
  Result := false;

  frm := TSerialConfigureFrm.Create(nil);
  try
    MyViewOut();

    if frm.ShowModal = mrOk then
    begin
      if MyViewIn() then
        Result := true;
    end;
  finally
    frm.Free();
  end;

end;

end.


