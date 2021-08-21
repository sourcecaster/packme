import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:packme/packme.dart';
import 'generated/example.generated.dart';

final Random rand = Random();

String randomString() {
    const String src = 'qwertyuiopasdfghjklzxcvbnm134567890 ';
    final int length = rand.nextInt(20);
    String result = '';
    for (int i = 0; i < length; i++) {
        result += src[rand.nextInt(length)];
    }
    return result;
}

List<int> randomList() {
    final List<int> result = <int>[];
    final int length = rand.nextInt(10);
    for (int i = 0; i < length; i++) {
        result.add(rand.nextInt(256));
    }
    return result;
}

TestMessage randomTextMessage() {
    final TestMessage message = TestMessage(
        reqInt8: rand.nextInt(256) - 128,
        reqUint16: rand.nextInt(65536),
        reqDouble: rand.nextDouble(),
        reqBool: rand.nextBool(),
        reqString: randomString(),
        reqList: randomList(),
        reqEnum: TypeEnum.values[rand.nextInt(TypeEnum.values.length)],
        reqNested: NestedObject(a: rand.nextInt(256), b: randomString()),
        optInt8: rand.nextBool() ? null : rand.nextInt(256) - 128,
        optUint16: rand.nextBool() ? null : rand.nextInt(65536),
        optDouble: rand.nextBool() ? null : rand.nextDouble(),
        optBool: rand.nextBool() ? null : rand.nextBool(),
        optString: rand.nextBool() ? null : randomString(),
        optList: rand.nextBool() ? null : randomList(),
        optEnum: rand.nextBool() ? null : TypeEnum.values[rand.nextInt(TypeEnum.values.length)],
        optNested: rand.nextBool() ? null : NestedObject(a: rand.nextInt(256), b: randomString()),
    );
    return message;
}

void main() {
    final PackMe packer = PackMe(onError: (String error, [StackTrace? stack]) => print(error));

    /// Message Factory has to be registered in order to make it possible to
    /// unpack Uint8List to Message objects.
    packer.register(exampleMessageFactory);

    /// Generate TestMessage (see example.json) with random data.
    final TestMessage message = randomTextMessage();

    /// Pack TestMessage to Uint8List.
    Uint8List packedMessage = packer.pack(message)!;

    /// Unpack Uint8List to TestMessage.
    TestMessage unpackedMessage = packer.unpack(packedMessage)! as TestMessage;

    print('\nSource message:\n$message');
    print('\nUnpacked message:\n$unpackedMessage');
    print('\nRunning performance test in 5 seconds (1 million cycles)...');

    /// Run pack/unpack cycle 1 million times.
    Timer(const Duration(seconds: 5), () {
        final DateTime dt1 = DateTime.now();
        print('Started at: $dt1');
        for (int i = 0; i < 1000000; i++) {
            packedMessage = packer.pack(message)!;
            unpackedMessage = packer.unpack(packedMessage)! as TestMessage;
        }
        final DateTime dt2 = DateTime.now();
        final double delta = (dt2.millisecondsSinceEpoch - dt1.millisecondsSinceEpoch) / 1000;
        print('Finished at: $dt2 and took ${delta.toStringAsFixed(2)} seconds.');
        print('Cycles per second: ${(1000000 / delta).round()}');
    });
}