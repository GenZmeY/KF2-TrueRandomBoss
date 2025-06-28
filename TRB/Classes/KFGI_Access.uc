// This file is part of True Random Boss.
// True Random Boss - a mutator for Killing Floor 2.
//
// Copyright (C) 20XX GenZmeY (mailto: genzmey@gmail.com)
//
// True Random Boss is free software: you can redistribute it
// and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// True Random Boss is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with True Random Boss. If not, see <https://www.gnu.org/licenses/>.

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
