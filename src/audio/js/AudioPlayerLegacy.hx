package audio.js;

#if js
import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ScriptProcessorNode;
import micromod.bindings.js.MicromodJs.Micromod;
#end

@:publicFields
class AudioPlayerLegacy implements IAudioPlayer {
	var audioContext:AudioContext;
	var scriptProcessor:ScriptProcessorNode;
	var micromod:Micromod;
	var onaudioprocess:AudioProcessingEvent->Void;
	
	var bufferSize:Int = 0;
	public var isPlaying:Bool = false;
	public var samplesProcessed:Int = 0;

	function new():Void {
		audioContext = new AudioContext();
		scriptProcessor = audioContext.createScriptProcessor(0, 0, 2);
	}

	public function setAudioSource(source:IMicromodSource) {
		onaudioprocess = (event:AudioProcessingEvent) -> {
			if (isPlaying) {
				samplesProcessed += event.outputBuffer.length;
				var leftBuf:haxe.io.Float32Array = cast event.outputBuffer.getChannelData(0);
				var rightBuf:haxe.io.Float32Array = cast event.outputBuffer.getChannelData(1);
				source.getAudio(leftBuf, rightBuf, event.outputBuffer.length);
			} else {
				// Fill with silence when stopped
				var leftBuf:haxe.io.Float32Array = cast event.outputBuffer.getChannelData(0);
				var rightBuf:haxe.io.Float32Array = cast event.outputBuffer.getChannelData(1);
				for (i in 0...leftBuf.length) {
					leftBuf[i] = 0;
					rightBuf[i] = 0;
				}
			}
		}
	}

	function getSamplingRate():Float {
		return audioContext.sampleRate;
	}

	function play():Void {
		isPlaying = true;
		samplesProcessed = 0;
		scriptProcessor.onaudioprocess = onaudioprocess;
		scriptProcessor.connect(audioContext.destination);
	}

	function stop():Void {
		isPlaying = false;
		if (scriptProcessor.onaudioprocess != null) {
			scriptProcessor.disconnect(audioContext.destination);
			scriptProcessor.onaudioprocess = null;
		}
	}

	public function pause() {
		isPlaying = false;
	}

	public function resume() {
		isPlaying = true;
	}

	function getBufferSize():Int {
		return bufferSize;
	}

	function getSamplesProcessed():Int {
		return samplesProcessed;
	}
}
