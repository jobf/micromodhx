package micromod;

import haxe.io.Bytes;
import audio.IAudioPlayer;

#if hl
import micromod.bindings.hl.MicromodHl as MicromodHx;
typedef ModuleFormat = haxe.io.Bytes;
#end

#if js
import audio.js.AudioPlayer;
import micromod.bindings.js.MicromodJs as MicromodHx;
typedef ModuleFormat = js.lib.Int8Array;
#end

class Micromod {
	public static var isInitialised:Bool = false;

	#if sys
	static function read_file(path:String, to:Bytes, length:Int):Int {
		var count = -1;
		var file = sys.io.File.read(path);
		var pos = 0;
		count = file.readBytes(to, pos, length);
		file.close();
		return count;
	}

	static var header_size:Int = 1084;

	public static function read_module_length(path:String):Int {
		var header:Bytes = Bytes.alloc(header_size);
		var length = read_file(path, header, header_size);
		if (length == header_size) {
			length = MicromodHx.calculate_mod_file_len(header);
			if (length < 0) {
				trace("Module file type not recognised");
			}
		} else {
			trace("Unable to read module file");
			length = -1;
		}
		return length;
	}

	public static function read_module(path:String, length:Int):Bytes {
		var module:Bytes = Bytes.alloc(length);
		var len = read_file(path, module, length);
		return module;
	}
	#end

	public static function initialise(module_data:ModuleFormat, sample_rate:Int):String {
		if (sample_rate <= 0) {
			return 'Invalid sample rate $sample_rate. Cannot continue.';
		}

		var errorMessage = "";

		try {
			MicromodHx.initialise(module_data, sample_rate);
			isInitialised = true;
		} catch (e) {
			isInitialised = false;
			errorMessage = e.message;
		}

		return errorMessage;
	}

	public static function get_string(instrument:Int) {
		return MicromodHx.get_string(instrument);
	}

	public static function calculate_song_duration():Int {
		return MicromodHx.calculate_song_duration();
	}

	public static function get_version():String {
		return MicromodHx.get_version();
	}

	public static function set_position(pattern:Int) {
		MicromodHx.set_position(pattern);
	}

	public static function seek(samplePosition:Int) {
		MicromodHx.seek(samplePosition);
	}

	public static function get_name():String {
		return MicromodHx.get_name();
	}

	public static function get_source() {
		return MicromodHx.get_source();
	}

	public static function get_audio(interleaved:Bytes, count:Int) {
		MicromodHx.get_audio(interleaved, count);
	}
}
