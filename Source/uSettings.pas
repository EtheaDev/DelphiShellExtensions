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
unit uSettings;

interface

uses
  System.SysUtils,
  System.Classes,
  VCL.Graphics,
  System.Generics.Collections,
  IniFiles;

const
  MaxfontSize = 30;
  MinfontSize = 8;
  default_lightbackground = 200;
  default_darkbackground = 55;

type
  TThemeSelection = (tsAsWindows, tsDarkTheme, tsLightTheme);
  TThemeType = (ttLight, ttDark);
  TSVGEngine = (enImage32, enTSVG);

  //Class to register Theme attributes (like dark or light)
  TThemeAttribute = class
    StyleName: String;
    ThemeType: TThemeType;

  //function to get Theme Attributes
  class function GetStyleAttributes(const AStyleName: string;
    out AThemeAttribute: TThemeAttribute): Boolean;
  private
  end;

  TSettings = class
  private
    FSplitterPos: Integer;
    FFontSize: Integer;
    FStyleName: string;
    FUseDarkStyle: boolean;
    FFontName: string;
    FShowEditor: Boolean;
    FActivePageIndex: Integer;
    FThemeSelection: TThemeSelection;
    function GetUseDarkStyle: Boolean;
    class function GetSettingsFileName: string; static;
  protected
    FIniFile: TIniFile;
  public
    LightBackground: Integer;
    constructor CreateSettings(const ASettingFileName: string);
    destructor Destroy; override;

    class var FSettingsFileName: string;
    class var FSettingsPath: string;
    class property SettingsFileName: string read GetSettingsFileName;

    procedure UpdateSettings(const AFontName: string;
      AFontSize: Integer; AEditorVisible: Boolean);
    procedure ReadSettings; Virtual;
    procedure WriteSettings; virtual;

    property UseDarkStyle: Boolean read GetUseDarkStyle;
    property FontSize: Integer read FFontSize write FFontSize;
    property FontName: string read FFontName write FFontName;
    property ShowEditor: Boolean read FShowEditor write FShowEditor;
    property StyleName: string read FStyleName write FStyleName;
    property SplitterPos: Integer read FSplitterPos write FSplitterPos;
    property ActivePageIndex: Integer read FActivePageIndex write FActivePageIndex;
    property ThemeSelection: TThemeSelection read FThemeSelection write FThemeSelection;
  end;

  TPreviewSettings = class(TSettings)
  public
    constructor CreateSettings;
  end;

  TEditorSettings = class(TSettings)
  private
  public
    CurrentFileName: string;
    procedure ReadSettings; override;
    procedure WriteSettings; override;
    constructor CreateSettings;
    destructor Destroy; override;
  end;

implementation

uses
  Vcl.Controls,
  System.Types,
  System.TypInfo,
  System.Rtti,
  System.StrUtils,
  System.IOUtils,
  Winapi.ShlObj,
  Winapi.Windows,
  Vcl.Themes,
  uLogExcept,
  uRegistry,
  uMisc
  ;

var
  ThemeAttributes: TList<TThemeAttribute>;

procedure InitDefaultThemesAttributes;

  procedure RegisterThemeAttributes(
    const AVCLStyleName: string;
    const AThemeType: TThemeType);
  var
    LThemeAttribute: TThemeAttribute;

    procedure UpdateThemeAttributes;
    begin
      LThemeAttribute.StyleName := AVCLStyleName;
      LThemeAttribute.ThemeType := AThemeType;
    end;

  begin
    for LThemeAttribute in ThemeAttributes do
    begin
      if SameText(LThemeAttribute.StyleName, AVCLStyleName) then
      begin
        UpdateThemeAttributes;
        Exit; //Found: exit
      end;
    end;
    //not found
    LThemeAttribute := TThemeAttribute.Create;
    ThemeAttributes.Add(LThemeAttribute);
    UpdateThemeAttributes;
  end;

begin
  ThemeAttributes := TList<TThemeAttribute>.Create;

  if StyleServices.Enabled then
  begin
    //High-DPI Themes (Delphi 11.0)
    RegisterThemeAttributes('Windows'               ,ttLight );
    RegisterThemeAttributes('Aqua Light Slate'      ,ttLight );
    RegisterThemeAttributes('Copper'                ,ttLight );
    RegisterThemeAttributes('CopperDark'            ,ttDark  );
    RegisterThemeAttributes('Coral'                 ,ttLight );
    RegisterThemeAttributes('Diamond'               ,ttLight );
    RegisterThemeAttributes('Emerald'               ,ttLight );
    RegisterThemeAttributes('Flat UI Light'         ,ttLight );
    RegisterThemeAttributes('Glow'                  ,ttDark  );
    RegisterThemeAttributes('Iceberg Classico'      ,ttLight );
    RegisterThemeAttributes('Lavender Classico'     ,ttLight );
    RegisterThemeAttributes('Sky'                   ,ttLight );
    RegisterThemeAttributes('Slate Classico'        ,ttLight );
    RegisterThemeAttributes('Sterling'              ,ttLight );
    RegisterThemeAttributes('Tablet Dark'           ,ttDark  );
    RegisterThemeAttributes('Tablet Light'          ,ttLight );
    RegisterThemeAttributes('Windows10'             ,ttLight );
    RegisterThemeAttributes('Windows10 Blue'        ,ttDark  );
    RegisterThemeAttributes('Windows10 Dark'        ,ttDark  );
    RegisterThemeAttributes('Windows10 Green'       ,ttDark  );
    RegisterThemeAttributes('Windows10 Purple'      ,ttDark  );
    RegisterThemeAttributes('Windows10 SlateGray'   ,ttDark  );
    RegisterThemeAttributes('Glossy'                ,ttDark  );
    RegisterThemeAttributes('Windows10 BlackPearl'  ,ttDark  );
    RegisterThemeAttributes('Windows10 Blue Whale'  ,ttDark  );
    RegisterThemeAttributes('Windows10 Clear Day'   ,ttLight );
    RegisterThemeAttributes('Windows10 Malibu'      ,ttLight );
    RegisterThemeAttributes('Windows11 Modern Dark' ,ttDark  );
    RegisterThemeAttributes('Windows11 Modern Light',ttLight );
  end;
