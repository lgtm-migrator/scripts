# 2017-10-04
# Injabie3 - https://injabie3.moe
#
# Description:
# UPS/Battery Notification for Discord Webhooks.
#
# Gets UPS/battery status, and if the server goes on battery, it
# notifies a webhook with information. This assumes your UPS protects 
# your internet connection, and that your ISP connection is unaffected
# by this outage.
#
# Make sure your UPS battery is using the Windows default driver.
# The APC driver that comes with PowerChute does not allow Windows to 
# access the battery information.

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

Discord-PostWebhook "Discord Battery Script" `
    ":information_source: The battery checker script has been started."

# Event loop.
do
{
    $Battery = Get-WmiObject -Class Win32_Battery
    $Status = $Battery.BatteryStatus
    $BatteryPercentage = $Battery.EstimatedChargeRemaining


    if (($Status -eq 1) -and ($BatteryPercentage -le 35) -and (-not $triggeredLow))
    #Low Battery
    {
        $emojis = ":warning: :battery:"
        Discord-PostWebhook "Battery Low" `
            "$emojis The server has $BatteryPercentage% battery left! Shutdown will commence soon!"
        $triggeredLow = $true
        $triggeredFullyCharged = $false
    }
    elseif(($Status -eq 1) -and (-not $triggered))
    # Battery is discharging.
    {
        $emojis = ":warning: :battery:"
        Discord-PostWebhook "Power Outage" `
            "$emojis The server has switched to battery power ($BatteryPercentage% remaining)!"
        $triggered = $true
        $triggeredFullyCharged = $false
    }
    elseif (($Status -eq 2) -and $triggered)
    # Back on AC.
    {
        $emojis = ":information_source: :electric_plug:"
        Discord-PostWebhook "Power Online" `
            "$emojis The server has switched to AC with $BatteryPercentage% remaining."
        $triggered = $false
        $triggeredLow = $false
        shutdown /a /m \\LuiP-Miria
    }
    elseif (($Status -eq 2) -and ($BatteryPercentage -eq 100) -and (-not $triggeredFullyCharged))
    # Battery fully charged!
    {
        $emojis = ":information_source: :electric_plug:"
        Discord-PostWebhook "Battery Recharged" `
            "$emojis The battery is now fully charged!"
        $triggeredFullyCharged = $true
    }

    $time = Get-Date
    $msg = "$time Currently at $BatteryPercentage%"
    echo $msg
    Sleep $checkInterval
} while ($true)

