# Discord Webhook Notifer function.
# Created by Injabie3 - https://injabie3.moe
# -------------------
# Description:
#
# Function to send payload to a Discord webhook.
# -------------------
# Created on 2017-10-07
# Modified on 2018-02-09

# The function below is modified from:
# http://techibee.com/powershell/hey-powershell-what-is-my-laptop-battery-status/1037
Function Discord-PostWebhook ($title, $message)
{
    # Read settings from an external file.
    $settings = (Get-Content "Discord-Webhook.json") -join "`n" | ConvertFrom-Json

    # Some settings in shorter variables.
    $webhook = $settings.webhook
    $bodyMessage = $settings.message
    $bodyMessage.embeds[0].title = $title
    $bodyMessage.embeds[0].description = $message

    # Some information in the footer.
    $time = Get-Date
    $text = $bodyMessage.embeds[0].footer[0].text
    $bodyMessage.embeds[0].footer[0].text = "$text | $time"
    # Send payload
    return Invoke-WebRequest -UseBasicParsing $webhook -ContentType "application/json" -Method POST -Body ($bodyMessage | ConvertTo-Json -Depth 4) -Verbose
}