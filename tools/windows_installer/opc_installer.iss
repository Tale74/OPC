#ifndef MyAppName
#define MyAppName "OPC"
#endif

#ifndef MyAppVersion
#define MyAppVersion "4.0.0"
#endif

#ifndef MyAppPublisher
#define MyAppPublisher "OPC"
#endif

#ifndef MyAppExeName
#define MyAppExeName "OPC.exe"
#endif

#ifndef MyBuildInputDir
#define MyBuildInputDir "..\_work\build_input"
#endif

#ifndef MyOutputDir
#define MyOutputDir "..\_work\output"
#endif

#define MyAppId "{{4A1E4F3D-C0BE-4D25-8A57-0B6A37972F8B}"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir={#MyOutputDir}
OutputBaseFilename=OPC_Setup_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#MyBuildInputDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
