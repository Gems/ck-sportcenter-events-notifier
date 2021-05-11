
## `${ICAL_TMPL}`

The `${ICAL_TMPL}` secret variable contents gets added as is to the ICAL event content.

It could contain a list of participants or other extensions to the event details.

Example:
```
ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN={Person Name}:MAILTO:{Person email}
```
NB: The `PARTSTAT=NEEDS-ACTION;RSVP=TRUE;` doesn't really affect the `gcalcli` creates the event and it doesn't make `gcalcli` and Google Calendar to send invitations out. The `PARTSTAT=NEEDS-ACTION` directive in global ICAL template makes it happen. Though with some patching of the `gcalcli` code one could make it work as expected. I've spent two days on finding this out 🤦‍

## `${WEB_CREDS}`

The `${WEB_CREDS}` secret variable contains credentials for the CK Sportcenter account.

The following format is expected:
```
username={username goes here}&password={password goes here}
```
