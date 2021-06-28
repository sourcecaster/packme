## What is PackMe
PackMe is a lightweight library for packing your data into binary buffer (presumably in order to be sent over tcp connection) and unpacking it back to class objects described in a simple way via JSON manifest file.

## It is Fast
Since PackMe generates .dart classes, there is no need for any resource demanding serialization/deserialization process. No intermediate steps involved, every class has it's own efficient methods to quickly put all data to Uint8List buffer and extract it. Comparing to popular solutions it's performance is similar to FlatBuffers and greately outperforms Proto Buffers.

## It is Simple
You do not need to learn any additional data format or special manifest syntax (like in case of using FlatBuffers or Proto Buffers), just use JSON! Everyone knows JSON, right? Objects, types and messages declarations are very simple and intuitive.

## Usage
Here's a simple manifest.json file (located in packme directory) for some hypothetical client-server application:
```json
{
    "get_user": [
        {
            "id": "string",
        },
        {
            "first_name": "string",
            "last_name": "string",
            "age": "uint16"
        }
    ]
}
```
Generate dart files: 
```bash
dart compile.dart packme generated
```
Using on client side:
```dart
import 'generated/manifest.generated.dart';
import 'package:packme/packme.dart';

...

PackMe packMe = PackMe();
packMe.register(manifestMessageFactory); // Required by PackMe to create class instances while unpacking messages

GetUserRequest request = GetUserRequest(id: 'a7db84cc2ef5012a6498bc64334ffa7d');
socket.send(packMe.pack(request)); // Some socket implementation

socket.listen((Uint8List data) {
    final PackMeMessage? message = packMe.unpack(data);
    if (message is GetUserResponse) print('User data: ${message.firstName} ${message.firstName}, ${message.age} y.o.');
});
```
Using on server side:
```dart
import 'generated/manifest.generated.dart';
import 'package:packme/packme.dart';

...

PackMe packMe = PackMe();
packMe.register(manifestMessageFactory); // Required by PackMe to create class instances while unpacking messages

server.listen((Uint8List data, SomeSocket socket) { // Some server implementation
    final PackMeMessage? message = packMe.unpack(data);
    if (message is GetUserRequest) {
        GetUserResponse response = GetUserResponse(
            firstName: 'Peter',
            lastName: 'Hollens',
            age: '39'
        );
        socket.send(packMe.pack(response));
    }
});
```

## Supported platforms
Now it's only for Dart. Will it be cross platform? Well it depends... If developers will find this package useful then it will be implemented for JavaScript and C++ I guess.
