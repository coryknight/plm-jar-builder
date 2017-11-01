---
external help file: Config-help.xml
Module Name: PLM-Jar-Builder
online version: https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-PlmJarBuilderConfigProperty.md
schema: 2.0.0
---

# Get-PlmJarBuilderConfigProperty

## SYNOPSIS
Gets a PLM-Jar-Builder configuration property.

## SYNTAX

### PropertyName
```
Get-PlmJarBuilderConfigProperty [-PropertyName] <String>
```

### PropertyPath
```
Get-PlmJarBuilderConfigProperty [-PropertyPath] <String>
```

## DESCRIPTION
The "Get-PlmJarBuilderConfigProperty" cmdlet reads the PLM-Jar-Builder configuration and creates one if none exists.
Then, it gets the correct PLM-Jar-Builder configuration property path and returns its value.

## EXAMPLES

### -------------------------- BEISPIEL 1 --------------------------
```
Get-PlmJarBuilderConfigProperty -PropertyName "ExerciseRootPath"
```

Get-PlmJarBuilderConfigProperty -PropertyPath "Custom.ExerciseRootPath"

## PARAMETERS

### -PropertyName
The property name of the property whose value is to be returned.

```yaml
Type: String
Parameter Sets: PropertyName
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PropertyPath
The property path of the property whose value is to be returned.

```yaml
Type: String
Parameter Sets: PropertyPath
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-PlmJarBuilderConfigProperty.md](https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-PlmJarBuilderConfigProperty.md)

