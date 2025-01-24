#!/bin/bash

# 0 means start the notification
# 2 means added successfully
# 3 means addition process canceled
# -1 means close


APP_STATE=-1

LONG_TERM_TODO="/home/mohsen/.local/share/todo_notification/todo_list.csv"
DAILY_TODO="/home/mohsen/.local/share/todo_notification/daily_todo_list.csv"
TODO_FILE=$DAILY_TODO


add_to_list() {
	echo "adding to list..."
	local entry=$(zenity --entry)

	if [ "$entry" == "" ]; then
		APP_STATE=3;
		return 0;
	fi

	local title=$(echo $entry | cut -d '|' -f 1)
	local date=$(echo $entry | cut -d '|' -f 2)
	local description=$(echo $entry | cut -d '|' -f 3)

	local num=$(tail -n 1 $TODO_FILE | cut -d '|' -f 1)
	local new_id=$((num + 1))

	if [ "$date" == "" ]; then
		# date not specified
		date="no deadline"
	fi

	echo -e "$new_id|$title|$date|$description" >> $TODO_FILE

	echo "added successfully";
	APP_STATE=2;
}


remove_from_list() {
	echo "removing task $1 from list..."
	sed -i "/^${1}|/d" $TODO_FILE
	echo "deleted successfully"
}


main_page() {

	local zenity_command="zenity --height=300 --width=700 --list --checklist --text 'Select completed tasks to delete' --column '' --column 'ID' --column 'title' --column 'date' --column 'description' --ok-label='Delete' --extra-button 'Add' "
	while IFS="|" read -r id title date description; do
		zenity_command+="FALSE $id '$title' '$date' '$description' "
	done < $TODO_FILE
	
	echo $zenity_command > zenity_cmd.sh
	zenity_output=$(bash zenity_cmd.sh)
	rm zenity_cmd.sh
	
	if [ "$zenity_output" == "Add" ]; then
		add_to_list;
		while [ $APP_STATE -eq 2 ]; do
			add_to_list;
		done
		return 0;
	fi

	if [ "$zenity_output" == "" ]; then
		APP_STATE=-1;
		return 0;
	fi

	IFS="|"
	for number in $zenity_output; do
		remove_from_list $number
	done

	APP_STATE=0; # run notification function again
}


notify() {
	zenity_state=$(zenity --info --title="Todo List" --text="Do you want to see your todo list?" --ok-label="Close" --extra-button "Daily" --extra-button "Long Term")

	case $zenity_state in
		"Daily") TODO_FILE=$DAILY_TODO; main_page; return 0;;
		"Long Term") TODO_FILE=$LONG_TERM_TODO; main_page; return 0;;
		*) APP_STATE=-1; return 0;;
	esac

}


APP_STATE=0

while [ $APP_STATE -ne -1 ]; do
	case $APP_STATE in
		0|3) notify;;
	esac
done


