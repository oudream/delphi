object frmCac: TfrmCac
  Left = 153
  Top = 260
  BorderStyle = bsDialog
  Caption = #26657#39564#30721#31867#22411#36873#25321
  ClientHeight = 220
  ClientWidth = 371
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 371
    Height = 167
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
    object cgCrc: TRadioGroup
      Left = 16
      Top = 16
      Width = 337
      Height = 105
      Caption = #26657#39564#31867#22411
      ItemIndex = 1
      Items.Strings = (
        'CRC16'#12288#20108#23383#33410#24490#29615#20887#20313#30721#65292#20302#23383#33410#22312#21069#65292#39640#23383#33410#22312#21518
        'CRC8'#12288#20108#23383#33410#24490#29615#20887#20313#30721)
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 80
    Top = 184
    Width = 75
    Height = 25
    Caption = #30830#35748
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 216
    Top = 184
    Width = 75
    Height = 25
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
