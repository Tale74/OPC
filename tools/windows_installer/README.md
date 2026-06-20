# OPC Windows Installer Lane

This lane prepares a standard Inno Setup installer for the Windows build of OPC.

## What uninstall removes

- Installed program files
- Start Menu shortcuts
- Optional Desktop shortcut
- Standard Windows uninstall entry

## What uninstall does not remove

- User data
- Local database files
- Exported PDF files

## 1. Build the Windows release app

Run this manually from the project root:

```powershell
flutter build windows --release
```

The default Flutter release output expected by the helper script is:

```text
build/windows/x64/runner/Release
```

## 2. Prepare a dedicated installer workspace

Run the helper script and point it to any installer workspace you want:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\windows_installer\prepare_windows_installer.ps1 `
  -InstallerRoot D:\OPC_Installer_Work
```

This prepares:

```text
D:\OPC_Installer_Work\build_input
D:\OPC_Installer_Work\output
```

It copies the Windows release build into `build_input`.

If your Flutter release build is in a different location, pass it explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\windows_installer\prepare_windows_installer.ps1 `
  -InstallerRoot D:\OPC_Installer_Work `
  -ReleaseBuildPath D:\Somewhere\Release
```

## 3. Compile the Inno Setup script manually

Open Inno Setup Compiler and compile:

```text
tools/windows_installer/opc_installer.iss
```

Or use `ISCC.exe` manually and pass the prepared workspace:

```powershell
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" `
  "/DMyBuildInputDir=D:\OPC_Installer_Work\build_input" `
  "/DMyOutputDir=D:\OPC_Installer_Work\output" `
  "/DMyAppVersion=4.0.0" `
  "/DMyAppExeName=OPC.exe" `
  ".\tools\windows_installer\opc_installer.iss"
```

## 4. Optional compile through the helper script

If you want, the helper script can also call Inno Setup Compiler:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\windows_installer\prepare_windows_installer.ps1 `
  -InstallerRoot D:\OPC_Installer_Work `
  -CompileInstaller `
  -IsccPath "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
```

## 5. Where the final installer appears

The generated installer is written to:

```text
<InstallerRoot>\output
```

Expected filename pattern:

```text
OPC_Setup_<version>.exe
```

## Notes

- The installer uses product name `OPC`.
- The current Windows executable name expected by this lane is `OPC.exe`.
- The lane does not hardcode a single local development path.
- Input and output locations are controlled by script parameters or Inno Setup defines.
