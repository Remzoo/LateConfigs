#pragma semicolon 1

#define DEBUG 0

#define PLUGIN_AUTHOR "Remzo"
#define PLUGIN_VERSION "1.00"
#define TAG "[LateConfigs]"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

bool isMapEnd;
ArrayList convarList;

ConVar cvEnabled;
ConVar cvDelay;

public Plugin myinfo = 
{
	name = "Late configs",
	author = PLUGIN_AUTHOR,
	description = "Runs comamnds after a specified time from map start",
	version = PLUGIN_VERSION,
	url = "https://strefagier.com.pl"
};

public void OnPluginStart()
{
	cvEnabled = CreateConVar("sm_lateconfigs_enabled", "1", "Determines if enabled or not", 0, true, 0.0, true, 1.0);
	cvDelay = CreateConVar("sm_lateconfigs_delay", "3", "Time in seconds after comamnds will be executed", 0, true, 0.0);
	
	RegAdminCmd("sm_lateconfigs_reload", Command_Reload, ADMFLAG_RCON, "Reloads configs");
	RegAdminCmd("sm_lateconfigs_run", Command_Run, ADMFLAG_RCON, "Runs configs - for testing purposes");
	
	AutoExecConfig();
}

public void OnMapStart() {
	readConfigs();
	isMapEnd = false;
}

public void OnMapEnd() {
	isMapEnd = true;
}

public void OnAutoConfigsBuffered()
{
	if(cvEnabled.BoolValue) {
		PrintToServer("%s Configs will be executed in %f seconds", TAG, cvDelay.FloatValue);
		CreateTimer(cvDelay.FloatValue, Timer_ExecuteConfigs);
	}
}

public Action Timer_ExecuteConfigs(Handle timer) {
	if(!isMapEnd) {
		executeConfigs();
	}
}

void executeConfigs() {
	for (int i = 0; i < convarList.Length; i++) {
		char convar[64];
		convarList.GetString(i, convar, sizeof(convar));
#if DEBUG
		PrintToServer("%s Executing command: %s", TAG, convar);
#endif
		ServerCommand("%s", convar);
	}
}

void readConfigs() {
	convarList = new ArrayList(64);
	
	char configsPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, configsPath, sizeof(configsPath), "/configs/lateconfigs.cfg");
	
	if(!FileExists(configsPath)) {
		createEmptyConfigsFile(configsPath);
		return;
	}
	
	File configsFile = OpenFile(configsPath, "r");
	if(configsFile == null) {
		SetFailState("Can not read convars from config file /configs/lateconfigs.cfg It should be auto generated if not exists!");
		return;
	}
	
	char buffer[128];
	while(!configsFile.EndOfFile() && configsFile.ReadLine(buffer, sizeof(buffer))) {
		TrimString(buffer);
		
		if(strlen(buffer) <= 1) { // empty line or just one char - ignone, continue to next line
			continue;
		}
		
		if(buffer[0] == '/' && buffer[1] == '/') { // this line is commented - continue
			continue;
		}
		
		convarList.PushString(buffer);
	}
	
	configsFile.Close();
}

void createEmptyConfigsFile(char[] configsPath) {
	File file = OpenFile(configsPath, "a");
	if(file == null) {
		SetFailState("Can not create config file /configs/lateconfigs.cfg!");
		return;
	}
	
	file.WriteLine("// This is config file for lateconfigs.smx plugin");
	file.WriteLine("// Type your convars line by line without any characters at line start.");
	file.WriteLine("// It will be executed after delay time");
	
	file.Close();
}

public Action Command_Reload(int client, int args) {
	readConfigs();
	ReplyToCommand(client, "%s Config reloaded.", TAG);
	
	return Plugin_Handled;
}

public Action Command_Run(int client, int args) {
	if(convarList == null || convarList.Length == 0) {
		ReplyToCommand(client, "%s There is nothing to run. Empty config file.", TAG);
	}
	else {
		executeConfigs();
		ReplyToCommand(client, "%s Configs executed.", TAG);
	}
	
	return Plugin_Handled;
}