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
# Modified on 2018-02-09 - Use my custom function from Discord-Webhook.ps1.

# Include the function first.
.".\Discord-Webhook.ps1"

# Read settings from an external file.
$settings = (Get-Content "Discord-Battery.json") -join "`n" | ConvertFrom-Json

# Some settings in shorter variables.
$checkInterval = $settings.checkInterval

$triggered = $false
$triggeredLow = $false
$triggeredCritical = $false
$triggeredFullyCharged = $false

Discord-PostWebhook "Discord Battery Script" ":information_source: The battery checker script has been started."

# Event loop.
do
{
    $Battery = Get-WmiObject -Class Win32_Battery
    $Status = $Battery.BatteryStatus
    $BatteryPercentage = $Battery.EstimatedChargeRemaining


    if (($Status -eq 1) -and ($BatteryPercentage -le 35) -and (-not $triggeredLow))
    #Low Battery
    {
        Discord-PostWebhook "Battery Low" ":warning: :battery: The server has $BatteryPercentage% battery left!  Shutdown will commence soon!"
        $triggeredLow = $true
        $triggeredFullyCharged = $false
    }
    elseif(($Status -eq 1) -and (-not $triggered))
    # Battery is discharging.
    {
        Discord-PostWebhook "Power Outage" ":warning: :battery: The server has switched to battery power ($BatteryPercentage% remaining)!"
        $triggered = $true
        $triggeredFullyCharged = $false
    }
    elseif (($Status -eq 2) -and $triggered)
    # Back on AC.
    {
        Discord-PostWebhook "Power Online" ":information_source: :electric_plug: The server has switched to AC with $BatteryPercentage% remaining."
        $triggered = $false
        $triggeredLow = $false
        shutdown /a /m \\LuiP-Miria
    }
    elseif (($Status -eq 2) -and ($BatteryPercentage -eq 100) -and (-not $triggeredFullyCharged))
    # Battery fully charged!
    {
        Discord-PostWebhook "Battery Recharged" ":information_source: :electric_plug: The battery is now fully charged!"
        $triggeredFullyCharged = $true
    }

    $time = Get-Date
    $msg = "$time Currently at $BatteryPercentage%"
    echo $msg
    Sleep $checkInterval
} while ($true)

