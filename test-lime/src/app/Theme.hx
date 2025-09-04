package app;

import app.Font;

@:structInit
@:publicFields
class Theme {
	var background:Int = 0x444444ff;
	var textColorA:Int = 0xA7AEB4ff;
	var textColorB:Int = 0x6baa75ff;
	var buttonColorA:Int = 0x6baa75ff;
	var buttonColorB:Int = 0xCBFF4Dff;
	var font:Array<Int> = halfling;
}

var chalk:Theme = {
	background: 0x1D201Fff,
	textColorA: 0xD1DEDEff,
	textColorB: 0xC58882ff,
	buttonColorA: 0xDF928Eff,
	buttonColorB: 0xEAD2ACff,
	font: comic_fans
}

var suite:Theme = {
	background: 0x02040Fff,
	textColorA: 0xE5DADAff,
	textColorB: 0x002642ff,
	buttonColorB: 0x840032ff,
	buttonColorA: 0xE59500ff,
	font: scarlet
}

var slate:Theme = {
	background: 0x1A2323ff,
	textColorA: 0x88D9E6ff,
	textColorB: 0x526760ff,
	buttonColorA: 0x8B8BAEff,
	buttonColorB: 0x88D9E6ff,
	font: around
}

var iceburn:Theme = {
	background: 0xE7E7E7ff,
	textColorA: 0x485696ff,
	textColorB: 0xFC7A1Eff,
	buttonColorA: 0xF9C784ff,
	buttonColorB: 0xF24C00ff,
	font:computer
}
