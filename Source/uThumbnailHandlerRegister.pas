unit uThumbnailHandlerRegister;

interface

uses
  ComObj,
  Classes,
  Windows,
  uMyThumbnailHandler;

type
  TThumbnailHandlerRegister = class(TComObjectFactory)
  private
    FTThumbnailHandlerClass: TThumbnailHandlerClass;
    class procedure DeleteRegValue(const Key, ValueName: string; RootKey: HKEY);
  protected
  public
    constructor Create(ATThumbnailHandlerClass: TThumbnailHandlerClass;
      const APreviewClassID: TGUID; const AName, ADescription: string);
    destructor Destroy; override;
    function CreateComObject(const Controller: IUnknown): TComObject; override;
    procedure UpdateRegistry(Register: Boolean); override;
    property TThumbnailHandlerClass: TThumbnailHandlerClass read FTThumbnailHandlerClass;
  end;


implementation

uses
  Math,
  StrUtils,
  SysUtils,
  ShlObj,
  System.Win.ComConst,
  ComServ;

constructor TThumbnailHandlerRegister.Create(ATThumbnailHandlerClass: TThumbnailHandlerClass;
  const APreviewClassID: TGUID;  const AName, ADescription: string);
begin
  inherited Create(ComServ.ComServer, ATThumbnailHandlerClass.GetComClass,
    APreviewClassID, AName, ADescription, ciMultiInstance, tmBoth);
  FTThumbnailHandlerClass := ATThumbnailHandlerClass;
end;

function TThumbnailHandlerRegister.CreateComObject(const Controller: IUnknown): TComObject;
begin
  result := inherited CreateComObject(Controller);
  TComMyThumbnailProvider(result).ThumbnailHandlerClass := TThumbnailHandlerClass;
end;

class procedure TThumbnailHandlerRegister.DeleteRegValue(const Key, ValueName: string; RootKey: HKEY);
var
  RegKey: HKEY;
begin
  if RegOpenKeyEx(RootKey, PChar(Key), 0, KEY_ALL_ACCESS, regKey) = ERROR_SUCCESS then
  begin
    try
      RegDeleteValue(regKey, PChar(ValueName));
    finally
      RegCloseKey(regKey)
    end;
  end;
end;

destructor TThumbnailHandlerRegister.Destroy;
begin
  inherited;
end;

procedure TThumbnailHandlerRegister.UpdateRegistry(Register: Boolean);

    procedure CreateRegKeyDWORD(const Key, ValueName: string;Value: DWORD; RootKey: HKEY);
    var
      Handle: HKey;
      Status, Disposition: Integer;
    begin
      Status := RegCreateKeyEx(RootKey, PChar(Key), 0, '',
        REG_OPTION_NON_VOLATILE, KEY_READ or KEY_WRITE, nil, Handle,
        @Disposition);
      if Status = 0 then
      begin
        {
        Status := RegSetValueEx(Handle, PChar(ValueName), 0, REG_SZ,
          PChar(Value), (Length(Value) + 1)* sizeof(char));
        }
        Status := RegSetValueEx(Handle, PChar(ValueName), 0, REG_DWORD,
          @Value, sizeof(Value));
        RegCloseKey(Handle);
      end;
      if Status <> 0 then raise EOleRegistrationError.CreateRes(@SCreateRegKeyError);
    end;

  procedure CreateRegKeyREG_SZ(const Key, ValueName: string;Value: string; RootKey: HKEY);
  var
    Handle: HKey;
    Status, Disposition: Integer;
  begin
    Status := RegCreateKeyEx(RootKey, PChar(Key), 0, '',
      REG_OPTION_NON_VOLATILE, KEY_READ or KEY_WRITE, nil, Handle,
      @Disposition);
    if Status = 0 then
    begin
      Status := RegSetValueEx(Handle, PChar(ValueName), 0, REG_SZ,
        PChar(Value), (Length(Value) + 1)* sizeof(char));
      RegCloseKey(Handle);
    end;
    if Status <> 0 then raise EOleRegistrationError.CreateRes(@SCreateRegKeyError);
  end;

var
  RootKey: HKEY;
  RootUserReg: HKEY;
  RootPrefix: string;
  sComServerKey: string;
  ProgID: string;
  sAppID: string;
  sClassID: string;
  LRegKey: string;
begin

  if Instancing = ciInternal then
    Exit;

  ComServer.GetRegRootAndPrefix(RootKey, RootPrefix);
  RootUserReg := IfThen(ComServer.PerUserRegistration, HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE);
  sClassID := SysUtils.GUIDToString(ClassID);
  ProgID := GetProgID;
  sComServerKey := Format('%sCLSID\%s\%s',[RootPrefix,sClassID,ComServer.ServerKey]);
  sAppID := ThumbnailProviderGUID;
  if Register then
  begin
    inherited UpdateRegistry(True);
    LRegKey := Format('%sCLSID\%s',[RootPrefix, sClassID]);
    CreateRegKey(LRegKey, 'AppID', sAppID, RootKey);
    CreateRegKey(LRegKey, 'DisplayName', 'Delphi Svg Thumbnail Provider', RootKey);
    //CreateRegKeyDWORD(LRegKey, 'DisableLowILProcessIsolation', 1, RootKey);

    if ProgID <> '' then
    begin
      CreateRegKey(sComServerKey, 'ProgID', ProgID, RootKey);

      //Add extension for .svg files
      LRegKey := RootPrefix + '.svg' + '\shellex\' + ThumbnailProviderGUID;
      CreateRegKey(LRegKey, '', sClassID, RootKey);
      CreateRegKey(sComServerKey, 'VersionIndependentProgID', ProgID, RootKey);
      LRegKey := RootPrefix + ProgID + '\shellex\' + ThumbnailProviderGUID;
      CreateRegKey(LRegKey, '', sClassID, RootKey);
    end;
  end
  else
  begin
    if ProgID <> '' then
    begin
      DeleteRegValue('SOFTWARE\Microsoft\Windows\CurrentVersion\PreviewHandlers', sClassID, RootUserReg);
      DeleteRegKey(RootPrefix + ProgID + '\shellex', RootKey);
      DeleteRegValue(LRegKey, 'DllSurrogate', RootKey);
      DeleteRegValue(LRegKey, 'DisableLowILProcessIsolation', RootKey);
      //Delete extension for svg
      DeleteRegKey(RootPrefix + '.svg' + '\shellex\' + ThumbnailProviderGUID, RootKey);
    end;
    inherited UpdateRegistry(False);
  end;
end;

end.