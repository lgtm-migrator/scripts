# iDOLM@STER Cinderella Girls Starlight Stage
## Description
This simple script backs up profile banner images and JSON data from
[deresute.me](https://deresute.me), which fetches data from the iDOLM@STER Cinderella
Girls Starlight Stage game. Use this in conjunction with crontab and run it at set
intervals.

## Usage
1. Download script.
2. Add `deresute-users.sh` with an `DERESUTE_PROFILE` associative array. Key
   should be 9 digit ID, value should be private ID in deresute.me.
3. Modify download locations as you see fit.
4. Run the script.
5. Optionally, add the script to your crontab.
