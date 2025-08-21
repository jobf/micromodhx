import micromod.bindings.js.AudioPlayer;
import micromod.bindings.js.MicromodJs.Micromod as MicromodJs;
import micromod.bindings.js.MicromodJs.Module;
import js.html.FileReader;
import js.Browser;
import js.lib.Int8Array;

@:expose
class TestPlayer {
	static var player:AudioPlayer;

	public static function init(f) {
		trace(f);

		var reader = new FileReader();

		reader.onloadend = event -> {
			var data = new Int8Array(reader.result);
			var module = new Module(data);
			var sample_rate = 48000;
			var micromod = new MicromodJs(module, sample_rate);
			trace(micromod.getVersion());
			player = new AudioPlayer();
			player.setAudioSource(micromod);
			Browser.document.getElementById("songName").innerHTML = "Song Name:" + module.songName;
			trace(micromod.getSamplingRate());
			trace(micromod.calculateSongDuration());
			for (instrument in module.instruments) {
				trace(instrument.instrumentName);
			}
		}

		reader.readAsArrayBuffer(f);
	}

	public static function play() {
		if (player != null) {
			player.play();
		}
	}

	public static function stop() {
		if (player != null) {
			player.stop();
		}
	}
}

