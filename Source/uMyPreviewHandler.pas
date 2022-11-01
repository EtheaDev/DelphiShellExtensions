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
unit uMyPreviewHandler;

interface

uses
  Classes,
  Controls,
  StdCtrls,
  SysUtils,
  uCommonPreviewHandler,
  uStreamPreviewHandler,
  uPreviewHandler;

  type
    TMyPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;

const
  //TODO: USE A CUSTOM GUID
  My_PreviewHandlerGUID_64: TGUID = '{D2728FD3-2E54-49B8-8D39-2B2BBF4EB501}';
  My_PreviewHandlerGUID_32: TGUID = '{7F5DC4D3-A3CD-4F3D-8B8E-1D9F9CD15504}';

implementation

Uses
  uLogExcept,
  Windows,
  Forms,
  uMisc;
type
  TWinControlClass = class(TWinControl);

constructor TMyPreviewHandler.Create(AParent: TWinControl);
begin
  TLogPreview.Add('TMyPreviewHandler.Create');
  inherited Create(AParent);
  TLogPreview.Add('TMyPreviewHandler Done');
end;

end.
