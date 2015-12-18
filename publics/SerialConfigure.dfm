object SerialConfigureFrm: TSerialConfigureFrm
  Left = 239
  Top = 120
  BorderStyle = bsDialog
  Caption = #37197#32622#20018#21475
  ClientHeight = 398
  ClientWidth = 424
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
  object BaudRateRG: TRadioGroup
    Left = 16
    Top = 168
    Width = 385
    Height = 89
    Caption = '&B'#27874#29305#29575
    Columns = 5
    ItemIndex = 6
    Items.Strings = (
      '110'
      '300'
      '600'
      '1200'
      '2400'
      '4800'
      '9600'
      '14400'
      '19200'
      '38400'
      '56000'
      '57600'
      '115200'
      '128000'
      '256000')
    TabOrder = 0
  end
  object ByteSizeRG: TRadioGroup
    Left = 192
    Top = 24
    Width = 209
    Height = 49
    Caption = '&D'#25968#25454#20301
    Columns = 5
    ItemIndex = 3
    Items.Strings = (
      '5'
      '6'
      '7'
      '8')
    TabOrder = 1
  end
  object StopBitsRG: TRadioGroup
    Left = 16
    Top = 88
    Width = 161
    Height = 73
    Caption = '&S'#20572#27490#20301
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      '1'
      '2')
    TabOrder = 2
  end
  object CommNameGB: TGroupBox
    Left = 16
    Top = 24
    Width = 161
    Height = 49
    Caption = '&C'#36890#35759#21475
    TabOrder = 3
    object CommNameCB: TComboBox
      Left = 10
      Top = 17
      Width = 143
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'COM1'
      Items.Strings = (
        'COM1'
        'COM2'
        'COM3'
        'COM4'
        'COM5'
        'COM6'
        'COM7'
        'COM8'
        'COM9'
        'COM10'
        'COM11'
        'COM12'
        'COM13'
        'COM14'
        'COM15'
        'COM16'
        'COM17'
        'COM18'
        'COM19')
    end
  end
  object ParityRG: TRadioGroup
    Left = 192
    Top = 88
    Width = 209
    Height = 73
    Caption = '&P'#26816#39564
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'None'
      'Odd'
      'Even'
      'Mark'
      'Space')
    TabOrder = 4
  end
  object StreamControlGB: TGroupBox
    Left = 16
    Top = 264
    Width = 385
    Height = 49
    Caption = '&S'#27969#25511#21046
    TabOrder = 5
    object StreamControlCB: TComboBox
      Left = 10
      Top = 17
      Width = 367
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        #26080
        #30828#20214#27969)
    end
  end
  object Button1: TButton
    Left = 88
    Top = 344
    Width = 81
    Height = 33
    Caption = #30830#23450
    ModalResult = 1
    TabOrder = 6
  end
  object Button2: TButton
    Left = 240
    Top = 344
    Width = 81
    Height = 33
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 7
  end
end
