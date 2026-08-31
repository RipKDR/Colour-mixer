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

class $InventoryItemsTable extends InventoryItems
    with TableInfo<$InventoryItemsTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pigmentIdMeta =
      const VerificationMeta('pigmentId');
  @override
  late final GeneratedColumn<String> pigmentId = GeneratedColumn<String>(
      'pigment_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lineMeta = const VerificationMeta('line');
  @override
  late final GeneratedColumn<String> line = GeneratedColumn<String>(
      'line', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _customNameMeta =
      const VerificationMeta('customName');
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
      'custom_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _pricePerTubeMeta =
      const VerificationMeta('pricePerTube');
  @override
  late final GeneratedColumn<double> pricePerTube = GeneratedColumn<double>(
      'price_per_tube', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tubeSizeMlMeta =
      const VerificationMeta('tubeSizeMl');
  @override
  late final GeneratedColumn<double> tubeSizeMl = GeneratedColumn<double>(
      'tube_size_ml', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(37));
  static const VerificationMeta _amountLeftMeta =
      const VerificationMeta('amountLeft');
  @override
  late final GeneratedColumn<double> amountLeft = GeneratedColumn<double>(
      'amount_left', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        pigmentId,
        brand,
        line,
        customName,
        pricePerTube,
        tubeSizeMl,
        amountLeft,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_items';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pigment_id')) {
      context.handle(_pigmentIdMeta,
          pigmentId.isAcceptableOrUnknown(data['pigment_id']!, _pigmentIdMeta));
    } else if (isInserting) {
      context.missing(_pigmentIdMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('line')) {
      context.handle(
          _lineMeta, line.isAcceptableOrUnknown(data['line']!, _lineMeta));
    }
    if (data.containsKey('custom_name')) {
      context.handle(
          _customNameMeta,
          customName.isAcceptableOrUnknown(
              data['custom_name']!, _customNameMeta));
    }
    if (data.containsKey('price_per_tube')) {
      context.handle(
          _pricePerTubeMeta,
          pricePerTube.isAcceptableOrUnknown(
              data['price_per_tube']!, _pricePerTubeMeta));
    }
    if (data.containsKey('tube_size_ml')) {
      context.handle(
          _tubeSizeMlMeta,
          tubeSizeMl.isAcceptableOrUnknown(
              data['tube_size_ml']!, _tubeSizeMlMeta));
    }
    if (data.containsKey('amount_left')) {
      context.handle(
          _amountLeftMeta,
          amountLeft.isAcceptableOrUnknown(
              data['amount_left']!, _amountLeftMeta));
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
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pigmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pigment_id'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      line: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line'])!,
      customName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_name'])!,
      pricePerTube: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_per_tube'])!,
      tubeSizeMl: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tube_size_ml'])!,
      amountLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_left'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryItemsTable createAlias(String alias) {
    return $InventoryItemsTable(attachedDatabase, alias);
  }
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  final int id;
  final String pigmentId;
  final String brand;
  final String line;
  final String customName;
  final double pricePerTube;
  final double tubeSizeMl;

  /// 0.0 = empty, 1.0 = full
  final double amountLeft;
  final DateTime createdAt;
  const InventoryItem(
      {required this.id,
      required this.pigmentId,
      required this.brand,
      required this.line,
      required this.customName,
      required this.pricePerTube,
      required this.tubeSizeMl,
      required this.amountLeft,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pigment_id'] = Variable<String>(pigmentId);
    map['brand'] = Variable<String>(brand);
    map['line'] = Variable<String>(line);
    map['custom_name'] = Variable<String>(customName);
    map['price_per_tube'] = Variable<double>(pricePerTube);
    map['tube_size_ml'] = Variable<double>(tubeSizeMl);
    map['amount_left'] = Variable<double>(amountLeft);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return InventoryItemsCompanion(
      id: Value(id),
      pigmentId: Value(pigmentId),
      brand: Value(brand),
      line: Value(line),
      customName: Value(customName),
      pricePerTube: Value(pricePerTube),
      tubeSizeMl: Value(tubeSizeMl),
      amountLeft: Value(amountLeft),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      id: serializer.fromJson<int>(json['id']),
      pigmentId: serializer.fromJson<String>(json['pigmentId']),
      brand: serializer.fromJson<String>(json['brand']),
      line: serializer.fromJson<String>(json['line']),
      customName: serializer.fromJson<String>(json['customName']),
      pricePerTube: serializer.fromJson<double>(json['pricePerTube']),
      tubeSizeMl: serializer.fromJson<double>(json['tubeSizeMl']),
      amountLeft: serializer.fromJson<double>(json['amountLeft']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pigmentId': serializer.toJson<String>(pigmentId),
      'brand': serializer.toJson<String>(brand),
      'line': serializer.toJson<String>(line),
      'customName': serializer.toJson<String>(customName),
      'pricePerTube': serializer.toJson<double>(pricePerTube),
      'tubeSizeMl': serializer.toJson<double>(tubeSizeMl),
      'amountLeft': serializer.toJson<double>(amountLeft),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryItem copyWith(
          {int? id,
          String? pigmentId,
          String? brand,
          String? line,
          String? customName,
          double? pricePerTube,
          double? tubeSizeMl,
          double? amountLeft,
          DateTime? createdAt}) =>
      InventoryItem(
        id: id ?? this.id,
        pigmentId: pigmentId ?? this.pigmentId,
        brand: brand ?? this.brand,
        line: line ?? this.line,
        customName: customName ?? this.customName,
        pricePerTube: pricePerTube ?? this.pricePerTube,
        tubeSizeMl: tubeSizeMl ?? this.tubeSizeMl,
        amountLeft: amountLeft ?? this.amountLeft,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryItem copyWithCompanion(InventoryItemsCompanion data) {
    return InventoryItem(
      id: data.id.present ? data.id.value : this.id,
      pigmentId: data.pigmentId.present ? data.pigmentId.value : this.pigmentId,
      brand: data.brand.present ? data.brand.value : this.brand,
      line: data.line.present ? data.line.value : this.line,
      customName:
          data.customName.present ? data.customName.value : this.customName,
      pricePerTube: data.pricePerTube.present
          ? data.pricePerTube.value
          : this.pricePerTube,
      tubeSizeMl:
          data.tubeSizeMl.present ? data.tubeSizeMl.value : this.tubeSizeMl,
      amountLeft:
          data.amountLeft.present ? data.amountLeft.value : this.amountLeft,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('id: $id, ')
          ..write('pigmentId: $pigmentId, ')
          ..write('brand: $brand, ')
          ..write('line: $line, ')
          ..write('customName: $customName, ')
          ..write('pricePerTube: $pricePerTube, ')
          ..write('tubeSizeMl: $tubeSizeMl, ')
          ..write('amountLeft: $amountLeft, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pigmentId, brand, line, customName,
      pricePerTube, tubeSizeMl, amountLeft, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.id == this.id &&
          other.pigmentId == this.pigmentId &&
          other.brand == this.brand &&
          other.line == this.line &&
          other.customName == this.customName &&
          other.pricePerTube == this.pricePerTube &&
          other.tubeSizeMl == this.tubeSizeMl &&
          other.amountLeft == this.amountLeft &&
          other.createdAt == this.createdAt);
}

class InventoryItemsCompanion extends UpdateCompanion<InventoryItem> {
  final Value<int> id;
  final Value<String> pigmentId;
  final Value<String> brand;
  final Value<String> line;
  final Value<String> customName;
  final Value<double> pricePerTube;
  final Value<double> tubeSizeMl;
  final Value<double> amountLeft;
  final Value<DateTime> createdAt;
  const InventoryItemsCompanion({
    this.id = const Value.absent(),
    this.pigmentId = const Value.absent(),
    this.brand = const Value.absent(),
    this.line = const Value.absent(),
    this.customName = const Value.absent(),
    this.pricePerTube = const Value.absent(),
    this.tubeSizeMl = const Value.absent(),
    this.amountLeft = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String pigmentId,
    this.brand = const Value.absent(),
    this.line = const Value.absent(),
    this.customName = const Value.absent(),
    this.pricePerTube = const Value.absent(),
    this.tubeSizeMl = const Value.absent(),
    this.amountLeft = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : pigmentId = Value(pigmentId);
  static Insertable<InventoryItem> custom({
    Expression<int>? id,
    Expression<String>? pigmentId,
    Expression<String>? brand,
    Expression<String>? line,
    Expression<String>? customName,
    Expression<double>? pricePerTube,
    Expression<double>? tubeSizeMl,
    Expression<double>? amountLeft,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pigmentId != null) 'pigment_id': pigmentId,
      if (brand != null) 'brand': brand,
      if (line != null) 'line': line,
      if (customName != null) 'custom_name': customName,
      if (pricePerTube != null) 'price_per_tube': pricePerTube,
      if (tubeSizeMl != null) 'tube_size_ml': tubeSizeMl,
      if (amountLeft != null) 'amount_left': amountLeft,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InventoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? pigmentId,
      Value<String>? brand,
      Value<String>? line,
      Value<String>? customName,
      Value<double>? pricePerTube,
      Value<double>? tubeSizeMl,
      Value<double>? amountLeft,
      Value<DateTime>? createdAt}) {
    return InventoryItemsCompanion(
      id: id ?? this.id,
      pigmentId: pigmentId ?? this.pigmentId,
      brand: brand ?? this.brand,
      line: line ?? this.line,
      customName: customName ?? this.customName,
      pricePerTube: pricePerTube ?? this.pricePerTube,
      tubeSizeMl: tubeSizeMl ?? this.tubeSizeMl,
      amountLeft: amountLeft ?? this.amountLeft,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pigmentId.present) {
      map['pigment_id'] = Variable<String>(pigmentId.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (line.present) {
      map['line'] = Variable<String>(line.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (pricePerTube.present) {
      map['price_per_tube'] = Variable<double>(pricePerTube.value);
    }
    if (tubeSizeMl.present) {
      map['tube_size_ml'] = Variable<double>(tubeSizeMl.value);
    }
    if (amountLeft.present) {
      map['amount_left'] = Variable<double>(amountLeft.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('pigmentId: $pigmentId, ')
          ..write('brand: $brand, ')
          ..write('line: $line, ')
          ..write('customName: $customName, ')
          ..write('pricePerTube: $pricePerTube, ')
          ..write('tubeSizeMl: $tubeSizeMl, ')
          ..write('amountLeft: $amountLeft, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressTable extends LessonProgress
    with TableInfo<$LessonProgressTable, LessonProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta =
      const VerificationMeta('lessonId');
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
      'lesson_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _bestDeltaEMeta =
      const VerificationMeta('bestDeltaE');
  @override
  late final GeneratedColumn<double> bestDeltaE = GeneratedColumn<double>(
      'best_delta_e', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [lessonId, completed, bestDeltaE, attempts];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  VerificationContext validateIntegrity(Insertable<LessonProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(_lessonIdMeta,
          lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta));
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('best_delta_e')) {
      context.handle(
          _bestDeltaEMeta,
          bestDeltaE.isAcceptableOrUnknown(
              data['best_delta_e']!, _bestDeltaEMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  LessonProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressData(
      lessonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lesson_id'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      bestDeltaE: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}best_delta_e']),
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }
}

class LessonProgressData extends DataClass
    implements Insertable<LessonProgressData> {
  final String lessonId;
  final bool completed;
  final double? bestDeltaE;
  final int attempts;
  const LessonProgressData(
      {required this.lessonId,
      required this.completed,
      this.bestDeltaE,
      required this.attempts});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || bestDeltaE != null) {
      map['best_delta_e'] = Variable<double>(bestDeltaE);
    }
    map['attempts'] = Variable<int>(attempts);
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      lessonId: Value(lessonId),
      completed: Value(completed),
      bestDeltaE: bestDeltaE == null && nullToAbsent
          ? const Value.absent()
          : Value(bestDeltaE),
      attempts: Value(attempts),
    );
  }

  factory LessonProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressData(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      completed: serializer.fromJson<bool>(json['completed']),
      bestDeltaE: serializer.fromJson<double?>(json['bestDeltaE']),
      attempts: serializer.fromJson<int>(json['attempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'completed': serializer.toJson<bool>(completed),
      'bestDeltaE': serializer.toJson<double?>(bestDeltaE),
      'attempts': serializer.toJson<int>(attempts),
    };
  }

  LessonProgressData copyWith(
          {String? lessonId,
          bool? completed,
          Value<double?> bestDeltaE = const Value.absent(),
          int? attempts}) =>
      LessonProgressData(
        lessonId: lessonId ?? this.lessonId,
        completed: completed ?? this.completed,
        bestDeltaE: bestDeltaE.present ? bestDeltaE.value : this.bestDeltaE,
        attempts: attempts ?? this.attempts,
      );
  LessonProgressData copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressData(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      completed: data.completed.present ? data.completed.value : this.completed,
      bestDeltaE:
          data.bestDeltaE.present ? data.bestDeltaE.value : this.bestDeltaE,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressData(')
          ..write('lessonId: $lessonId, ')
          ..write('completed: $completed, ')
          ..write('bestDeltaE: $bestDeltaE, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lessonId, completed, bestDeltaE, attempts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressData &&
          other.lessonId == this.lessonId &&
          other.completed == this.completed &&
          other.bestDeltaE == this.bestDeltaE &&
          other.attempts == this.attempts);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressData> {
  final Value<String> lessonId;
  final Value<bool> completed;
  final Value<double?> bestDeltaE;
  final Value<int> attempts;
  final Value<int> rowid;
  const LessonProgressCompanion({
    this.lessonId = const Value.absent(),
    this.completed = const Value.absent(),
    this.bestDeltaE = const Value.absent(),
    this.attempts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    required String lessonId,
    this.completed = const Value.absent(),
    this.bestDeltaE = const Value.absent(),
    this.attempts = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId);
  static Insertable<LessonProgressData> custom({
    Expression<String>? lessonId,
    Expression<bool>? completed,
    Expression<double>? bestDeltaE,
    Expression<int>? attempts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (completed != null) 'completed': completed,
      if (bestDeltaE != null) 'best_delta_e': bestDeltaE,
      if (attempts != null) 'attempts': attempts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressCompanion copyWith(
      {Value<String>? lessonId,
      Value<bool>? completed,
      Value<double?>? bestDeltaE,
      Value<int>? attempts,
      Value<int>? rowid}) {
    return LessonProgressCompanion(
      lessonId: lessonId ?? this.lessonId,
      completed: completed ?? this.completed,
      bestDeltaE: bestDeltaE ?? this.bestDeltaE,
      attempts: attempts ?? this.attempts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (bestDeltaE.present) {
      map['best_delta_e'] = Variable<double>(bestDeltaE.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('completed: $completed, ')
          ..write('bestDeltaE: $bestDeltaE, ')
          ..write('attempts: $attempts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MixRecipesTable mixRecipes = $MixRecipesTable(this);
  late final $RecipeTagsTable recipeTags = $RecipeTagsTable(this);
  late final $InventoryItemsTable inventoryItems = $InventoryItemsTable(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [mixRecipes, recipeTags, inventoryItems, lessonProgress];
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
typedef $$InventoryItemsTableCreateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<int> id,
  required String pigmentId,
  Value<String> brand,
  Value<String> line,
  Value<String> customName,
  Value<double> pricePerTube,
  Value<double> tubeSizeMl,
  Value<double> amountLeft,
  Value<DateTime> createdAt,
});
typedef $$InventoryItemsTableUpdateCompanionBuilder = InventoryItemsCompanion
    Function({
  Value<int> id,
  Value<String> pigmentId,
  Value<String> brand,
  Value<String> line,
  Value<String> customName,
  Value<double> pricePerTube,
  Value<double> tubeSizeMl,
  Value<double> amountLeft,
  Value<DateTime> createdAt,
});

class $$InventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pigmentId => $composableBuilder(
      column: $table.pigmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get line => $composableBuilder(
      column: $table.line, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerTube => $composableBuilder(
      column: $table.pricePerTube, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tubeSizeMl => $composableBuilder(
      column: $table.tubeSizeMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountLeft => $composableBuilder(
      column: $table.amountLeft, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pigmentId => $composableBuilder(
      column: $table.pigmentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get line => $composableBuilder(
      column: $table.line, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerTube => $composableBuilder(
      column: $table.pricePerTube,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tubeSizeMl => $composableBuilder(
      column: $table.tubeSizeMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountLeft => $composableBuilder(
      column: $table.amountLeft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryItemsTable> {
  $$InventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pigmentId =>
      $composableBuilder(column: $table.pigmentId, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get line =>
      $composableBuilder(column: $table.line, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => column);

  GeneratedColumn<double> get pricePerTube => $composableBuilder(
      column: $table.pricePerTube, builder: (column) => column);

  GeneratedColumn<double> get tubeSizeMl => $composableBuilder(
      column: $table.tubeSizeMl, builder: (column) => column);

  GeneratedColumn<double> get amountLeft => $composableBuilder(
      column: $table.amountLeft, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (
      InventoryItem,
      BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem>
    ),
    InventoryItem,
    PrefetchHooks Function()> {
  $$InventoryItemsTableTableManager(
      _$AppDatabase db, $InventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> pigmentId = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> line = const Value.absent(),
            Value<String> customName = const Value.absent(),
            Value<double> pricePerTube = const Value.absent(),
            Value<double> tubeSizeMl = const Value.absent(),
            Value<double> amountLeft = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryItemsCompanion(
            id: id,
            pigmentId: pigmentId,
            brand: brand,
            line: line,
            customName: customName,
            pricePerTube: pricePerTube,
            tubeSizeMl: tubeSizeMl,
            amountLeft: amountLeft,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String pigmentId,
            Value<String> brand = const Value.absent(),
            Value<String> line = const Value.absent(),
            Value<String> customName = const Value.absent(),
            Value<double> pricePerTube = const Value.absent(),
            Value<double> tubeSizeMl = const Value.absent(),
            Value<double> amountLeft = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryItemsCompanion.insert(
            id: id,
            pigmentId: pigmentId,
            brand: brand,
            line: line,
            customName: customName,
            pricePerTube: pricePerTube,
            tubeSizeMl: tubeSizeMl,
            amountLeft: amountLeft,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventoryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryItemsTable,
    InventoryItem,
    $$InventoryItemsTableFilterComposer,
    $$InventoryItemsTableOrderingComposer,
    $$InventoryItemsTableAnnotationComposer,
    $$InventoryItemsTableCreateCompanionBuilder,
    $$InventoryItemsTableUpdateCompanionBuilder,
    (
      InventoryItem,
      BaseReferences<_$AppDatabase, $InventoryItemsTable, InventoryItem>
    ),
    InventoryItem,
    PrefetchHooks Function()>;
typedef $$LessonProgressTableCreateCompanionBuilder = LessonProgressCompanion
    Function({
  required String lessonId,
  Value<bool> completed,
  Value<double?> bestDeltaE,
  Value<int> attempts,
  Value<int> rowid,
});
typedef $$LessonProgressTableUpdateCompanionBuilder = LessonProgressCompanion
    Function({
  Value<String> lessonId,
  Value<bool> completed,
  Value<double?> bestDeltaE,
  Value<int> attempts,
  Value<int> rowid,
});

class $$LessonProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
      column: $table.lessonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bestDeltaE => $composableBuilder(
      column: $table.bestDeltaE, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));
}

class $$LessonProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
      column: $table.lessonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bestDeltaE => $composableBuilder(
      column: $table.bestDeltaE, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));
}

class $$LessonProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<double> get bestDeltaE => $composableBuilder(
      column: $table.bestDeltaE, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);
}

class $$LessonProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LessonProgressTable,
    LessonProgressData,
    $$LessonProgressTableFilterComposer,
    $$LessonProgressTableOrderingComposer,
    $$LessonProgressTableAnnotationComposer,
    $$LessonProgressTableCreateCompanionBuilder,
    $$LessonProgressTableUpdateCompanionBuilder,
    (
      LessonProgressData,
      BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>
    ),
    LessonProgressData,
    PrefetchHooks Function()> {
  $$LessonProgressTableTableManager(
      _$AppDatabase db, $LessonProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> lessonId = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<double?> bestDeltaE = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonProgressCompanion(
            lessonId: lessonId,
            completed: completed,
            bestDeltaE: bestDeltaE,
            attempts: attempts,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String lessonId,
            Value<bool> completed = const Value.absent(),
            Value<double?> bestDeltaE = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonProgressCompanion.insert(
            lessonId: lessonId,
            completed: completed,
            bestDeltaE: bestDeltaE,
            attempts: attempts,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LessonProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LessonProgressTable,
    LessonProgressData,
    $$LessonProgressTableFilterComposer,
    $$LessonProgressTableOrderingComposer,
    $$LessonProgressTableAnnotationComposer,
    $$LessonProgressTableCreateCompanionBuilder,
    $$LessonProgressTableUpdateCompanionBuilder,
    (
      LessonProgressData,
      BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>
    ),
    LessonProgressData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MixRecipesTableTableManager get mixRecipes =>
      $$MixRecipesTableTableManager(_db, _db.mixRecipes);
  $$RecipeTagsTableTableManager get recipeTags =>
      $$RecipeTagsTableTableManager(_db, _db.recipeTags);
  $$InventoryItemsTableTableManager get inventoryItems =>
      $$InventoryItemsTableTableManager(_db, _db.inventoryItems);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(_db, _db.lessonProgress);
}
