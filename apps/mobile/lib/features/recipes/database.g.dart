// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MixRecipesTable extends MixRecipes
    with TableInfo<$MixRecipesTable, MixRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MixRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _pigmentDataMeta =
      const VerificationMeta('pigmentData');
  @override
  late final GeneratedColumn<String> pigmentData = GeneratedColumn<String>(
      'pigment_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labLMeta = const VerificationMeta('labL');
  @override
  late final GeneratedColumn<double> labL = GeneratedColumn<double>(
      'lab_l', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _labAMeta = const VerificationMeta('labA');
  @override
  late final GeneratedColumn<double> labA = GeneratedColumn<double>(
      'lab_a', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _labBMeta = const VerificationMeta('labB');
  @override
  late final GeneratedColumn<double> labB = GeneratedColumn<double>(
      'lab_b', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, notes, pigmentData, labL, labA, labB, colorValue, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mix_recipes';
  @override
  VerificationContext validateIntegrity(Insertable<MixRecipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('pigment_data')) {
      context.handle(
          _pigmentDataMeta,
          pigmentData.isAcceptableOrUnknown(
              data['pigment_data']!, _pigmentDataMeta));
    } else if (isInserting) {
      context.missing(_pigmentDataMeta);
    }
    if (data.containsKey('lab_l')) {
      context.handle(
          _labLMeta, labL.isAcceptableOrUnknown(data['lab_l']!, _labLMeta));
    } else if (isInserting) {
      context.missing(_labLMeta);
    }
    if (data.containsKey('lab_a')) {
      context.handle(
          _labAMeta, labA.isAcceptableOrUnknown(data['lab_a']!, _labAMeta));
    } else if (isInserting) {
      context.missing(_labAMeta);
    }
    if (data.containsKey('lab_b')) {
      context.handle(
          _labBMeta, labB.isAcceptableOrUnknown(data['lab_b']!, _labBMeta));
    } else if (isInserting) {
      context.missing(_labBMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MixRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MixRecipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      pigmentData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pigment_data'])!,
      labL: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lab_l'])!,
      labA: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lab_a'])!,
      labB: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lab_b'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MixRecipesTable createAlias(String alias) {
    return $MixRecipesTable(attachedDatabase, alias);
  }
}

class MixRecipe extends DataClass implements Insertable<MixRecipe> {
  final int id;
  final String name;
  final String notes;
  final String pigmentData;
  final double labL;
  final double labA;
  final double labB;
  final int colorValue;
  final DateTime createdAt;
  const MixRecipe(
      {required this.id,
      required this.name,
      required this.notes,
      required this.pigmentData,
      required this.labL,
      required this.labA,
      required this.labB,
      required this.colorValue,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    map['pigment_data'] = Variable<String>(pigmentData);
    map['lab_l'] = Variable<double>(labL);
    map['lab_a'] = Variable<double>(labA);
    map['lab_b'] = Variable<double>(labB);
    map['color_value'] = Variable<int>(colorValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MixRecipesCompanion toCompanion(bool nullToAbsent) {
    return MixRecipesCompanion(
      id: Value(id),
      name: Value(name),
      notes: Value(notes),
      pigmentData: Value(pigmentData),
      labL: Value(labL),
      labA: Value(labA),
      labB: Value(labB),
      colorValue: Value(colorValue),
      createdAt: Value(createdAt),
    );
  }

  factory MixRecipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MixRecipe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      pigmentData: serializer.fromJson<String>(json['pigmentData']),
      labL: serializer.fromJson<double>(json['labL']),
      labA: serializer.fromJson<double>(json['labA']),
      labB: serializer.fromJson<double>(json['labB']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'pigmentData': serializer.toJson<String>(pigmentData),
      'labL': serializer.toJson<double>(labL),
      'labA': serializer.toJson<double>(labA),
      'labB': serializer.toJson<double>(labB),
      'colorValue': serializer.toJson<int>(colorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MixRecipe copyWith(
          {int? id,
          String? name,
          String? notes,
          String? pigmentData,
          double? labL,
          double? labA,
          double? labB,
          int? colorValue,
          DateTime? createdAt}) =>
      MixRecipe(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        pigmentData: pigmentData ?? this.pigmentData,
        labL: labL ?? this.labL,
        labA: labA ?? this.labA,
        labB: labB ?? this.labB,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt ?? this.createdAt,
      );
  MixRecipe copyWithCompanion(MixRecipesCompanion data) {
    return MixRecipe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      pigmentData:
          data.pigmentData.present ? data.pigmentData.value : this.pigmentData,
      labL: data.labL.present ? data.labL.value : this.labL,
      labA: data.labA.present ? data.labA.value : this.labA,
      labB: data.labB.present ? data.labB.value : this.labB,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MixRecipe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('pigmentData: $pigmentData, ')
          ..write('labL: $labL, ')
          ..write('labA: $labA, ')
          ..write('labB: $labB, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, notes, pigmentData, labL, labA, labB, colorValue, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MixRecipe &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.pigmentData == this.pigmentData &&
          other.labL == this.labL &&
          other.labA == this.labA &&
          other.labB == this.labB &&
          other.colorValue == this.colorValue &&
          other.createdAt == this.createdAt);
}

class MixRecipesCompanion extends UpdateCompanion<MixRecipe> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<String> pigmentData;
  final Value<double> labL;
  final Value<double> labA;
  final Value<double> labB;
  final Value<int> colorValue;
  final Value<DateTime> createdAt;
  const MixRecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.pigmentData = const Value.absent(),
    this.labL = const Value.absent(),
    this.labA = const Value.absent(),
    this.labB = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MixRecipesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
    required String pigmentData,
    required double labL,
    required double labA,
    required double labB,
    required int colorValue,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        pigmentData = Value(pigmentData),
        labL = Value(labL),
        labA = Value(labA),
        labB = Value(labB),
        colorValue = Value(colorValue);
  static Insertable<MixRecipe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<String>? pigmentData,
    Expression<double>? labL,
    Expression<double>? labA,
    Expression<double>? labB,
    Expression<int>? colorValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (pigmentData != null) 'pigment_data': pigmentData,
      if (labL != null) 'lab_l': labL,
      if (labA != null) 'lab_a': labA,
      if (labB != null) 'lab_b': labB,
      if (colorValue != null) 'color_value': colorValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MixRecipesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? notes,
      Value<String>? pigmentData,
      Value<double>? labL,
      Value<double>? labA,
      Value<double>? labB,
      Value<int>? colorValue,
      Value<DateTime>? createdAt}) {
    return MixRecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      pigmentData: pigmentData ?? this.pigmentData,
      labL: labL ?? this.labL,
      labA: labA ?? this.labA,
      labB: labB ?? this.labB,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (pigmentData.present) {
      map['pigment_data'] = Variable<String>(pigmentData.value);
    }
    if (labL.present) {
      map['lab_l'] = Variable<double>(labL.value);
    }
    if (labA.present) {
      map['lab_a'] = Variable<double>(labA.value);
    }
    if (labB.present) {
      map['lab_b'] = Variable<double>(labB.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MixRecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('pigmentData: $pigmentData, ')
          ..write('labL: $labL, ')
          ..write('labA: $labA, ')
          ..write('labB: $labB, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecipeTagsTable extends RecipeTags
    with TableInfo<$RecipeTagsTable, RecipeTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES mix_recipes (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_tags';
  @override
  VerificationContext validateIntegrity(Insertable<RecipeTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_id'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
    );
  }

  @override
  $RecipeTagsTable createAlias(String alias) {
    return $RecipeTagsTable(attachedDatabase, alias);
  }
}

class RecipeTag extends DataClass implements Insertable<RecipeTag> {
  final int id;
  final int recipeId;
  final String tag;
  const RecipeTag(
      {required this.id, required this.recipeId, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  RecipeTagsCompanion toCompanion(bool nullToAbsent) {
    return RecipeTagsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      tag: Value(tag),
    );
  }

  factory RecipeTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeTag(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  RecipeTag copyWith({int? id, int? recipeId, String? tag}) => RecipeTag(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        tag: tag ?? this.tag,
      );
  RecipeTag copyWithCompanion(RecipeTagsCompanion data) {
    return RecipeTag(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTag(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeTag &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.tag == this.tag);
}

class RecipeTagsCompanion extends UpdateCompanion<RecipeTag> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<String> tag;
  const RecipeTagsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.tag = const Value.absent(),
  });
  RecipeTagsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required String tag,
  })  : recipeId = Value(recipeId),
        tag = Value(tag);
  static Insertable<RecipeTag> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (tag != null) 'tag': tag,
    });
  }

  RecipeTagsCompanion copyWith(
      {Value<int>? id, Value<int>? recipeId, Value<String>? tag}) {
    return RecipeTagsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTagsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MixRecipesTable mixRecipes = $MixRecipesTable(this);
  late final $RecipeTagsTable recipeTags = $RecipeTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [mixRecipes, recipeTags];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('mix_recipes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('recipe_tags', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$MixRecipesTableCreateCompanionBuilder = MixRecipesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> notes,
  required String pigmentData,
  required double labL,
  required double labA,
  required double labB,
  required int colorValue,
  Value<DateTime> createdAt,
});
typedef $$MixRecipesTableUpdateCompanionBuilder = MixRecipesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> notes,
  Value<String> pigmentData,
  Value<double> labL,
  Value<double> labA,
  Value<double> labB,
  Value<int> colorValue,
  Value<DateTime> createdAt,
});

final class $$MixRecipesTableReferences
    extends BaseReferences<_$AppDatabase, $MixRecipesTable, MixRecipe> {
  $$MixRecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeTagsTable, List<RecipeTag>>
      _recipeTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.recipeTags,
          aliasName:
              $_aliasNameGenerator(db.mixRecipes.id, db.recipeTags.recipeId));

  $$RecipeTagsTableProcessedTableManager get recipeTagsRefs {
    final manager = $$RecipeTagsTableTableManager($_db, $_db.recipeTags)
        .filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MixRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $MixRecipesTable> {
  $$MixRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pigmentData => $composableBuilder(
      column: $table.pigmentData, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get labL => $composableBuilder(
      column: $table.labL, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get labA => $composableBuilder(
      column: $table.labA, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get labB => $composableBuilder(
      column: $table.labB, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> recipeTagsRefs(
      Expression<bool> Function($$RecipeTagsTableFilterComposer f) f) {
    final $$RecipeTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recipeTags,
        getReferencedColumn: (t) => t.recipeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecipeTagsTableFilterComposer(
              $db: $db,
              $table: $db.recipeTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MixRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $MixRecipesTable> {
  $$MixRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pigmentData => $composableBuilder(
      column: $table.pigmentData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get labL => $composableBuilder(
      column: $table.labL, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get labA => $composableBuilder(
      column: $table.labA, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get labB => $composableBuilder(
      column: $table.labB, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MixRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MixRecipesTable> {
  $$MixRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get pigmentData => $composableBuilder(
      column: $table.pigmentData, builder: (column) => column);

  GeneratedColumn<double> get labL =>
      $composableBuilder(column: $table.labL, builder: (column) => column);

  GeneratedColumn<double> get labA =>
      $composableBuilder(column: $table.labA, builder: (column) => column);

  GeneratedColumn<double> get labB =>
      $composableBuilder(column: $table.labB, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recipeTagsRefs<T extends Object>(
      Expression<T> Function($$RecipeTagsTableAnnotationComposer a) f) {
    final $$RecipeTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recipeTags,
        getReferencedColumn: (t) => t.recipeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecipeTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.recipeTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MixRecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MixRecipesTable,
    MixRecipe,
    $$MixRecipesTableFilterComposer,
    $$MixRecipesTableOrderingComposer,
    $$MixRecipesTableAnnotationComposer,
    $$MixRecipesTableCreateCompanionBuilder,
    $$MixRecipesTableUpdateCompanionBuilder,
    (MixRecipe, $$MixRecipesTableReferences),
    MixRecipe,
    PrefetchHooks Function({bool recipeTagsRefs})> {
  $$MixRecipesTableTableManager(_$AppDatabase db, $MixRecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MixRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MixRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MixRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> pigmentData = const Value.absent(),
            Value<double> labL = const Value.absent(),
            Value<double> labA = const Value.absent(),
            Value<double> labB = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MixRecipesCompanion(
            id: id,
            name: name,
            notes: notes,
            pigmentData: pigmentData,
            labL: labL,
            labA: labA,
            labB: labB,
            colorValue: colorValue,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> notes = const Value.absent(),
            required String pigmentData,
            required double labL,
            required double labA,
            required double labB,
            required int colorValue,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MixRecipesCompanion.insert(
            id: id,
            name: name,
            notes: notes,
            pigmentData: pigmentData,
            labL: labL,
            labA: labA,
            labB: labB,
            colorValue: colorValue,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MixRecipesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recipeTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (recipeTagsRefs) db.recipeTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recipeTagsRefs)
                    await $_getPrefetchedData<MixRecipe, $MixRecipesTable,
                            RecipeTag>(
                        currentTable: table,
                        referencedTable: $$MixRecipesTableReferences
                            ._recipeTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MixRecipesTableReferences(db, table, p0)
                                .recipeTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.recipeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MixRecipesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MixRecipesTable,
    MixRecipe,
    $$MixRecipesTableFilterComposer,
    $$MixRecipesTableOrderingComposer,
    $$MixRecipesTableAnnotationComposer,
    $$MixRecipesTableCreateCompanionBuilder,
    $$MixRecipesTableUpdateCompanionBuilder,
    (MixRecipe, $$MixRecipesTableReferences),
    MixRecipe,
    PrefetchHooks Function({bool recipeTagsRefs})>;
typedef $$RecipeTagsTableCreateCompanionBuilder = RecipeTagsCompanion Function({
  Value<int> id,
  required int recipeId,
  required String tag,
});
typedef $$RecipeTagsTableUpdateCompanionBuilder = RecipeTagsCompanion Function({
  Value<int> id,
  Value<int> recipeId,
  Value<String> tag,
});

final class $$RecipeTagsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeTagsTable, RecipeTag> {
  $$RecipeTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MixRecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.mixRecipes.createAlias(
          $_aliasNameGenerator(db.recipeTags.recipeId, db.mixRecipes.id));

  $$MixRecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$MixRecipesTableTableManager($_db, $_db.mixRecipes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecipeTagsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  $$MixRecipesTableFilterComposer get recipeId {
    final $$MixRecipesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recipeId,
        referencedTable: $db.mixRecipes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MixRecipesTableFilterComposer(
              $db: $db,
              $table: $db.mixRecipes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecipeTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  $$MixRecipesTableOrderingComposer get recipeId {
    final $$MixRecipesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recipeId,
        referencedTable: $db.mixRecipes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MixRecipesTableOrderingComposer(
              $db: $db,
              $table: $db.mixRecipes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecipeTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  $$MixRecipesTableAnnotationComposer get recipeId {
    final $$MixRecipesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recipeId,
        referencedTable: $db.mixRecipes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MixRecipesTableAnnotationComposer(
              $db: $db,
              $table: $db.mixRecipes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecipeTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipeTagsTable,
    RecipeTag,
    $$RecipeTagsTableFilterComposer,
    $$RecipeTagsTableOrderingComposer,
    $$RecipeTagsTableAnnotationComposer,
    $$RecipeTagsTableCreateCompanionBuilder,
    $$RecipeTagsTableUpdateCompanionBuilder,
    (RecipeTag, $$RecipeTagsTableReferences),
    RecipeTag,
    PrefetchHooks Function({bool recipeId})> {
  $$RecipeTagsTableTableManager(_$AppDatabase db, $RecipeTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<String> tag = const Value.absent(),
          }) =>
              RecipeTagsCompanion(
            id: id,
            recipeId: recipeId,
            tag: tag,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int recipeId,
            required String tag,
          }) =>
              RecipeTagsCompanion.insert(
            id: id,
            recipeId: recipeId,
            tag: tag,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecipeTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (recipeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recipeId,
                    referencedTable:
                        $$RecipeTagsTableReferences._recipeIdTable(db),
                    referencedColumn:
                        $$RecipeTagsTableReferences._recipeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecipeTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecipeTagsTable,
    RecipeTag,
    $$RecipeTagsTableFilterComposer,
    $$RecipeTagsTableOrderingComposer,
    $$RecipeTagsTableAnnotationComposer,
    $$RecipeTagsTableCreateCompanionBuilder,
    $$RecipeTagsTableUpdateCompanionBuilder,
    (RecipeTag, $$RecipeTagsTableReferences),
    RecipeTag,
    PrefetchHooks Function({bool recipeId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MixRecipesTableTableManager get mixRecipes =>
      $$MixRecipesTableTableManager(_db, _db.mixRecipes);
  $$RecipeTagsTableTableManager get recipeTags =>
      $$RecipeTagsTableTableManager(_db, _db.recipeTags);
}
