
#define HL_NAME(n) micromodHl_##n

#include "micromod.h"
#include <hl.h>

// get_version

HL_PRIM vbyte *HL_NAME(get_version)(_NO_ARG) {
  const char *text = micromod_get_version();
  const uchar *utext = (uchar *)text;
  
  hl_buffer *b = hl_alloc_buffer();
  hl_buffer_str(b, utext);
  vbyte *string = (vbyte *)hl_buffer_content(b, NULL);

  return string;
}

DEFINE_PRIM(_BYTES, get_version, _NO_ARG);

// calculate_mod_file_len

HL_PRIM int HL_NAME(calculate_mod_file_len)(vbyte *module_header) {

  const long len = micromod_calculate_mod_file_len(module_header);
  return len;
}

DEFINE_PRIM(_I32, calculate_mod_file_len, _BYTES);

// initialise

HL_PRIM int HL_NAME(initialise)(vbyte *data, int sampling_rate) {

  const long len = micromod_initialise(data, sampling_rate);
  return len;
}

DEFINE_PRIM(_I32, initialise, _BYTES _I32);

// get_string

HL_PRIM int HL_NAME(get_string)(int instrument, vbyte *string) {
  micromod_get_string(instrument, string);
}

DEFINE_PRIM(_VOID, get_string, _I32 _BYTES);

// calculate_song_duration

HL_PRIM int HL_NAME(calculate_song_duration)(_NO_ARG) {
	return micromod_calculate_song_duration();
}

DEFINE_PRIM(_I32, calculate_song_duration, _NO_ARG);

// get_audio

HL_PRIM int HL_NAME(get_audio)(vbyte *output_buffer, int count) {
	short *soutput_buffer = (short *)output_buffer;
	micromod_get_audio(soutput_buffer, count);
}

DEFINE_PRIM(_VOID, get_audio, _BYTES _I32);
