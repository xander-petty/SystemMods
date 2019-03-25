Function Set-AutoLogon {
<#
    .SYNOPSIS
    Changes a computer to automatically login.

    .DESCRIPTION
    The function changes registry files to allow for a specifies user account to automatically login at startup.

    .PARAMETER DefaultUserName
    A [string] parameter that specifies the username that will be used to auto sign in. The default value is "Administrator."

    .PARAMETER DefaultPassword
    A [string] parameter that sets the password for the specifies username. The default value is set to "null" for security purposes.

    .PARAMETER Enable
    This [switch] parameter determines if you are turning auto logon 'on' or 'off.' Using Enable will turn auto logon 'On'. The default value is 'Off.'

    .PARAMETER Session
    A [System.Management.Automation.Runspaces.PSSession[]] parameter that passes existing remote sessions into the function. Your sessions must be contained within a variable. 

    .PARAMETER ComputerName
    A [string[]] parameter that can be used to specify an individual or list of computer names to the function. Using the ComputerName parameter will have the function create the remote session for you. 

    .PARAMETER Credential
    A [System.Management.Automation.CredentialAttribute()] parameter that is used to pass a variable containing secure credentials. See Get-Help Get-Credential for doing this. 

    .EXAMPLE
    Set-AutoLogon -DefaultUserName 'localhost\NOC' -DefaultPassword '1LifeChanged' -Enable -Session $Session
    This will enable auto login on the remote session computers for the local account called 'NOC.' 

    .EXAMPLE
    Set-AutoLogon -DefaultPassword 'password' -Enable -ComputerName 'ENW10LIB01' -Credential $Cred 
    This enables auto login of the Administrator account on the computer named ENW10LIB01. Note: This is utilizing the default value of the DefaultUserName parameter. 

    .EXAMPLE
    Set-AutoLogon -Session $Session
    This would disable auto login on all of the computers in the remote session.

    .EXAMPLE
    Set-AutoLogon -ComputerName 'ENW10LIB01' -Credential $Cred
    This would disable auto login on the computer named 'ENW10LIB01'. 

    .NOTES
    This function was created by Xander Petty with intended use for Northern Oklahoma College. Use with caution.
#>
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory=$true,
            HelpMessage = "Please user a variable containing a remote session(s).",
            ParameterSetName = "Set 1")]
        [System.Management.Automation.Runspaces.PSSession[]]$Session = $null,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a computer name in plain text or a list contained in a variable",
            ParameterSetName = "Set 2")]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing your credentials",
            ParameterSetName = "Set 2")]
        [System.Management.Automation.CredentialAttribute()]$Credential,
                
        [string]$DefaultUserName = "Administrator",
        [string]$DefaultPassword = $null,
        [switch]$Enable = $false
        )

BEGIN {
    $RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon'
    } # End of BEGIN Block

PROCESS {
    TRY {
        IF ($Session -eq $null) {
            IF ($ComputerName -eq $env:COMPUTERNAME) {
                Write-Debug -Message "Using local computer for session"
                $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
                Write-Verbose -Message "Connected to local computer"
                } # End of IF ComputerName 
            ELSE {
            Write-Debug -Message "Attempring to create PSSession from $ComputerName"
            $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
            Write-Verbose -Message "Connected to $Session"
                } # End of ELSE Block
            } # End of IF Session
        Write-Debug -Message "Attempting to Invoke remote command to $Session"
        Invoke-Command -Session $Session -ErrorAction Stop -ScriptBlock {
                Write-Verbose -Message "Connected to $using:Session"
                IF ($using:Enable -eq $true) {
                    $Value = '1'
                    } # End of IF Enable
                ELSE {
                    $Value = '0'
                    } # End of ELSE
                Write-Debug -Message "Attemptinig registry change Default UserName"
                Set-ItemProperty -Path $using:RegPath -Name DefaultUserName -Value $using:DefaultUserName -Force -ErrorAction Stop
                Write-Debug -Message "Attempting registry change Default Password"
                New-ItemProperty -Path $using:RegPath -Name DefaultPassword -Value $using:DefaultPassword -Force -ErrorAction Stop
                Write-Debug -Message "Attempting registry change to AutoAdminLogon"
                Set-ItemProperty -Path $using:RegPath -Name AutoAdminLogon -Value $Value -Force -ErrorAction Stop
                Write-Verbose -Message "Registry edits complete"
                } # End of ScriptBlock
        } #End of TRY Block 
    CATCH {
        Write-Verbose -Message "Couldn't Connect"
        }
    } # End of PROCESS Block
END {}
} # End of Function Set-AutoLogon

