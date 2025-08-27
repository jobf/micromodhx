import haxe.Timer;
import js.html.audio.AudioWorkletGlobalScope;
import js.html.audio.AudioDestinationNode;
#if js
import js.html.audio.AudioContext;
import js.html.audio.AudioContextState;
import js.html.audio.AudioWorkletNodeOptions; // .AudioWorkletNode;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.AudioWorkletProcessor;
import js.html.Blob;
import js.html.URL;
import js.lib.Float32Array;
import micromod.bindings.js.MicromodJs.Micromod;
import micromod.bindings.js.MicromodJs.AudioSource;
#end

@:publicFields
class AudioWorkletPlayer {
	var audioContext:AudioContext;
	var node:AudioWorkletNode;
	var micromod:AudioSource;
	var bufferSize:Int = 0;
	var buffersProcessed:Int = 0;
	var feeder:Timer;
	var isInitialized:Bool = false;
	var phase:Float = 0;
	var isPlaying:Bool = false;

	function new():Void {
		bufferSize = 1024;
		buffersProcessed = 0;
		audioContext = new AudioContext();

		// load the processor vias a blob url
		var blob = new Blob([Processor.code], {type: "application/javascript"});
		var url = URL.createObjectURL(blob);
		audioContext.audioWorklet.addModule(url);

		// practice good blob url hygiene ??
		// URL.revokeObjectURL(url);

		// delay the next part because the worklet will fail when audio-stream-processor is not finished loading
		Timer.delay(() -> {
			// create the AudioWorkletNode
			node = new AudioWorkletNode(audioContext, 'audio-stream-processor', {
				// numberOfInputs: numberOfInputs,
				numberOfOutputs: 1,
				outputChannelCount: [2],
				// parameterData: parameterData,
				// processorOptions: processorOptions,
				// channelCount: channelCount,
				// channelCountMode: channelCountMode,
				// channelInterpretation: channelInterpretation
			});

			// listen for messages from the processor (to tell us it's hungry)
			node.port.onmessage = event -> {
				if (event.data.type == 'needMoreData') {
					// Generate and send more data immediately
					if (isPlaying) {
						generateAndSendBuffer();
					}
				} else if (event.data.type == 'bufferStatus') {
					trace('Buffer queue: ${event.data.queueLength}, Samples: ${event.data.samplesProcessed}, Silent: ${event.data.silentSamples}');
				}
			}

			// connect to output
			node.connect(this.audioContext.destination);

			isInitialized = true;
			trace('AudioWorklet stream player initialized (inline processor)');
			// trace('Connected to destination, gain: ${this.gainNode.gain.value}');
		}, 2000);
	}

	function generateAndSendBuffer() {
		if (!isInitialized || node == null) {
			return;
		}
		var buffL = new Float32Array(bufferSize);
		var buffR = new Float32Array(bufferSize);
		micromod.getAudio(buffL, buffR, bufferSize);
		// generateTestBuffer(buffL, buffR, bufferSize);

		streamAudioData(buffL, buffR);
	}

	function streamAudioData(buffL:Float32Array, buffR:Float32Array) {
		if (audioContext.state == SUSPENDED) {
			trace('to do .. Resuming suspended audio context...');
			//   audioContext.resume().then(() => {
			// 	 trace('Audio context resumed, state: ${this.audioContext.state}');
			//   });
		}

		node.port.postMessage({
			type: 'audioData',
			leftBuffer: buffL,
			rightBuffer: buffR,
		});
	}

