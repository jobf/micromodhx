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

#if cpp
import micromod.bindings.hxcpp.MicromodHxcpp as MicromodHx;
typedef ModuleFormat = haxe.io.Bytes;
#end

class Micromod {
	public static var isInitialised:Bool = false;
	
	#if sys
	static function read_file(path:String, to:Bytes, length:Int):Int {
		var count = -1;
		#if sys
		var file = sys.io.File.read(path);
		var pos = 0;
		count = file.readBytes(to, pos, length);
		file.close();
		#end

		return count;
	}

	static var header_size:Int = 1084;

	public static function read_module_length(path:String):Int {
		var header:Bytes = Bytes.alloc(header_size);
		var length = read_file(path, header, header_size);
		if (length == header_size){
			length = MicromodHx.calculate_mod_file_len(header);
			if( length < 0){
				trace("Module file type not recognised");
			}
		}
		else{
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

	// public static function get_audio(output_buffer:Bytes, sample_count:Int) {
	// 	MicromodHx.get_audio(output_buffer, sample_count);
	// }
	#end

	public static function get_audio(player:IAudioPlayer){
		player.setAudioSource(MicromodHx.get_source());
	}

	#if js
	// public static function get_audio(player:IAudioPlayer){
	// 	@:privateAccess
	// 	player.setAudioSource(MicromodHx.micromod);
	// }
	#end

	public static function initialise(module_data:ModuleFormat, sample_rate:Int):String {
		var errorMessage = "";

		try {
			MicromodHx.initialise(module_data, sample_rate);
			isInitialised = true;
		}
		catch(e) {
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

	public static function set_position(pos:Int) {
		MicromodHx.set_position(pos);
	}

	public static function get_name():String {
		return MicromodHx.get_name();
	}
}
