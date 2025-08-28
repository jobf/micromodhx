package app;

import peote.view.text.TextElement;
import peote.view.text.TextOptions;
import peote.view.text.Text;

class Button extends Text {
	public function new(x:Int, y:Int, text:String, ?textOptions:TextOptions) {
		super(x, y, text, textOptions);
		onOver = _onOver;
		onOut = _onOut;
	}

	inline function _onOver(button:Text, text:TextElement) {
		button.changeBgA(0x8F);
	};

	inline function _onOut(button:Text, text:TextElement) {
		button.changeBgA(0xFF);
	};
}
