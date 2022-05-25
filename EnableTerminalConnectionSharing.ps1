
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EnableTerminalConnectionSharing -internetInterface "WiFi" -Disable:$True
# This powershell script accepts two optional parameters (requires edit if the script)
# -internetInterface "InterfaceName" , accepts the friendly name of the interface that you want to share internet from
# -Disable:$True , is used to disable the internet sharing, $False can be used but is the same as beeing omitted
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Param
(
    [Parameter(Mandatory = $false)]
    [string]
    $internetInterface,

    [Parameter(Mandatory = $false)]
    [switch]
    $Disable

)

Begin {

    $netShare = $null

    try {
        # Create a NetSharingManager object
        $netShare = New-Object -ComObject HNetCfg.HNetShare
    }
    catch {
        # Register the HNetCfg library silently (once)
        regsvr32 /s hnetcfg.dll

        # Create a NetSharingManager object
        $netShare = New-Object -ComObject HNetCfg.HNetShare
    }
}

Process {

    # Find the terminal interface
    # The interface description is always Remote NDIS based Internet Sharing Device - followed by a number
    # This script assumes only one terminal is connected to the PC

    Write-Host $Disable.IsPresent

    # Get adapter name with the correct description
    $terminalInterface = Get-NetAdapter -InterfaceDescription 'Remote *'
    $terminalInterfaceName = $terminalInterface.Name

    # test if interface is present
    if ([string]::IsNullOrWhiteSpace($terminalInterfaceName)) { 
            
        Write-Host $(Get-Date) ": Error - No terminal interface found, Aborting"
        Exit
        
    } else {

        # interface found        
        Write-Host $(Get-Date) ": Terminal interface found: " $terminalInterfaceName

        # Check if no internetInerface name is provided
        # The input parameter must be used if multiple internet interfaces is present on the Host machine
        
        try 
        {
            if (-not [string]::IsNullOrWhiteSpace($internetInterface)) { 
                
                # Name is provided via the -internetInterface "" input parameteri
                $internetInterfaceName = $internetInterface.Name
                Write-Host $(Get-Date) ": Internet interface defined: " $internetInterfaceName
            }
            else {

                # Find the interface with connected status and not undefined status
                $foundInternetInterface = Get-NetAdapter | Where-Object { $_.MediaConnectionState -eq 'Connected' -and $_.PhysicalMediaType -ne 'Unspecified' } | Sort-Object LinkSpeed -Descending

                # Store the name of the found interface
                $internetInterfaceName = $foundInternetInterface.Name
                Write-Host $(Get-Date) ": Internet interface found: " $internetInterfaceName
            }
        }
        catch 
        {
            Write-Host $(Get-Date) ": Error - No interface with internet autoatically found, Aborting"
            Exit
        }


        # Find the Enum values for each interface (friendly name can not be used to control the interface)
        $internetConnection = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $internetInterfaceName }
        $terminalConnection = $netShare.EnumEveryConnection | Where-Object { $netShare.NetConnectionProps.Invoke($_).Name -eq $terminalInterfaceName }
            
        # Get sharing configuration
        $internetConfig = $netShare.INetSharingConfigurationForINetConnection.Invoke($internetConnection)
        $terminalConfig = $netShare.INetSharingConfigurationForINetConnection.Invoke($terminalConnection)


        # Check if ICS is already active and if it should be disabled
        if ($Disable.IsPresent) {
                
            Write-Host $(Get-Date) ": Disabling the ICS"
            $internetConfig.DisableSharing()
            $terminalConfig.DisableSharing()
            Exit

        }
        elseif ($internetConfig.SharingEnabled -eq $true) {
                
            # ICS is already active, exit.
            Write-Host $(Get-Date) ": ICS is already active on interface: $internetInterfaceName"
            Exit

        }
        else {  
            # Activate ICS
            Write-Host $(Get-Date) ": Trying to activate ICS"

            try 
            {
                $internetConfig.EnableSharing(0)
                $terminalConfig.EnableSharing(1)
            } 
            catch 
            {
                Write-Host $(Get-Date) ": Failed to activate ICS, manually check if ICS is active on other interface?"
                Exit
            }


            # Output some information to console about the sharing
            Write-Host $(Get-Date) ": ICS activated from: Internet-interface: $internetInterfaceName -> Terminal-interface: $terminalInterfaceName  ( Status:"$internetConfig.SharingEnabled")"
        }
    }
}
 
