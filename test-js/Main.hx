import audio.js.AudioPlayer;
import js.Browser;
import js.html.XMLHttpRequest;
import js.lib.Int8Array;
import micromod.Micromod;

// import TestPlayer to bundle it with main.js
import TestPlayer;

function main() {

	var player = new AudioPlayer();

	var request = new XMLHttpRequest();
	var url = "test.mod";
	request.open("GET", url, true);
	request.responseType = ARRAYBUFFER;
	request.onloadend = event -> {
		
		var data = new Int8Array(request.response);
		var samplerate = Std.int(player.getSamplingRate());

		Micromod.initialise(data, samplerate);
		
		print_module_info();

		Browser.window.addEventListener("click", event -> {
			// Micromod.get_audio(player);
		});
	}

	request.send();
}

function print_module_info():Void {
	var samples_remaining = Micromod.calculate_song_duration();
	trace('samples_remaining $samples_remaining');

	for (i in 0...16)
	{
		var instrument = i;
		var label = StringTools.lpad('$instrument', "0", 2);
		var a = '$label: ' + Micromod.get_string(instrument);

		instrument += 16;
		var label = StringTools.lpad('$instrument', "0", 2);
		var b = '$label: ' + Micromod.get_string(instrument);

		trace('$a $b');
	}
}