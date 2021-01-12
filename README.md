
## `${ICAL_TMPL}`

The `${ICAL_TMPL}` secret variable contents gets added as is to the ICAL event content.

It could contain a list of participants or other extensions to the event details.

Example:
```
ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN={Person Name}:MAILTO:{Person email}
```

## `${WEB_CREDS}`

The `${WEB_CREDS}` secret variable contains credentials for the CK Sportcenter account.

The following format is expected:
```
username={username goes here}&password={password goes here}
```


