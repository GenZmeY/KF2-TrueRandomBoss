class KFGI_Access extends Object
	within KFGameInfo;

public function SetRandomBoss()
{
	OverrideBossIndex(Rand(default.AIBossClassList.Length));
}

public function class<KFPawn_Monster> Boss()
{
	return BossAITypePawn(BossIndex);
}

public function OverrideBossIndex(int Index, optional bool Force = false)
{
	if (Index < 0 || Index >= default.AIBossClassList.Length)
	{
		return;
	}

	if (!UseSpecificBossIndex(BossIndex) || Force)
	{
		BossIndex = Index;
	}

	MyKFGRI.CacheSelectedBoss(BossIndex);
}

public function class<KFPawn_Monster> BossAITypePawn(int AIType)
{
	if (AIType < AIBossClassList.Length)
		return AIBossClassList[AIType];
	else
		return None;
}

defaultproperties
{

}
