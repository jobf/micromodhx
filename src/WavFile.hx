import haxe.io.Bytes;
import format.wav.Data.WAVE;

function from_bytes(data:Bytes, samplingRate:Int, num_channels:Int, bitsPerSample:Int):WAVE {
	return {
		header: {
			format: WF_PCM,
			channels: num_channels,
			samplingRate: samplingRate,
			byteRate: Std.int(samplingRate * num_channels * bitsPerSample / 8),
			blockAlign: Std.int(num_channels * bitsPerSample / 8),
			bitsPerSample: bitsPerSample
		},
		data: data,
		cuePoints: []
	};
}

#if sys
function write_to_disk(wave:WAVE, path:String) {
	var file = sys.io.File.write(path);
	var w = new format.wav.Writer(file);
	w.write(wave);
	file.close();
}
#end