	function generateTestBuffer(buffL:Float32Array, buffR:Float32Array, length:Int = 1024) {
		
		var frequency = 220; // A4 note
		var sampleRate = audioContext.sampleRate;

		// Keep track of phase to maintain continuity between buffers

		for (i in 0...length) {
			var leftSample = Math.sin(phase) * 0.3; // Left channel
			var rightSample = Math.sin(phase * 1.5) * 0.3; // Right channel (slightly different frequency)

			buffL[i] = leftSample; // Left channel
			buffR[i] = rightSample; // Right channel

			// buffer[i * 2] = leftSample; // Left channel
			// buffer[i * 2 + 1] = rightSample; // Right channel

			phase += 2 * Math.PI * frequency / sampleRate;

			// Keep phase in reasonable range
			if (phase > 2 * Math.PI * 1000) {
				phase -= 2 * Math.PI * 1000;
			}
		}

		// Mark this buffer as stereo  errrrm weird dude
		// buffer.channels = 2;
		// buffer.samplesPerChannel = length;

		// Debug: Log some sample values occasionally
		// if (Math.random() < 0.01) {
		// 	trace('Generated ${length} stereo samples (${buffer.length} total)');
		// 	trace('First few L/R pairs:', [[buffer[0], buffer[1]], [buffer[2], buffer[3]], [buffer[4], buffer[5]]]);
		// }

		// return buffer;
	}

	public function startTestWorklet() {
		// throw new haxe.exceptions.NotImplementedException();
	}

	function getSamplingRate():Float {
		return audioContext.sampleRate;
	}

	/* begin playback, starts requesting audio data */
	function play():Void {
		if (!isInitialized) {
			trace('AudioWorklet not initialized');
			return;
		 }
	
		 if (audioContext.state == SUSPENDED) {
			audioContext.resume();//.then(() => {
			//   console.log(`Audio context resumed for start`);
			// });
		 }
	
		 isPlaying = true;
		 node.port.postMessage({ type: 'start' });
		 trace('Audio playback started');
	}

	/* stop playback completely, clears all buffers */
	function stop():Void {
		if (!isInitialized) {
			return;
		 }
	
		 isPlaying = false;
		 node.port.postMessage({ type: 'stop' });
		 trace('Audio playback stopped');
	}
	
	/* pause playback, keeps buffers for seamless resume */
	function pause(){
		if (!isInitialized) {
			return;
		 }
	
		 isPlaying = false;
		 node.port.postMessage({ type: 'pause' });
		 trace('Audio playback paused');
	}
	
	/* resume from pause */
	function resume(){
		if (!isInitialized) {
			return;
		 }
	
		 if (audioContext.state == SUSPENDED) {
			audioContext.resume();
			// .then(() => {
			//   console.log(`Audio context resumed`);
			// });
		 }
	
		 isPlaying = true;
		 node.port.postMessage({ type: 'resume' });
		 trace('Audio playback resumed');
	}

	function setAudioSource(micromod:AudioSource):Void {
		this.micromod = micromod;
		// this.micromod = new SineSource(getSamplingRate());
	}

	function getBufferSize():Int {
		return bufferSize;
	}

	function getBuffersProcessed():Int {
		return buffersProcessed;
	}

	function testSimpleAudio() {
		var ctx = new AudioContext();
		var osc = ctx.createOscillator();
		var gain = ctx.createGain();

		osc.connect(gain);
		gain.connect(ctx.destination);
		gain.gain.value = 0.1; // Low volume
		osc.frequency.value = 440;

		osc.start();
		Timer.delay(() -> osc.stop(), 1000);
	}
}

class SineSource implements AudioSource {
	var rate:Int;
	var freq:Float;
	var phase:Float;
	var sampleIndex:Int = 0;

	public function new(samplingRate:Int) {
		rate = samplingRate;
		freq = 440;
		phase = 0;
		trace('SineSource created: $rate, freqHz: $freq');
	}

	public function getSamplingRate():Int {
		return rate;
	}

	public function getAudio(leftBuf:Float32Array, rightBuf:Float32Array, count:Int):Void {
		for (i in 0...count) {
			phase = (sampleIndex * 2 * Math.PI * freq) / rate;

			var leftSample = Math.sin(phase) * 0.3;
			var rightSample = Math.sin(phase * 0.5) * 0.3; // Different freq for right because yolo

			leftBuf[i] = leftSample;
			rightBuf[i] = rightSample;

			sampleIndex++;
		}
	}
}
