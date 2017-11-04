[![Build status](https://ci.appveyor.com/api/projects/status/ba8i29gqp62lw4rp/branch/master?svg=true)](https://ci.appveyor.com/project/Dargmuesli/plm-jar-builder/branch/master)

# PLM-Jar-Builder
Erstellt .jar-Dateien für EECS/PLM Java-Projekte an der Universität Kassel.

## Inhaltsverzeichnis
1. **[Disclaimer](#Disclaimer)**
2. **[Hintergrund](#Hintergrund)**
3. **[Installation](#Installation)**
4. **[Benutzung](#Benutzung)**
5. **[Funktion](#Funktion)**
6. **[Konfiguration](#Konfiguration)**
7. **[Module](#Module)**

<a name="Disclaimer"></a>

## Disclaimer
Dieses Tool ist weder die Lösung einer Aufgabe selbst, noch soll es dem/der Studierenden das Erlernen des Umgangs mit der Konsole verhindern. Der Einsatz ist eigenverantwortlich.

<a name="Hintergrund"></a>

## Hintergrund
Im Rahmen der Lehrveranstaltung "Einführung in die Programmierung" im Fachbereich 16 (Elektrotechnik/Informatik) der Universität Kassel müssen Übungen bearbeitet und abgegeben werden.
Die Bearbeitung umfasst das Anfertigen von Dokumenten und Java-Programmen, die nur als jar-Archiv zusammengefasst hochgeladen/abgegeben werden können.´
Daraus entstand die Idee für einen Assistenten, der einem beim Erstellen, Hoch- und Herunterladen von .jar-Dateien hilft.

<a name="Installation"></a>

## Installation
```PowerShell
Install-Module "PSDepend" -Scope "CurrentUser" -Force
Invoke-PSDepend -InputObject @{"dargmuesli/plm-jar-builder" = "master"} -Install -Force
```

<a name="Benutzung"></a>

## Benutzung
In erster Linie sollte der Assistent verwendet werden, der durch die möglichen Funktionen des Moduls führt.

```PowerShell
Invoke-PlmJarBuilder
```

Alternativ können auch [einzelne Module]() direkt angesprochen werden.

<a name="Funktion"></a>

## Funktion
Es wird eine Ordnerstruktur ähnlich zur folgenden vorausgesetzt:

```
Übungen\
├── Aufgabenblatt 1\
│   ├── Lösung\
│   │   ├── Hallo\
│   │   │   ├── Hallo.class
│   │   │   ├── Hallo.java
|   |   |   :
│   │   ├── 123456789_01.jar
│   │   ├── Lösung 1.odt
│   │   ├── Lösung 1.pdf
│   │   ├── UML 2d.odg
│   │   ├── UML 2d.pdf
│   │   ├── UML 2i.odg
│   │   ├── UML 2i.pdf
|   |   :
│   ├── Aufgabenblatt 1.pdf
|   :
├── Aufgabenblatt 2\
:
```

<a name="Konfiguration"></a>

## Konfiguration
Die Standardwerte, die bei der Ausführung vom PLM-Jar-Builder genutzt werden, können in einer Konfigurationsdatei angepasst werden.
Die Konfigurationsdatei befindet sich im Modul-Ordner, meist hier: `%USERPROFILE%\Documents\WindowsPowerShell\Modules\plm-jar-builder\PLM-Jar-Builder\Config\PLM-Jar-Builder.json`

Folgende Einstellungsmöglichkeiten gibt es:


### Custom
Einstellungen, die dem Benutzer die Eingabe von Funktionsparametern ersparen, aber die Programmfunktion nicht grundlegend ändern.

- **ExerciseRootPath**  
Der Pfad zum Ordner, in dem sich die Aufgabenordner (`Aufgabenblatt 1`, ...) befinden.  
Standardwert: `%MyDocuments%\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen`

- **DownloadPath**  
Der Pfad zum Ordner, in den .jar-Dateien heruntergeladen werden.  
Standardwert: `%Downloads%` (Registry-Schlüssel)

- **Exclude**  
Dateiendungen, die vom Archiv-Packen ausgeschlossen werden sollen.  
Standardwert: `"*.class", "*.jar", "*.odt", "*.odg"`

- **NoNote**  
Ob eine Markdown-Notiz bezüglich dieses Moduls mit in die .jar-Datei gepackt werden soll.  
Standardwert: `false`


#### PLM
Daten, die im Browser-Authentifizierungsfenster angegeben werden müssen, bevor man die PLM-Seite überhaupt sieht.

- **Username**  
Der PLM-Benutzername.  
Standardwert: `""`

- **EncryptedPassword**  
Eine verschlüsselte Version des PLM-Passworts.  
Standardwert: `""`

Der Wert für das verschlüsselte Passwort kann über folgendes Kommando erstellt werden:

```PowerShell
'passwort' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
```

Dass Apostrophe das Passwort einschließen ist notwendig, um gewisse Sonderzeichen im Passwort zu ermöglichen.
Das Passwort kann (nur) vom selben Windows-Account wieder entschlüsselt werden.


#### User
Daten, die zur Anmeldung direkt auf der PLM-Seite genutzt werden.

- **MatriculationNumber**  
Die Matrikelnummer, die als Benutzername für die PLM-Seite im Dateinamen der .jar-Datei vorkommen soll.  
Standardwert: `""`

- **EncryptedPassword**  
Eine verschlüsselte Version des Passworts.  
Standardwert: `""`

Der Wert für das verschlüsselte Passwort kann über folgendes Kommando erstellt werden:

```PowerShell
'passwort' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
```

Dass Apostrophe das Passwort einschließen ist notwendig, um gewisse Sonderzeichen im Passwort zu ermöglichen.
Das Passwort kann nur vom selben Windows-Account wieder entschlüsselt werden, mit dem es verschlüsselt wurde.


### Default
Einstellungen, die die Funktion des Moduls grundlegend ändern, weil sie Änderungen an der vorgegebenen Ordnerhierarchie darstellen.

- **SolutionPath**  
Der Pfad zum Order innerhalb des Aufgabenordners, der die Lösung enthält.
Darin sollten alle Dateien sein, die in die .jar-Datei gepackt werden sollen.  
Standardwert: `"Lösung"`

- **ExerciseSheetRegex**  
Der reguläre Ausdruck, nach dem Aufgabenordner und Übungsnummern gefunden werden.  
Standardwert: `"^Aufgabenblatt (\\d{1,2})$"`

- **JarFileRegex**  
Der reguläre Ausdruck, nach dem .jar-Dateien, Matrikelnummern und Übungsnummern gefunden werden.  
Standardwert: `"^(\\d+|.*)_(\\d{2}).jar$"`

<a name="Module"></a>

## Modules
- **Assistant**
  - [Invoke-PlmJarBuilder](PLM-Jar-Builder/Docs/Invoke-PlmJarBuilder.md)
- **Config**
  - [Get-PlmJarBuilderConfig](PLM-Jar-Builder/Docs/Get-PlmJarBuilderConfig.md)
  - [Get-PlmJarBuilderConfigProperty](PLM-Jar-Builder/Docs/Get-PlmJarBuilderConfigProperty.md)
  - [Get-PlmJarBuilderConfigPropertyPath](PLM-Jar-Builder/Docs/Get-PlmJarBuilderConfigPropertyPath.md)
  - [Get-PlmJarBuilderVariable](PLM-Jar-Builder/Docs/Get-PlmJarBuilderVariable.md)
  - [New-PlmJarConfig](PLM-Jar-Builder/Docs/New-PlmJarConfig.md)
  - [Set-PlmJarBuilderConfigProperty](PLM-Jar-Builder/Docs/Set-PlmJarBuilderConfigProperty.md)
  - [Set-PlmJarBuilderVariable](PLM-Jar-Builder/Docs/Set-PlmJarBuilderVariable.md)
- **JAR**
  - [Find-MatriculationNumber](PLM-Jar-Builder/Docs/Find-MatriculationNumber.md)
  - [Get-ExerciseFolder](PLM-Jar-Builder/Docs/Get-ExerciseFolder.md)
  - [New-PlmJar](PLM-Jar-Builder/Docs/New-PlmJar.md)
- **PLM**
  - [Get-PlmJar](PLM-Jar-Builder/Docs/Get-PlmJar.md)
  - [Get-PlmUri](PLM-Jar-Builder/Docs/Get-PlmUri.md)
  - [Initialize-PlmSession](PLM-Jar-Builder/Docs/Initialize-PlmSession.md)
  - [Publish-PlmJar](PLM-Jar-Builder/Docs/Publish-PlmJar.md)
  - [Test-PlmUploadAvailable](PLM-Jar-Builder/Docs/Test-PlmUploadAvailable.md)
