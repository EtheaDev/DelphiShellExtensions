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
unit PreviewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, System.Generics.Collections,
  ComCtrls, ToolWin, ImgList, Vcl.Menus,
  uSettings, System.ImageList, Vcl.VirtualImageList,
  UPreviewContainer, Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TFrmPreview = class(TPreviewContainer)
    PanelTop: TPanel;
    EditorPanel: TPanel;
    StatusBar: TStatusBar;
    ToolBar: TToolBar;
    ContentPanel: TPanel;
    Splitter: TSplitter;
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    ToolButtonShowText: TToolButton;
    ToolButtonAbout: TToolButton;
    ToolButtonSettings: TToolButton;
    ContentMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure ToolButtonSettingsClick(Sender: TObject);
    procedure ToolButtonAboutClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ToolButtonShowTextClick(Sender: TObject);
    procedure ToolButtonMouseEnter(Sender: TObject);
    procedure ToolButtonMouseLeave(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
  private
    FFontName: string;
    FFontSize: Integer;
    FSimpleText: string;
    FFileName: string;
    FPreviewSettings: TPreviewSettings;
    class var FAParent: TWinControl;
    function DialogPosRect: TRect;
    procedure AppException(Sender: TObject; E: Exception);
    procedure UpdateGUI;
    procedure UpdateFromSettings;
    procedure SaveSettings;
    procedure SetEditorFontSize(const AValue: Integer);
    procedure SetEditorFontName(const AValue: string);
  protected
  public
    procedure ScaleControls(const ANewPPI: Integer);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class property AParent: TWinControl read FAParent write FAParent;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStream(const AStream: TStream);
    property EditorFontName: string read FFontName write SetEditorFontName;
    property EditorFontSize: Integer read FFontSize write SetEditorFontSize;
  end;


implementation

uses
  Vcl.Clipbrd
  , Vcl.Themes
  , uLogExcept
  , System.Types
  , Registry
  , uMisc
  , IOUtils
  , ShellAPI
  , ComObj
  , IniFiles
  , GraphUtil
  , uAbout
  , Xml.XMLDoc
  , SettingsForm
  ;

{$R *.dfm}

  { TFrmPreview }

procedure TFrmPreview.AppException(Sender: TObject; E: Exception);
begin
  // log unhandled exceptions
  TLogPreview.Add('AppException');
  TLogPreview.Add(E);
end;

constructor TFrmPreview.Create(AOwner: TComponent);
begin
  inherited;
  FPreviewSettings := TPreviewSettings.CreateSettings;
end;

destructor TFrmPreview.Destroy;
begin
  FreeAndNil(FPreviewSettings);
  inherited;
end;

function TFrmPreview.DialogPosRect: TRect;
begin
  Result := ClientToScreen(ActualRect);
end;

procedure TFrmPreview.UpdateGUI;
begin
  if EditorPanel.Visible then
  begin
    Splitter.Top := EditorPanel.Top + EditorPanel.Height;
    Splitter.Visible := True;
    ToolButtonShowText.Caption := 'Hide Text';
    ToolButtonShowText.Hint := 'Hide content of file';
  end
  else
  begin
    Splitter.Visible := False;
    ToolButtonShowText.Caption := 'Show Text';
    ToolButtonShowText.Hint := 'Show content of file';
  end;
  ToolButtonShowText.Visible := True;
  ToolButtonAbout.Visible := True;
  ToolButtonSettings.Visible := True;
end;

procedure TFrmPreview.FormCreate(Sender: TObject);
var
  FileVersionStr: string;
begin
  inherited;
  TLogPreview.Add('TFrmPreview.FormCreate');
  FileVersionStr := uMisc.GetFileVersion(GetModuleLocation());
  FSimpleText := Format(StatusBar.SimpleText,
    [FileVersionStr, {$IFDEF WIN32}32{$ELSE}64{$ENDIF}]);
  StatusBar.SimpleText := FSimpleText;
  Application.OnException := AppException;
  UpdateFromSettings;
end;

procedure TFrmPreview.FormDestroy(Sender: TObject);
begin
  HideAboutForm;
  SaveSettings;
  TLogPreview.Add('TFrmPreview.FormDestroy');
  inherited;
end;

procedure TFrmPreview.FormResize(Sender: TObject);
begin
  EditorPanel.Height := Round(Self.Height * (FPreviewSettings.SplitterPos / 100));
  Splitter.Top := EditorPanel.Height;
  if Self.Width < (550 * Self.ScaleFactor) then
    ToolBar.ShowCaptions := False
  else
    Toolbar.ShowCaptions := True;
  UpdateGUI;
end;

procedure TFrmPreview.LoadFromFile(const AFileName: string);
begin
  TLogPreview.Add('TFrmPreview.LoadFromFile Init');
  FFileName := AFileName;
  //TODO: Implement loading of file
  ContentMemo.Lines.LoadFromFile(AFileName);
  TLogPreview.Add('TFrmEditor.LoadFromFile Done');
end;

procedure TFrmPreview.LoadFromStream(const AStream: TStream);
var
  LStringStream: TStringStream;
begin
  TLogPreview.Add('TFrmPreview.LoadFromStream Init');
  AStream.Position := 0;
  LStringStream := TStringStream.Create('',TEncoding.UTF8);
  try
    LStringStream.LoadFromStream(AStream);
    //TODO: Loading content from stream
    ContentMemo.Lines.Text := LStringStream.DataString;
  finally
    LStringStream.Free;
  end;
  TLogPreview.Add('TFrmEditor.LoadFromStream Done');
end;

procedure TFrmPreview.SaveSettings;
begin
  if Assigned(FPreviewSettings) then
  begin
    FPreviewSettings.UpdateSettings(Self.Font.Name,
      EditorFontSize,
      EditorPanel.Visible);
    FPreviewSettings.WriteSettings;
  end;
end;

procedure TFrmPreview.ScaleControls(const ANewPPI: Integer);
var
  LCurrentPPI: Integer;
  LNewSize: Integer;
begin
  LCurrentPPI := FCurrentPPI;
  if ANewPPI <> LCurrentPPI then
  begin
    LNewSize := MulDiv(VirtualImageList.Width, ANewPPI, LCurrentPPI);
    VirtualImageList.SetSize(LNewSize, LNewSize);
  end;
end;

procedure TFrmPreview.SetEditorFontSize(const AValue: Integer);
begin
  if (AValue >= MinfontSize) and (AValue <= MaxfontSize) then
  begin
    FFontSize := AValue;
	  //TODO: assign font size
    ContentMemo.Font.Size := FFontSize;
  end;
end;

procedure TFrmPreview.SetEditorFontName(const AValue: string);
begin
  if FFontName <> AValue then
  begin
    FFontName := AValue;
    ContentMemo.Font.Name := FFontName;
  end;
end;

procedure TFrmPreview.SplitterMoved(Sender: TObject);
begin
  FPreviewSettings.SplitterPos := splitter.Top * 100 div
    (Self.Height - Toolbar.Height);
  SaveSettings;
end;

procedure TFrmPreview.ToolButtonShowTextClick(Sender: TObject);
begin
  EditorPanel.Visible := not EditorPanel.Visible;
  ToolBar.Invalidate;
  UpdateGUI;
  SaveSettings;
end;

procedure TFrmPreview.ToolButtonAboutClick(Sender: TObject);
begin
  ShowAboutForm(DialogPosRect, Title_SVGPreview);
end;

procedure TFrmPreview.ToolButtonMouseEnter(Sender: TObject);
begin
  StatusBar.SimpleText := (Sender as TToolButton).Hint;
end;

procedure TFrmPreview.ToolButtonMouseLeave(Sender: TObject);
begin
  StatusBar.SimpleText := FSimpleText;
end;

procedure TFrmPreview.UpdateFromSettings;
begin
  FPreviewSettings.ReadSettings;
  if FPreviewSettings.FontSize >= MinfontSize then
    EditorFontSize := FPreviewSettings.FontSize
  else
    EditorFontSize := MinfontSize;
  //TODO: Update GUI based on Settings
  EditorPanel.Visible := FPreviewSettings.ShowEditor;
  TStyleManager.TrySetStyle(FPreviewSettings.StyleName, False);
  UpdateGUI;
end;

procedure TFrmPreview.ToolButtonSettingsClick(Sender: TObject);
begin
  if ShowSettings(DialogPosRect, Title_SVGPreview, FPreviewSettings, True) then
  begin
    FPreviewSettings.WriteSettings;
    UpdateFromSettings;
  end;
end;

end.
