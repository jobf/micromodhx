package audio;

import haxe.io.Float32Array;
import haxe.io.Bytes;

interface IMicromodSource {
	function calculateSongDuration():Int;
	function getSamplingRate():Float;
	
	#if js
	function getAudio(leftBuf:Float32Array, rightBuf:Float32Array, count:Int):Void;
	#end

	#if sys
	function getAudio(interleavedBuf:Bytes, count:Int):Void;
	#end
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

	#if sys


	var phase:Int = 0;
	var PI2 = 2.0 * Math.PI;

	inline function sine(frequencyHz:Float, position:Float, sampleRate:Float):Float {
		return Math.sin(PI2 * position * frequencyHz / sampleRate);
	}

	var n:Int = 0;
	var sample:Int = 0;
	var freq:Float = 220.0;


	public function getAudio(block:Bytes, numSamples:Int):Void {
		n = 0;
		for (i in 0...numSamples) {
			var leftSample = Std.int(32767.0 * sine(leftFreq, phase, sampleRate));
			block.set(n++, leftSample & 0xFF);
			block.set(n++, leftSample >> 8);

			var rightSample = Std.int(32767.0 * sine(rightFreq, phase++, sampleRate));
			block.set(n++, rightSample & 0xFF);
			block.set(n++, rightSample >> 8);
		}
	}
	#end

	#if js
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
	#end
}
