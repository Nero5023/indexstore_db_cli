# indexstore_db_cli
This is a simple CLI tool based on [indexstore-db](https://github.com/apple/indexstore-db)

## Setup
Config `config.json`'s libIndexStore path, the default path is `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib`

## Build
```
$ swift build
```

## Run
```
$ ./.build/debug/indexstore_db_cli [args]
```
or
```
$ swift run [args]
```

```
OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  generate-db             Generate index store database.
  get-usr                 Get USRs for a symbol name.
  find-reference          Find references for a symbol name.
  find-definition         Find references for a symbol name.

```
