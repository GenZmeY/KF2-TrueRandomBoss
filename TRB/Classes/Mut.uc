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

class Mut extends KFMutator
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

public function AddMutator(Mutator M)
{
	if (M == Self) return;

	if (M.Class == Class)
		Mut(M).SafeDestroy();
	else
		Super.AddMutator(M);
}

static function String GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	return String(class'TRB');
}

defaultproperties
{

}