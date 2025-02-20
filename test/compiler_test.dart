import 'package:packme/compiler.dart' as compiler;
import 'package:test/test.dart';
import 'generated/compiler-test.generated.dart';

void main() {
    test('Compiler run check: dart run packme packme generated', () {
        compiler.main(<String>['--test', 'test/packme', 'test/generated']);
    });

    test('compilerTestMessageFactory contains SendInfoMessage, GetDataResponse, GetDataRequest', () {
        expect(compilerTestMessageFactory[511521838], isNotNull);
        expect(compilerTestMessageFactory[160528308], isNotNull);
        expect(compilerTestMessageFactory[845589919], isNotNull);
    });

    test('compilerTestMessageFactory returns proper instances', () {
        expect(compilerTestMessageFactory[511521838]!.call(), isA<SendInfoMessage>());
        expect(compilerTestMessageFactory[160528308]!.call(), isA<GetDataResponse>());
        expect(compilerTestMessageFactory[845589919]!.call(), isA<GetDataRequest>());
    });

    test(r'PackMeMessage.$estimate() returns required buffer length in bytes', () {
        final SendInfoMessage sendInfoMessage = SendInfoMessage(
            id: <int>[2, 4],
            notes: <String>[''],
            version: HalfLifeVersion.two,
            entity: InfoEntity(
                string: 'Alyx',
                value: 19,
                flag: true,
                version: HalfLifeVersion.four
            ),
            subEntity: InfoSubclass(
                string: 'Alyx Vance',
                value: 19,
                flag: false,
                version: HalfLifeVersion.two,
                weight: 1,
                comment: 'Doctor Freeman, I presume?',
            )
        );
        final GetDataRequest getDataRequest = GetDataRequest(id: <int>[1, 7]);
        final GetDataResponse getDataResponse = getDataRequest.$response(items: <GetDataResponseItem>[
            GetDataResponseItem(string: 'impulse', value: 101, version: HalfLifeVersion.one),
            GetDataResponseItem(string: 'impulse', value: 203, version: HalfLifeVersion.one, flag: false),
            GetDataResponseItem(),
            GetDataResponseItem(flag: true),
        ]);
        expect(sendInfoMessage.$estimate(), equals(103));
        expect(getDataResponse.$estimate(), equals(50));
        expect(getDataRequest.$estimate(), equals(15));
    });
}