Function Set-CAD {
<#
    .SYNOPSIS
    Enables or disables ctrl+alt+del on the lock screen.

    .DESCRIPTION
    This function modifies the registry files to enable or disable ctrl+alt+del on the lock screen.

    .PARAMETER Session
    A [System.Management.Automation.Runspaces.PSSession[]] parameter that passes existing remote sessions into the function. Your sessions must be contained within a variable.

    .PARAMETER Enable
    This [switch] parameter determines if you are turning auto logon 'on' or 'off.' Using Enable will turn auto logon 'On'. The default value is 'Off.'

    .PARAMETER ComputerName
    A [string[]] parameter that can be used to specify an individual or list of computer names to the function. Using the ComputerName parameter will have the function create the remote session for you. 

    .PARAMETER Credential
    A [System.Management.Automation.CredentialAttribute()] parameter that is used to pass a variable containing secure credentials. See Get-Help Get-Credential for doing this. 

    .EXAMPLE
    Set-CAD -Session $Session -Enable
    This would enable the use of ctrl+alt+del on the lock screen of all computers in the remote session.

    .EXAMPLE
    Set-CAD -Session
    This would disable ctrl+alt+del on the lock screen of all computers in the remote session.

    .EXAMPLE
    Set-CAD -ComputerName 'ENW10LIB01' -Credential $Cred -Enable
    This would enable ctrl+alt+del on the computer named 'ENW10LIB01' 

    .EXAMPLE
    Set-CAD -ComputerName 'ENW10LIB01' -Credential $Cred 
    This would disable ctrl+alt+del on the computer named 'ENW10LIB01'

    .NOTES
    This function was created by Xander Petty with intended use for Northern Oklahoma College. Use with caution.
#>
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing a remote session(s).",
            ParameterSetName = "Set 1")]
        [System.Management.Automation.Runspaces.PSSession[]]$Session = $null,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a computer name or a variable containing a list of names.",
            ParameterSetName = "Set 2")]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing your credentials.",
            ParameterSetName = "Set 2")]
        [System.Management.Automation.CredentialAttribute()]$Credential,

        [switch]$Enable = $false
        )
BEGIN {
    $RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon'
    } # End of BEGIN Block

PROCESS {
    TRY {
        IF ($Session -eq $null) {
            IF ($ComputerName -eq $env:COMPUTERNAME) {
                Write-Debug -Message "Using local computer for session"
                $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
                Write-Verbose -Message "Connected to local computer"
                } # End of IF ComputerName
            ELSE {
            Write-Debug "Attempring to create session from $ComputerName"
            $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
            Write-Verbose -Message "Connected to $Session"
                } # End of ELSE Block
            } # End of IF Session
        Write-Debug -Message "Attempting to connect to $Session"
        Invoke-Command -Session $Session -ScriptBlock {
            Write-Verbose -Message "Connected to $using:Session"
            IF ($Enable -eq $true) {
                $Value = '0'
                } # End of IF Enable
            ELSE {
                $Value = '1'
                } # End of ELSE
            Write-Debug -Message "Attempting registry change"
            Set-ItemProperty -Path $using:RegPath -Name DisableCAD -Value $Value -Force -ErrorAction Stop
            Write-Verbose -Message "Registry change complete"
            } # End of ScriptBlock
        } # End of TRY Block
    CATCH {
        Write-Verbose -Message "Couldn't Connect"
        } # End of CATCH Block
    } # End of PROCESS Block
} # End of Function Set-CAD

Function Get-AutoLogon {
<#
    .SYNOPSIS
    Returns auto login information from specifies machines.

    .DESCRIPTION
    This function checks the registry files to determine if auto logon is enabled or disabled. 

    .PARAMETER Session
    A [System.Management.Automation.Runspaces.PSSession[]] parameter that passes existing remote sessions into the function. Your sessions must be contained within a variable.

    .PARAMTER ComputerName
    A [string[]] parameter that can be used to specify an individual or list of computer names to the function. Using the ComputerName parameter will have the function create the remote session for you. 

    .PARAMETER Credential
    A [System.Management.Automation.CredentialAttribute()] parameter that is used to pass a variable containing secure credentials. See Get-Help Get-Credential for doing this. 

    .EXAMPLE
    Get-AutoLogon -Session
    This would query the computers in the remote session for auto logon registry files.

    .EXAMPLE
    Get-AutoLogon -ComputerName 'ENW10LIB01' -Credential $Cred
    This would query the computer named 'ENW10LIB01' for auto logon registry files.

    .NOTES
    This function was created by Xander Petty with intended use for Northern Oklahoma College. Use with caution.
#>
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing a remote session(s).",
            ParameterSetName = "Set 1")]
        [System.Management.Automation.Runspaces.PSSession[]]$Session = $null,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a computer name or a variable containing a list of computer names.",
            ParameterSetName = "Set 2")]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing your credentials.",
            ParameterSetName = "Set 2")]
        [System.Management.Automation.CredentialAttribute()]$Credential
        )

