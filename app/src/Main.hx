package;

import peote.view.text.Text;
#if js
import js.html.FileList;
import audio.js.AudioPlayer;
#end
import micromod.Micromod;

class Main extends App {
	var processed:Text;
	var size:Text;
	var player:AudioPlayer;

	public function start() {
		player = new AudioPlayer();
		player.setAudioSource(new SineSource(player.getSamplingRate()));

		var x = 180;
		var y = 0;
		var lineHeight = 10;
		var writeLine:(line:String) -> Text = line -> {
			return text.add(new Text(x, y += lineHeight, line));
		}

		writeLine("drop mod on screen");

		window.onDropFile.add((fileList) -> {
			trace(fileList);
			var list:js.html.FileList = cast fileList;
			if (list.length > 0) {
				var reader = new js.html.FileReader();
				reader.onloadend = () -> {
					/** load mod data*/

					var data:js.lib.Int8Array = new js.lib.Int8Array(reader.result);

					Micromod.initialise(data, Std.int(player.getSamplingRate()));
					Micromod.get_audio(player);

					/** print mod data*/

					y = 0;
					text.buff.clear();

					writeLine(Micromod.get_name());
					processed = writeLine("0");
					size = writeLine("0");

					var duration = Micromod.calculate_song_duration();
					writeLine(duration + " total");

					for (i in 0...16) {
						var instrument = i;
						var label = StringTools.lpad('$instrument', "0", 2);
						var a = '$label: ' + Micromod.get_string(instrument);

						instrument += 16;
						var label = StringTools.lpad('$instrument', "0", 2);
						var b = '$label: ' + Micromod.get_string(instrument);

						writeLine('$a $b');
					}
				};
				reader.readAsArrayBuffer(list.item(0));
			}
		});

		add_element({
			label: "PLAY",
			role: BUTTON,
			interactions: {
				on_press: interactive -> {

					if(!onUpdate.has(_onUpdate)){
						onUpdate.add(_onUpdate);
					}

					player.play();
				}
			}
		});

		add_element({
			label: "PAUSE",
			role: BUTTON,
			interactions: {
				on_press: interactive -> {
					if (player.isPlaying) {
						player.pause();
					} else {
						player.resume();
					}
				}
			}
		});

		add_element({
			label: "STOP",
			role: BUTTON,
			interactions: {
				on_press: interactive -> {
					player.stop();
					Micromod.set_position(0);
				}
			}
		});

		add_element({
			label: "TEST",
			role: BUTTON,
			interactions: {
				on_press: interactive -> {
					player.testSimpleAudio();
				}
			}
		});
	}

	function _onUpdate(dt:Int):Void {
		if (processed != null) {
			processed.text = player.getBuffersProcessed() + "";
			text.updateText(processed);

			size.text = player.getBufferSize() + "";
			text.updateText(size);
		}
	}
}
