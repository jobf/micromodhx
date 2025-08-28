package audio.js;

import haxe.Timer;
import js.html.audio.AudioWorkletGlobalScope;
import js.html.audio.AudioDestinationNode;
#if js
import audio.js.AudioWorkletContext;
import js.html.audio.AudioContextState;
import js.html.audio.AudioWorkletNodeOptions; // .AudioWorkletNode;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.AudioWorkletProcessor;
import js.html.Blob;
import js.html.URL;
import js.lib.Float32Array;
import micromod.bindings.js.MicromodJs.Micromod;
import micromod.bindings.js.MicromodJs.MicromodSource;
#end

@:publicFields
class AudioPlayer {
	var audioContext:AudioWorkletContext;
	var node:AudioWorkletNode;
	var micromod:MicromodSource;
	var bufferSize:Int = 0;
	var samplesProcessed:Int = 0;
	var feeder:Timer;
	var isInitialized:Bool = false;
	var phase:Float = 0;
	var isPlaying:Bool = false;

	function new():Void {
		bufferSize = 1024;
		audioContext = new AudioWorkletContext();

		var blob = new Blob([Processor.code], {type: "application/javascript"});
		var url = URL.createObjectURL(blob);
		audioContext.audioWorklet.addModule(url);
	}

	function initAudioWorkletNode() {
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

		// practice good blob url hygiene ??
		// URL.revokeObjectURL(url);

		// listen for messages from the processor (to tell us it's hungry)
		node.port.onmessage = event -> {
			if (event.data.type == 'dataRequest') {
				// Generate and send more data immediately
				if (isPlaying) {
					generateAndSendBuffer();
				}
			} else if (event.data.type == 'bufferStatus') {
				// debug
				// trace('Buffer queue: ${event.data.queueLength}, Samples: ${event.data.samplesProcessed}, Silent: ${event.data.silentSamples}');
			}
		}

		// connect to output
		node.connect(this.audioContext.destination);

		isInitialized = true;
		trace('AudioWorklet stream player initialized (inline processor)');
	}

	function generateAndSendBuffer() {
		samplesProcessed += bufferSize;
		var buffL = new Float32Array(bufferSize);
		var buffR = new Float32Array(bufferSize);
		micromod.getAudio(buffL, buffR, bufferSize);
		streamAudioData(buffL, buffR);
	}

	function streamAudioData(buffL:Float32Array, buffR:Float32Array) {
		if (audioContext.state == SUSPENDED) {
			trace('to do .. Resuming suspended audio context...');
			audioContext.resume();
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
	}

	function getSamplingRate():Float {
		return audioContext.sampleRate;
	}

	/* begin playback, starts requesting audio data */
	function play():Void {
		if (node == null) {
			initAudioWorkletNode();
		}

		if (!isInitialized) {
			trace('AudioWorklet not initialized');
			return;
		}

		if (audioContext.state == SUSPENDED) {
			audioContext.resume();
		}

		isPlaying = true;
		node.port.postMessage({type: 'start'});
		trace('Audio playback started');
	}

	/* stop playback completely, clears all buffers */
	function stop():Void {
		if (node == null) {
			return;
		}

		isPlaying = false;
		node.port.postMessage({type: 'stop'});
		trace('Audio playback stopped');
	}

	/* pause playback, keeps buffers for seamless resume */
	function pause() {
		if (node == null) {
			return;
		}

		isPlaying = false;
		node.port.postMessage({type: 'pause'});
		trace('Audio playback paused');
	}

	/* resume from pause */
	function resume() {
		if (node == null) {
			return;
		}

		if (audioContext.state == SUSPENDED) {
			audioContext.resume();
		}

		isPlaying = true;
		node.port.postMessage({type: 'resume'});
		trace('Audio playback resumed');
	}

	function setAudioSource(micromod:MicromodSource):Void {
		this.micromod = micromod;
		isInitialized = true;
	}

	function getBufferSize():Int {
		return bufferSize;
	}

	function getSamplesProcessed():Int {
		return samplesProcessed;
	}

	function testSimpleAudio() {
		var ctx = new AudioWorkletContext();
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

class SineSource implements MicromodSource {
	var sampleRate:Float;
	var leftFreq:Float = 440;
	var rightFreq:Float = 220;
	var amplitude = 1.0;
	var leftPhase:Float = 0;
	var rightPhase:Float = 0;
	var sampleIndex:Int = 0;

	public function new(samplingRate:Float) {
		sampleRate = samplingRate;
	}

	public function getSamplingRate():Float {
		return sampleRate;
	}

	public function getAudio(leftBuf:Float32Array, rightBuf:Float32Array, numSamples:Int):Void {
		var leftPhaseIncrement = (2 * Math.PI * leftFreq) / this.sampleRate;
		var rightPhaseIncrement = (2 * Math.PI * rightFreq) / this.sampleRate;

		for (i in 0...numSamples) {
			leftBuf[i] = Math.sin(this.leftPhase) * amplitude;
			rightBuf[i] = Math.sin(this.rightPhase) * amplitude;

			this.leftPhase += leftPhaseIncrement;
			this.rightPhase += rightPhaseIncrement;

			if (this.leftPhase > 2 * Math.PI)
				this.leftPhase -= 2 * Math.PI;
			if (this.rightPhase > 2 * Math.PI)
				this.rightPhase -= 2 * Math.PI;
		}
	}
}
