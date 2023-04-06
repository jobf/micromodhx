import haxe.io.Bytes;
import sys.io.FileInput;
import sys.io.File;
import sys.FileSystem;
import amlib.micromodhx.Micromod;

class Main{
	public static function main():Void{
		var args = Sys.args();
		if(args.length <= 0){
			return;
		}

		var path = args[0];
		if(!FileSystem.exists(path)){
			return;
		}

		var module_bytes = File.getBytes(path);
		var header_bytes = module_bytes.sub(0, 1084);

		var length = read_module_length(header_bytes);
		
		if(length > 0){
			trace('Module Data Length: $length bytes.');
			var module_portable = ammer.ffi.Bytes.fromHaxeCopy(module_bytes);
			var sample_frequency = 48000;
			var oversample = 2;
			var initilize_error = Micromod.initialise(module_portable, sample_frequency * oversample);
			if(initilize_error == 0){
				print_module_info();

				var samples_remaining = Micromod.calculate_song_duration();
				var seconds = samples_remaining / ( sample_frequency * oversample );
				trace('Song duration $seconds seconds');

				// play the module
				trace('playing!');
			}
			else{
				if(initilize_error == -1){
					trace('Data not regonised as module.');
				}
				if(initilize_error == -2){
					trace('Sampling rate is less than 8000hz.');
				}

				trace('Unable to initialise replay.');
			}
		}
	}

	static function read_module_length(header:Bytes):Int{
		var header_portable = ammer.ffi.Bytes.fromHaxeCopy(header);
		var length = Micromod.calculate_mod_file_len(header_portable);
		return length;
	}

	static function print_module_info():Void{
		var string_portable = ammer.ffi.Bytes.zalloc(23);
		for(inst in 0...16){

			Micromod.get_string(inst, string_portable);
			var string = string_portable.toHaxeCopy(23);
			trace(string);

			Micromod.get_string(inst + 16, string_portable);
			var string = string_portable.toHaxeCopy(23);
			trace(string);
			
		}
	}
}