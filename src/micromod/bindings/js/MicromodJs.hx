package micromod.bindings.js;

import audio.IMicromodSource;
// import js.lib.Float32Array;
import haxe.io.Float32Array;

@:native("Module") extern class Module {
	function new(data:js.lib.Int8Array):Void;
	var songName(default, null):String;
	var instruments(default, null):Array<Instrument>;
}

@:native("Instrument") extern class Instrument
{
	var instrumentName(default, null):String;
}



@:native("Micromod") extern class Micromod implements IMicromodSource {
	function new(module:Module, sampleRate:Int):Void;
	function getVersion():String;
	function getSamplingRate():Float;
	function setInterpolation(isEnabled:Bool):Void;
	function getRow():Int;
	function getSequencePos():Int;
	function calculateSongDuration():Int;
	function setPosition(pattern:Int):Int;
	function seek(samplePos:Int):Int;
	function getAudio(leftBuf:Float32Array, rightBuf:Float32Array, count:Int):Void;
}

@:publicFields
class MicromodJs {
	private static var micromod:Micromod;
	private static var module:Module;
	
	static function calculate_mod_file_len(header:haxe.io.Bytes):Int {
		// to do 
		return 0;
	}

	static function initialise(data:js.lib.Int8Array, sampling_rate:Int) {
		// trace(data);
		module = new Module(data);
		micromod = new Micromod(module, sampling_rate);
	}

	static function get_string(instrument:Int):String {
		return module.instruments[instrument]?.instrumentName;
	}

	static function calculate_song_duration():Int {
		return micromod.calculateSongDuration();
	}

	static function get_audio(output_buffer:haxe.io.Bytes, sample_count:Int) {
		// to do
	}

	static function get_version():String {
		return micromod.getVersion();
	}
	
	static function set_position(pattern:Int) {
		micromod.setPosition(pattern);
	}

	static function seek(samplePosition:Int) {
		micromod.seek(samplePosition);
	}

	static function get_name():String{
		return module.songName;
	}

	static function get_source():IMicromodSource{
		return micromod;
	}
}
