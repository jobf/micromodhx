package audio.js;

#if js
import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ScriptProcessorNode;
import micromod.bindings.js.MicromodJs.Micromod;
#end

@:publicFields
class AudioPlayerLegacy implements IAudioPlayer{
	var audioContext:AudioContext;
	var scriptProcessor:ScriptProcessorNode;
	var micromod:Micromod;
	var bufferSize:Int = 0;
	var onaudioprocess: AudioProcessingEvent->Void;
	public var isPlaying:Bool;
	public var samplesProcessed:Int;
	
	
	
	function new():Void {
		audioContext = new AudioContext();
		scriptProcessor = audioContext.createScriptProcessor(0, 0, 2);
		bufferSize = 0;
		samplesProcessed = 0;
		onaudioprocess = (event:AudioProcessingEvent) -> {
			samplesProcessed += event.outputBuffer.length;
			var leftBuf = event.outputBuffer.getChannelData(0);
			var rightBuf = event.outputBuffer.getChannelData(1);
			// to do left buf
			// micromod.getAudio(leftBuf, rightBuf, event.outputBuffer.length);
		}
	}

	public function setAudioSource(source:IMicromodSource) {
		// to do
	}

	function getSamplingRate():Float {
		return audioContext.sampleRate;
	}

	function play():Void {
		samplesProcessed = 0;
		scriptProcessor.onaudioprocess = onaudioprocess;
		scriptProcessor.connect(audioContext.destination);
	}

	function stop():Void {
		if (scriptProcessor.onaudioprocess != null) {
			scriptProcessor.disconnect(audioContext.destination);
			scriptProcessor.onaudioprocess = null;
		}
	}
	
	public function pause() {
 		// to do
	}
	
	public function resume() {
 		// to do
	}
	
	function getBufferSize():Int {
		return bufferSize;
	}

	function getSamplesProcessed():Int {
		return samplesProcessed;
	}
}
