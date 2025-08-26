#if js
import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ScriptProcessorNode;
import micromod.bindings.js.MicromodJs.Micromod;
#end

@:publicFields
class AudioPlayer {
	var audioContext:AudioContext;
	var scriptProcessor:ScriptProcessorNode;
	var micromod:Micromod;
	var bufferSize:Int = 0;
	var buffersProcessed:Int = 0;
	var onaudioprocess: AudioProcessingEvent->Void;

	function new():Void {
		audioContext = new AudioContext();
		scriptProcessor = audioContext.createScriptProcessor(0, 0, 2);
		bufferSize = 0;
		buffersProcessed = 0;
		onaudioprocess = (event:AudioProcessingEvent) -> {
			buffersProcessed += event.outputBuffer.length;
			var leftBuf = event.outputBuffer.getChannelData(0);
			var rightBuf = event.outputBuffer.getChannelData(1);
			micromod.getAudio(leftBuf, rightBuf, event.outputBuffer.length);
		}
	}

	function getSamplingRate():Float {
		return audioContext.sampleRate;
	}

	function play():Void {
		buffersProcessed = 0;
		scriptProcessor.onaudioprocess = onaudioprocess;
		scriptProcessor.connect(audioContext.destination);
	}

	function stop():Void {
		if (scriptProcessor.onaudioprocess != null) {
			scriptProcessor.disconnect(audioContext.destination);
			scriptProcessor.onaudioprocess = null;
		}
	}

	function setAudioSource(micromod:Micromod):Void {
		this.micromod = micromod;
	}

	function getBufferSize():Int {
		return bufferSize;
	}

	function getBuffersProcessed():Int {
		return buffersProcessed;
	}
}
