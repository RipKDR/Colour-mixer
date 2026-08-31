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
  TextColumn get pigmentData => text()(); // JSON array of {id, weight}
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

@DriftDatabase(tables: [MixRecipes, RecipeTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
