<#
    .SYNOPSIS
    Invokes the PLM-Jar-Builder.

    .DESCRIPTION
    The "Invoke-PlmJarBuilder" cmdlet leads through the execution of possible PLM-Jar-Buidler commands.

    .PARAMETER Offline
    Whether to disable update checks and dependency resolution.

    .EXAMPLE
    Invoke-PlmJarBuilder

    .LINK
    https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Invoke-PlmJarBuilder.md
#>
Function Invoke-PlmJarBuilder {
    Param(
        [Switch] $Offline
    )

    # Check online status and install dependencies if connected to the internet
    If (-Not (Test-Connection -ComputerName "google.com" -Count 1 -Quiet)) {
        $Offline = $True

        # Internet connection test failed. Operating in offline mode...
        Write-Host "Internet-Verbindungstest fehlgeschlagen. Arbeite im Offline-Modus..." -ForegroundColor "Cyan"
    }

    If (-Not $Offline) {

        #Checking for updates
        Write-Host "Suche nach Updates..." -ForegroundColor "Cyan"

        $ModuleAuthorUsername = Get-PlmJarBuilderVariable -Name "ModuleAuthorUsername"
        $ModuleName = Get-PlmJarBuilderVariable -Name "ModuleName"
        $ExistingVersion = (Get-Module -Name $ModuleName).Version
        $LatestRelease = $Null

        Try {
            $LatestRelease = New-Object "System.Version" (Invoke-RestMethod -Uri "https://api.github.com/repos/$ModuleAuthorUsername/$ModuleName/releases/latest").tag_name
        } Catch {
            # Latest release does not exist
        }

        If ($LatestRelease -And $LatestRelease.CompareTo($ExistingVersion)) {

            # A new version of $ModuleName was found. Currently installed is v$ExistingVersion. Do you want to automatically update to the new version now?
            If (Read-PromptYesNo -Caption "v$LatestRelease" -Message "Eine neue Version vom $ModuleName wurde gefunden. Aktuell installiert ist v$ExistingVersion. Soll jetzt automatisch zur neuesten Version geupdatet werden?" -DefaultChoice 0) {
                Invoke-PSDepend @{"$ModuleAuthorUsername/$ModuleName" = ""} -Install -Import -Force
            }
        }

        # Installing dependencies
        Write-Host "Installiere Abhängigkeiten..." -ForegroundColor "Cyan"

        If (-Not (Get-Module -Name "PSDepend" -ListAvailable)) {
            Install-Module -Name "PSDepend" -Scope CurrentUser
        }

        Invoke-PSDepend -Path "..\Requirements.psd1" -Install -Import -Force
    }

    $ConfigPath = Get-PlmJarBuilderVariable -Name "ConfigPath"

    # Create config file if it does not exist already
    If (-Not (Test-Path -Path $ConfigPath)) {

        # Creating a config file
        Write-Host "Erstelle eine Konfigurationsdatei..." -ForegroundColor "Cyan"
        New-PlmJarConfig
    }

    # Read settings file
    # Loaded configuration
    Write-Host "Geladene Konfiguration:" -ForegroundColor "Yellow"

    $ExerciseRootPath = (Get-PlmJarBuilderConfigProperty -PropertyName "ExerciseRootPath").ExerciseRootPath.TrimEnd("\")
    Write-Host "ExerciseRootPath = $ExerciseRootPath" -ForegroundColor "Cyan"
    $DownloadPath = (Get-PlmJarBuilderConfigProperty -PropertyName "DownloadPath").DownloadPath.TrimEnd("\")
    Write-Host "DownloadPath = $DownloadPath" -ForegroundColor "Cyan"
    $Exclude = (Get-PlmJarBuilderConfigProperty -PropertyName "Exclude").Exclude
    Write-Host "Exclude = $Exclude" -ForegroundColor "Cyan"
    $NoNote = (Get-PlmJarBuilderConfigProperty -PropertyName "NoNote").NoNote
    Write-Host "NoNote = $NoNote" -ForegroundColor "Cyan"
    $PlmUsername = (Get-PlmJarBuilderConfigProperty -PropertyName "PlmUsername").Username
    Write-Host "PlmUsername = $PlmUsername" -ForegroundColor "Cyan"
    $PlmPassword = (Get-PlmJarBuilderConfigProperty -PropertyName "PlmPassword").EncryptedPassword
    Write-Host "PlmPassword = $PlmPassword" -ForegroundColor "Cyan"
    $MatriculationNumber = (Get-PlmJarBuilderConfigProperty -PropertyName "MatriculationNumber").MatriculationNumber
    Write-Host "MatriculationNumber = $MatriculationNumber" -ForegroundColor "Cyan"
    $UserPassword = (Get-PlmJarBuilderConfigProperty -PropertyName "UserPassword").EncryptedPassword
    Write-Host "UserPassword = $UserPassword" -ForegroundColor "Cyan"

    :mainloop While ($True) {
        # What do you want to do?

        # 1) Create JAR files
        # 2) Upload JAR to PLM
        # 3) Download JAR from PLM
        # 4) Exit (or press CTRL+C)

        # Choice
        # ---
        # Invalid choice!
        $Answer = Read-ValidInput `
            -Prompt @"

Was möchtest du tun?

1) .jar-Dateien erstellen
2) .jar-Dateien zu PLM hochladen
3) .jar-Dateien von PLM herunterladen
4) Beenden (oder jederzeit CTRL+C drücken)

Wahl
"@ `
            -ValidityCheck {@(1, 2, 3, 4) -Contains $args[0]} `
            -ErrorMessage "Ungültige Wahl!"

        Switch ($Answer) {
            1 {
                If (($ExerciseRootPath -Eq $Null) -Or (-Not (Test-Path $ExerciseRootPath)) -Or (-Not (Get-ExerciseFolder -ExerciseRootPath $ExerciseRootPath))) {

                    # The path in which the exercise folders are placed
                    # ---
                    # Invalid path!
                    # The given folder does not contain exercise folders!
                    $ExerciseRootPath = Read-ValidInput `
                        -Prompt "Der Pfad, in dem sich die Aufgaben-Ordern befinden" `
                        -ValidityCheck @(
                        {Test-Path $args[0]}
                        {Get-ExerciseFolder -ExerciseRootPath $args[0]}
                    ) `
                        -ErrorMessage @(
                        "Ungültiger Pfad!"
                        "Der angegebene Ordner enthält keine Aufgaben-Order!"
                    )
                }

                If ($NoNote -Eq $Null) {
                    # Note Exclusion
                    # Do you want prevent the addition of a disclaimer to your jar file?
                    If (Read-PromptYesNo -Caption "Notiz-Ausschluss" -Message "Soll das Packen des Disclaimers in die .jar-Datei verhindert werden?") {
                        $NoNote = $True
                    } Else {
                        $NoNote = $False
                    }
                }

                If ($Exclude -Eq $Null) {

                    # Exclusion
                    # Do you want to exclude certain file types?
                    If (Read-PromptYesNo -Caption "Ausschluss" -Message "Sollen bestimmte Dateitypen vom Packen in die .jar-Datei ausgeschlossen werden?") {
                        # Comma separated file exclusions
                        # ---
                        # Invalid format! (Not `"*.abc, *.xyz`")
                        $Exclude = [String[]](Read-ValidInput `
                                -Prompt "Kommagetrennte Dateitypen" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\*\.\w+, )*\*\.\w+$"}
                            ) `
                                -ErrorMessage @(
                                "Ungültiges Format! (Nicht `"*.abc, *.xyz`")"
                            )).Split(",").Trim()
                    } Else {
                        $Exclude = @()
                    }
                }

                If ((-Not $MatriculationNumber) -Or (-Not ($MatriculationNumber -Match "^\d+$"))) {

                    # Do you want to include your matriculation number in the jar file's name?

                    # 1) Yes, enter it manually
                    # 2) Yes, find it automatically
                    # 3) No, skip

                    # Choice
                    # ---
                    # Invalid choice!
                    $Answer = Read-ValidInput `
                        -Prompt @"

Soll deine Matrikelnummer in den .jar-Dateinamen?

1) Ja, manuell eingeben
2) Ja, automatisch finden
3) Nein, überspringen

Wahl
"@ `
                        -ValidityCheck {@(1, 2, 3) -Contains $args[0]} `
                        -ErrorMessage "Ungültige Wahl!"

                    Switch ($Answer) {
                        1 {
                            # My matriculation number
                            # ---
                            # Invalid format!
                            $MatriculationNumber = Read-ValidInput `
                                -Prompt "Meine Matrikelnummer" `
                                -ValidityCheck @(
                                {$args[0] -Match "^\d+$"}
                            ) `
                                -ErrorMessage @(
                                "Ungültiges Format!"
                            )
                            Break
                        }
                        2 {
                            $MatriculationNumber = Find-MatriculationNumber -ExerciseRootPath $ExerciseRootPath

                            If ($MatriculationNumber) {
                                # Found matriculation number:
                                Write-MultiColor -Text @("Gefundene Matrikelnummer: ", $MatriculationNumber) -Color @("Cyan", "Yellow")
                            } Else {

                                # No matriculation number found.
                                Write-Host "Keine Matrikelnummer gefunden." -ForegroundColor "Cyan"
                            }

                            Break
                        }
                        3 {
                            Break
                        }
                    }
                }

                # Which exercises do you want to create a jar file for?

                # 1) The newest
                # 2) Individual exercise numbers
                # 3) All

                # Choice
                # ---
                # Invalid choice!
                $Answer = Read-ValidInput `
                    -Prompt @"

Für welche Aufgaben möchtest du .jar-Dateien erstellen?

1) Die neueste
2) Bestimmte Aufgabennummern
3) Alle

Wahl
"@ `
                    -ValidityCheck {@(1, 2, 3) -Contains $args[0]} `
                    -ErrorMessage "Ungültige Wahl!"

                Switch ($Answer) {
                    1 {
                        New-PlmJar `
                            -ExerciseRootPath $ExerciseRootPath `
                            -NoNote:$NoNote `
                            -Exclude:$Exclude `
                            -MatriculationNumber:$MatriculationNumber
                        Break
                    }
                    2 {
                        # Comma separated exercise numbers
                        # ---
                        # Invalid format!
                        $ExerciseNumber = [Int[]](Read-ValidInput `
                                -Prompt "Kommagetrennte Aufgabennummern" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\d{1,2}, )*\d{1,2}$"}
                            ) `
                                -ErrorMessage @(
                                "Ungültiges Format!"
                            )).Split(",").Trim()

                        New-PlmJar `
                            -ExerciseRootPath $ExerciseRootPath `
                            -NoNote:$NoNote `
                            -Exclude:$Exclude `
                            -MatriculationNumber:$MatriculationNumber `
                            -ExerciseNumber $ExerciseNumber
                        Break
                    }
                    3 {
                        New-PlmJar `
                            -ExerciseRootPath $ExerciseRootPath `
                            -NoNote:$NoNote `
                            -Exclude:$Exclude `
                            -MatriculationNumber:$MatriculationNumber `
                            -All
                        Break
                    }
                }

                Break
            }
            2 {
                If (-Not $PlmUsername) {

                    # PLM username
                    $PlmUsername = Read-Host -Prompt "PLM-Benutzername"
                }

                If (-Not $PlmPassword) {

                    # PLM password
                    $PlmPassword = Read-Host -Prompt "PLM-Passwort" -AsSecureString
                } ElseIf (-Not ($PlmPassword -Is [SecureString]) -And ($PlmPassword -Is [String])) {
                    $PlmPassword = $PlmPassword | ConvertTo-SecureString
                }

                If (-Not $MatriculationNumber) {

                    # Matriculation number
                    $MatriculationNumber = Read-Host -Prompt "Matrikelnummer"
                }

                If (-Not $UserPassword) {

                    # User password
                    $UserPassword = Read-Host -Prompt "Benutzer-Passwort" -AsSecureString
                } ElseIf (-Not ($UserPassword -Is [SecureString]) -And ($UserPassword -Is [String])) {
                    $UserPassword = $UserPassword | ConvertTo-SecureString
                }

                $Session = Initialize-PlmSession -PlmUsername $PlmUsername -PlmPassword $PlmPassword -UserUsername $MatriculationNumber -UserPassword $UserPassword

                # The path to the jar file that should be uploaded
                # ---
                # Not a jar file!
                $JarFilePath = Read-ValidInput `
                    -Prompt "Der Pfad zur .jar-Datei, die hochgeladen werden soll" `
                    -ValidityCheck @(
                    {[System.IO.Path]::GetExtension($args[0]) -Eq ".jar"}
                ) `
                    -ErrorMessage @(
                    "Nicht eine .jar-Datei!"
                )

                Publish-PlmJar -Session $Session -JarFilePath $JarFilePath

                Break
            }
            3 {
                If (-Not $PlmUsername) {

                    # PLM username
                    $PlmUsername = Read-Host -Prompt "PLM-Benutzername"
                }

                If (-Not $PlmPassword) {

                    # PLM password
                    $PlmPassword = Read-Host -Prompt "PLM-Passwort" -AsSecureString
                } ElseIf (-Not ($PlmPassword -Is [SecureString]) -And ($PlmPassword -Is [String])) {
                    $PlmPassword = $PlmPassword | ConvertTo-SecureString
                }

                If (-Not $MatriculationNumber) {

                    # Matriculation number
                    $MatriculationNumber = Read-Host -Prompt "Matrikelnummer"
                }

                If (-Not $UserPassword) {

                    # User password
                    $UserPassword = Read-Host -Prompt "Benutzer-Passwort" -AsSecureString
                } ElseIf (-Not ($UserPassword -Is [SecureString]) -And ($UserPassword -Is [String])) {
                    $UserPassword = $UserPassword | ConvertTo-SecureString
                }

                If (($DownloadPath -Eq $Null) -Or (-Not (Test-Path $DownloadPath))) {

                    # The path to download the jar file to
                    # ---
                    # Invalid path!
                    $DownloadPath = Read-ValidInput `
                        -Prompt "Der Pfad, in den die .jar-Dateien heruntergeladen werden sollen" `
                        -ValidityCheck @(
                        {Test-Path $args[0]}
                    ) `
                        -ErrorMessage @(
                        "Ungültiger Pfad!"
                    )
                }

                $Session = Initialize-PlmSession -PlmUsername $PlmUsername -PlmPassword $PlmPassword -UserUsername $MatriculationNumber -UserPassword $UserPassword

                # Which exercise numbers do you want to download?

                # 1) The newest
                # 2) Individual exercise numbers
                # 3) All

                # Choice
                # ---
                # Invalid choice!
                $Answer = Read-ValidInput `
                    -Prompt @"

Welche Aufgabennummern sollen heruntergeladen werden?

1) Die neueste
2) Bestimmte Aufgabennummern
3) Alle

