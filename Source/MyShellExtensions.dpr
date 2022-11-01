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
library MyShellExtensions;
uses
  ComServ,
  Main in 'Main.pas',
  uMisc in 'uMisc.pas',
  uRegistry in 'uRegistry.pas',
  uLogExcept in 'uLogExcept.pas',
  uStreamPreviewHandler in 'uStreamPreviewHandler.pas',
  uCommonPreviewHandler in 'uCommonPreviewHandler.pas',
  uPreviewHandler in 'uPreviewHandler.pas',
  uPreviewContainer in 'uPreviewContainer.pas' {PreviewContainer},
  uMyPreviewHandler in 'uMyPreviewHandler.pas',
  uPreviewHandlerRegister in 'uPreviewHandlerRegister.pas',
  uMyThumbnailHandler in 'uMyThumbnailHandler.pas',
  uThumbnailHandlerRegister in 'uThumbnailHandlerRegister.pas',
  uMyContextMenuHandler in 'uMyContextMenuHandler.pas',
  PreviewForm in 'PreviewForm.pas' {FrmPreview},
  SettingsForm in 'SettingsForm.pas' {UserSettingsForm},
  uSettings in 'uSettings.pas',
  uAbout in 'uAbout.pas' {FrmAbout};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

  {$R *.res}

begin
end.
