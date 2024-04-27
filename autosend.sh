#!/data/data/com.termux/files/usr/bin/bash

# log function: Appends a timestamped log message to 't1.log'
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> t1.log
}

# Default path for the CSV file
default_csv="./test-data.csv"

usage() {
    echo "Usage: $0 [-f csv_file_path]"
    echo "  -f Specify the CSV file path containing contact details."
    exit 1
}

# usage function: Displays usage instructions and option processing handling the '-f' option to specify the CSV file. and exits with an error code
while getopts ":f:" opt; do
  case $opt in
    f) CONTACTS_CSV="$OPTARG"
    ;;
    \?) log "Invalid option -$OPTARG"
        usage
    ;;
  esac
done

# Sets the CSV file path to the provided value or the default
CONTACTS_CSV="${CONTACTS_CSV:-$default_csv}"

# validate_phone function: Ensures a phone number is a valid 10-digit format
validate_phone() {
    local phone=$1
    phone=${phone//[^0-9]/}
    [[ $phone =~ ^[0-9]{10}$ ]]
}

if [[ ! -f "$CONTACTS_CSV" ]]; then
    log "CSV test data file not found: $CONTACTS_CSV ; prompting for filename"
while true; do
    echo -e "Enter csv filename manually:"
    read -r CONTACTS_CSV
    log "CSV filename entered: $CONTACTS_CSV"
    # Remove potential quotes (single and double)
    CONTACTS_CSV="${CONTACTS_CSV//\'/}"  # Remove all single quotes
    CONTACTS_CSV="${CONTACTS_CSV//\"}"  # Remove all double quotes
    log "CSV filename processed: $CONTACTS_CSV"
    if [[ -f "$CONTACTS_CSV" ]]; then
	log "reading $CONTACTS_CSV ..."
    	break  # Exit the loop if the file is found
    else
        echo -e "File not found. Please try again.\n"
	log "File $CONTACTS_CSV not found. Check for mispellings and make sure file is in the current directory"
    fi
done
fi



TEMPLATE_FILE="./message_template.txt"


if [[ ! -f "$TEMPLATE_FILE" ]]; then
   echo "Template file not found: $TEMPLATE_FILE"

	while true; do
		default_sender='your friend'
		echo -e "Enter your name to include in the message:"
		read -r SENDER_NAME
		SENDER_NAME="${SENDER_NAME:-$default_sender}"
		echo $SENDER_NAME
		SENDER_NAME=$(echo "${SENDER_NAME}" | sed 's/[^a-zA-Z]//g')

		echo -e "\nYou entered $SENDER_NAME"
		read -p "Is that correct? [y/n] " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			log "Using sender name $SENDER_NAME"
			break
		elif [[ $REPLY =~ ^[Nn]$ ]]; then
			log "Incorrectly entered sender name as $SENDER_NAME, trying again"
		else
			echo -e "Invalid response. Answer y for yes or n for no"
		fi
	done
	MSG="this is $SENDER_NAME from San Diego DSA! I wanted to make sure you’ve heard about the Quarterly Assembly we have scheduled for Sunday at 4. Can we count on you to attend?"
	MSG_TEMPLATE="${MSG_TEMPLATE:-$MSG}"

else
	MSG_TEMPLATE="$(cat "$TEMPLATE_FILE")"
fi




# Function to clean and sanitize names
clean_name() {
  name="$1"


  # Split on spaces, capitalize the first part
  name=(${name// / })

  # Remove non-alphanumeric characters (keep hyphens)
  name="${name//[^a-zA-Z-]/}"

  name="${name,,}"
  name="${name^}"
  echo "$name"
}


# grab columns by name if feasible
while IFS=',' read -r _ first_name last_name Phone _
do
	first_name=$(clean_name "$first_name")
	last_name=$(clean_name "$last_name")
	phone=${Phone:2}

    if validate_phone "$phone"; then
#        if termux-sms-send -n "$phone" "Hey $first_name, $MSG_TEMPLATE"; then
	if echo -e "$phone \nHey $first_name, $MSG_TEMPLATE"; then
            log "SMS sent to $first_name $last_name: $phone"
        else
            log "Failed to send SMS to $first_name $last_name: $phone"
        fi
    else
        log "Invalid phone number for $first_name $last_name: $phone"
    fi
done < <(tail -n +2 "$CONTACTS_CSV")

log "All messages have been processed."
