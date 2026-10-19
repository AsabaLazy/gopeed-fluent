#ifndef MyAppName
#define MyAppName "Gopeed(Fluent)"
#endif
#ifndef MyAppVersion
#define MyAppVersion "1.9.3"
#endif
#ifndef MyAppPublisher
#define MyAppPublisher "Minessential"
#endif
#ifndef MyAppURL
#define MyAppURL "https://github.com/AsabaLazy/gopeed-fluent"
#endif
#ifndef MyAppExeName
#define MyAppExeName "gopeed.exe"
#endif
#ifndef Architectures
#define Architectures "x64"
#endif
#define AppUserModelID "Mine.Gopeed.Fluent"
#define AppUserModelToastActivatorCLSID "0197064E-A982-7D4A-8AAA-B3F15AF86E60"

[CustomMessages]
english.DeleteUserData=Would you like to delete all user data and settings?%n(Located in %APPDATA%\Gopeed(Fluent) folder)
chinesesimplified.DeleteUserData=是否同时删除所有用户数据和设置？%n(位于 %APPDATA%\Gopeed(Fluent) 文件夹)

[Setup]
AppId={{0197064E-A982-7D4A-8AAA-B3F15AF86E60}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
LicenseFile=..\..\..\..\LICENSE
OutputDir=Output
OutputBaseFilename=gopeed
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=yes
CloseApplications=force

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#Architectures}\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  AppDataPath: string;
  ExitCode: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    if MsgBox(CustomMessage('DeleteUserData'), mbConfirmation, MB_YESNO) = IDYES then
    begin
      Exec('taskkill', '/F /IM gopeed.exe', '', SW_HIDE, ewWaitUntilTerminated, ExitCode);
      Exec('taskkill', '/F /IM host.exe', '', SW_HIDE, ewWaitUntilTerminated, ExitCode);
      AppDataPath := ExpandConstant('{userappdata}\Gopeed(Fluent)');
      if DirExists(AppDataPath) then DelTree(AppDataPath, True, True, True);
      AppDataPath := ExpandConstant('{localappdata}\Gopeed(Fluent)');
      if DirExists(AppDataPath) then DelTree(AppDataPath, True, True, True);
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Google\Chrome\NativeMessagingHosts\com.gopeed.gopeed');
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Mozilla\NativeMessagingHosts\com.gopeed.gopeed');
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Classes\magnet');
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Classes\.torrent');
      RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Classes\Gopeed_torrent');
    end;
  end;
  if CurUninstallStep = usDone then
  begin
    DelTree(ExpandConstant('{app}'), True, True, True);
  end;
end;

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}";  AppUserModelID: "{#AppUserModelID}"; AppUserModelToastActivatorCLSID: "{#AppUserModelToastActivatorCLSID}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; AppUserModelID: "{#AppUserModelID}"; AppUserModelToastActivatorCLSID: "{#AppUserModelToastActivatorCLSID}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
