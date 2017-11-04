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
        Write-Host "Internet connection test failed. Operating in offline mode..." -ForegroundColor "Cyan"
    }

    If (-Not $Offline) {
        Write-Host "Checking for updates..." -ForegroundColor "Cyan"

        $ModuleAuthorUsername = Get-PlmJarBuilderVariable -Name "ModuleAuthorUsername"
        $ModuleName = Get-PlmJarBuilderVariable -Name "ModuleName"
        $ExistingVersion = (Get-Module -Name $ModuleName).Version
        $LatestRelease = $Null

        Try {
            $LatestRelease = New-Object "System.Version" (Invoke-RestMethod -Uri "https://api.github.com/repos/$ModuleAuthorUsername/$ModuleName/releases/latest")
        } Catch {
            # Latest release does not exist
        }

        If ($LatestRelease -And $LatestRelease.CompareTo($ExistingVersion)) {
            If (Read-PromptYesNo -Caption "v$LatestRelease" -Message "A new version of $ModuleName was found. Currently installed is v$ExistingVersion. Do you want to automatically update to the new version now?" -DefaultChoice 0) {
                Invoke-PSDepend @{"$ModuleAuthorUsername/$ModuleName" = ""} -Install -Import -Force
            }
        }

        Write-Host "Installing dependencies..." -ForegroundColor "Cyan"

        If (-Not (Get-Module -Name "PSDepend" -ListAvailable)) {
            Install-Module -Name "PSDepend" -Scope CurrentUser
        }

        Invoke-PSDepend -Path "..\Requirements.psd1" -Install -Import -Force
    }

    $ConfigPath = Get-PlmJarBuilderVariable -Name "ConfigPath"

    # Create config file if it does not exist already
    If (-Not (Test-Path -Path $ConfigPath)) {
        Write-Host "Creating a config file..." -ForegroundColor "Cyan"
        New-PlmJarConfig
    }

    # Read settings file
    Write-Host "Loaded configuration:" -ForegroundColor "Yellow"

    $ExerciseRootPath = (Get-PlmJarBuilderConfigProperty -PropertyName "ExerciseRootPath").ExerciseRootPath.TrimEnd("\")
    Write-Host "ExerciseRootPath = $ExerciseRootPath" -ForegroundColor "Cyan"
    $DownloadPath = (Get-PlmJarBuilderConfigProperty -PropertyName "DownloadPath").DownloadPath.TrimEnd("\")
    Write-Host "DownloadPath = $DownloadPath" -ForegroundColor "Cyan"
    $Include = (Get-PlmJarBuilderConfigProperty -PropertyName "Include").Include
    Write-Host "Include = $Include" -ForegroundColor "Cyan"
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
        $Answer = Read-ValidInput `
            -Prompt @"

What do you want to do?

1) Create JAR files
2) Upload JAR to PLM
3) Download JAR from PLM
4) Exit (or press CTRL+C)

Choice
"@ `
            -ValidityCheck {@(1, 2, 3, 4) -Contains $args[0]} `
            -ErrorMessage "Invalid choice!"

        Switch ($Answer) {
            1 {
                If (($ExerciseRootPath -Eq $Null) -Or (-Not (Test-Path $ExerciseRootPath)) -Or (-Not (Get-ExerciseFolder -ExerciseRootPath $ExerciseRootPath))) {
                    $ExerciseRootPath = Read-ValidInput `
                        -Prompt "The path in which the exercise folders are placed" `
                        -ValidityCheck @(
                        {Test-Path $args[0]}
                        {Get-ExerciseFolder -ExerciseRootPath $args[0]}
                    ) `
                        -ErrorMessage @(
                        "Invalid choice!"
                        "The given folder does not contain exercise folders!"
                    )
                }

                If ($NoNote -Eq $Null) {
                    If (Read-PromptYesNo -Caption "Note Exclusion" -Message "Do you want prevent the addition of a disclaimer to your jar file?") {
                        $NoNote = $True
                    } Else {
                        $NoNote = $False
                    }
                }

                If ($Include -Eq $Null) {
                    If (Read-PromptYesNo -Caption "Inclusions" -Message "Do you want to include certain file types?") {
                        $Include = [String[]](Read-ValidInput `
                                -Prompt "Comma separated file inclusions" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\*\.\w+, )*\*\.\w+$"}
                            ) `
                                -ErrorMessage @(
                                "Invalid format!"
                            )).Split(",").Trim()
                    } Else {
                        $Include = @()
                    }
                }

                If ($Exclude -Eq $Null) {
                    If (Read-PromptYesNo -Caption "Exclusion" -Message "Do you want to exclude certain file types?") {
                        $Exclude = [String[]](Read-ValidInput `
                                -Prompt "Comma separated file exclusions" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\*\.\w+, )*\*\.\w+$"}
                            ) `
                                -ErrorMessage @(
                                "Invalid format!"
                            )).Split(",").Trim()
                    } Else {
                        $Exclude = @()
                    }
                }

                If ((-Not $MatriculationNumber) -Or (-Not ($MatriculationNumber -Match "^\d+$"))) {
                    $Answer = Read-ValidInput `
                        -Prompt @"

Do you want to include your matriculation number in the jar file's name?

1) Yes, enter it manually
2) Yes, find it automatically
3) No, skip

Choice
"@ `
                        -ValidityCheck {@(1, 2, 3) -Contains $args[0]} `
                        -ErrorMessage "Invalid choice!"

                    Switch ($Answer) {
                        1 {
                            $MatriculationNumber = Read-ValidInput `
                                -Prompt "My matriculation number" `
                                -ValidityCheck @(
                                {$args[0] -Match "^\d+$"}
                            ) `
                                -ErrorMessage @(
                                "Invalid format!"
                            )
                            Break
                        }
                        2 {
                            $MatriculationNumber = Find-MatriculationNumber -ExerciseRootPath $ExerciseRootPath

                            If ($MatriculationNumber) {
                                Write-MultiColor -Text @("Found matriculation number: ", $MatriculationNumber) -Color @("Cyan", "Yellow")
                            } Else {
                                Write-Host "No matriculation number found." -ForegroundColor "Cyan"
                            }

                            Break
                        }
                        3 {
                            Break
                        }
                    }
                }

                $Answer = Read-ValidInput `
                    -Prompt @"

Which exercises do you want to create a jar file for?

1) The newest
2) Individual exercise numbers
3) All

Choice
"@ `
                    -ValidityCheck {@(1, 2, 3) -Contains $args[0]} `
                    -ErrorMessage "Invalid choice!"

                Switch ($Answer) {
                    1 {
                        New-PlmJar `
                            -ExerciseRootPath $ExerciseRootPath `
                            -NoNote:$NoNote `
                            -Include:$Include `
                            -Exclude:$Exclude `
                            -MatriculationNumber:$MatriculationNumber
                        Break
                    }
                    2 {
                        $ExerciseNumber = [Int[]](Read-ValidInput `
                                -Prompt "Comma separated exercise numbers" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\d{1,2}, )*\d{1,2}$"}
                            ) `
                                -ErrorMessage @(
                                "Invalid format!"
                            )).Split(",").Trim()

                        New-PlmJar `
                            -ExerciseRootPath $ExerciseRootPath `
                            -NoNote:$NoNote `
                            -Include:$Include `
                            -Exclude:$Exclude `
                            -MatriculationNumber:$MatriculationNumber `
                            -ExerciseNumber $ExerciseNumber
                        Break
                    }
                    3 {
                        New-PlmJar `
                            -ExerciseRootPath $ExerciseRootPath `
                            -NoNote:$NoNote `
                            -Include:$Include `
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
                    $PlmUsername = Read-Host -Prompt "PLM username"
                }

                If (-Not $PlmPassword) {
                    $PlmPassword = Read-Host -Prompt "PLM password" -AsSecureString
                } ElseIf (-Not ($PlmPassword -Is [SecureString]) -And ($PlmPassword -Is [String])) {
                    $PlmPassword = $PlmPassword | ConvertTo-SecureString
                }

                If (-Not $MatriculationNumber) {
                    $MatriculationNumber = Read-Host -Prompt "MatriculationNumber"
                }

                If (-Not $UserPassword) {
                    $UserPassword = Read-Host -Prompt "User password" -AsSecureString
                } ElseIf (-Not ($UserPassword -Is [SecureString]) -And ($UserPassword -Is [String])) {
                    $UserPassword = $UserPassword | ConvertTo-SecureString
                }

                $Session = Initialize-PlmSession -PlmUsername $PlmUsername -PlmPassword $PlmPassword -UserUsername $MatriculationNumber -UserPassword $UserPassword
                $JarFilePath = Read-ValidInput `
                    -Prompt "The path to the jar file that should be uploaded" `
                    -ValidityCheck @(
                    {[System.IO.Path]::GetExtension($args[0]) -Eq ".jar"}
                ) `
                    -ErrorMessage @(
                    "Not a jar file!"
                )

                Publish-PlmJar -Session $Session -JarFilePath $JarFilePath

                Break
            }
            3 {
                If (-Not $PlmUsername) {
                    $PlmUsername = Read-Host -Prompt "PLM username"
                }

                If (-Not $PlmPassword) {
                    $PlmPassword = Read-Host -Prompt "PLM password" -AsSecureString
                } ElseIf (-Not ($PlmPassword -Is [SecureString]) -And ($PlmPassword -Is [String])) {
                    $PlmPassword = $PlmPassword | ConvertTo-SecureString
                }

                If (-Not $MatriculationNumber) {
                    $MatriculationNumber = Read-Host -Prompt "MatriculationNumber"
                }

                If (-Not $UserPassword) {
                    $UserPassword = Read-Host -Prompt "User password" -AsSecureString
                } ElseIf (-Not ($UserPassword -Is [SecureString]) -And ($UserPassword -Is [String])) {
                    $UserPassword = $UserPassword | ConvertTo-SecureString
                }

                If (($DownloadPath -Eq $Null) -Or (-Not (Test-Path $DownloadPath))) {
                    $DownloadPath = Read-ValidInput `
                        -Prompt "The path to download the jar file to" `
                        -ValidityCheck @(
                        {Test-Path $args[0]}
                    ) `
                        -ErrorMessage @(
                        "Invalid path!"
                    )
                }

                $Session = Initialize-PlmSession -PlmUsername $PlmUsername -PlmPassword $PlmPassword -UserUsername $MatriculationNumber -UserPassword $UserPassword
                $Answer = Read-ValidInput `
                    -Prompt @"

Which exercise numbers do you want to download?

1) The newest
2) Individual exercise numbers
3) All

Choice
"@ `
                    -ValidityCheck {@(1, 2, 3) -Contains $args[0]} `
                    -ErrorMessage "Invalid choice!"

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
                        Write-Host "Available download options: "

                        $AvailableJars = Get-PlmJar `
                            -Session $Session `
                            -UserUsername $MatriculationNumber `
                            -UserPassword $UserPassword `
                            -ListAvailable

                        ForEach ($AvailableJar In $AvailableJars) {
                            Write-Host $AvailableJar.PSObject.Properties.Name
                        }

                        $ExerciseNumber = [Int[]](Read-ValidInput `
                                -Prompt "Comma separated exercise numbers" `
                                -ValidityCheck @(
                                {$args[0] -Match "^(\d{1,2}, )*\d{1,2}$"}
                            ) `
                                -ErrorMessage @(
                                "Invalid format!"
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
