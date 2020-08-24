params ["_static", "_player"];

if (!alive _static) exitWith
{
    ["Steal Static", "You cannot steal a destroyed static weapon"] call A3A_fnc_customHint;
};

if (alive gunner _static) exitWith
{
    ["Steal Static", "The gunner of this static weapon is still alive"] call A3A_fnc_customHint;
};

if (activeGREF && ((typeOf _static == staticATteamPlayer) || (typeOf _static == staticAAteamPlayer))) exitWith
{
    ["Steal Static", "This weapon cannot be dissassembled"] call A3A_fnc_customHint;
};

private _marker = _static getVariable "StaticMarker";

if (!(sidesX getVariable [_marker,sideUnknown] == teamPlayer)) exitWith
{
    ["Steal Static", "You have to conquer this zone in order to be able to steal this Static Weapon"] call A3A_fnc_customHint;
};

_static setOwner (owner _player);
private _staticClass =	typeOf _static;
private _staticComponents = getArray (configFile >> "CfgVehicles" >> _staticClass >> "assembleInfo" >> "dissasembleTo");

deleteVehicle _static;

//We need to create the ground weapon holder first, otherwise it won't spawn exactly where we tell it to.
private _groundWeaponHolder = createVehicle ["GroundWeaponHolder", (getPosATL _player), [], 0, "CAN_COLLIDE"];

for "_i" from 0 to ((count _staticComponents) - 1) do
	{
		_groundWeaponHolder addBackpackCargoGlobal [(_staticComponents select _i), 1];
	};

[_groundWeaponHolder] call A3A_fnc_postmortem;

["Steal Static", "Weapon Stolen. It won't despawn when you assemble it again"] call A3A_fnc_customHint;
