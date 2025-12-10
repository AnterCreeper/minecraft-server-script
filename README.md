# Minecraft Server Docker Launcher Scripts

### License

This project is licensed under the MIT license. **DO NOT** download or clone this project until you have read and agree the LICENSE.     
该项目采用 `MIT` 授权。当你下载或克隆项目时，默认已经阅读并同意该协定。

### Overview

This project is used to simplify minecraft server docker setup.
The files under the project:
- init.sh: main script (default for fabric 1.21.10)
- modlist.txt: list of mod urls to be downloaded.
- cfglist.txt: list of options to be modified in `server.properties`.

### Usage

1. clone the project `git clone <url of project>`
2. create container with properties below:
- image: `eclipse-temurin:21-jre`
- mount: `<path to project>:/minecraft`
- port: `25565:25565/tcp`
- command: `/minecraft/init.sh`
3. start the container and wait for initial setup procedure.
4. connect interactive shell and type in `screen -r` to enter the console of minecraft server.
