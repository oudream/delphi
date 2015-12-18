object UDPTestForm: TUDPTestForm
  Left = 417
  Top = 119
  Width = 973
  Height = 551
  Caption = 'UDP'#36830#25509#27979#35797#65288'EDPF'#25253#25991#26684#24335#20998#26512#65289#24037#20855
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #26032#23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 957
    Height = 41
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 13
      Width = 49
      Height = 13
      Caption = #36828#31243'IP:'
    end
    object Label2: TLabel
      Left = 189
      Top = 13
      Width = 42
      Height = 13
      Caption = 'RPort:'
    end
    object Label3: TLabel
      Left = 296
      Top = 13
      Width = 42
      Height = 13
      Caption = 'LPort:'
    end
    object SpeedButton1: TSpeedButton
      Left = 825
      Top = 4
      Width = 40
      Height = 17
      Caption = #28165#25910
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 825
      Top = 21
      Width = 40
      Height = 17
      Caption = #28165#21457
      OnClick = SpeedButton2Click
    end
    object Button1: TButton
      Left = 405
      Top = 2
      Width = 64
      Height = 34
      Caption = #24320#22987#30417#21548
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 468
      Top = 2
      Width = 39
      Height = 34
      Caption = #21457#36865
      TabOrder = 1
      OnClick = Button2Click
    end
    object Edit2: TEdit
      Left = 231
      Top = 9
      Width = 43
      Height = 21
      TabOrder = 2
      Text = '5555'
    end
    object Edit3: TEdit
      Left = 339
      Top = 9
      Width = 43
      Height = 21
      TabOrder = 3
      Text = '5556'
    end
    object GroupCastEd: TCheckBox
      Left = 557
      Top = 11
      Width = 140
      Height = 17
      Caption = #32452#25773#26041#24335#12288#26412#22320'IP'#65306
      TabOrder = 4
    end
    object GroupIpEd: TEdit
      Left = 62
      Top = 9
      Width = 113
      Height = 21
      TabOrder = 5
      OnExit = GroupIpEdExit
      OnKeyPress = GroupIpEdKeyPress
    end
    object Button3: TButton
      Left = 506
      Top = 2
      Width = 39
      Height = 34
      Caption = #20998#27573
      TabOrder = 6
      OnClick = Button3Click
    end
    object LocalIpsEd: TComboBox
      Left = 700
      Top = 9
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 7
    end
    object SpinEdit3: TSpinEdit
      Left = 872
      Top = 8
      Width = 66
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 8
      Value = 0
      OnChange = SpinEdit3Change
    end
    object Button8: TButton
      Left = 275
      Top = 7
      Width = 18
      Height = 25
      Caption = #25442
      TabOrder = 9
      OnClick = Button8Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 957
    Height = 453
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 260
      Top = 0
      Width = 8
      Height = 453
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 260
      Height = 453
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel3'
      TabOrder = 0
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 260
        Height = 453
        Align = alClient
        Lines.Strings = (
          #25509#25910#21306)
        TabOrder = 0
      end
    end
    object Panel4: TPanel
      Left = 268
      Top = 0
      Width = 689
      Height = 453
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Memo2: TMemo
        Left = 0
        Top = 0
        Width = 689
        Height = 453
        Align = alClient
        Lines.Strings = (
          'a5 5a a5 5a')
        TabOrder = 0
        OnChange = Memo2Change
        OnKeyPress = Memo2KeyPress
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 494
    Width = 957
    Height = 19
    Panels = <>
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer1Timer
    Left = 412
    Top = 97
  end
end
