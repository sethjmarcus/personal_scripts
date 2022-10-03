#!/bin/bash

echo "Enter masechta name. Don't worry about spaces"
read masechta_name

#regex to check that command line argument is a number
re='^[0-9]+$'

until [[ $start_num =~ $re ]]; do
	echo 'Enter starting number'
	read start_num

	if ! [[ $start_num =~ $re ]] ; then
		echo "error: Not a number. Try again"
	fi
done

# Brings up a GUI for the user to select which folder to run the script on. I found this online. I am not sure how it works though.
folder=$(zenity --file-selection --directory --title="Choose rsync source directory" --filename=$HOME/Desktop/)

if [ -z "$folder" ]; then
	echo "Program killed."
	exit 1
fi

# Loop through the folder where the name of the file matches "*.MP3". Type flag might be redundant here. The -tr flag allows for reverse (oldest first) ordering.
# See above comment on how I got this.

find $folder -name "*.MP3" -type f -print0 | xargs -0 ls -tr | while read i; do
	#Get parts of the date needed for renaming
	MODDATE=$(stat -c %y "$i")
	MODDAY=$(date -d "$MODDATE" '+%d')
	MODMONTHNAME=$(date -d "$MODDATE" '+%b')
	MODYEAR=$(date -d "$MODDATE" '+%Y')

	# Create the new file name
	new_file_name=$(printf "${masechta_name} #%03d ${MODMONTHNAME} ${MODDAY} ${MODYEAR}.MP3" "$start_num")
	echo ${folder}//${new_file_name}
	mv -i -- "$i" "${folder}//${new_file_name}"

	start_num=$((start_num+1))
done
