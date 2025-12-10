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

# run script if exist
launch() {
screen -DmS minecraft -s ./run.sh
}
if [ -f "run.sh" ]; then
launch
exit 0
fi

{
# install system packages
apt update
apt install -y screen aria2

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
