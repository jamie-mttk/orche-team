#!/bin/sh
read -p "Init system may cause unexpected problems,type YES to confirm:" CONFIRM
if [ "$CONFIRM" != "YES" ];then
	echo Init abort,type any key to continue!
	exit 1
fi

./server.sh init $@
