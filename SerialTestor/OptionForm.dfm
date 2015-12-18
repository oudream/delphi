object frmOption: TfrmOption
  Left = 202
  Top = 206
  BorderStyle = bsDialog
  Caption = #36890#35759#21442#25968
  ClientHeight = 443
  ClientWidth = 417
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 104
    Top = 392
    Width = 75
    Height = 25
    Caption = #30830#35748
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 224
    Top = 392
    Width = 75
    Height = 25
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 417
    Height = 361
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 2
    object RadioGroup1: TRadioGroup
      Left = 8
      Top = 8
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
    object RadioGroup2: TRadioGroup
      Left = 8
      Top = 104
      Width = 385
      Height = 41
      Caption = '&D'#25968#25454#20301
      Columns = 5
      ItemIndex = 4
      Items.Strings = (
        '4'
        '5'
        '6'
        '7'
        '8')
      TabOrder = 1
    end
    object RadioGroup3: TRadioGroup
      Left = 8
      Top = 152
      Width = 236
      Height = 41
      Caption = '&S'#20572#27490#20301
      Columns = 3
      ItemIndex = 0
      Items.Strings = (
        '1'
        '1.5'
        '2')
      TabOrder = 2
    end
    object RadioGroup5: TRadioGroup
      Left = 8
      Top = 264
      Width = 235
      Height = 81
      Caption = '&P'#26816#39564
      Columns = 3
      ItemIndex = 0
      Items.Strings = (
        'None'
        'Odd'
        'Even'
        'Mark'
        'Space')
      TabOrder = 3
    end
    object RadioGroup6: TRadioGroup
      Left = 308
      Top = 152
      Width = 85
      Height = 41
      Caption = '&Echo'
      Columns = 2
      Enabled = False
      ItemIndex = 0
      Items.Strings = (
        'Off'
        'On')
      TabOrder = 4
    end
    object RadioGroup7: TRadioGroup
      Left = 308
      Top = 200
      Width = 89
      Height = 145
      Caption = '&Flow Control'
      Enabled = False
      ItemIndex = 0
      Items.Strings = (
        'None'
        'Xon/Xoff'
        'RTS'
        'Xon/RTS')
      TabOrder = 5
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 200
      Width = 236
      Height = 57
      Caption = '&C'#36890#35759#21475
      TabOrder = 6
      object PortsComboBox: TComboBox
        Left = 10
        Top = 22
        Width = 111
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
      end
      object RS485ModeEd: TCheckBox
        Left = 136
        Top = 24
        Width = 89
        Height = 17
        Caption = 'RS485Mode'
        TabOrder = 1
      end
    end
  end
end
