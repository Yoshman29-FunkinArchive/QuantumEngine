#if !macro
import assets.Paths;
import assets.Assets;
import openfl.utils.Assets as OpenFLAssets;

import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Controls;
import backend.plugins.Conductor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import backend.FunkinCamera;

import utils.CoolUtil;

using StringTools;
using assets.Assets.AssetsUtil;
using backend.plugins.Conductor.ConductorUtils;

using utils.CoolUtil.CoolExtension;

import flixel.util.FlxDestroyUtil;
#end