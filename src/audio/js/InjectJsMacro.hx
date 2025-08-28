package audio.js;

#if macro
import sys.io.File;
import haxe.macro.Context;
import haxe.macro.Expr;

class InjectJsMacro {
	macro static public function createField(fieldName:String):Array<Field> {
		var calledFrom = Context.getPosInfos(Context.currentPos());
		// trace('calledFrom $calledFrom');

		var jsPath = StringTools.replace(calledFrom.file, ".hx", ".js");
		var content:String = File.getContent(jsPath);
		// trace('$jsPath : $content');

		var fields = Context.getBuildFields();
		var newField = {
			name: fieldName,
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro :String, macro $v{content}),
			pos: Context.currentPos()
		};
		fields.push(newField);

		return fields;
	}
}
#end