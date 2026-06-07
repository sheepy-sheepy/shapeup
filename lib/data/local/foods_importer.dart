import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:shapeup/data/local/database.dart';

class FoodsImporter {
  FoodsImporter(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  Future<void> importIfNeeded() async {
    final countExp = db.foods.id.count();
    final query = db.selectOnly(db.foods)..addColumns([countExp]);
    final row = await query.getSingle();
    final total = row.read(countExp) ?? 0;

    if (total > 0) return;

    final raw = (await rootBundle.loadString('assets/foods.csv'))
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final rows = const CsvToListConverter().convert(raw, eol: '\n');

    if (rows.isEmpty) return;

    await db.batch((batch) {
      for (var i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length < 5) continue;

        batch.insert(
          db.foods,
          FoodsCompanion.insert(
            id: _uuid.v4(),
            name: r[0].toString(),
            calories: double.parse(r[1].toString()),
            proteins: double.parse(r[2].toString()),
            fats: double.parse(r[3].toString()),
            carbs: double.parse(r[4].toString()),
          ),
        );
      }
    });
  }
}
