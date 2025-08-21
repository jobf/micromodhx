import js.Browser;
import js.html.XMLHttpRequest;
import micromod.bindings.js.AudioPlayer;
import js.lib.Int8Array;
import micromod.Micromod;

// import TestPlayer to build it into main.js
import TestPlayer;

function main() {

	var player = new AudioPlayer();

	var request = new XMLHttpRequest();
	var url = "test.mod";
	request.open("GET", url, true);
	request.responseType = ARRAYBUFFER;
	request.onloadend = event -> {
		var data = new Int8Array(request.response);
		Micromod.initialise(data, player.getSamplingRate());
		var samples_remaining = Micromod.calculate_song_duration();
		
		trace('samples_remaining $samples_remaining');
		print_module_info();

		Browser.window.addEventListener("click", event -> {
			trace('click !');
			// to do
			Micromod.get_audio(player);
		});
	}
	request.send();
}

function print_module_info():Void {
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