#ifndef AppVersion
  #define AppVersion "1.0.1"
#endif

[Setup]
AppId={{125E942D-5E71-45B7-9B9A-20414ABFF418}
AppName=Attendance
AppVersion={#AppVersion}
AppPublisher=Gryvaen
DefaultDirName={localappdata}\Programs\Attendance
DefaultGroupName=Attendance
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\dist
OutputBaseFilename=AttendanceInstaller
SetupIconFile=..\Attendance\Resources\Images\Icon.ico
UninstallDisplayIcon={app}\Attendance.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Files]
Source: "..\artifacts\publish\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Attendance"; Filename: "{app}\Attendance.exe"
Name: "{userdesktop}\Attendance"; Filename: "{app}\Attendance.exe"; Tasks: desktopicon

[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; Flags: unchecked

[Run]
Filename: "{app}\Attendance.exe"; Description: "Launch Attendance"; Flags: nowait postinstall skipifsilent