BEGIN {
    $RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon'
    } # End of BEGIN Block

PROCESS {
    TRY {
        IF ($Session -eq $null) {
            IF ($ComputerName -eq $env:COMPUTERNAME) {
                Write-Debug -Message "Using local computer for session"
                $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
                Write-Verbose -Message "Connected to local computer"
                } # End of IF ComputerName
            ELSE {
            Write-Debug -Message "Attempting to create session with $ComputerName"
            $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
            Write-Verbose -Message "Connected to $Session"
                } # End of ELSE Block
            } #End of IF Session
        Write-Debug -Message "Attempting to access $Session" 
        Invoke-Command -Session $Session -ScriptBlock {
            Write-Debug -Message "Looking for AutoAdminLogon registry file"
            $AutoAdminLogon = Get-ItemProperty -Path $using:RegPath -Name AutoAdminLogon -ErrorAction Stop
            Write-Debug -Message "Looking for DefaultUserName registry file"
            $DefaultUserName = Get-ItemProperty -Path $using:RegPath -Name DefaultUserName -ErrorAction Stop
            Write-Debug -Message "Looking for DefaultPassword registry file"
            $DefaultPassword = Get-ItemProperty -Path $using:RegPath -Name DefaultPassword -ErrorAction Stop
            IF ($AutoAdminLogon.AutoAdminLogon -eq 1) {
                $Status = "Enabled"
                } # End of IF AutoAdminLogon 
            ELSE {
                $Status = "Disabled"
                } # End of ELSE
            $Table = @{
                PSComputerName = $env:COMPUTERNAME
                "Auto Logon" = $Status
                "Default UserName" = $DefaultUserName.DefaultUserName
                "Default Password" = $DefaultPassword.DefaultPassword
                } # End of Table
            $Object = New-Object -TypeName psobject -Property $Table 
            $Object
            } # End of ScriptBlock
        Write-Verbose -Message "Obtained registry info"
        } # End of TRY Black
    CATCH {
        Write-Verbose -Message "Could not connect"
        } # End of CATCH Block
    } # End of PROCESS Block
} # End of Function Get-AutoLogon

Function Get-CAD {
<#
    .SYNOPSIS
    Returns ctrl+alt+del lock screen information from specifies machines.

    .DESCRIPTION
    This function checks the registry files to determine if ctrl+alt+del is enabled or disabled. 

    .PARAMETER Session
    A [System.Management.Automation.Runspaces.PSSession[]] parameter that passes existing remote sessions into the function. Your sessions must be contained within a variable.

    .PARAMTER ComputerName
    A [string[]] parameter that can be used to specify an individual or list of computer names to the function. Using the ComputerName parameter will have the function create the remote session for you. 

    .PARAMETER Credential
    A [System.Management.Automation.CredentialAttribute()] parameter that is used to pass a variable containing secure credentials. See Get-Help Get-Credential for doing this. 

    .EXAMPLE
    Get-CAD -Session
    This would query the computers in the remote session for ctrl+alt+del registry files.

    .EXAMPLE
    Get-CAD -ComputerName 'ENW10LIB01' -Credential $Cred
    This would query the computer named 'ENW10LIB01' for ctrl+alt+del registry files.

    .NOTES
    This function was created by Xander Petty with intended use for Northern Oklahoma College. Use with caution.
#>
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing a remote session(s).",
            ParameterSetName = "Set 1")]
        [System.Management.Automation.Runspaces.PSSession[]]$Session,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a computer name or a variable containing a list of computer names",
            ParameterSetName = "Set 2")]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [parameter(
            Mandatory=$true,
            HelpMessage = "Please enter a variable containing your credentials.",
            ParameterSetName = "Set 2")]
        [System.Management.Automation.CredentialAttribute()]$Credential
        )
BEGIN {
    $RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon'
    } # End of BEGIN Block

