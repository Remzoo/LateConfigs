# LateConfigs
Runs commands after a specified time from map start


## How to install
1. Download `lateconfigs.smx` and move it to sourcemod plugins directory
2. Load plugin with your favorite method (reload map, server, execute `sm plugins load lateconfigs.smx` command, or just wait until map end)
3. The plugin will create 2 configs file:
* `plugin.lateconfigs.cfg` - under your `/cfg/sourcemod/` location
* `lateconfigs.cfg` - under you `/sourcemod/configs/` location
4. In `plugin.lateconfigs.cfg` you can set plugin settings
5. And in `lateconfigs.cfg` you can write commands which will be executed after delay


## ConVars
The plugin can be controlled by following convars:
* `sm_lateconfigs_enabled` - default value **1** - Determines if enabled or not
* `sm_lateconfigs_delay` - default value **3** - Time in seconds after commands will be executed

## Admin Commands
Administrator with **RCON** privileges can run following commands:
* `sm_lateconfigs_reload` - Reloads configs
* `sm_lateconfigs_run` - Runs configs - for testing purposes
