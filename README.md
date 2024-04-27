# Automate Sending SMS using Termux

Quick script to automate sending personalized reminder text messages from the termux app
Contacts to message are eeadread from a CSV file.
CSV format/header titles are: (blank),first_name,last_name,Phone

Messages are sent through your phone cell provider, so less likely to end up in spam.
### Usage:
`autosend.sh -f 'example-data.csv'`
Script will ask for csv filename if not entered with command and/or if default_csv variable value isn't found (default is hypothetical test-data.csv)

### For message template to send, use either:
* `message_template-RENAME_ME.txt` and rename to `message_template.txt`
  * Dont use variables in this, write out exactly what message will say
  * Personalized openner "Hey $(first_name)" already in the script, don't include here. Edit script directly to change that openner. 
* Edit the script and modify the value of the MSG variable

Comment out the `termux-sms-send` line and uncomment the `if echo` line right below it for testing without sending anything.

