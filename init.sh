#!/bin/bash
# configuration
major=0.18.2
minor=1.1.0
version=1.21.10
eula=3                 #the line number of "eula=false"
modlist="modlist.txt"  #url list of mods
cfglist="cfglist.txt"  #modify list of server.properties
xmxsize=6144           #Xmx size in megabytes
source=https://meta.fabricmc.net/v2/versions/loader/$version/$major/$minor/server/jar
jarfile=fabric-server-mc.$version-loader.$major-launcher.$minor.jar
cmdline="-XX:+UseZGC -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:-DontCompileHugeMethods"

# switch to script root
script_dir=$(cd "$(dirname "$0")" && pwd)
cd "${script_dir}"

# launch if exist
launch() {
# excute run script, -dmS: return, -DmS: block
screen -dmS minecraft -s ./run.sh

# start proxy, opening minecraft and ssh port
#chisel client --auth <username>:<password> <url> R:25565:localhost:25565 R:<port>:localhost:22

}
if [ -f "run.sh" ]; then
launch
exit 0
fi

{
# install system packages
apt -y -qq update
apt -y -qq install screen aria2 openssh-server openssh-sftp-server

# download proxy daemon
#curl -OJ <url>/chisel_1.11.4_linux_amd64.deb
#dpkg -i chisel_1.11.4_linux_amd64.deb

# download mod jarfiles
mkdir mods
cd mods
while read file
do
aria2c -x 16 -s 16 $file
done < ../${modlist}
} &

{
# download minecraft jarfile
curl -OJ $source
while [ ! -f "eula.txt" ]
do
java -jar $jarfile nogui
done

# setup eula
sed -i "${eula}s/false/true/" eula.txt

# setup server.properties
while read args
do
IFS='=' read -ra arg <<< "${args}"
sed -i "s/^${arg[0]}=.*/${arg[0]}=${arg[1]}/" server.properties
done < $cfglist
} &

# setup run script
wait
echo "java ${cmdline} -Xmx${xmxsize}M -Xms512M -jar ${jarfile} nogui" > run.sh
chmod +x run.sh
launch
