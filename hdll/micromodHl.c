
#define HL_NAME(n) micromodHl_##n

#include "micromod.h"
#include <hl.h>

static long samples_remaining;
static long samples_total;

// from sdlplayer.c, Not sure why it was not in the micromod lib itself...

/* Reduce stereo-separation of count samples. */
void crossfeed(short *audio, int count) {
  int l, r, offset = 0, end = count << 1;
  while (offset < end) {
    l = audio[offset];
    r = audio[offset + 1];
    audio[offset++] = (l + l + l + r) >> 2;
    audio[offset++] = (r + r + r + l) >> 2;
  }
}

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
  samples_total = len;
  return len;
}

DEFINE_PRIM(_I32, calculate_mod_file_len, _BYTES);

// initialise

HL_PRIM int HL_NAME(initialise)(vbyte *data, int sampling_rate) {

  const long len = micromod_initialise(data, sampling_rate);
  // samples_remaining = len;
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
  samples_remaining = micromod_calculate_song_duration();
  return samples_remaining;
}

DEFINE_PRIM(_I32, calculate_song_duration, _NO_ARG);

// get_audio

HL_PRIM int HL_NAME(get_audio)(vbyte *output_buffer, int count) {

  if (count > 0) {
    /* Get audio from replay.*/
    short *soutput_buffer = (short *)output_buffer;
    micromod_get_audio(soutput_buffer, count);
    crossfeed(soutput_buffer, count);
    samples_remaining -= count;
  }
}

DEFINE_PRIM(_VOID, get_audio, _BYTES _I32);

// set_position

HL_PRIM int HL_NAME(set_position)(int pos) {
  micromod_set_position(pos);
}

DEFINE_PRIM(_VOID, set_position, _I32);

// seek

HL_PRIM int HL_NAME(seek)(int sample_pos) {
  micromod_seek(sample_pos);
  samples_remaining = samples_total - sample_pos;
}

DEFINE_PRIM(_VOID, seek, _I32);
