import lime.ui.MouseButton;
import peote.view.Display;
import peote.view.text.TextProgram;
import turbo.interactive.Elements;
import haxe.CallStack;
import lime.app.Application;
import peote.view.PeoteView;
import peote.view.text.TextOptions;
import turbo.theme.Colors;
import turbo.UI;

abstract class App extends Application {
	var peoteView:PeoteView;
	var display:Display;
	var text:TextProgram;
	var ui:UI;

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

		var display_rect:Rectangle = {
			x: 20,
			y: 20,
			width: window.width - 40,
			height: window.height - 40
		}

		var default_item_rect:Rectangle = {
			x: 0,
			y: 0,
			width: 150,
			height: 30
		}

		var item_rects:Map<String, Rectangle> = ["DEFAULT" => default_item_rect];
		var colors:Colors = Themes.RAY_CHERRY();
		var colors:Colors = Themes.BORDEAUX();

		var textOptions:TextOptions = {
			fgColor: colors.fg_idle,
			// bgColor: bgColor,
			// letterWidth: letterWidth,
			// letterHeight: letterHeight,
			// letterSpace: letterSpace,
			// lineSpace: lineSpace,
			// zIndex: zIndex
		}

		ui = new UI(peoteView, display_rect, item_rects, colors, textOptions);
		text = new TextProgram();
		display.addProgram(text);

		var x = 0;
		var y = 0;
		var space = default_item_rect.height + 2;

		add_element = (model:InteractiveModel) -> {
			var element = ui.make(model, x, y);
			y += space;
			return element;
		};

		start();
	}

	var add_element:(model:InteractiveModel) -> BaseInteractive;

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
						text.buff.updateElement(elem);
						if (elem.owner.onOut != null) {
							elem.owner.onOut(elem.owner);
						}
					}
				}
				if (pickedElement >= 0) {
					var elem = text.buff.getElement(pickedElement);
					if (elem != null) {
						elem.fgColor.a = 0x80;
						text.buff.updateElement(elem);
						if (elem.owner.onOver != null) {
							elem.owner.onOver(elem.owner);
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
