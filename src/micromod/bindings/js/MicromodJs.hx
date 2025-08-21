package micromod.bindings.js;

import js.lib.Float32Array;

@:native("Module") extern class Module {
	function new(data:js.lib.Int8Array):Void;
	var songName(default, null):String;
	var instruments(default, null):Array<Instrument>;
}

@:native("Instrument") extern class Instrument
{
	var instrumentName(default, null):String;
}

@:native("Micromod") extern class Micromod {
	function new(module:Module, sampleRate:Int):Void;
	function getVersion():String;
	function getSamplingRate():Int;
	function setInterpolation(isEnabled:Bool):Void;
	function getRow():Int;
	function getSequencePos():Int;
	function setSequencePos(pos:Int):Void;
	function calculateSongDuration():Int;
	function seek(samplePos:Int):Int;
	function getAudio(leftBuf:Float32Array, rightBuf:Float32Array, count:Int):Void;
}

class MicromodJs {
	static var micromod:Micromod;
	static var module:Module;
	
	public static function calculate_mod_file_len(header:haxe.io.Bytes):Int {
		// to do 
		return 0;
	}

	public static function initialise(data:js.lib.Int8Array, sampling_rate:Int) {
		module = new Module(data);
		micromod = new Micromod(module, sampling_rate);
	}

	public static function get_string(instrument:Int):String {
		return module.instruments[instrument].instrumentName;
	}

	public static function calculate_song_duration():Int {
		return micromod.calculateSongDuration();
	}

	public static function get_audio(output_buffer:haxe.io.Bytes, sample_count:Int) {
		// to do
	}

	public static function get_version():String {
		return micromod.getVersion();
	}
}
