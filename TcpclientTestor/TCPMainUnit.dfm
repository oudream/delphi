object TCPTestForm: TTCPTestForm
  Left = 193
  Top = 141
  Width = 696
  Height = 480
  Caption = 'TCP'#36830#25509#27979#35797#24037#20855
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #26032#23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 41
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 150
      Top = 14
      Width = 21
      Height = 13
      Caption = 'IP:'
    end
    object Label2: TLabel
      Left = 312
      Top = 14
      Width = 35
      Height = 13
      Caption = #31471#21475':'
    end
    object Button1: TButton
      Left = 512
      Top = 8
      Width = 75
      Height = 25
      Caption = #36830#25509#20027#26426
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 597
      Top = 8
      Width = 75
      Height = 25
      Caption = #21457#36865#25968#25454
      TabOrder = 1
      OnClick = Button2Click
    end
    object CheckBox1: TCheckBox
      Left = 7
      Top = 3
      Width = 113
      Height = 17
      Caption = #26174#31034#25509#25910#25968#25454
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object Edit1: TEdit
      Left = 176
      Top = 10
      Width = 121
      Height = 21
      TabOrder = 3
      Text = '127.0.0.1'
    end
    object Edit2: TEdit
      Left = 344
      Top = 10
      Width = 121
      Height = 21
      TabOrder = 4
      Text = '5555'
    end
    object CheckBox2: TCheckBox
      Left = 8
      Top = 20
      Width = 97
      Height = 17
      Caption = #33258#21160#21457#36865
      TabOrder = 5
      OnClick = CheckBox2Click
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
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = ClientSocket1Connect
    OnDisconnect = ClientSocket1Disconnect
    OnRead = ClientSocket1Read
    OnError = ServerSocket1ClientError
    Left = 472
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 200
    Top = 89
  end
end
