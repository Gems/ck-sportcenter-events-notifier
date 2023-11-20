#!/bin/bash

# Replace with your actual poll ID
POLL_ID="5226825270513631873"

# Define the path to the JSON file in the same directory
JSON_FILE="./bot-updates-Monday-EOD-2.json"

# Check if the JSON file exists
if [ -e "$JSON_FILE" ]; then
    # Parse the JSON data from the file and extract poll votes
    poll_answer_data=$(jq -c '.result[] | select(.poll_answer) | select(.poll_answer.poll_id == "'$POLL_ID'")' "$JSON_FILE")
	
	
	echo "===================="
	echo "${poll_answer_data}"
	echo "===================="
	
	# get last poll summary
    latest_poll_data=$(jq -c '.result[] | select(.poll) | select(.poll.id == "'$POLL_ID'")' "$JSON_FILE" | jq -sc '. | sort_by(.update_id | tonumber) | reverse' | jq -c '.[0]')
	
    # Extract poll options for the specified POLL_ID
    enriched_poll_options=$(jq -c '.poll.options | to_entries | map({option_id: .key} + .value)' <<< "$latest_poll_data")
	# Put back the enriched poll options inside the latest poll data
	latest_poll_data_with_enriched_poll_options=$(jq -c --argjson opt "$enriched_poll_options" '.poll.options = $opt' <<< "$latest_poll_data")

	
	echo "===================="
	echo "${latest_poll_data_with_enriched_poll_options}"
	echo "===================="
	
	
	echo "===================="
	declare -A vote_map
	declare -A vote_count_map
    if [ -n "$poll_answer_data" ]; then
        #echo "Poll ID: $POLL_ID"
        while read -r vote; do
			#echo "Processing ${vote}"
            user_id=$(jq -r '.poll_answer.user.id' <<< "$vote")
            first_name=$(jq -r '.poll_answer.user.first_name' <<< "$vote")
            last_name=$(jq -r '.poll_answer.user.last_name' <<< "$vote")
            username=$(jq -r '.poll_answer.user.username' <<< "$vote")
            user_details="$first_name"
            [ "$last_name" != "null" ] && user_details+=" $last_name"
            [ "$username" != "null" ] && user_details+=" ($username)"
			user=$(echo "${user_details}" | awk -F' ' '{print $1}')
            option_id=$(jq -r '.poll_answer.option_ids[0]' <<< "$vote")
            option_text=$(jq -r --argjson option_id "$option_id" '.poll.options[] | select(.option_id == $option_id) | .text' <<< "$latest_poll_data_with_enriched_poll_options")
			# Add the user to the list of users who voted for this option
			vote_map["$option_text"]+=$'\n\t- '${user}
			# Increment the vote count for this option
			((vote_count_map["$option_text"]++))
            #echo -e "- $user ===> $option_text"
        done <<< "$poll_answer_data"
		
		# Print the map
        echo "Poll Votes:"
		for option_text in "${!vote_map[@]}"; do
			users="${vote_map["$option_text"]}"
			num_votes="${vote_count_map["$option_text"]}"
			echo "${option_text} [${num_votes} votes]"
			echo "${users:1}"
			echo
		done
    elif [ -n "$poll_data" ]; then
        echo "Poll ID: $POLL_ID"
        echo "Poll Votes: (No votes yet)"
    else
        echo "Poll with ID $POLL_ID not found in updates."
    fi
	echo "===================="
else
    echo "JSON file not found in the current directory."
fi