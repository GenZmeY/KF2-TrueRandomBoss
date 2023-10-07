class TRBMut extends KFMutator
	dependson(TRB);

var private TRB TRB;

public simulated function bool SafeDestroy()
{
	return (bPendingDelete || bDeleteMe || Destroy());
}

public event PreBeginPlay()
{
	Super.PreBeginPlay();

	if (WorldInfo.NetMode == NM_Client) return;

	foreach WorldInfo.DynamicActors(class'TRB', TRB)
	{
		break;
	}

	if (TRB == None)
	{
		TRB = WorldInfo.Spawn(class'TRB');
	}

	if (TRB == None)
	{
		`Log_Base("FATAL: Can't Spawn 'TRB'");
		SafeDestroy();
	}
}

public function AddMutator(Mutator Mut)
{
	if (Mut == Self) return;

	if (Mut.Class == Class)
		TRBMut(Mut).SafeDestroy();
	else
		Super.AddMutator(Mut);
}

defaultproperties
{

}