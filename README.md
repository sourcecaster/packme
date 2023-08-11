## What is PackMe
Two words: binary serialization. Or rather, four words: Blazing Fast Binary Serialization (BFBS). PackMe is a lightweight library that allows using your JSON description of data protocols to generate all necessary classes (Flutter/Dart, JS, C++ etc.) for your client-server binary data communication.
<table><tr><td>

```json
"demand": [
    {
        "request": "string",
        "deadline": "datetime"
    },
    {
        "excuses": ["string"]
    }
]

```

</td><td>

```dart
Future<void> main() async {
    // ... Simple as that!
    Uint8List buffer = packMe.pack(DemandRequest(
        request: "I demand an answer!",
        deadline: DateTime.now()
    ));
    buffer = await serverQuery(buffer);
    DemandResponse myAnswer = packMe.unpack(buffer);
    myAnswer.excuses.forEach(print);
}
```

</td></tr></table>


## Performance 
BFBS. Spoiler alert! 500,000+ pack/unpack cycles per second for data of average size and complexity (see example.dart).

Since PackMe generates .dart classes, there is no need for resource demanding serialization/deserialization process. With no intermediate steps involved, each class has efficient methods to quickly place all data into a Uint8List buffer and extract it. Compared to popular solutions, it completely outmatches JSON or Protobuf in terms of performance.

## Simplicity & Security
PackMe offers simplicity without need for special syntax knowledge - just use JSON. Declare types, messages and requests with ease. Moreover, the generated classes ensure data consistency, enhancing processing efficiency and fortifying server side security.

