import 'dart:typed_data';
import 'package:packme/packme.dart';
import 'package:test/test.dart';
import 'generated/packme-test.generated.dart';

TestMessage generateTestMessage() {
    return TestMessage(
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
    );
}

void main() {
    test('PackMe.pack(PackMeMessage message) returns Uint8List', () {
        final PackMe packme = PackMe();
        final Uint8List? data = packme.pack(generateTestMessage());
        expect(data, isA<Uint8List>());
    });

    test('PackMe.unpack(Uint8List data) returns TestMessage', () {
        final PackMe packme = PackMe();
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
    });
}