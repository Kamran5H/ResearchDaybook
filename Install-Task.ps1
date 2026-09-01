# Registers the auto-popup: opens Research Daybook ONCE per day, at/after 10 AM.
# Combines Daily 10:00 AM trigger + AtLogOn trigger.
# launch.vbs contains the hour guard (< 10 AM skips) and once-per-day guard (%LOCALAPPDATA%\ResearchDaybook\lastshown.txt).
$ErrorActionPreference = 'Stop'
$base = Split-Path -Parent $MyInvocation.MyCommand.Definition
$vbs  = Join-Path $base 'launch.vbs'
if (-not (Test-Path $vbs)) { throw "launch.vbs not found at $vbs" }

# Remove existing task
try { Unregister-ScheduledTask -TaskName 'ResearchDaybook' -Confirm:$false -ErrorAction SilentlyContinue } catch {}

$action = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument ('"{0}"' -f $vbs) -WorkingDirectory $base
$triggers = @(
    (New-ScheduledTaskTrigger -Daily -At 10:00AM),
    (New-ScheduledTaskTrigger -AtLogOn)
)
$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit ([TimeSpan]::FromMinutes(5)) `
    -Priority 5

Register-ScheduledTask -TaskName 'ResearchDaybook' -Action $action -Trigger $triggers `
  -Settings $settings -Description 'Opens Research Daybook once daily at/after 10 AM.' -Force | Out-Null

# Also register/refresh the Windows Startup folder shortcut for multi-layer redundancy
$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir 'ResearchDaybook.lnk'
$wsh = New-Object -ComObject WScript.Shell
$sc = $wsh.CreateShortcut($shortcutPath)
$sc.TargetPath = 'wscript.exe'
$sc.Arguments = ('"{0}"' -f $vbs)
$sc.WorkingDirectory = $base
$sc.Description = 'Research Daybook Daily Launcher'
$ico = Join-Path $base 'daybook.ico'
if (Test-Path $ico) {
    $sc.IconLocation = $ico
}
$sc.Save()

Write-Host "SUCCESS: ResearchDaybook configured with Task Scheduler (10 AM Daily + AtLogOn) and Startup folder shortcut." -ForegroundColor Green