## Usage
The most effective way to use it in client-server applications is through the [ConnectMe](https://pub.dev/packages/connectme) package, which provides essential features like message listeners and asynchronous queries. Nevertheless, it can also be used separately.

Here's a simple manifest.json file (located in the "protocols" directory) for a hypothetical client-server application:
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
It implies that the client can get a user with the specified "id" from the server. The first step is to generate your classes: 
```bash
# Usage: dart run packme <json_manifests_dir> <generated_classes_dir> [<file1>, <file2>...]
> dart run packme protocols generated
```
Next, let's import manifest.generated.dart and proceed with a simple code for both client and server sides. Here goes the client side first:
```dart
import 'package:packme/packme.dart';
import 'generated/manifest.generated.dart';

// Hypothetical application client
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
Now the server side:
```dart
import 'package:packme/packme.dart';
import 'generated/manifest.generated.dart';

// Hypothetical application server
void main() {
    // ... whatever code goes here

    PackMe packMe = PackMe();
    // Register class factory to make PackMe able to create class instances while unpacking messages
    packMe.register(manifestMessageFactory);
    
    server.listen((Uint8List data, SomeSocket socket) { // Some server implementation
        final PackMeMessage? message = packMe.unpack(data);
        if (message is GetUserRequest) {
            GetUserResponse response = message.$response(
                firstName: 'Peter',
                lastName: 'Hollens',
                age: 41,
            );
            // We could as well use GetUserResponse(...) but, using message.$response(...)
            // is more valid since it sets internal $transactionId value which can be used 
            // to determine which exactly request this response is related to.
            socket.send(packMe.pack(response));
        }
    });
}
```

## JSON Nodes
The JSON manifest is structured as an object containing various nodes. There are four different types of nodes you can create: enumeration, object, message and request.

### Enumeration
Declares a custom enumeration data type which you can later refer to:
```json
"message_status": [
    "sent",
    "delivered",
    "read",
    "unsent"
]
```
It will generate enum "MessageStatus". In order to declare a field of this enum type use "@" as a type prefix:
```json
"status": "@message_status"
```

### Object
Declares a custom object (class) data type which can be referred to:
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
**Objects can inherit other objects.** Use the symbol "@" to specify the object to inherit:
```json
"animal": {
    "legs": "uint8",
    "tail": "bool"
},

"cat@animal": {
    "color": "@color_enum",
    "fur": "bool"
}
```
If the object you want to inherit is located in another file, use the following format: \<name>@\<filename>:\<object>. For instance, if the object "animal" is declared in the file "data_types.json":
```json
"cat@data_types:animal": {
    "color": "@color_enum",
    "fur": "bool"
}
```

### Message
Declares a message object (command) designed to be packed into a binary buffer and transmitted through a communication channel. Message is declared as an array of a single object (single - because it implies a one-way transaction with no response expected):
```json
"update": [
    {
        "field_1": "uint8",
        "field_2": "uint16",
        "field_3": "uint32"
    }
]
```
This will generate class "UpdateMessage". Messages are utilized for one-way data transmission, such as periodic updates.

### Request
Declares a request/response object (query) intended to be packed into a binary buffer and transmitted through a communication channel. Request is declared as an array of two objects (because it describes both the request and the expected response):
```json
"get_something": [
    {
        "field_1": "uint8",
    }, 
    {
        "field_1": "uint16",
        "field_2": "uint32",
        "field_3": "uint64"
    }
]
```
This will generate two classes: "GetSomethingRequest" and "GetSomethingResponse". The Request class will include the method $response(...) which returns an instance of the Response class.

## Fields and Data Types
Fields are declared as key-value pairs of objects, where the key represents the field name and value defines the data type of that field. You can declare fields of standard types (such as uint32, double, string) or custom types (declared enum/object or nested object). Array of any type can be used as well.

By default, all fields are required. In order to declare an optional (nullable) field, use "?" prefix:
```json
"something_required": "string",
"?something_optional": "string"
```
Using optional fields is a good way to optimize resulting packet size since PackMe does not store any data in the buffer for null valued fields.

### Integer types
```json
"timestamp": "uint32"
```
- uint8 - 8 bits (from 0 to 255)
- int8 - 8 bits (from -128 to 127)
- uint16 - 16 bits (from 0 to 65,535)
- int16 - 16 bits (from -32,768 to 32,767)
- uint32 - 8 bits (from 0 to 4,294,967,295)
- int32 - 8 bits (from -2,147,483,648 to 2,147,483,647)
- uint64 - 8 bits (from 0 to 18,446,744,073,709,551,615)
- int64 - 8 bits (from -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807)

### Floating point types
```json
"temperature": "double"
```
- float - 32 bits (from -3.4E+38 to 3.4E+38, ~7 significant digits)
- double - 64 bits (from -1.7E+308 to 1.7E+308, ~16 significant digits)

### Binary
```json
"mongo_id": "binary12",
"some_hash": "binary64"
```
The declaration above defines two Uint8List fields: one with a length of 12 bytes and another with a length of 64 bytes.

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
DateTime fields are packed as 64-bit signed integers (number of milliseconds that have elapsed since the Unix epoch).

### Nested object
It is possible to use nested objects as field types:
```json
// Some message declaration
"position_update": [
    {
        "time": "datetime",
        "coordinates": {
            "x": "double",
            "y": "double"
        }
    }
]
```
In this case an additional class named "PositionUpdateMessageCoordinates" will be generated, with "x" and "y" properties implemented.

### Reference
```json
"owner": "@user",
"color": "@color_enum"
```
References are declared with the prefix "@" enabling the utilization of previously declared objects and enumerations. Note that an object declaration can include a field that references the same object within which it's declared.

If the object you want to refer is located in another file, use the following format: \<name>@\<filename>:\<object>. For instance, if the object "user" is declared in the file "data_types.json":
```json
"owner": "@data_types:user",
```

### Array
If you need to declare a field as an array of specific type, just put your type string into square brackets:
```json
// Some object declaration
"data": {
    "object_ids": ["binary12"],
    "numbers": ["uint32"],
    "names": ["string"],
    "users": ["@user"],
    "children": [{
        "name": "string",
        "age": "uint8"
    }]
    "matrix2x2": [["double"]]
}
```
As you can see, arrays of nested objects and nested arrays are also supported. 

It's worth noting that in this instance, an additional class named "DataChild" will be generated for the "children" field. Pay attention to a singular form of the field's name "children". Therefore the "children" property of the "Data" class will be declared as:
```dart
List<DataChild> children;
```
A singular form of the field's name will be used if possible every time you declare an array of nested objects.