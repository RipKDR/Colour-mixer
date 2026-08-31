import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

class MixRecipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get pigmentData => text()();
  RealColumn get labL => real()();
  RealColumn get labA => real()();
  RealColumn get labB => real()();
  IntColumn get colorValue => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecipeTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(MixRecipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => text()();
}

class InventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pigmentId => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get line => text().withDefault(const Constant(''))();
  TextColumn get customName => text().withDefault(const Constant(''))();
  RealColumn get pricePerTube => real().withDefault(const Constant(0))();
  RealColumn get tubeSizeMl => real().withDefault(const Constant(37))();
  /// 0.0 = empty, 1.0 = full
  RealColumn get amountLeft => real().withDefault(const Constant(1.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class LessonProgress extends Table {
  TextColumn get lessonId => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  RealColumn get bestDeltaE => real().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {lessonId};
}

@DriftDatabase(tables: [MixRecipes, RecipeTags, InventoryItems, LessonProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(inventoryItems);
            await m.createTable(lessonProgress);
          }
        },
      );

  Future<List<MixRecipe>> getAllRecipes() =>
      (select(mixRecipes)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<MixRecipe> getRecipe(int id) =>
      (select(mixRecipes)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertRecipe(MixRecipesCompanion recipe) =>
      into(mixRecipes).insert(recipe);

  Future<bool> deleteRecipe(int id) =>
      (delete(mixRecipes)..where((t) => t.id.equals(id))).go().then((c) => c > 0);

  Future<int> duplicateRecipe(MixRecipe recipe) => insertRecipe(
        MixRecipesCompanion.insert(
          name: '${recipe.name} (copy)',
          notes: Value(recipe.notes),
          pigmentData: recipe.pigmentData,
          labL: recipe.labL,
          labA: recipe.labA,
          labB: recipe.labB,
          colorValue: recipe.colorValue,
        ),
      );

  Future<List<InventoryItem>> getAllInventory() =>
      (select(inventoryItems)..orderBy([(t) => OrderingTerm.asc(t.customName)]))
          .get();

  Future<int> insertInventory(InventoryItemsCompanion item) =>
      into(inventoryItems).insert(item);

  Future<bool> updateInventory(InventoryItem item) =>
      update(inventoryItems).replace(item);

  Future<bool> deleteInventory(int id) => (delete(inventoryItems)
        ..where((t) => t.id.equals(id)))
      .go()
      .then((c) => c > 0);

  Future<List<LessonProgressData>> getAllLessonProgress() =>
      select(lessonProgress).get();

  Future<void> upsertLessonProgress(LessonProgressCompanion row) =>
      into(lessonProgress).insertOnConflictUpdate(row);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'chromastudio.sqlite'));
    return NativeDatabase(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
