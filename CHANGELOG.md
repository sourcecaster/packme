## v2.0.0
* BREAKING CHANGE: references made with prefix @ are not loaded from other files automatically! Use @filename:refname format.
* Object inheritance is now supported: "animal": \{&lt;fields&gt;\}, "cat@animal": \{&lt;additional fields&gt;\}.
* Now it is possible to declare nested arrays: "field": \[\["int8"\]\].
* Compiler rewritten from scratch: cleaner code, better error handling, more informative log.
* Compiler command line now accepts file names (optionally): dart run packme <srcDirectory> <outDirectory> \[file1, file2, file3...\].

## v1.2.1
* Bugfix: Uint8List with unexpected length caused out-of-range exception in pack/unpack methods.

## v1.2.0
* Added support for binary type (uses Uint8List). Format: binary12, binary64 etc. - any buffer length in bytes.
* Color schemes used to print messages are updated: list items are now displayed using color of corresponding data type.

## v1.1.5
* Safari WebSocket data parsing bug fixed (it adds some extra bytes to buffer and actual Uint8List data size is smaller that its underlying buffer).

## v1.1.4
* Description updated.

## v1.1.3
* Added some additional log output for the compiler script.
* Tests implemented.

## v1.1.2
* Project structure updated.

## v1.1.1
* MessageFactory no longer generated if no messages declared.
* Examples updated.
* ReadMe updated.

## v1.1.0
* Enums and Types are now can be referenced from another manifest files.
* Added some details for compiler error messages.

## v1.0.1
* Bugfix: it was impossible to refer type declared after current one.

## v1.0.0
* Enum declaration implemented.
* Type (nested object) declaration implemented.
* Single message or request and response messages declaration implemented.
* $response method for request messages implemented.
* Example provided.

