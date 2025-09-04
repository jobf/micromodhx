package app;

import app.Theme;
import haxe.CallStack;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteView;
import peote.view.text.BMFontData;
import peote.view.text.Text;
import peote.view.text.TextElement;
import peote.view.text.TextOptions;
import peote.view.text.TextProgram;

abstract class App extends Application {
	var peoteView:PeoteView;
	var display:Display;
	var text:TextProgram;
	var space:Int = 0;

	var xLine:Int = 0;
	var yLine:Int = 0;
	var lineHeight:Int;
	var lastMoveX:Float;
	var lastMoveY:Float;
	var isMouseMove:Bool;
	var margin:Int;
	var theme:Theme;

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try {
					init();
				} catch (_) {
					trace(CallStack.toString(CallStack.exceptionStack()), _);
				}
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	var themes:Array<Theme> = [
		suite,
		chalk,
		slate,
		iceburn,
		{},
	];

	function init() {
		theme = themes[themes.length - 1];

		peoteView = new PeoteView(window);

		display = new Display(0, 0, 800, 450, theme.background);
		peoteView.addDisplay(display);

		var textOptions:TextOptions = {
			fgColor: theme.textColorA,
			letterWidth: 16,
			letterHeight: 16,
		}

		var font = new BMFontData(theme.font);
		text = new TextProgram(font, textOptions);
		display.addProgram(text);

		lineHeight = Std.int(textOptions.letterHeight + textOptions.letterHeight / 4);
		margin = 2;
		xLine = margin;
		yLine = margin;

		start();
	}

	function clear():Void {
		yLine = margin;
		text.buff.clear();
	}

	function setTheme(theme:Theme){
		this.theme = theme;
		text.defaultOptions.fgColor = theme.textColorA;
		display.color = theme.background;
		text.setFont(new BMFontData(theme.font));
	}

	function initThemeChoice() {
		var x = display.width - themes.length * lineHeight;
		var y = display.height - lineHeight;
		for (n => theme in themes) {
			add_button(String.fromCharCode(n + 1), (text, char) -> {
				setTheme(theme);
				clear();
				initUi();
			}, x, y, true);
			x += lineHeight;
		}
	}



	function writeLine(line:String, title:String):Text {
		// add title
		text.add(new Text(xLine, yLine, title, {
			fgColor: theme.textColorB,
		}));

		// add line
		var space = title.length == 0 ? 0 : 1;
		var xLabel = this.text.defaultOptions.letterWidth * (title.length + space) + xLine;
		var line = text.add(new Text(xLabel, yLine, line));
		yLine += lineHeight;

		return line;
	}

	function add_button(label:String, action:(text:Text, char:TextElement) -> Void, x:Int, y:Int, isTransparentBg:Bool=false):Text {
		var text = new Text(x, y, label, {
			fgColor: theme.buttonColorA,
			bgColor: isTransparentBg ? 0x00000000 : theme.buttonColorB,
		});

		if(!isTransparentBg){
		}
		var aOver = isTransparentBg ? 0x00 : 0x8f;
		var aOut = isTransparentBg ? 0x00 : 0xff;
		text.onOver = (text:Text, char:TextElement) -> text.changeBgA(aOver);
		text.onOut = (text:Text, char:TextElement) -> text.changeBgA(aOut);

		text.onAction = action;

		return this.text.add(text);
	}

	abstract function start():Void;
	
	abstract function initUi():Void;
	
	#if (!js)
		override function render(context:RenderContext):Void
		{	
			if (isMouseMove) {
				isMouseMove = false;
				onMouseMoveFrameSynced(lastMoveX, lastMoveY);
			}
		}
	#end

	override function onMouseMove(x:Float, y:Float) {
		#if (!js)
		lastMoveX = x;
		lastMoveY = y;
		isMouseMove = true;
		#else
		onMouseMoveFrameSynced(x, y);
		#end
	}

	var lastOverIndex:Int = -1;
	var lastDownIndex:Int = -1;
	var lockDown = false;

	inline function onMouseMoveFrameSynced(x:Float, y:Float):Void {
		try {
			var pickedElement = peoteView.getElementAt(x, y, display, text);
			if (pickedElement != lastOverIndex) {
				if (lastOverIndex >= 0) {
					var elem = text.buff.getElement(lastOverIndex);
					if (elem != null) {
						elem.fgColor.a = 0xff;
						var owner:Text = elem.owner;
						if (owner.onOut != null) {
							owner.onOut(owner, elem);
							for (e in owner.elements) {
								this.text.buff.updateElement(e);
							}
						}
					}
				}
				if (pickedElement >= 0) {
					var elem = text.buff.getElement(pickedElement);
					if (elem != null) {
						elem.fgColor.a = 0x80;
						var owner:Text = elem.owner;
						if (owner.onOver != null) {
							owner.onOver(owner, elem);

							for (e in owner.elements) {
								this.text.buff.updateElement(e);
							}
						}
					}
				}
				lastOverIndex = pickedElement;
			}
		} catch (_)
			trace(CallStack.toString(CallStack.exceptionStack()), _);
	}

	override function onWindowLeave():Void {
		if (lastDownIndex >= 0) {
			var elem = text.buff.getElement(lastOverIndex);
			if (elem != null) {
				elem.fgColor.a = 0xff;
				text.buff.updateElement(elem);
				if (elem.owner.onOut != null) {
					elem.owner.onOut(elem.owner, elem);
				}
			}
		}
	}

	override function onMouseDown(x:Float, y:Float, button:MouseButton):Void {
		try {
			lastDownIndex = peoteView.getElementAt(x, y, display, text);
			if (lastDownIndex >= 0) {
				var elem = text.buff.getElement(lastDownIndex);
				if (elem == null)
					return;
				if (elem.owner.onAction != null) {
					elem.owner.onAction(elem.owner, elem);
				}
			}
		} catch (_)
			trace(CallStack.toString(CallStack.exceptionStack()), _);
	}
}
