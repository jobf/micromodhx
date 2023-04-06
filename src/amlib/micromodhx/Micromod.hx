package amlib.micromodhx;

import ammer.ffi.*;

@:ammer.lib.includePath("../../../native/micromod/micromod-c")
@:ammer.lib.linkNames([])
@:ammer.lib.headers.includeLocal("micromod.h")
@:ammer.lib.headers.includeLocal("micromod.c")
@:ammer.nativePrefix("micromod_")
class Micromod extends ammer.def.Library<"micromod"> {
	/**
		Calculate the length in bytes of a module file given the 1084-byte header.
		Returns -1 if the data is not recognised as a module.
	**/
	public static function calculate_mod_file_len(module_header:Bytes):Int;

	
	/**
		Set the player to play the specified module data.
		Returns -1 if the data is not recognised as a module.
		Returns -2 if the sampling rate is less than 8000hz.
	**/
	public static function initialise(module:Bytes, sampling_rate:Int):Int;

	/**
		Returns the total song duration in samples at the current sampling rate.
	**/
	// public static function micromod_calculate_song_duration():Int;

	/**
		Jump directly to a specific pattern in the sequence.
	**/
	// public static function micromod_set_position(pos:Int):Void;

	/**
		Mute the specified channel.
		If channel is negative, un-mute all channels.
		Returns the number of channels.
	**/
	// public static function micromod_mute_channel(channel:Int):Int;

	/**
		Set the playback gain.
		For 4-channel modules, a value of 64 can be used without distortion.
		For 8-channel modules, a value of 32 or less is recommended.
	**/
	// public static function micromod_set_gain(value:Int):Void;

	/**
		Calculate the specified number of stereo samples of audio.
		Output buffer must be zeroed.
	**/
	// public static function micromod_get_audio(output_buffer:Array<Int>, count:Int):Void;
}