import haxe.io.Bytes;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import lime.media.openal.AL;

@:publicFields
class AudioPlayer {
	var source:ALSource;
	var buffers:Array<ALBuffer>;
	var isPlaying:Bool;
	var shouldStop:Bool;

	function new() {
		var numBuffers = 2;
		buffers = AL.genBuffers(numBuffers);

		source = AL.createSource();
	}

	function setDataRequestCallback(cb:() -> Void) {}

	function setStatusCallback(cb:() -> Void) {}

	function addAudioData(sampleData:Bytes) {}

	function start() {
		if (isPlaying) {
			return;
		}

		isPlaying = true;
		shouldStop = false;

		// Start processing thread
		//   timer =
	}

	function stop() {	}

	function pause() { }

	function resume() { }
}
