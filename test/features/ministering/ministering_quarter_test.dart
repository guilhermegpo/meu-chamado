import 'package:flutter_test/flutter_test.dart';
import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';

void main() {
  group('Quarter', () {
    test('mapeia cada mês para o trimestre correto', () {
      const expected = {
        1: 1,
        2: 1,
        3: 1,
        4: 2,
        5: 2,
        6: 2,
        7: 3,
        8: 3,
        9: 3,
        10: 4,
        11: 4,
        12: 4,
      };

      for (final entry in expected.entries) {
        expect(
          Quarter.of(DateTime.utc(2026, entry.key, 15)).number,
          entry.value,
          reason: 'mês ${entry.key}',
        );
      }
    });

    test('trata as viradas de trimestre pelos limites', () {
      expect(Quarter.of(DateTime.utc(2026, 3, 31)), const Quarter(2026, 1));
      expect(Quarter.of(DateTime.utc(2026, 4, 1)), const Quarter(2026, 2));
      expect(Quarter.of(DateTime.utc(2026, 9, 30)), const Quarter(2026, 3));
      expect(Quarter.of(DateTime.utc(2026, 10, 1)), const Quarter(2026, 4));
      expect(Quarter.of(DateTime.utc(2026, 12, 31)), const Quarter(2026, 4));
      expect(Quarter.of(DateTime.utc(2027, 1, 1)), const Quarter(2027, 1));
    });

    test('define janela meio aberta: início inclusivo, fim exclusivo', () {
      const quarter = Quarter(2026, 3);

      expect(quarter.start, DateTime.utc(2026, 7));
      expect(quarter.nextStart, DateTime.utc(2026, 10));

      expect(quarter.contains(DateTime.utc(2026, 7)), isTrue);
      expect(quarter.contains(DateTime.utc(2026, 9, 30)), isTrue);
      expect(quarter.contains(DateTime.utc(2026, 10)), isFalse);
      expect(quarter.contains(DateTime.utc(2026, 6, 30)), isFalse);
    });

    test('o quarto trimestre vira o ano corretamente', () {
      const quarter = Quarter(2026, 4);
      expect(quarter.start, DateTime.utc(2026, 10));
      expect(quarter.nextStart, DateTime.utc(2027));
      expect(quarter.contains(DateTime.utc(2026, 12, 31)), isTrue);
      expect(quarter.contains(DateTime.utc(2027, 1, 1)), isFalse);
    });

    test('rotula em português', () {
      expect(const Quarter(2026, 3).label, '3º trimestre de 2026');
    });
  });

  group('calendarDate', () {
    test('normaliza para meia-noite UTC, descartando a hora', () {
      final late = DateTime(2026, 9, 30, 23, 45);
      expect(calendarDate(late), DateTime.utc(2026, 9, 30));
    });

    test(
      'uma entrevista tarde da noite em 30/09 continua no terceiro trimestre',
      () {
        // Sem a normalização, o fuso do aparelho poderia empurrar o instante
        // para 01/10 em UTC e mover a entrevista de trimestre.
        final recorded = calendarDate(DateTime(2026, 9, 30, 23, 59));
        expect(Quarter.of(recorded), const Quarter(2026, 3));
        expect(const Quarter(2026, 3).contains(recorded), isTrue);
        expect(const Quarter(2026, 4).contains(recorded), isFalse);
      },
    );
  });

  group('QuarterSummary', () {
    test('calcula pendentes e progresso', () {
      const summary = QuarterSummary(
        quarter: Quarter(2026, 3),
        activeCompanionships: 21,
        interviewedCompanionships: 16,
      );

      expect(summary.pending, 5);
      expect(summary.progress, closeTo(16 / 21, 0.0001));
    });

    test('não divide por zero quando não há duplas', () {
      const summary = QuarterSummary(
        quarter: Quarter(2026, 3),
        activeCompanionships: 0,
        interviewedCompanionships: 0,
      );

      expect(summary.pending, 0);
      expect(summary.progress, 0);
    });
  });
}
