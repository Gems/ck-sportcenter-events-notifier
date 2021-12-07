#!/usr/bin/env bash
#set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $dir

curl --http1.1 -vs -X POST -d "action=logIn&`head -1 .auth/web-creds`" "https://ck-sportcenter.lu/login.php" 2>/tmp/badminton-cookie.out

if [ "$1" == "-v" ]; then
  cat /tmp/badminton-cookie.out
fi

cookie=$(cat /tmp/badminton-cookie.out | grep -F 'Set-Cookie' | awk '{print $3}')
curl --http1.1 -s -H "Cookie: $cookie" 'https://ck-sportcenter.lu/clients_reservations.php' > /tmp/badminton.out

# Convert HTML output to JSON
echo '[' >/tmp/current_reservations.json

cat /tmp/badminton.out | grep -E '^(<tr|</tr>|<td>)' | grep -vE '(nbsp|Badminton|GH|\[SY\])' | sed -E 's/<tr.+>/{/g;s/.+tr>/},/g;s/<.?td>//g;s/([0-9]{2}.[0-9]{2}.[0-9]{4})/"date": "\1",/g;s/([0-9]{2}:[0-9]{2}) -/"start": "\1",/g;s/ [0-9]{2}:[0-9]{2}//g;s/(Court.+)/"title": "\1"/g;s/^([^"}{].+)/,"description": "\1"/g;' | tail -n +3 >>/tmp/current_reservations.json

echo "{}]" >>/tmp/current_reservations.json

# TODO: remove once the delta reservations handling is working
cp /tmp/current_reservations.json /tmp/badminton.json

# find deleted reservations
jq -n --argfile file1 /tmp/previous_reservations.json --argfile file2 /tmp/current_reservations.json '[$file1[] as $left | select([$file2[]] | all(.date != $left.date or .start != $left.start or .title != $left.title)) | {date: $left.date, start: $left.start, title: $left.title, description: $left.description}]' > /tmp/deleted_reservations.json

# find newly added reservations
jq -n --argfile file2 /tmp/previous_reservations.json --argfile file1 /tmp/current_reservations.json '[$file1[] as $left | select([$file2[]] | all(.date != $left.date or .start != $left.start or .title != $left.title)) | {date: $left.date, start: $left.start, title: $left.title, description: $left.description}]' > /tmp/added_reservations.json

