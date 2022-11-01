object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Preview Handler Host Demo'
  ClientHeight = 559
  ClientWidth = 960
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 505
    Top = 0
    Width = 4
    Height = 559
    AutoSnap = False
    ExplicitLeft = 217
    ExplicitHeight = 338
  end
  object Panel1: TPanel
    Left = 509
    Top = 0
    Width = 451
    Height = 559
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 421
    ExplicitWidth = 535
    ExplicitHeight = 558
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 505
    Height = 559
    Align = alLeft
    TabOrder = 1
    object ShellListView1: TShellListView
      Left = 1
      Top = 1
      Width = 503
      Height = 557
      ObjectTypes = [otFolders, otNonFolders]
      Root = 'D:\ETHEA\DelphiShellExtensions\Test'
      Sorted = True
      Align = alClient
      ReadOnly = False
      HideSelection = False
      OnChange = ShellListView1Change
      TabOrder = 0
      ExplicitWidth = 415
    end
  end
end
