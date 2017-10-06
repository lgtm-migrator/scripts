# Discord UPS Alerts
This script checks your uninterruptable power supply (UPS) and sends a Discord webhook notification when:
- The UPS switches from AC to battery power.
- The UPS returns to AC power after being on battery power.
- The UPS reaches the Windows "low" battery threshold.


## Usage
- Download and modify settings in `settings.json`
- Run the script.
If you decide to run the script using Task Scheduler, remember to disable the automatic termination of the script.