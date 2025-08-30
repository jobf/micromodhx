package audio.lime;

import lime.media.openal.ALC;
import lime.media.openal.AL;

class AudioPlayer implements IAudioPlayer {
	public var isPlaying:Bool = false;
	public var samplesProcessed:Int = 0;

	var sampleRate:Int;

	public function new() {
		sampleRate = 48000;
	}

	public function getSamplingRate():Float {
		return sampleRate;
	}

	public function getSamplesProcessed():Int {
		return 0;
	}

	public function setAudioSource(source:IMicromodSource) {}

	public function play() {}

	public function stop() {}

	public function pause() {}

	public function resume() {}
}
