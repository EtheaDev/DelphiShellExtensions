// **************************************************************************************************
//
// Unit uPreviewContainer
// unit for the Delphi Preview Handler https://github.com/RRUZ/delphi-preview-handler
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is uPreviewContainer.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2021 Rodrigo Ruz V.
// All Rights Reserved.
//
// *************************************************************************************************

unit uPreviewContainer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TPreviewContainer = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPreviewHandler: TObject;
    FActualRect: TRect;
  public
    procedure SetFocusTabFirst;
    procedure SetFocusTabLast;
    procedure SetBackgroundColor(color: TColorRef);
    procedure SetBoundsRectAndPPI(const ARect: TRect; AOldPPI, ANewPPI: Integer); virtual;
    procedure SetTextColor(color: TColorRef);
    procedure SetTextFont(const plf: TLogFont);
    property PreviewHandler: TObject read FPreviewHandler write FPreviewHandler;
    property ActualRect: TRect read FActualRect;
  end;

function GetRect(const ARect: TRect; const ATxt: string): string;

implementation

uses
  System.Math,
  Vcl.Styles,
  Vcl.Themes,
  uLogExcept,
  uSettings;

{$R *.dfm}

function GetRect(const ARect: TRect; const ATxt: string): string;
begin
  Result := Format('%s: L:%d - T:%d - W:%d - H:%d',
    [ATxt, ARect.Left, ARect.Top, ARect.Width, ARect.Height]);
end;

procedure TPreviewContainer.SetFocusTabFirst;
begin
  SelectNext(nil, True, True);
end;

procedure TPreviewContainer.SetFocusTabLast;
begin
  SelectNext(nil, False, True);
end;

procedure TPreviewContainer.FormCreate(Sender: TObject);
var
  LSettings: TPreviewSettings;
begin
  TLogPreview.Add('TPreviewContainer.FormCreate'+
    'ScaleFactor: '+Self.ScaleFactor.ToString+
    'CurrentPPI '+Self.CurrentPPI.ToString);
  LSettings := TPreviewSettings.CreateSettings;
  try
    if (Trim(LSettings.StyleName) <> '') and not SameText('Windows', LSettings.StyleName) then
      TStyleManager.TrySetStyle(LSettings.StyleName, False);
  finally
    LSettings.Free;
  end;
  TLogPreview.Add('TPreviewContainer.FormCreate Done');
end;

procedure TPreviewContainer.FormDestroy(Sender: TObject);
begin
  TLogPreview.Add('TPreviewContainer.FormDestroy');
end;

procedure TPreviewContainer.SetBackgroundColor(color: TColorRef);
begin
end;

procedure TPreviewContainer.SetBoundsRectAndPPI(const ARect: TRect;
  AOldPPI, ANewPPI: Integer);
var
  Lmsg: string;
  LActualMonitor, LMainMonitor: TMonitor;
  LScaleFactor: Double;
  I: Integer;
begin
  LActualMonitor := Screen.MonitorFromWindow(Self.Handle);
  LMainMonitor := LActualMonitor;
  for I := 0 to Screen.MonitorCount do
  begin
    LMainMonitor := Screen.Monitors[I];
    if LMainMonitor.Primary then
      Break;
  end;

  if LMainMonitor <> LActualMonitor then
  begin
    LScaleFactor := LActualMonitor.PixelsPerInch / LMainMonitor.PixelsPerInch;
    ARect.Width := Round(ARect.Width * LScaleFactor);
    ARect.Height := Round(ARect.Height * LScaleFactor);
  end;

  Lmsg := 'TPreviewContainer.SetBoundsRect:'+
  ' Visible: '+Self.Visible.Tostring+slineBreak+
    ' ANewPPI = AOldPPI'+slineBreak+
    ' Form.CurrentPPI:'+Self.CurrentPPI.ToString+slineBreak+
    ' Form.Scaled:'+Self.Scaled.ToString+slineBreak+
    ' AOldPPI:'+AOldPPI.ToString+slineBreak+
    ' ANewPPI:'+ANewPPI.ToString+slineBreak+
    ' Scaled:'+Self.Scaled.ToString+slineBreak+
    ' ARect.Width: '+ARect.Width.ToString+slineBreak+
    ' ARect.Height: '+ARect.Height.ToString+slineBreak;

  SetWindowPos(WindowHandle, 0, ARect.Left, ARect.Top, ARect.Width, ARect.Height, SWP_NOZORDER + SWP_NOACTIVATE);
  FActualRect := ARect;
  FCurrentPPI := ANewPPI;

  TLogPreview.Add(Lmsg);
end;

procedure TPreviewContainer.SetTextColor(color: TColorRef);
begin
end;

procedure TPreviewContainer.SetTextFont(const plf: TLogFont);
begin
end;

end.
