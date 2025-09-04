package audio.js;

import haxe.io.Float32Array;
import audio.IMicromodSource;
import audio.IAudioPlayer;

#if js
import audio.js.AudioWorkletContext;
import js.html.Blob;
import js.html.URL;
#end

@:publicFields
class AudioPlayer implements IAudioPlayer {
	var micromod:IMicromodSource;
	
	var audioContext:AudioWorkletContext;
	var node:AudioWorkletNode;

	var bufferSize:Int = 1024;
	var totalSamples:Int = 0;
	var samplesProcessed:Int = 0;
	var phase:Float = 0;
	var isInitialized:Bool = false;
	var isPlaying:Bool = false;

	function new():Void {
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
		trace('audio-stream-processor initialized');
	}

	function generateAndSendBuffer() {
		samplesProcessed += bufferSize;
		var buffL = new Float32Array(bufferSize);
		var buffR = new Float32Array(bufferSize);
		micromod.getAudio(buffL, buffR, bufferSize);
		streamAudioData(buffL, buffR);
		if(samplesProcessed >= totalSamples)
		{
			samplesProcessed = 0;
		}
	}

	function streamAudioData(buffL:Float32Array, buffR:Float32Array) {
		if (audioContext.state == SUSPENDED) {
			trace('to do .. Resuming suspended audio context...');
			audioContext.resume();
		}

		node.port.postMessage({
			type: 'audioData',
			leftBuffer: buffL,
			rightBuffer: buffR,
		});
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
		samplesProcessed = 0;
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

	function setAudioSource(micromod:IMicromodSource):Void {
		this.micromod = micromod;
		totalSamples = micromod.calculateSongDuration();
		isInitialized = true;
	}

	function getBufferSize():Int {
		return bufferSize;
	}

	function getSamplesProcessed():Int {
		return samplesProcessed;
	}
}
