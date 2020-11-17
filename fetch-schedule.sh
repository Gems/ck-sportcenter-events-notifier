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
echo '[' >/tmp/badminton.json

cat /tmp/badminton.out | grep -E '^(<tr|</tr>|<td>)' | grep -vE '(nbsp|Badminton|GH|\[SY\])' | sed -E 's/<tr.+>/{/g;s/.+tr>/},/g;s/<.?td>//g;s/([0-9]{2}.[0-9]{2}.[0-9]{4})/"date": "\1",/g;s/([0-9]{2}:[0-9]{2}) -/"start": "\1",/g;s/ [0-9]{2}:[0-9]{2}//g;s/(Court.+)/"title": "\1"/g;s/^([^"}{].+)/,"description": "\1"/g;' | tail -n +3 >>/tmp/badminton.json

echo "{}]" >>/tmp/badminton.json

