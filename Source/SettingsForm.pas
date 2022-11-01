{******************************************************************************}
{                                                                              }
{       Delphi Shell Extensions: Template form Shell extensions                }
{                                                                              }
{       Copyright (c) 2022 (Ethea S.r.l.)                                      }
{       Author: Carlo Barazzetta                                               }
{                                                                              }
{       https://github.com/EtheaDev/DelphiShellExtensions                      }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{  The Original Code is:                                                       }
{  Delphi Preview Handler  https://github.com/RRUZ/delphi-preview-handler      }
{                                                                              }
{  The Initial Developer of the Original Code is Rodrigo Ruz V.                }
{  Portions created by Rodrigo Ruz V. are Copyright 2011-2021 Rodrigo Ruz V.   }
{  All Rights Reserved.                                                        }
{******************************************************************************}
unit SettingsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, ColorGrd, StdCtrls, CheckLst,
  ActnList, System.ImageList, Vcl.ImgList,
  uSettings, Vcl.ButtonGroup,
  Vcl.ToolWin, Vcl.VirtualImageList, uAbout, Vcl.WinXCtrls,
  Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type
  TUserSettingsForm = class(TForm)
    pc: TPageControl;
    StatusBar: TStatusBar;
    OpenDialog: TOpenDialog;
    tsFont: TTabSheet;
    stTheme: TTabSheet;
    FontLabel: TLabel;
    CbFont: TComboBox;
    SizeLabel: TLabel;
    EditFontSize: TEdit;
    FontSizeUpDown: TUpDown;
    MenuButtonGroup: TButtonGroup;
    TitlePanel: TPanel;
    ThemeLeftPanel: TPanel;
    ThemesRadioGroup: TRadioGroup;
    SelectThemeRadioGroup: TRadioGroup;
    ThemeClientPanel: TPanel;
    stGeneral: TTabSheet;
    PanelTopTheme: TPanel;
    PanelTopFont: TPanel;
    PanelTopPreviewSettings: TPanel;
    ShowEditorCheckBox: TCheckBox;
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    procedure ExitFromSettings(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuButtonGroupButtonClicked(Sender: TObject; Index: Integer);
    procedure SelectThemeRadioGroupClick(Sender: TObject);
    procedure ThemesRadioGroupClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CbFontDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
  private
    FFileName: string;
    FAboutForm: TFrmAbout;
    FTitle: string;
    procedure PopulateAvailThemes;
    procedure AssignSettings(ASettings: TSettings);
    procedure UpdateSettings(ASettings: TSettings);
    procedure SetTitle(const Value: string);
    procedure ChangePage(AIndex: Integer);
    procedure CreateAboutForm;
    function SelectedStyleName: string;
    property Title: string read FTitle write SetTitle;
  public
  end;

function ShowSettings(const AParentRect: TRect;
  const ATitle: string;
  const ASettings: TSettings;
  AFromPreview: Boolean): Boolean;

implementation

uses
  System.UITypes,
  Vcl.Themes,
  uRegistry;

{$R *.dfm}

function ShowSettings(const AParentRect: TRect;
  const ATitle: string;
  const ASettings: TSettings; AFromPreview: Boolean): Boolean;
var
  LSettingsForm: TUserSettingsForm;
  I: integer;
begin
  Result := False;
  for I := 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].ClassType = TUserSettingsForm then
    begin
      Screen.Forms[I].BringToFront;
      exit;
    end;

  LSettingsForm := TUserSettingsForm.Create(nil);
  with LSettingsForm do
  Try
    Title := ATitle;
    AssignSettings(ASettings);
    if (AparentRect.Left <> 0) and (AparentRect.Right <> 0) then
    begin
      LSettingsForm.Left := (AParentRect.Left + AParentRect.Right - LSettingsForm.Width) div 2;
      LSettingsForm.Top := (AParentRect.Top + AParentRect.Bottom - LSettingsForm.Height) div 2;
    end;
    StatusBar.SimpleText := FFileName;

    Result := ShowModal = mrOk;
    if Result then
      UpdateSettings(ASettings);
  Finally
    LSettingsForm.Free;
  End;
end;

{ TUserSettingsForm }

procedure TUserSettingsForm.CbFontDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with CbFont do
  begin
    Canvas.fillrect(rect);
    Canvas.Font.Name  := Items[Index];
    Canvas.textout(rect.Left, rect.Top, Items[Index]);
  end;
end;

procedure TUserSettingsForm.SelectThemeRadioGroupClick(Sender: TObject);
begin
  ThemeClientPanel.StyleName := SelectedStyleName;
  CreateAboutForm;
end;

procedure TUserSettingsForm.SetTitle(const Value: string);
begin
  FTitle := Value;
  TitlePanel.Caption := '  '+FTitle+' - '+TitlePanel.Caption;
  Caption := TitlePanel.Caption;
end;

procedure TUserSettingsForm.ThemesRadioGroupClick(Sender: TObject);
begin
  PopulateAvailThemes;
end;

procedure TUserSettingsForm.FormCreate(Sender: TObject);
begin
  tsFont.TabVisible := False;
  stTheme.TabVisible := False;
  stGeneral.TabVisible := False;
  CbFont.Items.Assign(Screen.Fonts);
  TitlePanel.Font.Height := Round(TitlePanel.Font.Height * 1.5);
  MenuButtonGroup.Font.Height := Round(MenuButtonGroup.Font.Height * 1.2);
  PanelTopPreviewSettings.Font.Style := PanelTopPreviewSettings.Font.Style + [fsBold];
  PanelTopTheme.Font.Style := PanelTopTheme.Font.Style + [fsBold];
  PanelTopFont.Font.Style := PanelTopFont.Font.Style + [fsBold];
end;

procedure TUserSettingsForm.FormDestroy(Sender: TObject);
begin
  FAboutForm.Free;
end;

procedure TUserSettingsForm.ChangePage(AIndex: Integer);
begin
  pc.ActivePageIndex := AIndex;
end;

procedure TUserSettingsForm.AssignSettings(ASettings: TSettings);
begin
  ChangePage(ASettings.ActivePageIndex);
  MenuButtonGroup.ItemIndex := pc.ActivePageIndex +1;
  FFileName := ASettings.SettingsFileName;
  ThemesRadioGroup.ItemIndex := Ord(ASettings.ThemeSelection);
  CbFont.ItemIndex := CbFont.Items.IndexOf(ASettings.FontName);
  FontSizeUpDown.Position := ASettings.FontSize;
  ShowEditorCheckBox.Checked := ASettings.ShowEditor;
  PopulateAvailThemes;
end;

function TUserSettingsForm.SelectedStyleName: string;
begin
  if SelectThemeRadioGroup.ItemIndex <> -1 then
    Result := SelectThemeRadioGroup.Items[SelectThemeRadioGroup.ItemIndex]
  else
    Result := DefaultStyleName;
end;

procedure TUserSettingsForm.UpdateSettings(ASettings: TSettings);
begin
  ASettings.ActivePageIndex := pc.ActivePageIndex;
  ASettings.ThemeSelection := TThemeSelection(ThemesRadioGroup.ItemIndex);
  ASettings.FontName := CbFont.Text;
  ASettings.FontSize := FontSizeUpDown.Position;
  ASettings.StyleName := SelectedStyleName;
  ASettings.ShowEditor := ShowEditorCheckBox.Checked;
end;

procedure TUserSettingsForm.MenuButtonGroupButtonClicked(Sender: TObject;
  Index: Integer);
begin
  if Sender is TButtonGroup then
  begin
    case Index of
      0: ExitFromSettings(nil);
      1,2,3,4: ChangePage(Index -1);
    else
      Beep;
    end;
  end;
end;

procedure TUserSettingsForm.CreateAboutForm;
begin
  FAboutForm.Free;
  FAboutForm := TFrmAbout.Create(Self);
  FAboutForm.BorderIcons := [];
  FAboutForm.Title := FTitle;
  FAboutForm.Parent := ThemeClientPanel;
  FAboutForm.Align := alClient;
  FAboutForm.DisableButtons;
  FAboutForm.btnOK.OnClick := ExitFromSettings;
  FAboutForm.Visible := True;
end;

procedure TUserSettingsForm.PopulateAvailThemes;
var
  I: Integer;
  IsLight: Boolean;
  LStyleName: string;
  LThemeAttributes: TThemeAttribute;
begin
  if TThemeSelection(ThemesRadioGroup.ItemIndex) = tsAsWindows then
    IsLight := IsWindowsAppThemeLight
  else
    IsLight := TThemeSelection(ThemesRadioGroup.ItemIndex) = tsLightTheme;

  SelectThemeRadioGroup.Items.Clear;
  for I := 0 to High(TStyleManager.StyleNames) do
  begin
    LStyleName := TStyleManager.StyleNames[I];
    TThemeAttribute.GetStyleAttributes(LStyleName, LThemeAttributes);
    if not Assigned(LThemeAttributes) then
      Continue;
    if IsLight and (LThemeAttributes.ThemeType = ttLight) or
      (not IsLight and (LThemeAttributes.ThemeType = ttDark)) then
      SelectThemeRadioGroup.Items.Add(LStyleName);
  end;
  SelectThemeRadioGroup.OnClick := nil;
  try
    TStringList(SelectThemeRadioGroup.Items).Sort;
    SelectThemeRadioGroup.ItemIndex :=
      SelectThemeRadioGroup.Items.IndexOf(TStyleManager.ActiveStyle.Name);
    if SelectThemeRadioGroup.ItemIndex = -1 then
      SelectThemeRadioGroup.ItemIndex := 0;
  finally
    SelectThemeRadioGroup.OnClick := SelectThemeRadioGroupClick;
    SelectThemeRadioGroupClick(SelectThemeRadioGroup);
  end;
end;

procedure TUserSettingsForm.ExitFromSettings(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
