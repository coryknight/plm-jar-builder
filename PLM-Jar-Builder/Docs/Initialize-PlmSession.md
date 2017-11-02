---
external help file: PLM-help.xml
Module Name: PLM-Jar-Builder
online version: https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Initialize-PlmSession.md
schema: 2.0.0
---

# Initialize-PlmSession

## SYNOPSIS
Initializes a PLM session.

## SYNTAX

```
Initialize-PlmSession [-PlmUsername] <String> [-PlmPassword] <SecureString> [-UserUsername] <String>
 [-UserPassword] <SecureString>
```

## DESCRIPTION
The "Initialize-PlmSession" cmdlet request PLM's login site using basic authentication.
It fills the login site's form elements and submits that form.
The user should be logged in then, otherwise an error is thrown.

## EXAMPLES

### -------------------------- BEISPIEL 1 --------------------------
```
Initialize-PlmSession -PlmUsername "PLM" -UserUsername 123456789
```

## PARAMETERS

### -PlmUsername
The username for PLM's basic authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlmPassword
{{Fill PlmPassword Description}}

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserUsername
The user's username authenticate for download permissions.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserPassword
The user's password authenticate for download permissions.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
The user's password is trimmed to 15 characters, because PLM ...
wants it this way.

## RELATED LINKS

[https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Initialize-PlmSession.md](https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Initialize-PlmSession.md)
