# Discord UPS Alerts
This script checks your uninterruptable power supply (UPS) and sends a Discord webhook notification when:
- The UPS switches from AC to battery power.
- The UPS returns to AC power after being on battery power.
- The UPS drops below 25% battery remaining.


## Usage
- Download and modify settings in `Discord-Battery.json` and `Discord-Webhook.json`
- Modify the embed alert texts in `Discord-Battery.ps1`.
- Run the script.
If you decide to run the script using Task Scheduler, remember to disable the automatic termination of the script.