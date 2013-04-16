#!/bin/bash

# imapsync.sh - Migrating from private IMAP to Google Apps Email
# imapsync-list - standard list of accounts (need move to /tmp folder)


# check for root
if [ "$(id -u)" != "0" ]; then
   echo "You must run this script as root" 1>&2
   exit 1
fi


# installing dependencies
 apt-get update
 apt-get install libdigest-hmac-perl libdigest-hmac-perl libterm-readkey-perl \
				libterm-readkey-perl libdate-manip-perl libdate-manip-perl libmail-imapclient-perl \
				makepasswd rcs perl-doc libmail-imapclient-perl make

# cloning and installing imapsync (version 1.525)
 git clone git://github.com/imapsync/imapsync.git
 cd imapsync/
 make install



# running
cat imapsync-list|grep -v "^#" | sed '/^ *$/d' > /tmp/imapsync-list

LIST="/tmp/imapsync-list"
HOSTSOURCE="mx1.domain.com"
HIDE="--nofoldersizes --skipsize" #Blank this out if you want to see folder sizes

while IFS=: read UNAME1 PWORD1 UNAME2 PWORD2; do

	echo -e "\033[1m===> Synchronizing account ${UNAME1} ... \033[0m\n"

	# sync special folders to gmail
	imapsync --syncinternaldates --useheader 'Message-Id' \
	--host1 ${HOSTSOURCE} --user1 ${UNAME1} \
	--password1 ${PWORD1} --ssl1 \
	--host2 imap.googlemail.com \
	--port2 993 --user2 ${UNAME2} \
	--password2 ${PWORD2} --ssl2 \
	--ssl2 --noauthmd5 --split1 200 --split2 200 ${HIDE} \
	--folder "Inbox/Sent" --prefix2 '[Gmail]/' --regextrans2 's/Inbox\/Sent/Sent Mail/' \
	--folder "Inbox/Spam" --prefix2 '[Gmail]/' --regextrans2 's/Inbox\/Spam/Spam/' \
	--folder "Inbox/Trash" --prefix2 '[Gmail]/' --regextrans2 's/Inbox\/Trash/Trash/' \
	--folder "Inbox/Drafts" --prefix2 '[Gmail]/' --regextrans2 's/Inbox\/Drafts/Drafts/' \

done < ${LIST}









