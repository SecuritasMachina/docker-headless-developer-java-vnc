#!/bin/bash  
chmod ug+x $HOME/apps/mysql/bin/mysqld
startme() {
    mysqld --datadir=$HOME/data/mysql &
}

stopme() {
    pkill -f "mysqld" 
}
initDataDir(){
read -r -p "This will erase data in $HOME/data/mysql - Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	rm -rf $HOME/data/mysql/*
	mkdir -p $HOME/data/mysql
	echo "!!MySQL creating datafiles and 'root' account password, note password."
	mysqld --initialize --datadir=$HOME/data/mysql --user=root
	
else
	echo "Cancelled"
fi


}
case "$1" in 
    start)   startme ;;
    stop)    stopme ;;
    initDataDir)    initDataDir ;;
    restart) stopme; startme ;;
    *) echo "usage: $0 start|stop|restart|initDataDir" >&2
       exit 1
       ;;
esac