Wahl
"@ `
                    -ValidityCheck {@(1, 2, 3) -Contains $args[0]} `
                    -ErrorMessage "Ungültige Wahl!"

                Switch ($Answer) {
                    1 {
                        Get-PlmJar `
                            -Session $Session `
                            -UserUsername $MatriculationNumber `
                            -UserPassword $UserPassword `
                            -DownloadPath $DownloadPath
                        Break
                    }
                    2 {
                        # Available download options:
                        Write-Host "Verfügbare Download-Optionen: "

                        $AvailableJars = Get-PlmJar `
                            -Session $Session `
                            -UserUsername $MatriculationNumber `
                            -UserPassword $UserPassword `
                            -ListAvailable

                        ForEach ($AvailableJar In $AvailableJars) {
                            Write-Host $AvailableJar.PSObject.Properties.Name
                        }

                        # Comma separated exercise numbers
                        # ---
                        # Invalid format!
                        $ExerciseNumber = [Int[]](Read-ValidInput `
                                -Prompt "Kommagetrennte Aufgabennummern" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\d{1,2}, )*\d{1,2}$"}
                            ) `
                                -ErrorMessage @(
                                "Ungültiges Format!"
                            )).Split(",").Trim()

                        Get-PlmJar `
                            -Session $Session `
                            -UserUsername $MatriculationNumber `
                            -UserPassword $UserPassword `
                            -DownloadPath $DownloadPath `
                            -ExerciseNumber $ExerciseNumber
                        Break
                    }
                    3 {
                        Get-PlmJar `
                            -Session $Session `
                            -UserUsername $MatriculationNumber `
                            -UserPassword $UserPassword `
                            -DownloadPath $DownloadPath `
                            -All
                        Break
                    }
                }

                Break
            }
            4 {
                Break mainloop
            }
        }
    }
}

Export-ModuleMember -Function *