end;

{ TSettings }

constructor TSettings.CreateSettings(const ASettingFileName: string);
begin
  inherited Create;
  FIniFile := TIniFile.Create(ASettingFileName);
  FSettingsFileName := ASettingFileName;
  FSettingsPath := ExtractFilePath(ASettingFileName);
  System.SysUtils.ForceDirectories(FSettingsPath);
  ReadSettings;
end;

destructor TSettings.Destroy;
begin
  FIniFile.UpdateFile;
  FIniFile.Free;
  inherited;
end;

class function TSettings.GetSettingsFileName: string;
begin
  Result := FSettingsFileName;
end;

function TSettings.GetUseDarkStyle: Boolean;
begin
  Result := FUseDarkStyle;
end;

procedure TSettings.ReadSettings;
begin
  TLogPreview.Add('ReadSettings '+SettingsFileName);
  FFontSize := FIniFile.ReadInteger('Global', 'FontSize', 10);
  FFontName := FIniFile.ReadString('Global', 'FontName', 'Consolas');
  FShowEditor := FIniFile.ReadInteger('Global', 'ShowEditor', 1) = 1;
  FSplitterPos := FIniFile.ReadInteger('Global', 'SplitterPos', 33);
  FActivePageIndex := FIniFile.ReadInteger('Global', 'ActivePageIndex', 0);
  FStyleName := FIniFile.ReadString('Global', 'StyleName', DefaultStyleName);
  FThemeSelection := TThemeSelection(FIniFile.ReadInteger('Global', 'ThemeSelection', 0));

  //Select Style by default on Actual Windows Theme
  if FThemeSelection = tsAsWindows then
  begin
    FUseDarkStyle := not IsWindowsAppThemeLight;
  end
  else
    FUseDarkStyle := FThemeSelection = tsDarkTheme;

  if FUseDarkStyle then
    LightBackground := FIniFile.ReadInteger('Global', 'LightBackground', default_darkbackground)
  else
    LightBackground := FIniFile.ReadInteger('Global', 'LightBackground', default_lightbackground);
end;

procedure TSettings.UpdateSettings(const AFontName: string;
  AFontSize: Integer; AEditorVisible: Boolean);
begin
  FontSize := AFontSize;
  FontName := AFontName;
  ShowEditor := AEditorVisible;
end;

procedure TSettings.WriteSettings;
begin
  FIniFile.WriteInteger('Global', 'FontSize', FFontSize);
  FIniFile.WriteString('Global', 'FontName', FFontName);
  FIniFile.WriteString('Global', 'StyleName', FStyleName);
  FIniFile.WriteInteger('Global', 'ShowEditor', Ord(FShowEditor));
  FIniFile.WriteInteger('Global', 'SplitterPos', FSplitterPos);
  FIniFile.WriteInteger('Global', 'ActivePageIndex', FActivePageIndex);
  FIniFile.WriteInteger('Global', 'ThemeSelection', Ord(FThemeSelection));
  if (FUseDarkStyle and (LightBackground <> default_darkbackground)) or
    (not FUseDarkStyle and (LightBackground <> default_lightbackground)) then
    FIniFile.WriteInteger('Global', 'LightBackground', LightBackground);
end;

{ TPreviewSettings }

constructor TPreviewSettings.CreateSettings;
begin
  //TODO: define folder for Settings of Preview
  inherited CreateSettings(
    IncludeTrailingPathDelimiter(
      GetSpecialFolder(CSIDL_APPDATA)) +'MyPreviewHandler\Settings.ini');
end;

{ TEditorSettings }

constructor TEditorSettings.CreateSettings;
begin
  //TODO: define folder for Settings of Editor
  inherited CreateSettings(
    IncludeTrailingPathDelimiter(
      GetSpecialFolder(CSIDL_APPDATA)) +'SVGTextEditor\Settings.ini');
end;

destructor TEditorSettings.Destroy;
begin
  inherited;
end;

procedure TEditorSettings.ReadSettings;
begin
  inherited;
  CurrentFileName := FIniFile.ReadString('Global', 'CurrentFileName', '');
end;

procedure TEditorSettings.WriteSettings;
begin
  inherited;
  FIniFile.WriteString('Global', 'CurrentFileName', CurrentFileName);
end;

{ TThemeAttribute }

class function TThemeAttribute.GetStyleAttributes(const AStyleName: string;
  out AThemeAttribute: TThemeAttribute): Boolean;
var
  LThemeAttribute: TThemeAttribute;
begin
  for LThemeAttribute in ThemeAttributes do
  begin
    if SameText(AStyleName, LThemeAttribute.StyleName) then
    begin
      AThemeAttribute := LThemeAttribute;
      Exit(True);
    end;
  end;
  Result := False;
  AThemeAttribute := nil;
end;

procedure FreeThemesAttributes;
var
  LThemeAttribute: TThemeAttribute;
begin
  if Assigned(ThemeAttributes) then
  begin
    for LThemeAttribute in ThemeAttributes do
      LThemeAttribute.Free;
    FreeAndNil(ThemeAttributes);
  end;
end;

initialization
  InitDefaultThemesAttributes;

finalization
  FreeThemesAttributes;

end.
