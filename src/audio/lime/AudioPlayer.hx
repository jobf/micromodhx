package audio.lime;

import micromod.bindings.hl.MicromodHl;
import lime.utils.UInt8Array;
import lime.media.openal.ALC;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import haxe.io.Float32Array;
import lime.utils.Int16Array;
import haxe.io.Bytes;
import haxe.Timer;

@:publicFields
class AudioPlayer implements IAudioPlayer {
	var micromod:IMicromodSource;
	var buffer:ALBuffer;
	var buffers:Array<ALBuffer>;
	var source:ALSource;
	var timer:haxe.Timer;
	var blockCount:Int = 2;
	var buffersProcessed:Int = 0;

	var sampleRate:Float;
	var numChannels = 2;

	var bufferSize:Int;
	var bufferCount:Int;
	var totalSamples:Int = 0;
	var samplesProcessed:Int = 0;
	var phase:Float = 0;
	var isInitialized:Bool = false;
	var isPlaying:Bool = false;
	var interleaved:Bytes;
	var sampleBuffer:Bytes;
	
	public function new(sampleRate:Float = 48000) {
		bufferCount = 2;
		buffers = AL.genBuffers(bufferCount);

		// source will play the buffered audio
		source = AL.createSource();

		this.sampleRate = sampleRate;
		var bufferSampleCount = 4096;
		bufferSize = bufferSampleCount * numChannels * 2;
		sampleBuffer = Bytes.alloc(bufferSize);
		sampleBuffer.fill(0, bufferSize, 0);

		var time = 1000 / 144; // the fastest it needs to go? e.g. if we want to drive it from a 144hz vsynced update loop)
		timer = new Timer(time);

		// trace('time $time');

		for (buffer in buffers) {
			AL.bufferData(buffer, AL.FORMAT_STEREO16, Int16Array.fromBytes(sampleBuffer), bufferSize, Std.int(sampleRate));
			AL.sourceQueueBuffer(source, buffer);
			sampleBuffer.fill(0, bufferSize, 0);
		}

		timer.run = () -> {
			var num_buffers_finished:Int = AL.getSourcei(source, AL.BUFFERS_PROCESSED);
			buffersProcessed += num_buffers_finished;

			if (num_buffers_finished > 0) {
				// iterate the buffers that need to be refilled
				var finished_buffers = AL.sourceUnqueueBuffers(source, num_buffers_finished);
				for (buffer in finished_buffers) {
					if(isInitialized){
						MicromodHl.get_audio(sampleBuffer, bufferSampleCount);
					}
					AL.bufferData(buffer, AL.FORMAT_STEREO16, Int16Array.fromBytes(sampleBuffer), bufferSize, Std.int(sampleRate));
					AL.sourceQueueBuffer(source, buffer);
					sampleBuffer.fill(0, bufferSize, 0);
					samplesProcessed += bufferSampleCount;
				}
			}
		}

	}

	public function getSamplingRate():Float {
		return sampleRate;
	}

	public function getSamplesProcessed():Int {
		return samplesProcessed;
	}

	public function setAudioSource(source:IMicromodSource) {
		micromod = source;
		totalSamples = micromod.calculateSongDuration();
		isInitialized = true;
	}

	// for debugging :sweat:
	// public function write(interleaved:Bytes, name:String) {
	// 	var bits_per_sample = 16;
	// 	var numchannels = 2;
	// 	var wav_file = WavFile.from_bytes(interleaved, Std.int(sampleRate), numchannels, bits_per_sample);
	// 	WavFile.write_to_disk(wav_file, name + ".wav");
	// }

	public function play() {
		AL.sourcePlay(source);
		isPlaying = true;
	}

	public function stop() {
		AL.sourceStop(source);
		
		samplesProcessed = 0;
		isPlaying = false;
	}

	public function pause() {
		if (!isPlaying) return;
        
		isPlaying = false;
		AL.sourcePause(source);
	}

	public function resume() {
		if(isPlaying) return;

		AL.sourcePlay(source);
		isPlaying = true;
	}
}
