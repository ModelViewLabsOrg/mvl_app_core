import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';

void main() {
  group('DateTime Extension Tests', () {
    setUpAll(() {
      WidgetsFlutterBinding.ensureInitialized();
    });

    group('English Locale (en)', () {
      setUpAll(() async {
        await initializeDateFormatting('en');
        Intl.defaultLocale = 'en';
        await Jiffy.setLocale('en');
      });
      test('formatDate returns correct date format', () {
        final dt = DateTime(2023, 10, 26);

        expect(dt.mmm(), 'Oct');
        expect(dt.mmmm(), 'October');
        expect(dt.eee(), 'Thu');
        expect(dt.eeee(), 'Thursday');
        expect(dt.yMMMM(), 'October 2023');
        expect(dt.mmmmd(), 'October 26');
        expect(dt.dateWithDay(), 'Thu, oct 26');
        expect(dt.mmmed(), 'Thu, oct 26');
        expect(dt.dateFull(), 'Oct 26, 2023');
        expect(dt.dateFullShort(), '10/26/2023');
      });
    });

    group('Portuguese (Brazil) Locale (pt-br)', () {
      setUpAll(() async {
        await initializeDateFormatting('pt-br');
        Intl.defaultLocale = 'pt-br';
        await Jiffy.setLocale('pt-br');
      });

      test('formatDate returns correct date format', () {
        final dt = DateTime(2023, 10, 26);
        expect(dt.mmm(), 'Out.');
        expect(dt.mmmm(), 'Outubro');
        expect(dt.eee(), 'Qui.');
        expect(dt.eeee(), 'Quinta-feira');
        expect(dt.yMMMM(), 'Outubro de 2023');
        expect(dt.mmmmd(), '26 de outubro');
        expect(dt.dateWithDay(), 'Qui., 26 de out.');
        expect(dt.mmmed(), 'Qui., 26 de out.');
        expect(dt.dateFull(), '26 de out. de 2023');
        expect(dt.dateFullShort(), '26/10/2023');
      });
    });
  });
}
