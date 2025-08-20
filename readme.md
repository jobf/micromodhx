# haxe bindings for micromod

[micromod](https://github.com/martincameron/micromod) is

> A good-quality player library for the ProTracker MOD music format
for JavaScript (HTML5 Web Audio), Java, ANSI C (SDL) and Pascal (SDL).

Many of the original targets are supported by haxe.

C, JavaScript alone means lime could use it for background music, for example. I probably won't implement Java, however.

# status

Currently supports hashlink. Has enough functions to read data from the mod file and convert it to sample data.

# howto

You can test on linux by cloning

```
git clone --recusrive https://github.com/jobf/micromodhx
```

Then running. This will output some data to the command line and produce a file `bin/hl/test.wav`.

```
haxe test.hxml
```

# todo

- javascript bindings
- support windows hashlink
- hxcpp bindings
- finish binding all functions
- demo lime app supporting native, hl and web
