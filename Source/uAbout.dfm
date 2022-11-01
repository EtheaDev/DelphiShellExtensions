object FrmAbout: TFrmAbout
  Left = 651
  Top = 323
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 316
  ClientWidth = 446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    446
    316)
  TextHeight = 13
  object TitleLabel: TLabel
    Left = 8
    Top = 8
    Width = 116
    Height = 13
    Caption = 'SVG Preview - Freeware'
  end
  object LabelVersion: TLabel
    Left = 8
    Top = 34
    Width = 35
    Height = 13
    Caption = 'Version'
  end
  object Panel1: TPanel
    Left = 0
    Top = 265
    Width = 446
    Height = 51
    Align = alBottom
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    TabOrder = 0
    ExplicitTop = 264
    ExplicitWidth = 442
    object btnOK: TButton
      Left = 360
      Top = 16
      Width = 75
      Height = 25
      Caption = 'CLOSE'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnIssues: TButton
      Left = 8
      Top = 16
      Width = 125
      Height = 25
      Caption = 'Submit issue...'
      ImageIndex = 0
      TabOrder = 1
      OnClick = btnIssuesClick
    end
    object btnCheckUpdates: TButton
      Left = 139
      Top = 16
      Width = 125
      Height = 25
      Caption = 'Check for updates'
      ImageIndex = 3
      TabOrder = 2
      Visible = False
      OnClick = btnCheckUpdatesClick
    end
  end
  object MemoCopyRights: TMemo
    Left = 8
    Top = 83
    Width = 427
    Height = 176
    Anchors = [akLeft, akTop, akBottom]
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitHeight = 175
  end
  object LinkLabel: TLinkLabel
    Left = 8
    Top = 62
    Width = 280
    Height = 19
    Caption = 
      '<a href="https://github.com/EtheaDev/SVGShellExtensions">https:/' +
      '/github.com/EtheaDev/DelphiShellExtensions</a>'
    TabOrder = 2
    UseVisualStyle = True
    OnClick = LinkLabelClick
  end
end
