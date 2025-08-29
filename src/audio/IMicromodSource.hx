package audio;

import haxe.io.Float32Array;

interface IMicromodSource {
	function calculateSongDuration():Int;
	function getSamplingRate():Float;
	function getAudio(leftBuf:Float32Array, rightBuf:Float32Array, count:Int):Void;
}

class SineSource implements IMicromodSource {
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

	public function calculateSongDuration():Int {
		return Std.int(sampleRate * 5);
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
