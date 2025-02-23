# Reset-PnPDevices
A simple Powershell script to toggle the state of problematic PnP devices.

I've been having sporadic problems on a new PC build where the Bluetooth module would get in an error state on boot, requiring either a reboot or just enabling it / disabling it in Device Manager.  This was annoying when I was using bluetooth peripherals, so I wrote a quick script to run at startup.

Save this script somewhere and create a scheduled task with SYSTEM permissions if you want it to execute at boot. You can do this via Powershell (run with elevated privileges) like this:

```
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Path\To\Script"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "Reset Problem PnP Devices" -Action $Action -Trigger $Trigger -Principal $Principal
```

I write logs to %SYSTEMDRIVE%\PnPReset and they don't rotate. Feel free to judge me.
