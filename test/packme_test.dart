import 'dart:typed_data';
import 'package:packme/packme.dart';
import 'package:test/test.dart';
import 'generated/packme-test.generated.dart';

TestMessage generateTestMessage() {
    return TestMessage(
        reqId: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
        reqIds: <Uint8List>[
            Uint8List.fromList(<int>[1, 2, 3, 4]),
            Uint8List.fromList(<int>[2, 3, 4, 1]),
            Uint8List.fromList(<int>[3, 4, 1, 2]),
            Uint8List.fromList(<int>[5, 1, 2, 3]),
        ],
        reqInt8: -128,
        reqUint8: 255,
        reqInt16: -32768,
        reqUint16: 65535,
        reqInt32: -2147483648,
        reqUint32: 4294967295,
        reqInt64: -9223372036854775808,
        reqUint64: 9223372036854775807, // Dart int is signed int64 :(
        reqFloat: double.infinity,
        reqDouble: double.maxFinite,
        reqBool: true,
        reqString: "'👍 You're pretty good!",
        reqList: <int>[9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
        reqEnum: TestEnum.two,
        reqNested: NestedObject(
            a: 255,
            b: 'I am nested 😎'
        ),
        reqNestedList: <List<int>>[
            <int>[1],
            <int>[2, 3],
            <int>[4, 5, 6],
            <int>[7, 8, 9, 10],
        ],
        reqInherited: SubObject(
            a: 128,
            b: 'I am inherited from nested 😎',
            c: double.infinity
        ),
        reqInheritedMore: SubSubObject(
            a: 129,
            b: 'I am inherited from sub 😎',
            c: double.negativeInfinity,
            d: 1234567890
        ),
        reqMixedInherited: <NestedObject>[
            SubSubObject(
                a: 100,
                b: '200',
                c: 300,
                d: 400
            ),
            NestedObject(
                a: 1,
                b: '22'
            ),
            SubObject(
                a: 3,
                b: '44',
                c: 5.55
            )
        ],
        optId: Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
        optIds: <Uint8List>[
            Uint8List.fromList(<int>[1, 2, 3, 4]),
            Uint8List.fromList(<int>[2, 3, 4, 1]),
            Uint8List.fromList(<int>[3, 4, 1, 2]),
            Uint8List.fromList(<int>[5, 1, 2, 3]),
        ],
        optInt8: -128,
        optUint8: 255,
        optInt16: -32768,
        optUint16: 65535,
        optInt32: -2147483648,
        optUint32: 4294967295,
        optInt64: -9223372036854775808,
        optUint64: 9223372036854775807, // Dart int is signed int64 :(
        optFloat: double.infinity,
        optDouble: double.maxFinite,
        optBool: true,
        optString: "'👍 You're pretty good!",
        optList: <int>[9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
        optEnum: TestEnum.two,
        optNested: NestedObject(
            a: 255,
            b: 'I am nested 😎'
        ),
        optNestedList: <List<int>>[
            <int>[1],
            <int>[2, 3],
            <int>[4, 5, 6],
            <int>[7, 8, 9, 10],
        ],
        optInherited: SubObject(
            a: 128,
            b: 'I am inherited from nested 😎',
            c: double.infinity
        ),
        optInheritedMore: SubSubObject(
            a: 129,
            b: 'I am inherited from sub 😎',
            c: double.negativeInfinity,
            d: 1234567890
        ),
        optMixedInherited: <NestedObject>[
            SubSubObject(
                a: 100,
                b: '200',
                c: 300,
                d: 400
            ),
            NestedObject(
                a: 1,
                b: '22'
            ),
            SubObject(
                a: 3,
                b: '44',
                c: 5.55
            )
        ]
    );
}

void main() {
    test('PackMe.pack(PackMeMessage message) returns Uint8List', () {
        final PackMe packme = PackMe();
        final Uint8List? data = packme.pack(generateTestMessage());
        expect(data, isA<Uint8List>());
    });

    test('PackMe.unpack(Uint8List data) returns TestMessage', () {
        final PackMe packme = PackMe(onError: (String err, [StackTrace? stack]) {
            print(err);
            if (stack != null) print(stack);
        });
        packme.register(packmeTestMessageFactory);
        final Uint8List? data = packme.pack(generateTestMessage());
        final PackMeMessage? message = packme.unpack(data!);
        expect(message, isA<TestMessage>());
    });

    test('PackMe.unpack(PackMe.pack(message)) returns message', () {
        final PackMe packme = PackMe();
        packme.register(packmeTestMessageFactory);
        final Uint8List? data = packme.pack(generateTestMessage());
        final TestMessage message = packme.unpack(data!)! as TestMessage;
        final TestMessage sample = generateTestMessage();
        expect(message.reqId, equals(sample.reqId));
        expect(message.reqIds, equals(sample.reqIds));
        expect(message.reqInt8, equals(sample.reqInt8));
        expect(message.reqUint8, equals(sample.reqUint8));
        expect(message.reqInt16, equals(sample.reqInt16));
        expect(message.reqUint16, equals(sample.reqUint16));
        expect(message.reqInt32, equals(sample.reqInt32));
        expect(message.reqUint32, equals(sample.reqUint32));
        expect(message.reqInt64, equals(sample.reqInt64));
        expect(message.reqUint64, equals(sample.reqUint64));
        expect(message.reqFloat, equals(sample.reqFloat));
        expect(message.reqDouble, equals(sample.reqDouble));
        expect(message.reqBool, equals(sample.reqBool));
        expect(message.reqString, equals(sample.reqString));
        expect(message.reqList, equals(sample.reqList));
        expect(message.reqEnum, equals(sample.reqEnum));
        expect(message.reqNested.a, equals(sample.reqNested.a));
        expect(message.reqNested.b, equals(sample.reqNested.b));
        expect(message.reqNestedList, equals(sample.reqNestedList));
        expect(message.reqInherited.runtimeType, equals(SubObject));
        expect(message.reqInherited.a, equals(sample.reqInherited.a));
        expect(message.reqInherited.b, equals(sample.reqInherited.b));
        expect(message.reqInherited.c, equals(sample.reqInherited.c));
        expect(message.reqInheritedMore.runtimeType, equals(SubSubObject));
        expect(message.reqInheritedMore.a, equals(sample.reqInheritedMore.a));
        expect(message.reqInheritedMore.b, equals(sample.reqInheritedMore.b));
        expect(message.reqInheritedMore.c, equals(sample.reqInheritedMore.c));
        expect(message.reqInheritedMore.d, equals(sample.reqInheritedMore.d));
        expect(message.reqMixedInherited[0] is SubSubObject, equals(true));
        expect(message.reqMixedInherited[2] is SubObject, equals(true));
        expect(message.optId, equals(sample.optId));
        expect(message.optIds, equals(sample.optIds));
        expect(message.optInt8, equals(sample.optInt8));
        expect(message.optUint8, equals(sample.optUint8));
        expect(message.optInt16, equals(sample.optInt16));
        expect(message.optUint16, equals(sample.optUint16));
        expect(message.optInt32, equals(sample.optInt32));
        expect(message.optUint32, equals(sample.optUint32));
        expect(message.optInt64, equals(sample.optInt64));
        expect(message.optUint64, equals(sample.optUint64));
        expect(message.optFloat, equals(sample.optFloat));
        expect(message.optDouble, equals(sample.optDouble));
        expect(message.optBool, equals(sample.optBool));
        expect(message.optString, equals(sample.optString));
        expect(message.optList, equals(sample.optList));
        expect(message.optEnum, equals(sample.optEnum));
        expect(message.optNested!.a, equals(sample.optNested!.a));
        expect(message.optNested!.b, equals(sample.optNested!.b));
        expect(message.optNestedList, equals(sample.optNestedList));
        expect(message.optInherited.runtimeType, equals(SubObject));
        expect(message.optInherited!.a, equals(sample.optInherited!.a));
        expect(message.optInherited!.b, equals(sample.optInherited!.b));
        expect(message.optInherited!.c, equals(sample.optInherited!.c));
        expect(message.optInheritedMore.runtimeType, equals(SubSubObject));
        expect(message.optInheritedMore!.a, equals(sample.optInheritedMore!.a));
        expect(message.optInheritedMore!.b, equals(sample.optInheritedMore!.b));
        expect(message.optInheritedMore!.c, equals(sample.optInheritedMore!.c));
        expect(message.optInheritedMore!.d, equals(sample.optInheritedMore!.d));
        expect(message.optMixedInherited![0] is SubSubObject, equals(true));
        expect(message.optMixedInherited![2] is SubObject, equals(true));
    });
}