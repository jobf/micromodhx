package;

import micromod.Micromod;
import peote.view.text.Text;
#if js
import audio.js.AudioPlayer;
#end
#if sys
import audio.lime.AudioPlayer;
#end

class Main extends app.App {
	var processed:Text;
	var progress:Text;
	var player:AudioPlayer;
	var progressChars:Array<String>;
	var totalSamples:Int;
	var nLast:Int = -1;
	var seconds:Text;
	var instruments:Array<String>;

	public function start() {
		player = new AudioPlayer();

		// for debug
		// player.setAudioSource(new audio.IMicromodSource.SineSource(player.getSamplingRate()));
		// window.onMouseDown.add((x, y, button) -> if(player.isPlaying) player.stop() else player.play());

		writeLine("drop module to load . . .", "");

		window.onDropFile.add((drop) -> {
			// trace(drop);
			clear();

			#if js
			var list:js.html.FileList = cast drop;
			if (list.length > 0) {
				var file:js.html.File = list.item(0);
				var reader = new js.html.FileReader();
				reader.onloadend = () -> {
					if (validate(file.name)) {
						var module = new js.lib.Int8Array(reader.result);
						loadModule(module);
					}
				};
				reader.readAsArrayBuffer(list.item(0));
			}
			#end

			#if sys
			var fileName = drop;
			if (validate(fileName)) {
				var data = sys.io.File.getBytes(fileName);
				loadModule(data);
			}
			#end
		});
	}

	function validate(fileName:String) {
		if (isLHAFile(fileName)) {
			writeLine("LHA not supported, please extract first!", "Sorry!");
			return false;
			// var data = new UInt8Array(reader.result);
			// lha ain't working now so show a message
			// that is one serious side mission into wasm and all
		}
		return true;
	}

	function loadModule(data:ModuleFormat) {
		var error = Micromod.initialise(data, Std.int(player.getSamplingRate()));
		if (error.length > 0) {
			writeLine(error, "Error:");
			return;
		}

		player.setAudioSource(Micromod.get_source());
		player.samplesProcessed = 0;
		totalSamples = Micromod.calculate_song_duration();

		instruments = [
			for (i in 1...17) {
				var instrument = i;
				var label = StringTools.lpad('$instrument', "0", 2);
				var a = StringTools.rpad('$label' + Micromod.get_string(instrument), " ", 24);

				instrument += 16;

				var b = "";
				if (instrument <= 0x1f) {
					var label = StringTools.lpad('$instrument', "0", 2);
					b = StringTools.rpad('$label' + Micromod.get_string(instrument), " ", 24);
				}

				a + b;
			}
		];

		initUi();
	}

	function initUi():Void {
		resetProgressChars();
		initThemeChoice();

		var buttonGap = Std.int(text.defaultOptions.letterWidth * 3.3);

		// play button
		add_button(' ${String.fromCharCode(16)} ', (text, char) -> {
			play();
		}, xLine, yLine);

		// module name
		xLine += buttonGap;
		writeLine(Micromod.get_name(), "NAME:");
		xLine -= buttonGap;

		// pause button
		add_button(' ${String.fromCharCode(17)} ', (text, char) -> {
			if (player.isPlaying) {
				player.pause();
			} else {
				player.resume();
			}
		}, xLine, yLine);

		// total samples
		xLine += buttonGap;
		var total = writeLine(totalSamples + "", "TOTAL SAMPLES:    ");
		xLine -= buttonGap;

		// stop button
		add_button(' ${String.fromCharCode(15)} ', (text, char) -> {
			stop();
		}, xLine, yLine);

		// processed samples
		xLine += buttonGap;
		processed = writeLine("0", "SAMPLES PROCESSED:");
		var end = total.elements[total.elements.length - 1];
		xLine = end.x + (end.w * 2);
		yLine -= lineHeight;
		seconds = writeLine(Math.ceil(totalSamples / player.getSamplingRate()) + "", "SECONDS:");
		xLine = margin;

		// progress bar
		resetProgressChars();
		progress = add_button(progressChars.join(""), (text, char) -> {
			var index = text.elements.indexOf(char);
			trace(index);
			var completion = index / progressChars.length;
			var samplePosition = Math.floor(completion * totalSamples);
			Micromod.seek(samplePosition);
			player.samplesProcessed = samplePosition;
			resetProgressChars();
			nLast = Math.floor(completion) - 1;
			if (!player.isPlaying) {
				play();
			}
		}, xLine, yLine);

		writeLine("", ""); // empty line

		for (instr in instruments) {
			var line = writeLine(instr, "");
			for (n in [0, 1, 24, 25]) {
				if (n < line.elements.length) {
					line.elements[n].fgColor = theme.textColorB;
					text.buff.updateElement(line.elements[n]);
				}
			}
			text.updateText(line);
		}
	}

	function isLHAFile(filename:String):Bool {
		var segments = filename.split(".");
		var ext = segments[segments.length - 1].toLowerCase();
		return ext == 'lha' || ext == 'lzh';
	}

	function resetProgressChars():Void {
		progressChars = [for (n in 0...50) String.fromCharCode(6)];
	}

	function _onUpdate(dt:Int):Void {
		if (processed != null && player.isPlaying) {
			var samplesProcessed = player.getSamplesProcessed();
			processed.text = samplesProcessed + "";
			text.updateText(processed);

			seconds.text = Math.ceil((totalSamples - samplesProcessed) / player.getSamplingRate()) + "";
			text.updateText(seconds);

			var completion = samplesProcessed / totalSamples;
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
		// Micromod.seek(0);
		Micromod.set_position(0);
		processed.text = "0";
		text.updateText(processed);

		resetProgressChars();
		progress.text = progressChars.join("");
		text.updateText(progress);
	}
}
