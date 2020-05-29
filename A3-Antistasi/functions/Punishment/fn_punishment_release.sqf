/*
Function:
	A3A_fnc_punishment_release

Description:
	Releases a detainee from his sentence if he is incarcerated.
	Forgives all punishment stats.

Scope:
	<SERVER> Execute on server.

Environment:
	<ANY>

Parameters:
	<OBJECT> The detainee.
	<STRING> Who is calling the function. All external calls should only use "forgive".

Returns:
	<BOOLEAN> True if hasn't crashed; False is Invalid Params; nothing if it has crashed.

Examples:
	[cursorObject,"forgive"] remoteExec [A3A_fnc_punishment_release,2]; // Forgive all sins and release from Ocean Gulag.

Author: Caleb Serafin
Date Updated: 29 May 2020
License: MIT License, Copyright (c) 2019 Barbolani & The Official AntiStasi Community
*/
params ["_detainee",["_source",""]];
private _filename = "fn_punishment_release.sqf";

if (!isServer) exitWith {
	[[1, "NOT SERVER"], _filename] call A3A_fnc_log;
	false;
};

private _keyPairs = [ ["_punishmentPlatform",objNull] ];
private _UID = getPlayerUID _detainee;
private _data_instigator = [_UID,_keyPairs] call A3A_fnc_punishment_dataGet;
_data_instigator params ["_punishmentPlatform"];
private _playerStats = format["Player: %1 [%2]", name _detainee, _UID];

private _releaseFromSentence = {
	[_detainee] remoteExec ["A3A_fnc_punishment_removeActionForgive",0,false];
	[_detaineeUID,"remove"] call A3A_fnc_punishment_oceanGulag;
};
private _forgiveStats = {
	private _keyPairs = ["timeTotal","offenceTotal","overhead","_sentenceEndTime"];
	[_UID,_keyPairs] call A3A_fnc_punishment_dataRem;
};

switch (_source) do {
	case "punishment_warden": {
		call _forgiveStats;
		call _releaseFromSentence;
		[2, format ["RELEASE | %1", _playerStats], _filename] call A3A_fnc_log;
		["FF Notification", "Enough then."] remoteExec ["A3A_fnc_customHint", _detainee, false];
		true;
	};
	case "punishment_warden_manual": {
		call _forgiveStats;
		call _releaseFromSentence;
		[2, format ["FORGIVE | %1", _playerStats], _filename] call A3A_fnc_log;
		["FF Notification", "An admin looks with pity upon your soul.<br/>You have been forgiven."] remoteExec ["A3A_fnc_customHint", _detainee, false];
		true;
	};
	case "forgive": {
		call _forgiveStats;
		true;
	};
	default {
		[1, format ["INVALID PARAMS | _source=""%1""", _source], _filename] call A3A_fnc_log;
		false;
	};
};