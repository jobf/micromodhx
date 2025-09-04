# haxe bindings for micromod

[micromod](https://github.com/martincameron/micromod) is

> A good-quality player library for the ProTracker MOD music format
for JavaScript (HTML5 Web Audio), Java, ANSI C (SDL) and Pascal (SDL).

Many of the original targets are supported by haxe.

C and JavaScript alone means lime could use it for background music, for example. I probably won't implement Java, however there is an interesting tool there which generates mods from text files...

# status

It's work in progress, but currently there are bindings for hashlink and javascript with enough functionality to read the mod file, extract instrument names, and render audio samples.

There is also a gui app in the repo for playing back modules in real time.

# test

Clone the source

```
git clone --recursive https://github.com/jobf/micromodhx
```

## test the bindings (render audio to disk)

There are 2 minimal test apps that are meant for asserting that the bindings work on hashlink and JavaScript.

For a complete gui application see the [lime app section](#lime-app-render-audio-to-sound-card).

### hashlink

Currently supports linux with hashlink installed globally.

Run the following. This will compile the hdll and the test hashlink program to `bin/hl` which will then be run by the system-installed hashlink. You'll get some information about the test module on the command line and the module will be rendered to a wav `bin/hl/test.wav`.

```
haxe test-hl.hxml
```

### js

Currently suports linux with python intalled globally.

Run the following. This will compile the js and the test js program to `bin/js` along with dependencies. The files will then be server over http using python, open http://localhost:8123 and check the console. This aims to mirror the same behavior as the hashlink Main app, although the playback routine is not finished. To test audio playback browse to http://localhost:8123/test.html where there is a haxe port of the original javascript test page allowing you to load a module using file browser and play the audio.

```
haxe test-js.hxml
```

## lime app (render audio to sound card)

This is a gui application for playing modules and sits on top of lime, so you need that installed, along with some other haxelibs...

```
# lime
haxelib install lime

# peote-view
haxelib install peote-view
```
You want to be in the correct path

```
cd test-lime
```

Then you can run either with hashlink or in a web browser.

Download some modules from e.g. https://modarchive.org/ or use your own.  Currently micromod appears to only support mod, the s3m and xm claim is apparently false.

```
# hashlink
lime test hl

# browser
lime test html5
```

### glitches

The modules that are included in the micromod repository are glitchy. I had issues loading them into protracker and they cause the hashlink build of to segfault.

Modules from modarchive seem to be fine however.

# to do

- windows scripts (currently scripts used during compilation only support linux/mac?)
- make the hashlink test-lime more robust
- hxcpp bindings :(
- unify the API further
- code cleaning
- add haxelib.json