PROCESS {
    TRY {
        IF ($Session -eq $null) {
            IF ($ComputerName -eq $env:COMPUTERNAME) {
                Write-Debug -Message "Using local computer for session"
                $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
                Write-Verbose -Message "Connected to local computer"
                } # End of IF ComputerName
            ELSE {
            Write-Debug -Message "Attempting to create session with $ComputerName"
            $Session = New-PSSession -ComputerName $ComputerName -Credential $Cred -ErrorAction Stop
            Write-Verbose -Message "$Session has been created"
                } # End of ELSE Block
            } # End of IF Session
        Write-Debug -Message "Attempting to access $Session"
        Invoke-Command -Session $Session -ScriptBlock {
            Write-Debug -Message "Looking for DisableCAD registry file"
            $DisableCAD = Get-ItemProperty -Path $using:RegPath -Name DisableCAD -ErrorAction Stop
            IF ($DisableCAD.DisableCAD -eq 0) {
                $Status = "Enabled"
                } # End of IF DisableCAD
            ELSE {
                $Status = "Disabled"
                } # End of ELSE
            $Table = @{
                PSComputerName = $env:COMPUTERNAME
                "Ctrl-Alt-Del Status" = $Status
                }
            $Object = New-Object -TypeName psobject -Property $Table
            $Object
            } # End of ScriptBlock
        Write-Verbose -Message "Obtained registry info"
        } # End of TRY Block
    CATCH {
        Write-Verbose -Message "Couldn't connect"
        } # End of CATCH Block
    } # End of PROCESS Block
} # End of Function Get-CAD
# SIG # Begin signature block
# MIIFcwYJKoZIhvcNAQcCoIIFZDCCBWACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0NtU3D4rqiw+LER6KJrOY/HH
# /rSgggMMMIIDCDCCAfCgAwIBAgIQFpZplEQKLJxLR2CxAAds2TANBgkqhkiG9w0B
# AQUFADAcMRowGAYDVQQDDBFUZXN0IENvZGUgU2lnbmluZzAeFw0xNzA4MDExODI0
# MzFaFw0xODA4MDExODQ0MzFaMBwxGjAYBgNVBAMMEVRlc3QgQ29kZSBTaWduaW5n
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvHquqixWesWEFjlkx0vd
# 3jUqEDvEUPt9p0lUNnQQt6SwfYJ+CbklPRBw3E/VRYlizCy9CpNniurHz77ZBOsi
# PX6XJBJ82SW1N2ZiPRXFowheNX6qEtAhYhV7Q5BhqH/yvdg94pOo/IJUmCTpppxk
# sB9XAMN0ZqmEJneu8GnfJo9o0jXiixJFteYuFdpWwEO42qVGhYdVClVylf+Eeku2
# 9V4Al79pNbPmNv7sKmUyW2tU5G9Ko1ypI4s5+7+2q+eR7E16Gf59/d1nkysg5DCk
# t5cepcsxBgkdQWNA1IyKW9TZPkI2lU2GjAd3z41L/aMHrYX0dMFQVrU8nTj9gMgK
# lQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# HQYDVR0OBBYEFMzjNHaN6rToOJiHOS+2xxmfxhzhMA0GCSqGSIb3DQEBBQUAA4IB
# AQBKerh8lE0UsnzwIHRDH+ijueB874pbAh24iKlauj0ZjMRPgBFKLvj5/R9xeVPP
# Fu4QktLjntFcTnN1cK/aAuPFkoM/QYSkhPPsOABvSzPV+JyNSW3ZtRpxgfc8ToJm
# /d6ls4Oujv0xkZPT6lZ4lWM2dA4xJ8zzN1i5D35ZmyabsWqXKjBY0W4lTiZ8EUZ3
# s5TivvMDRCuI1Zjrc88frhSMK+hC97PACCO6Xluf8Mex4Ynizg0EREy3zCe5TYTQ
# 5XZ1Ww5PEosnOlOm4BRC3l7+2CZTz1SBVT0cjCVH9ylx9iXxfdRuvBad28tyowk4
# O0saQIvMgg1cwquVEI6B3xBYMYIB0TCCAc0CAQEwMDAcMRowGAYDVQQDDBFUZXN0
# IENvZGUgU2lnbmluZwIQFpZplEQKLJxLR2CxAAds2TAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# 2cdCzS5D6Xf6ogjVuJ/O6X2pWJEwDQYJKoZIhvcNAQEBBQAEggEAfp50Dny6aT4V
# jogaxSIIKi7DRHATXAw94tEyibGduxeGG+trS5O+xbbvK5Z7A3x5aLhg6UtMd4Gg
# shcG073oF8B5Gz8meAiuQsOJnOkuabYEYwH1t1wQYtWxRLtaO0+mNYfmM8gCaPxy
# wE49LTqcVnZ+WEJE/liQZmwvzvM5byRoSLagYESYgkb1IlY0U+2R5gJbpxMDJOkc
# MKcwmRhD+ULFPe7Pi5HnaBu2cs70jM5JIV2pt6UUJ+GuanJ3wbCT518xv++a3V/q
# yL+15JCijJ1ZhX2ydptJqI1ASONMns+EQAgpLHCdOnrX4+iVpyCUi1uUzx/ygUJO
# ReOa/KRYtA==
# SIG # End signature block
