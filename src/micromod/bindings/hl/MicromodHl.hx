package micromod.bindings.hl;

import haxe.io.Float32Array;
import haxe.io.Bytes;
import audio.IMicromodSource;

@:hlNative("micromodHl") extern class C {
	static function get_version():hl.Bytes;

	static function calculate_mod_file_len(module_header:hl.Bytes):Int;

	static function initialise(data:hl.Bytes, sampling_rate:Int):Int;

	static function get_string(instrument:Int, string:hl.Bytes):Void;

	static function calculate_song_duration():Int;

	static function get_audio(output_buffer:hl.Bytes, sample_count:Int):Void;
	
	static function set_position(pos:Int):Void;

	static function seek(sample_pos:Int):Void;
}

class MicromodHl {
	public static function get_version():String {
		var string = C.get_version();
		@:privateAccess
		return String.fromUTF8(string);
	}

	public static function calculate_mod_file_len(header:haxe.io.Bytes):Int {
		return C.calculate_mod_file_len(header);
	}

	public static function initialise(module:haxe.io.Bytes, sampleRate:Int):Int {
		return C.initialise(module, sampleRate);
	}

	public static function get_string(instrument:Int):String {
		var string = haxe.io.Bytes.alloc(23);
		C.get_string(instrument, string);
		@:privateAccess
		return String.fromUTF8(string);
	}

	public static function calculate_song_duration():Int {
		return C.calculate_song_duration();
	}

	static var mix_buffer:haxe.io.Bytes;
	public static function get_audio(output_buffer:haxe.io.Bytes, sample_count:Int) {
		C.get_audio(output_buffer, sample_count);
	}
	public static function set_position(pattern:Int) {
		C.set_position(pattern);
	}

	public static function seek(samplePosition:Int) {
		// trace('hl pos $pos');
		C.seek(samplePosition);
	}

	public static function get_name():String {
		return "todo - get hl name";
	}

	public static function get_source():IMicromodSource {
		return new MicromodSource((interleaved, count) -> get_audio(interleaved, count));
	}
}

class MicromodSource implements IMicromodSource {

	var get_audio:(interleaved:Bytes, count:Int)->Void;

	public function new(audioCallback:(interleaved:Bytes, count:Int)->Void){
		this.get_audio = audioCallback;		
	}

	public function calculateSongDuration():Int {
		return MicromodHl.calculate_song_duration();
	}

	public function getSamplingRate():Float {
		return 48000;
	}

	public function getAudio(interleavedBuf:Bytes, count:Int):Void {
		get_audio(interleavedBuf, count);
	}
}
