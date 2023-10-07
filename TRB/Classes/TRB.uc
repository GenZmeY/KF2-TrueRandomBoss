class TRB extends Info
	config(TRB);

const LatestVersion = 1;

enum E_State
{
	S_WAIT,
	S_WAVE,
	S_TRADER,
	S_END
};

var private config int            Version;
var private config E_LogLevel     LogLevel;
var private config float          WavePollingDT;
var private config float          TraderPollingDT;

var private KFGameInfo            KFGI;
var private KFGI_Access           KFGIA;
var private KFGameReplicationInfo KFGRI;

var private E_State               GameState;

public simulated function bool SafeDestroy()
{
	return (bPendingDelete || bDeleteMe || Destroy());
}

public event PreBeginPlay()
{
	`Log_Trace();

	if (WorldInfo.NetMode == NM_Client)
	{
		`Log_Fatal("NetMode == NM_Client, Destroy...");
		SafeDestroy();
		return;
	}

	Super.PreBeginPlay();

	PreInit();
}

private function PreInit()
{
	`Log_Trace();

	if (Version == `NO_CONFIG)
	{
		LogLevel = LL_Info;
		WavePollingDT   = 5.0f;
		TraderPollingDT = 1.0f;
		SaveConfig();
	}

	switch (Version)
	{
		case `NO_CONFIG:
			`Log_Info("Config created");

		case MaxInt:
			`Log_Info("Config updated to version"@LatestVersion);
			break;

		case LatestVersion:
			`Log_Info("Config is up-to-date");
			break;

		default:
			`Log_Warn("The config version is higher than the current version");
			`Log_Warn("Config version is" @ Version @ "but current version is" @ LatestVersion);
			`Log_Warn("The config version will be changed to" @ LatestVersion);
			break;
	}

	if (LatestVersion != Version)
	{
		Version = LatestVersion;
		SaveConfig();
	}

	if (LogLevel == LL_WrongLevel)
	{
		LogLevel = LL_Info;
		`Log_Warn("Wrong 'LogLevel', return to default value");
		SaveConfig();
	}
	`Log_Base("LogLevel:" @ LogLevel);
}

public event PostBeginPlay()
{
	`Log_Trace();

	if (bPendingDelete || bDeleteMe) return;

	Super.PostBeginPlay();

	PostInit();
}

private function PostInit()
{
	`Log_Trace();

	if (WorldInfo == None || WorldInfo.Game == None)
	{
		SetTimer(1.0f, false, nameof(PostInit));
		return;
	}

	KFGI = KFGameInfo(WorldInfo.Game);
	if (KFGI == None)
	{
		`Log_Fatal("Incompatible gamemode:" @ WorldInfo.Game $ ". Destroy...");
		SafeDestroy();
		return;
	}

	if (KFGI.GameReplicationInfo == None)
	{
		SetTimer(1.0f, false, nameof(PostInit));
		return;
	}

	KFGRI = KFGameReplicationInfo(KFGI.GameReplicationInfo);
	if (KFGRI == None)
	{
		`Log_Fatal("Incompatible Replication info:" @ KFGI.GameReplicationInfo);
		SafeDestroy();
		return;
	}

	KFGIA = new(KFGI) class'KFGI_Access';
	if (KFGIA == None)
	{
		`Log_Fatal("Can't create KFGI_Access object");
		SafeDestroy();
		return;
	}

	SetTimer(WavePollingDT, true, nameof(WavePolling));
}

private function WavePolling()
{
	`Log_Trace();

	if (!StateChanged()) return;

	`Log_Debug("GameState:" @ GameState);

	switch (GameState)
	{
		case S_TRADER:
			if (KFGRI.IsBossWaveNext())
			{
				`Log_Debug("Prepare to boss wave");
				SetTimer(TraderPollingDT, true, nameof(TraderPolling));
				ClearTimer(nameof(WavePolling));
			}
		break;

		case S_END:
			`Log_Debug("Cleanup");
			ClearTimer(nameof(WavePolling));
			ClearTimer(nameof(TraderPolling));
			SafeDestroy();
		break;

		case S_WAIT:
		case S_WAVE:
		default:
		break;
	}
}

private function TraderPolling()
{
	`Log_Trace();

	if (KFGRI.GetTraderTimeRemaining() < class'KFGame.KFVoteCollector'.default.TimeAfterSkipTrader || KFGRI.bWaveStarted)
	{
		`Log_Debug("Prev boss:" @ String(KFGIA.Boss()));
		KFGIA.SetRandomBoss();
		`Log_Info("New boss:" @ String(KFGIA.Boss()));
		ClearTimer(nameof(TraderPolling));
		SetTimer(WavePollingDT, true, nameof(WavePolling));
		return;
	}
}

private function E_State GetState()
{
	`Log_Trace();

	if (KFGRI.bMatchIsOver)    return S_END;
	if (!KFGRI.bMatchHasBegun) return S_WAIT;
	if (KFGRI.bTraderIsOpen)   return S_TRADER;
	if (KFGRI.bWaveStarted)    return S_WAVE;
}

private function bool StateChanged()
{
	local E_State NewState;
	local bool StateChanged;

	`Log_Trace();

	NewState = GetState();
	StateChanged = (GameState != NewState);
	GameState = NewState;

	return StateChanged;
}

defaultproperties
{
	GameState = S_WAIT
}