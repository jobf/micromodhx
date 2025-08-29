package audio.lime;

class AudioPlayer implements IAudioPlayer{
	public var isPlaying:Bool = false;
	public var samplesProcessed:Int;
	public function new(){}

	public function getSamplingRate():Float {
		return 0;
	}

	public function getSamplesProcessed():Int {
		return 0;
	}
	public function setAudioSource(source:IMicromodSource){
		
	}

	public function play() {
		
	}
	
	public function stop() {
		
	}

	public function pause() {
	}

	public function resume() {
	}
}