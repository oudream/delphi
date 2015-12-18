unit OptionUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, AdPort;

type
  TProxyType = (ptNone, ptMKInit);

  TOption = class(TObject)
  private
    FChanged: Boolean;
    FProxy: TProxyType;
    FRS485Mode: Boolean;
  protected
    FBaud: LongInt;
    FComNumber: Word;
    FDataBits: Word;
    FParity: TParity;
    FStopBits: Word;
  public
    constructor Create;
    procedure ViewForm;
    property Baud: LongInt read FBaud default adpoDefBaudRt;
    property Changed: Boolean read FChanged;
    property ComNumber: Word read FComNumber default adpoDefComNumber;
    property DataBits: Word read FDataBits default adpoDefDatabits;
    property Parity: TParity read FParity default adpoDefParity;
    property Proxy: TProxyType read FProxy;
    property RS485Mode: Boolean read FRS485Mode;
    property StopBits: Word read FStopBits default adpoDefStopbits;
  end;

implementation

uses OptionForm;

constructor TOption.Create;
begin
  FBaud      := 9600;
  FComNumber := 1;
  FDataBits  := 8;
  FParity    := pNone;
  FStopBits  := 1;
  FProxy := ptNone;
end;

procedure TOption.ViewForm;
var
  frm: TfrmOption;
begin
  frm:= TfrmOption.Create(nil);
  try
    frm.RadioGroup1.ItemIndex := frm.RadioGroup1.Items.IndexOf(IntToStr(FBaud));
    frm.PortsComboBox.ItemIndex := frm.PortsComboBox.Items.IndexOf('COM' + IntToStr(FComNumber));
    frm.RadioGroup2.ItemIndex := frm.RadioGroup2.Items.IndexOf(IntToStr(FDataBits));
    frm.RadioGroup3.ItemIndex := frm.RadioGroup3.Items.IndexOf(IntToStr(FStopBits));
    frm.RadioGroup5.ItemIndex := ord(FParity);
    frm.RS485ModeEd.Checked := FRS485Mode;
    if frm.ShowModal = mrOk then
    begin
      FBaud := strToInt(frm.RadioGroup1.Items[frm.RadioGroup1.ItemIndex]);
      FComNumber := frm.SelectedComNum;
      FDataBits := strToInt(frm.RadioGroup2.Items[frm.RadioGroup2.ItemIndex]);
      FStopBits := strToInt(frm.RadioGroup3.Items[frm.RadioGroup3.ItemIndex]);
      FParity := TParity(frm.RadioGroup5.ItemIndex);
      FRS485Mode := frm.RS485ModeEd.Checked;
    end;
  finally
    frm.Free;
  end;
end;

end.
