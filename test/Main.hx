import sys.FileSystem;
import haxe.io.Bytes;
import micromod.Micromod;

function main() {
	
	trace(Micromod.get_version());

	var args = Sys.args();
	if(args.length <= 0){
		throw "Need a file path as first argument!";
	}

	var path = args[0];
	if(!FileSystem.exists(path)){
		throw "File does not exist! " + path;
	}
	
	var sampling_frequency = 48000;
	var oversample = 2;
	var num_channels = 2;
	
	var length = Micromod.read_module_length(path);
	trace('Module data length $length');

	if (length > 0) {
		var oversampling_freq = sampling_frequency * oversample;
		var module:Bytes = Micromod.read_module(path, length);
		var result = Micromod.initialise(module, oversampling_freq);
		if (result == 0) {
			print_module_info();

			var samples_remaining:Int = Micromod.calculate_song_duration();
			var song_duration = samples_remaining / oversampling_freq;
			trace('song_duration $song_duration');
			trace('over_sampling_freq $oversampling_freq');
			trace('samples_remaining $samples_remaining');

			var count = samples_remaining;
			var mix_buffer_size = count * num_channels * 2;
			var mix_buffer = Bytes.alloc(mix_buffer_size);
			Micromod.get_audio(mix_buffer, count);

			trace('Mix buffer size $mix_buffer_size');
			var bits_per_sample = 16;
			var wav_file = WavFile.from_bytes(mix_buffer, oversampling_freq, num_channels, bits_per_sample);
			WavFile.write_to_disk(wav_file, "test.wav");
		}
	}
}

function print_module_info():Void {
	for (i in 0...16) {
		var instrument = i;
		var label = StringTools.lpad('$instrument', "0", 2);
		var a = '$label: ' + Micromod.get_string(instrument);

		instrument += 16;
		var label = StringTools.lpad('$instrument', "0", 2);
		var b = '$label: ' + Micromod.get_string(instrument);

		trace('$a $b');
	}
}
