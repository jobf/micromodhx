package;

import peote.view.Color;
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

		var lineHeight = Std.int(this.text.defaultOptions.letterHeight + this.text.defaultOptions.letterHeight/8);
		var x = 180;
		var y = lineHeight;

		var writeLine:(line:String, title:String) -> Text = (line, title) -> {
			// add title
			text.add(new Text(x, y, title));

			// add line
			var xLabel = this.text.defaultOptions.letterWidth * (title.length + 1) + x;
			var line = text.add(new Text(xLabel, y, line));
			y += lineHeight;

			// return line
			line;
		}

		writeLine("drop mod on screen", "");

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

					add_button(" PLAY ", text -> {
						if (!onUpdate.has(_onUpdate)) {
							onUpdate.add(_onUpdate);
						}
						player.play();
					});

					add_button(" PAUS ", text -> {
						if (player.isPlaying) {
							player.pause();
						} else {
							player.resume();
						}
					});

					add_button(" STOP ", text -> {
						player.stop();
						Micromod.set_position(0);
					});

					writeLine(Micromod.get_name(), "NAME:");
					// size = writeLine("0", "BUFFER SI");

					var duration = Micromod.calculate_song_duration();
					writeLine(duration + "", "TOTAL SAMPLES:");

					processed = writeLine("0", "SAMPLES PROCESSED:");

					for (i in 0...16) {
						var instrument = i;
						var label = StringTools.lpad('$instrument', "0", 2);
						var a = '$label: ' + Micromod.get_string(instrument);

						instrument += 16;
						var label = StringTools.lpad('$instrument', "0", 2);
						var b = '$label: ' + Micromod.get_string(instrument);

						writeLine('$a $b', "");
					}
				};
				reader.readAsArrayBuffer(list.item(0));
			}
		});
	}

	function _onUpdate(dt:Int):Void {
		if (processed != null) {
			processed.text = player.getBuffersProcessed() + "";
			text.updateText(processed);

			// size.text = player.getBufferSize() + "";
			// text.updateText(size);
		}
	}
}
