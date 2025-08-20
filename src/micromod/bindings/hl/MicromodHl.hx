package micromod.bindings.hl;

@:hlNative("micromodHl") extern class C {
	static function get_version():hl.Bytes;

	static function calculate_mod_file_len(module_header:hl.Bytes):Int;

	static function initialise(data:hl.Bytes, sampling_rate:Int):Int;

	static function get_string(instrument:Int, string:hl.Bytes):Void;

	static function calculate_song_duration():Int;

	static function get_audio(output_buffer:hl.Bytes, sample_count:Int):Void;
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

	public static function initialise(module:haxe.io.Bytes, length:Int):Int {
		return C.initialise(module, length);
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

	public static function get_audio(output_buffer:haxe.io.Bytes, sample_count:Int) {
		C.get_audio(output_buffer, sample_count);
	}
}
