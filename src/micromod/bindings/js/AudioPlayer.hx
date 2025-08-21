package micromod.bindings.js;

@:native("AudioPlayer") extern class AudioPlayer
{
	function new():Void;
	function getSamplingRate():Int;
	function play():Void;
	function stop():Void;
	function setAudioSource(micromod:micromod.bindings.js.MicromodJs.Micromod):Void;
}