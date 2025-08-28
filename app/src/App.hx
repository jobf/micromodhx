import peote.view.Color;
import peote.view.text.Text;
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
		display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		var textOptions:TextOptions = {
			fgColor: Color.WHITE,
			// bgColor: bgColor,
			letterWidth: 16,
			letterHeight: 16,
			// letterSpace: letterSpace,
			// lineSpace: lineSpace,
			// zIndex: zIndex
		}

		text = new TextProgram(textOptions);
		display.addProgram(text);

		var space = Std.int(textOptions.letterHeight + (textOptions.letterHeight / 8));
		var x = space;
		var y = 0;

		add_button = (label, action) -> {
			var text = new Text(x, y += space, label, {
				fgColor: Color.WHITE,
				bgColor: Color.RED,
			});
			
			text.onAction = action;
			text.onOver = (text:Text) -> text.changeBgA(0x8F);
			text.onOut = (text:Text) -> text.changeBgA(0xFF);

			return this.text.add(text);
		}

		start();
	}

	var add_button:(label:String, action:(text:Text) -> Void) -> Text;

	abstract function start():Void;

	override function onMouseMove(x:Float, y:Float) {
		#if (!html5)
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
							owner.onOut(owner);
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
							owner.onOver(owner);

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
					elem.owner.onOut(elem.owner);
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
					elem.owner.onAction(elem.owner);
				}
			}
		} catch (_)
			trace(CallStack.toString(CallStack.exceptionStack()), _);
	}
}
