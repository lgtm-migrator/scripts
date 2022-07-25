# 2017-10-07
# Injabie3 - https://injabie3.moe
#
# Description:
# Discord Webhook Notifer function.
#
# Function to send payload to a Discord webhook.

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
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    return Invoke-WebRequest -UseBasicParsing $webhook -ContentType "application/json" -Method POST -Body ($bodyMessage | ConvertTo-Json -Depth 4) -Verbose
}
