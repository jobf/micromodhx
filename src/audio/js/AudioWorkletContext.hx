package audio.js;

import js.html.audio.AudioContext;
import js.html.audio.AudioContextOptions;
import js.html.audio.AudioNode;
import js.html.audio.AudioWorkletNodeOptions;
import js.html.MessagePort;

/**
 * AudioWorkletNode does not exist on AudioContext latest haxe so we add it here
 */
@:native("AudioContext")
extern class AudioWorkletContext extends AudioContext {
	function new( ?contextOptions : AudioContextOptions ) : Void;
	public var audioWorklet:AudioWorkletNode;
}

@:native("AudioWorkletNode")
extern class AudioWorkletNode extends AudioNode {
	function new(context:AudioContext, name:String, options:AudioWorkletNodeOptions):Void;
	var port:MessagePort;
	function addModule(url:String):Void;
}
