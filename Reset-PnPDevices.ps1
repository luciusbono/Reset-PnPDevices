# Script to detect and reset problematic PnP devices at startup
# Requires administrative privileges

# Logging function
function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Host $logMessage
    Add-Content -Path "$env:USERPROFILE\log\PnPReset\device_reset.log" -Value $logMessage
}

# Ensure log directory exists
if (-not (Test-Path "$env:USERPROFILE\log\PnPResett")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\log\PnPReset" -Force | Out-Null
}

Write-Log "Starting PnP device check..."

try {
    # Get all devices in an error state. 
    # Checking for ConfigManagerErrorCode != 0 is redundant but I thought it might catch corner cases.
    $problemDevices = Get-PnpDevice | Where-Object { 
        $_.Present -eq $true -and (
            $_.Status -eq "Error" -or 
            $_.ConfigManagerErrorCode -ne 0
        )
    }

    if ($problemDevices) {
        foreach ($device in $problemDevices) {
            Write-Log "Found problematic device: $($device.FriendlyName)"
            Write-Log "Device ID: $($device.InstanceId)"
            Write-Log "Current Status: $($device.Status)"
            Write-Log "Error Code: $($device.ConfigManagerErrorCode)"
            
            try {
                # Disable the device
                Write-Log "Attempting to disable device..."
                Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
                Start-Sleep -Seconds 5
                
                # Enable the device
                Write-Log "Attempting to enable device..."
                Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
                Start-Sleep -Seconds 5
                
                # Check if the device is now working
                $deviceStatus = Get-PnpDevice -InstanceId $device.InstanceId
                if ($deviceStatus.Status -eq "OK") {
                    Write-Log "Successfully reset device: $($device.FriendlyName)"
                } else {
                    Write-Log "Device still having issues after reset: $($device.FriendlyName)"
                }
            }
            catch {
                Write-Log "Error resetting device: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Log "No problematic devices found."
    }
}
catch {
    Write-Log "Error executing script: $($_.Exception.Message)"
}

Write-Log "Script execution completed."
