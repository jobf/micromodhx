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
	var progress:Text;
	var player:AudioPlayer;
	var progressChars:Array<String>;
	var duration:Int;
	var nLast:Int = -1;

	public function start() {
		player = new AudioPlayer();
		player.setAudioSource(new SineSource(player.getSamplingRate()));

		var lineHeight = Std.int(this.text.defaultOptions.letterHeight + this.text.defaultOptions.letterHeight/4);
		var x = space * 9;
		var y = lineHeight;

		var writeLine:(line:String, title:String) -> Text = (line, title) -> {
			// add title
			text.add(new Text(x, y, title, {
				fgColor: Color.GREEN3,
			}));

			// add line
			var space = title.length == 0 ? 0 : 1;
			var xLabel = this.text.defaultOptions.letterWidth * (title.length + space) + x;
			var line = text.add(new Text(xLabel, y, line));
			y += lineHeight;

			// return line
			line;
		}

		writeLine("drop mod on screen", "");

		window.onDropFile.add((fileList) -> {
			// trace(fileList);
			resetProgressChars();
			var list:js.html.FileList = cast fileList;
			if (list.length > 0) {
				var reader = new js.html.FileReader();
				reader.onloadend = () -> {
					/** load mod data*/

					var data:js.lib.Int8Array = new js.lib.Int8Array(reader.result);

					Micromod.initialise(data, Std.int(player.getSamplingRate()));
					Micromod.get_audio(player);

					/** print mod data*/

					y = lineHeight;
					yButton = space;
					text.buff.clear();

					add_button(" PLAY ", (text, char) -> {
						if (!onUpdate.has(_onUpdate)) {
							onUpdate.add(_onUpdate);
						}
						player.play();
					});

					add_button(" PAUS ", (text, char) -> {
						if (player.isPlaying) {
							player.pause();
						} else {
							player.resume();
						}
					});

					add_button(" STOP ", (text, char) -> {
						stop();
					});

					writeLine(Micromod.get_name(), "NAME:");
					// size = writeLine("0", "BUFFER SI");

					duration = Micromod.calculate_song_duration();
					writeLine(duration + "",   "TOTAL SAMPLES:    ");

					processed = writeLine("0", "SAMPLES PROCESSED:");

					writeLine("", ""); // empty line

					// progress bar
					resetProgressChars();
					progress = add_button(progressChars.join(""), (text, char) -> {
						var index = text.elements.indexOf(char);
						trace(index);
						var completion = index / progressChars.length;
						var pos = Math.floor(completion * duration);
						player.samplesProcessed = pos;
						Micromod.set_position(pos);
						resetProgressChars();
						nLast = Math.floor(completion)-1;
					});

					writeLine("", ""); // empty line
					
					writeLine("", "Instruments ...");

					for (i in 1...17) {
						var instrument = i;
						var label = StringTools.lpad('$instrument', "0", 2);
						var a = '$label: ' + Micromod.get_string(instrument);

						instrument += 16;


						var b = "";
						if(instrument <= 0x1f){
							var label = StringTools.lpad('$instrument', "0", 2);
							b = '$label: ' + Micromod.get_string(instrument);
						}

						writeLine('$a $b', "");
					}
				};
				reader.readAsArrayBuffer(list.item(0));
			}
		});
	}
	function resetProgressChars():Void {
		progressChars = [for (n in 0...50) String.fromCharCode(6)];
	}

	function _onUpdate(dt:Int):Void {
		if (processed != null && player.isPlaying) {
			var samplesProcessed = player.getSamplesProcessed();
			processed.text = samplesProcessed + "";
			text.updateText(processed);

			var completion = samplesProcessed / duration;
			var n = Math.floor(progressChars.length * completion);
			if(nLast < n && n < progressChars.length) {
				for(i in 0... n){
					progressChars[i] = String.fromCharCode(7);
				}
				nLast = n;
				progress.text = progressChars.join("");
				text.updateText(progress);
			}
		}
	}

	function stop() {
		player.stop();
		nLast = -1;
		Micromod.set_position(0);
		processed.text = "0";
		text.updateText(processed);

		resetProgressChars();
		progress.text = progressChars.join("");
		text.updateText(progress);
	}
}
