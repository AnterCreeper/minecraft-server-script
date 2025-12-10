#!/bin/bash
major=0.18.2
minor=1.1.0
version=1.21.10
jarfile=fabric-server-mc.$version-loader.$major-launcher.$minor.jar
eula=3  #line number of eula=false
modlist="modlist.txt"
cfglist="cfglist.txt"
xmxsize=6144
cmdline="-Xdisableexplicitgc -Xgcpolicy:balanced -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:-DontCompileHugeMethods -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch"

script_dir=$(cd "$(dirname "$0")" && pwd)
cd "${script_dir}"

launch() {
screen -dmS minecraft -s ./run.sh
}

if [ -f "run.sh" ]; then
launch
fi

{
# install system packages
apt update
apt install -y screen aria2

# download mods
mkdir mods
cd mods
while read file
do
aria2c -x 16 -s 16 $file
done < ../${modlist}

} &
{
# download minecraft jarfile
curl -OJ https://meta.fabricmc.net/v2/versions/loader/$version/$major/$minor/server/jar
while [ ! -f "eula.txt" ]
do
java -jar $jarfile nogui
done

# setup eula
sed -i "${eula}s/false/true/" eula.txt

# setup config file
while read args
do
IFS=',' read -ra arg <<< "${args}"
sed -i "s/^${arg[0]}=.*/${arg[0]}=${arg[1]}/" server.properties
done < $cfglist

} &
wait
# setup run script
nursery_minimum=$(($xmxsize/4))
nursery_maximum=$(($xmxsize*2/5))
echo "java ${cmdline} -Xmx${xmxsize}M -Xms512M -Xmnx${nursery_maximum}M -Xmns${nursery_minimum}M -jar ${jarfile} nogui" > run.sh
chmod +x run.sh
launch
