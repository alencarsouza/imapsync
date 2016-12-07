#!/bin/bash
#
# imapsync.sh - Migrating from private IMAP to Google Apps Email
# imapsync-list - standard list of accounts (need move to /tmp folder)
#
#
# Copyright (c) 2013-2017 Junior Holowka <junior.holowka@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# check for root
if [ "$(id -u)" != "0" ]; then
   echo "You must run this script as root" 1>&2
   exit 1
fi

if [ ! -f /usr/local/imapsync ]; then

# installing dependencies
apt-get update -y
apt-get install -y libauthen-ntlm-perl libcrypt-ssleay-perl libdigest-hmac-perl \
libfile-copy-recursive-perl libio-compress-perl libio-socket-inet6-perl \
libio-socket-ssl-perl libio-tee-perl libmodule-scandeps-perl libnet-ssleay-perl \
libpar-packer-perl libreadonly-perl libterm-readkey-perl libtest-pod-perl \
libtest-simple-perl libunicode-string-perl liburi-perl make cpanminus git

cpanm Data::Uniqid Mail::IMAPClient
cpanm Authen::NTLM Data::Uniqid File::Copy::Recursive IO::Tee Mail::IMAPClient Unicode::String

# install imapsync
mkdir -pv /opt/
(cd /opt/ && git clone git://github.com/imapsync/imapsync.git)
cp /opt/imapsync/imapsync /usr/local/bin

}

# running
cat imapsync-list|grep -v "^#" | sed '/^ *$/d' > /tmp/imapsync-list

LIST="/tmp/imapsync-list"
SERVER1="imap.yourwebmail.com"
SERVER2="imap.gmail.com"
HIDE="--nofoldersizes --skipsize" #Blank this out if you want to see folder sizes

while IFS=: read UNAME1 PWORD1 UNAME2 PWORD2; do

	echo -e "\033[1m===> Synchronizing account ${UNAME1} ... \033[0m\n"

	# sync special folders to gmail
	imapsync --syncinternaldates --useheader 'Message-Id' \
	--host1 ${SERVER1} --user1 ${UNAME1} \
	--password1 ${PWORD1} --ssl1 \
	--host2 ${SERVER2} \
	--port2 993 --user2 ${UNAME2} \
	--password2 ${PWORD2} --ssl2 \
	--authmech1 LOGIN --authmech2 LOGIN --split1 200 --split2 200 ${HIDE} \
	--exclude 'Drafts|Trash|Spam'

done < ${LIST}

