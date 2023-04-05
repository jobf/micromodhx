## install deps

Install haxe 4.3.0

Install hashlink 1.13.0

Install ammer libs

```
haxelib git ammer-core https://github.com/Aurel300/ammer-core.git dev
haxelib git ammer https://github.com/Aurel300/ammer.git ammer-core-rewrite
```

## test

Build

```
cd test
haxe build-hl.hxml
```

Run

```
export LD_LIBRARY_PATH=/home/jf/code/haxe/ammer/micromodhx/test/bin/hl
hl bin/hl/out.hl mods/TestModFive.mod
```
