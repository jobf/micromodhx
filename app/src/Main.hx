package;

import app.Button;
import peote.view.Color;
import peote.view.text.Text;
#if js
import js.html.FileList;
import audio.js.AudioPlayer;
#end
import micromod.Micromod;

class Main extends app.App {
	var processed:Text;
	var progress:Text;
	var player:AudioPlayer;
	var progressChars:Array<String>;
	var duration:Int;
	var nLast:Int = -1;

	public function start() {
		player = new AudioPlayer();
		player.setAudioSource(new SineSource(player.getSamplingRate()));

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

					yLine = lineHeight;
					text.buff.clear();

					var buttonGap = Std.int(lineHeight * 3.5);
					add_button(' ${String.fromCharCode(16)} ', (text, char) -> {
						play();
					}, lineHeight, yLine);
					xLine += buttonGap;
					writeLine(Micromod.get_name(), "NAME:");
					xLine -= buttonGap;

					add_button(' ${String.fromCharCode(17)} ', (text, char) -> {
						if (player.isPlaying) {
							player.pause();
						} else {
							player.resume();
						}
					}, lineHeight, yLine);
					xLine += buttonGap;
					duration = Micromod.calculate_song_duration();
					writeLine(duration + "", "TOTAL SAMPLES:    ");
					xLine -= buttonGap;

					add_button(' ${String.fromCharCode(15)} ', (text, char) -> {
						stop();
					}, lineHeight, yLine);
					xLine += buttonGap;
					processed = writeLine("0", "SAMPLES PROCESSED:");
					xLine -= buttonGap;
					
					// progress bar
					resetProgressChars();
					progress = add_button(progressChars.join(""), (text, char) -> {
						var index = text.elements.indexOf(char);
						trace(index);
						var completion = index / progressChars.length;
						var pos = Math.floor(completion * duration);
						Micromod.set_position(pos);
						player.samplesProcessed = pos;
						resetProgressChars();
						nLast = Math.floor(completion) - 1;
						if (!player.isPlaying) {
							play();
						}
					}, lineHeight, yLine);

					// writeLine("", ""); // empty line
					writeLine("", ""); // empty line

					writeLine("", "Instruments ...");

					for (i in 1...17) {
						var instrument = i;
						var label = StringTools.lpad('$instrument', "0", 2);
						var a = '$label: ' + Micromod.get_string(instrument);

						instrument += 16;

						var b = "";
						if (instrument <= 0x1f) {
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

	function writeLine(line:String, title:String):Text {
		// add title
		text.add(new Text(xLine, yLine, title, {
			fgColor: Color.GREEN3,
		}));

		// add line
		var space = title.length == 0 ? 0 : 1;
		var xLabel = this.text.defaultOptions.letterWidth * (title.length + space) + xLine;
		var line = text.add(new Text(xLabel, yLine, line));
		yLine += lineHeight;

		return line;
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
			if (nLast != n) {
				for (i in 0...progressChars.length) {
					var code = i >= n ? 6 : 7;
					progressChars[i] = String.fromCharCode(code);
				}
				progress.text = progressChars.join("");
				text.updateText(progress);
				nLast = n;
			}
		}
	}

	function play() {
		if (!onUpdate.has(_onUpdate)) {
			onUpdate.add(_onUpdate);
		}
		player.play();
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

class Play extends Button{
	public function new(x:Int, y:Int, )
	{
		super(x, y, String.fromCharCode(16));
	}
}