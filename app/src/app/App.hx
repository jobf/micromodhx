package app;

import peote.view.text.TextElement;
import peote.view.Color;
import peote.view.text.Text;
import peote.view.text.BMFontData;
import lime.ui.MouseButton;
import peote.view.Display;
import peote.view.text.TextProgram;
import haxe.CallStack;
import lime.app.Application;
import peote.view.PeoteView;
import peote.view.text.TextOptions;

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

	function init() {
		peoteView = new PeoteView(window);
		var bg = Color.BLUE1;
		bg.valueHSV = 20 / 256;
		display = new Display(0, 0, window.width, window.height, bg);
		peoteView.addDisplay(display);

		var textOptions:TextOptions = {
			fgColor: Color.WHITE,
			letterWidth: 16,
			letterHeight: 16,
		}

		var font = new BMFontData(Font.halfling);
		text = new TextProgram(font, textOptions);
		display.addProgram(text);

		lineHeight = Std.int(textOptions.letterHeight + textOptions.letterHeight / 4);
		xLine = lineHeight;
		yLine = lineHeight;

		start();
	}

	function add_button(label:String, action:(text:Text, char:TextElement) -> Void, x:Int, y:Int):Text {
		// var x = x_ > 0 ? x_ : xButton;
		// var y = y_ > 0 ? y_ : yButton += space;

		var text = new Text(x, y, label, {
			fgColor: Color.WHITE,
			bgColor: Color.GREEN3,
		});

		text.onAction = action;
		text.onOver = (text:Text, char:TextElement) -> text.changeBgA(0x8F);
		text.onOut = (text:Text, char:TextElement) -> text.changeBgA(0xFF);

		return this.text.add(text);
	}

	abstract function start():Void;

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
