import peote.view.text.TextProgram;
import turbo.interactive.Elements;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import peote.ui.PeoteUIDisplay;
import peote.view.PeoteView;
import peote.view.text.TextOptions;
import turbo.theme.Colors;
import turbo.UI;

abstract class App extends Application 
{
	var peoteView:PeoteView;
	var uiDisplay:PeoteUIDisplay;
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

	function init(){
		peoteView = new PeoteView(window);

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
		// var colors:Colors = Themes.BORDEAUX();

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
		ui.display.addProgram(text);

		var x = 0;
		var y = 0;
		var space = default_item_rect.height + 2;

		add_element = (model:InteractiveModel) ->
		{
			var element = ui.make(model, x, y);
			y += space;
			return element;
		};

		start();
	}

	var add_element:(model:InteractiveModel) -> BaseInteractive;

	abstract function start():Void;
}
