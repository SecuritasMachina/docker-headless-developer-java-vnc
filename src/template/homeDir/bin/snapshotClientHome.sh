destPath="TODO"
if [[ $destPath = *TODO* ]]
then
	echo "Change destination path first in this file!"
	exit 1
fi

pathsToBackup=$HOME
ignorePaths="$HOME/.cache $HOME/tmp $HOME/jenkins.tmp $HOME/.config/google-chrome/Default/Service Worker/CacheStorage"
daysToKeep=45
tmpDir=$HOME/tmp/resiliency
credentialsSh=~/.NPD/setCredentials.sh
#Pull credentials from secure location
source $credentialsSh
echo "Using credentials from $credentialsSh"
if [[ $coldStorageEncryptKey = *TODO* ]]
then
	echo "Change password in $credentialsSh first!"
	exit 1
fi

encryptPassphrase=$coldStorageEncryptKey
snapShotDir=$tmpDir/snapshots
snapShotWorkDir=$tmpDir/work
cDate=$(date +%Y-%m-%d_%H:%M:%S)
#Used below
snapShotTarFileName=$cDate.tgz
snapShotTarFile=$snapShotWorkDir/$snapShotTarFileName

#Add snapshot dir to user backup
pathsToBackup="$snapShotDir $pathsToBackup"

#TODO Make ignore file
echo $ignorePaths > $snapShotWorkDir/ignoreFiles.txt

mkdir -p $snapShotDir
mkdir -p $snapShotWorkDir

apt list >$snapShotDir/InstalledAptList.txt

#echo "Will backup an estimated XXX GB"

echo "Ignoring: $ignorePaths"
echo "Backing up $pathsToBackup to $destPath/$snapShotTarFileName"
tar --preserve-permissions --ignore-failed-read --exclude-from="$HOME/tarexcludelist.txt" -czf $snapShotTarFile  -C $pathsToBackup . 

echo "Started encrypting $snapShotTarFileName with AES-256"
#Encrypt using AES256
gpg --symmetric --cipher-algo=AES-256 --passphrase="$encryptPassphrase" --batch $snapShotTarFile
echo "Finished encrypting $snapShotTarFileName"
#If someone happens upon device file is stored on, make it look like corrupted tar file..
cd $snapShotWorkDir
mv $snapShotTarFileName old$snapShotTarFileName
mv $snapShotTarFile.gpg $snapShotTarFileName
cp $snapShotTarFileName $destPath
rm -rf $tmpDir

#delete archives over $daysToKeep days old
echo "Deleting files older than $daysToKeep days old"
find $destPath -mtime +$daysToKeep -type f -delete
echo "!! Finished !! "
