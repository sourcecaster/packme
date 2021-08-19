## What is PackMe
PackMe is a lightweight library for packing your data into binary buffer (presumably in order to be sent over TCP connection) and unpacking it back to class objects described in a simple way via JSON manifest files.

## It is Fast 
Spoiler alert! ~500k pack/unpack cycles per second for data of average size and complexity. Of course it depends on system configuration :)

Since PackMe generates .dart classes, there is no need for any resource demanding serialization/deserialization process. No intermediate steps involved, every class has it's own efficient methods to quickly put all data to Uint8List buffer and extract it. Comparing to popular solutions it's performance is similar to FlatBuffers and greatly outperforms Proto Buffers.

## It is Simple
No special file formats (like for FlatBuffers or Proto Buffers manifest files), just use JSON. Objects, types and messages declarations are very simple and intuitive.

## Usage
The best way of using it for client-server applications is by using ConnectMe package which provides all necessary stuff like adding message listeners, calling asynchronous queries etc. But you can use it separately as well.

Here's a simple manifest.json file (located in packme directory) for some hypothetical client-server application:
```json
{
    "get_user": [
        {
            "id": "string"
        },
        {
            "first_name": "string",
            "last_name": "string",
            "age": "uint8"
        }
    ]
}
```
Generate dart files: 
```bash
# Usage: compiler.dart <json_manifests_dir> <generated_classes_dir>
dart compiler.dart packme generated
```
Using on client side:
```dart
import 'generated/manifest.generated.dart';
import 'package:packme/packme.dart';

void main() {
    // ... whatever code goes here

    PackMe packMe = PackMe();
    // Register class factory to make PackMe able to create class instances while unpacking messages
    packMe.register(manifestMessageFactory);
    
    GetUserRequest request = GetUserRequest(id: 'a7db84cc2ef5012a6498bc64334ffa7d');
    socket.send(packMe.pack(request)); // Some socket implementation
    
    socket.listen((Uint8List data) {
        final PackMeMessage? message = packMe.unpack(data);
        if (message is GetUserResponse) {
            print('He is awesome: ${message.firstName} ${message.lastName}, ${message.age} y.o.');
        }
    });
}
```
Using on server side:
```dart
import 'generated/manifest.generated.dart';
import 'package:packme/packme.dart';

void main() {
    // ... whatever code goes here

    PackMe packMe = PackMe();
    // Register class factory to make PackMe able to create class instances while unpacking messages
    packMe.register(manifestMessageFactory);
    
    server.listen((Uint8List data, SomeSocket socket) { // Some server implementation
        final PackMeMessage? message = packMe.unpack(data);
        if (message is GetUserRequest) {
            GetUserResponse response = GetUserResponse(
                firstName: 'Peter',
                lastName: 'Hollens',
                age: 39,
            );
            // Or: GetUserResponse response = message.$response(
            //     firstName: 'Peter',
            //     lastName: 'Hollens',
            //     age: 39,
            // );
            socket.send(packMe.pack(response));
        }
    });
}
```

## Messages
There are two types of messages: single messages and request / response messages. Single message is declared as an array with single object in JSON:
```json
"update": [{
    "field_1": "uint8",
    "field_2": "uint8",
    "field_3": "uint8"
}]
```
This will create class "UpdateMessage". Single messages are used when you need to send some data one way, for example, periodic updates. Request / response messages are declared as an array with two objects:
```json
"get_something": [{
    "field_1": "uint8",
}, {
    "field_1": "uint8",
    "field_2": "uint8",
    "field_3": "uint8"
}]
```
This will generate two classes: "GetSomethingRequest" and "GetSomethingResponse". Request class will have method $response(...) which returns an instance of response class.

## Optional fields
By default, all fields are required. In order to declare an optional field, use "?" prefix:
```json
"?something_optional": "string"
```
Using optional fields is a good way to optimize resulting packet size since PackMe does not store any data for null valued fields.

## Types
You can declare fields of standard type (such as uint32, double, string), custom type (declared enums or objects) or nested object type.

### Integer types
- uint8 - 8 bits (from 0 to 255)
- int8 - 8 bits (from -128 to 127)
- uint16 - 16 bits (from 0 to 65,535)
- int16 - 16 bits (from -32,768 to 32,767)
- uint32 - 8 bits (from 0 to 4,294,967,295)
- int32 - 8 bits (from -2,147,483,648 to 2,147,483,647)
- uint64 - 8 bits (from 0 to 18,446,744,073,709,551,615)
- int64 - 8 bits (from -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807)

### Floating point types
- float - 32 bits (from -3.4E+38 to 3.4E+38, ~7 significant digits)
- double - 64 bits (from -1.7E+308 to 1.7E+308, ~16 significant digits)

### Bool
```json
"parameter": "bool"
```
Note that using bool type is more efficient than uint8 since it requires only 1 bit and PackMe stores all bool fields together (up to 8 fields per byte).

### String
```json
"parameter": "string"
```
All strings are interpreted and stored as UTF-8 strings.

### DateTime
```json
"event_date": "datetime"
```
DateTime is packed as 64-bit signed integer (number of milliseconds that have elapsed since the Unix epoch).

### Enum
Enum is a custom type you can declare in the same JSON manifest file or in the separate one. Enum is declared as an array of strings:
```json
"message_status": [
    "sent",
    "delivered",
    "read",
    "unsent"
]
```
It will generate enum "MessageStatus". In order to declare a field of enum type use "@" as a type prefix:
```json
"status": "@message_status"
```

### Object
Like enums objects can be declared in any JSON file. It will be accessible for all manifest files. Object is declared as an object:
```json
"user_profile": {
    "first_name": "string",
    "last_name": "string",
    "birth_date": "datetime"
}
```
It will generate class "UserProfile". In order to declare a field of object type use "@" as a type prefix:
```json
"profile": "@user_profile"
```

### Nested object
It is possible to use nested objects as field types:
```json
"send_update": [{
    "values": {
        "min": "double",
        "max": "double"
    },
    "rates": [{
        "a": "float",
        "b": "float",
        "c": "float"
    }]
}]
```
In this case additional classes will be created: "SendUpdateMessageValues" and "SendUpdateMessageRate" which will be used as types for "values" and "rates" properties of "SendUpdateMessage" class.

## Arrays
If you need to declare a field as an array of specific type, just put your type string into square brackets:
```json
"numbers": ["uint32"],
"names": ["string"],
"users": ["@user"]
```

## Supported platforms
Now it's available for Dart and JavaScript. Will there be more platforms? Well it depends... If developers will find this package useful then it will be implemented for C++ I guess.
