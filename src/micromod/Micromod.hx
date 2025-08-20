package micromod;

import haxe.io.Bytes;

#if hl
import micromod.bindings.hl.MicromodHl as MicromodHx;
#end

class Micromod {
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

	public static function initialise(module:Bytes, length:Int) {
		return MicromodHx.initialise(module, length);
	}

	public static function get_string(instrument:Int) {
		return MicromodHx.get_string(instrument);
	}

	public static function calculate_song_duration():Int {
		return MicromodHx.calculate_song_duration();
	}

	public static function get_audio(output_buffer:Bytes, sample_count:Int) {
		MicromodHx.get_audio(output_buffer, sample_count);
	}

	public static function get_version():String {
		return MicromodHx.get_version();
	}
}
