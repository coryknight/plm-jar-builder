[![Build status](https://ci.appveyor.com/api/projects/status/ba8i29gqp62lw4rp/branch/master?svg=true)](https://ci.appveyor.com/project/Dargmuesli/plm-jar-builder/branch/master)

# PLM-Jar-Builder
Erstellt .jar-Dateien für EECS/PLM Java-Projekte an der Universität Kassel.

## Disclaimer
Dieses Tool ist weder die Lösung einer Aufgabe selbst, noch soll es dem/der Studierenden das Erlernen des Umgangs mit der Konsole verhindern. Der Einsatz ist eigenverantwortlich.

# Hintergrund
Im Rahmen der Lehrveranstaltung "Einführung in die Programmierung" im Fachbereich 16 (Elektrotechnik/Informatik) der Universität Kassel müssen Übungen bearbeitet und abgegeben werden. Die Bearbeitung umfasst das Anfertigen von Dokumenten und Java-Programmen, die nur als jar-Archiv zusammengefasst hochgeladen/abgegeben werden können.

# Funktion
Dieses Tool soll einem das Erstellen und somit die Abgabe der eigenen Übungslösungen erleichtern. Dabei wird eine Ordnerstruktur ähnlich zur folgenden vorausgesetzt:

```
%DOKUMENTE%\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen\
├── Aufgabenblatt 1\
│   ├── Lösung\
│   │   ├── Hallo\
│   │   │   ├── Hallo.class
│   │   │   └── Hallo.java
│   │   ├── 123456789_01.jar
│   │   ├── Lösung 1.odt
│   │   ├── Lösung 1.pdf
│   │   ├── UML 2d.odg
│   │   ├── UML 2d.pdf
│   │   ├── UML 2i.odg
│   │   └── UML 2i.pdf
│   └── Aufgabenblatt 1.pdf
├── Aufgabenblatt 2\
:
```

## Konfiguration

- **EncryptedPassword**
Der Wert für das verschlüsselte Passwort ist accountabhängig und kann über folgendes Kommando erstellt werden:

```PowerShell
'passwort' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
```

Dass Apostrophe das Passwort einschließen ist notwendig, um gewisse Sonderzeichen im Passwort zu ermöglichen.
