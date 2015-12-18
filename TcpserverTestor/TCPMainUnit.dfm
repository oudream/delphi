object TCPTestForm: TTCPTestForm
  Left = 187
  Top = 391
  Width = 696
  Height = 480
  Caption = 'TCP Server '#36830#25509#27979#35797#24037#20855
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #26032#23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 41
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 208
      Top = 3
      Width = 78
      Height = 30
      Caption = #24320#22987#30417#21548
      TabOrder = 0
      OnClick = Button1Click
    end
    object SpinEdit1: TSpinEdit
      Left = 9
      Top = 8
      Width = 64
      Height = 22
      MaxValue = 65536
      MinValue = 0
      TabOrder = 1
      Value = 5555
    end
    object Button2: TButton
      Left = 592
      Top = 3
      Width = 75
      Height = 30
      Caption = #21457#36865#25968#25454
      TabOrder = 2
      OnClick = Button2Click
    end
    object CheckBox1: TCheckBox
      Left = 320
      Top = 10
      Width = 113
      Height = 17
      Caption = #26174#31034#25509#25910#25968#25454
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object SpinEdit2: TSpinEdit
      Left = 513
      Top = 8
      Width = 72
      Height = 22
      MaxValue = 65536
      MinValue = 0
      TabOrder = 4
      Value = 1
      OnChange = SpinEdit2Change
    end
    object LocalIpsEd: TComboBox
      Left = 80
      Top = 8
      Width = 121
      Height = 21
      ItemHeight = 13
      TabOrder = 5
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 680
    Height = 382
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 337
      Top = 0
      Height = 382
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 337
      Height = 382
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel3'
      TabOrder = 0
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 337
        Height = 382
        Align = alClient
        Lines.Strings = (
          'Memo1')
        TabOrder = 0
      end
    end
    object Panel4: TPanel
      Left = 340
      Top = 0
      Width = 340
      Height = 382
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel4'
      TabOrder = 1
      object Memo2: TMemo
        Left = 0
        Top = 0
        Width = 340
        Height = 382
        Align = alClient
        Lines.Strings = (
          'Memo2')
        TabOrder = 0
        OnChange = Memo2Change
        OnKeyPress = Memo2KeyPress
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 423
    Width = 680
    Height = 19
    Panels = <>
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 624
    Top = 8
  end
end
