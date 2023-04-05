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

		var length = read_module_length(path);
		trace(length);
	}

	static function read_module_length(filename:String):Int{
		var file = File.read(filename);
		var header = file.read(1084);
		var bytes = ammer.ffi.Bytes.fromHaxeCopy(header);
		var length = Micromod.calculate_mod_file_len(bytes);
		return length;
	}
}