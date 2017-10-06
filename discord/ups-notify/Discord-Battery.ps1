# UPS/Battery Notification for Discord Webhooks.
# Created by Injabie3 - https://injabie3.moe
# -------------------
# Description:
#
# Gets UPS/battery status, and if the server goes on battery, it
# notifies a webhook with information. This assumes your UPS protects 
# your internet connection, and that your ISP connection is unaffected
# by this outage.
# -------------------
# Requirements:
# Make sure your UPS battery is using the Windows default driver.
# The APC driver that comes with PowerChute does not allow Windows to 
# access the battery information.
#
# Created on 2017-10-04

# Read settings from an external file.
$settings = (Get-Content "settings.json") -join "`n" | ConvertFrom-Json

# Some settings in shorter variables.
$checkInterval = $settings.checkInterval
$webhook = $settings.webhook
$bodyPowerOutage = $settings.messages.powerOutage | ConvertTo-Json
$bodyPowerOutageRecovery = $settings.messages.powerOutageRecovery | ConvertTo-Json
$bodyBatteryLow = $settings.messages.batteryLow | ConvertTo-Json

$triggered = $false
$triggeredLow = $false
$triggeredCritical = $false


# The function below is modified from:
# http://techibee.com/powershell/hey-powershell-what-is-my-laptop-battery-status/1037
Function Check-BatteryStatus {
$BatteryStatus = (Get-WmiObject -Class Win32_Battery -ea 0).BatteryStatus
if($BatteryStatus) {
    switch ($BatteryStatus)
    {
    1 { "Battery is discharging" }
    2 { "The system has access to AC so no battery is being discharged. However, the battery is not necessarily charging." }
    3 { "Fully Charged" }
    4 { "Low" }
    5 { "Critical" }
    6 { "Charging" }
    7 { "Charging and High" }
    8 { "Charging and Low" }
    9 { "Charging and Critical " }
    10 { "Unknown State" }
    11 { "Partially Charged" }            

    }
}
}

# Event loop.
do
{
    $Battery = Get-WmiObject -Class Win32_Battery
    $Status = $Battery.BatteryStatus
    if(($Status -eq 1) -and (-not $triggered))
    # Battery is discharging.
    {
        Invoke-WebRequest -UseBasicParsing $webhook -ContentType "application/json" -Method POST -Body $bodyPowerOutage -Verbose
        $triggered = $true
    }
    elseif (($Status -eq 2) -and $triggered)
    # Back on AC.
    {
        Invoke-WebRequest -UseBasicParsing $webhook -ContentType "application/json" -Method POST -Body $bodyPowerOutageRecovery -Verbose
        $triggered = $false
    }
    elseif (($Status -eq 4) -and (-not $triggeredLow))
    #Low Battery
    {
        Invoke-WebRequest -UseBasicParsing $webhook -ContentType "application/json" -Method POST -Body $bodyBatterylow -Verbose
    }


    $time = Get-Date
    $state = Check-BatteryStatus
    $msg = "$time $state"
    echo $msg
    Sleep $checkInterval
} while ($true)

