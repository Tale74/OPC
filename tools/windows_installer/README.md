# Windows PerUser installer (NSIS)

Aktuelni OPC Windows paket koristi NSIS PerUser, instalira u `%LOCALAPPDATA%\Programs\OPC`, pravi Start meni i Desktop prečicu sa zvaničnom OPC ikonom i uklanja samo svoj instalacioni direktorijum i prečice pri deinstalaciji. OPC baza je u korisničkom AppData prostoru izvan instalacionog direktorijuma i instalater je ne uklanja.

## Serijski postupak

Iz korena kanonskog BundleSource-a, posle prolaska `flutter analyze` i pune `flutter test` suite:

```powershell
flutter build windows --release --no-pub --build-name=4.0.3 --build-number=4
```

Pripremite odvojeni radni direktorijum, pa kopirajte ceo release izlaz u `build_input`:

```powershell
$work = 'D:\OPC_Installer_Work'
New-Item -ItemType Directory -Force "$work\build_input", "$work\output" | Out-Null
Copy-Item -Path 'build\windows\x64\runner\Release\*' -Destination "$work\build_input" -Recurse -Force
Copy-Item 'tools\windows_installer\OPC_WINDOWS_NSIS_403.nsi' "$work\OPC_WINDOWS_NSIS.nsi"
Copy-Item 'windows\runner\resources\app_icon.ico' "$work\OPC.ico"
```

NSIS skript koristi putanje `build_input`, `output` i `OPC.ico` relativne na radni direktorijum. Pre pokretanja proverite da `build_input` sadrži kompletan Windows release izlaz i da kopirani `OPC.ico` ima isti SHA-256 kao `windows\runner\resources\app_icon.ico`.

```powershell
Push-Location $work
try { & 'C:\Program Files (x86)\NSIS\makensis.exe' '/DOPC_VERSION=4.0.3' '.\OPC_WINDOWS_NSIS.nsi' }
finally { Pop-Location }
```

Ako se NSIS nalazi na drugoj putanji, navedite stvarnu lokaciju `makensis.exe`; ne menjajte signing identitete ili lokalnu OPC bazu. Rezultat je `$work\output\OPC_Setup_4.0.3_PerUser.exe`.

## Instalacija, update i deinstalacija

- Instalacionu i update proveru raditi u namenskom Windows nalogu/profilu ili zasebnoj VM sa sintetičkom bazom. Ne testirati preko postojeće poslovne instalacije.
- Pre update-a zabeležiti instalacionu putanju, package version i synthetic DB marker. Zatvoriti OPC uredno; NSIS ne prekida pokrenutu aplikaciju i ne menja datoteke dok mutex ne dozvoli rad.
- Pokrenuti novi PerUser Setup nad istom izolovanom instalacijom. Potvrditi da aplikacija i postojeći sintetički PREDMET ostaju dostupni, Start meni i Desktop prečica rade i prikazuju OPC ikonu.
- Pri uninstall-u proveriti da se uklanjaju app fajlovi/prečice, ali korisnička OPC baza i korisnički izvezeni dokumenti ostaju netaknuti.

## Kontinuitet

`opc_installer.iss` i `prepare_windows_installer.ps1` su zadržani kao istorijski Inno Setup admin lane za prethodno izdanje. OWNER je prihvatio da raniji Inno paket može koegzistirati sa novijim NSIS PerUser paketom; ne tretirati to samo po sebi kao release blokadu. Novi isporučeni 4.0.3 PerUser paket i NSIS skript predstavljaju aktuelnu Windows distribucionu putanju.
