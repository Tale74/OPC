// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $KorisniciTable extends Korisnici
    with TableInfo<$KorisniciTable, KorisniciData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KorisniciTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _imePrezimeMeta = const VerificationMeta(
    'imePrezime',
  );
  @override
  late final GeneratedColumn<String> imePrezime = GeneratedColumn<String>(
    'ime_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ulogaMeta = const VerificationMeta('uloga');
  @override
  late final GeneratedColumn<String> uloga = GeneratedColumn<String>(
    'uloga',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aktivanMeta = const VerificationMeta(
    'aktivan',
  );
  @override
  late final GeneratedColumn<bool> aktivan = GeneratedColumn<bool>(
    'aktivan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktivan" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _datumKreiranjaMeta = const VerificationMeta(
    'datumKreiranja',
  );
  @override
  late final GeneratedColumn<String> datumKreiranja = GeneratedColumn<String>(
    'datum_kreiranja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    imePrezime,
    uloga,
    pinHash,
    aktivan,
    datumKreiranja,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'korisnici';
  @override
  VerificationContext validateIntegrity(
    Insertable<KorisniciData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ime_prezime')) {
      context.handle(
        _imePrezimeMeta,
        imePrezime.isAcceptableOrUnknown(data['ime_prezime']!, _imePrezimeMeta),
      );
    } else if (isInserting) {
      context.missing(_imePrezimeMeta);
    }
    if (data.containsKey('uloga')) {
      context.handle(
        _ulogaMeta,
        uloga.isAcceptableOrUnknown(data['uloga']!, _ulogaMeta),
      );
    } else if (isInserting) {
      context.missing(_ulogaMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('aktivan')) {
      context.handle(
        _aktivanMeta,
        aktivan.isAcceptableOrUnknown(data['aktivan']!, _aktivanMeta),
      );
    }
    if (data.containsKey('datum_kreiranja')) {
      context.handle(
        _datumKreiranjaMeta,
        datumKreiranja.isAcceptableOrUnknown(
          data['datum_kreiranja']!,
          _datumKreiranjaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_datumKreiranjaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KorisniciData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KorisniciData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      imePrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ime_prezime'],
      )!,
      uloga: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uloga'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      aktivan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktivan'],
      )!,
      datumKreiranja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_kreiranja'],
      )!,
    );
  }

  @override
  $KorisniciTable createAlias(String alias) {
    return $KorisniciTable(attachedDatabase, alias);
  }
}

class KorisniciData extends DataClass implements Insertable<KorisniciData> {
  final int id;
  final String imePrezime;
  final String uloga;
  final String pinHash;
  final bool aktivan;
  final String datumKreiranja;
  const KorisniciData({
    required this.id,
    required this.imePrezime,
    required this.uloga,
    required this.pinHash,
    required this.aktivan,
    required this.datumKreiranja,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ime_prezime'] = Variable<String>(imePrezime);
    map['uloga'] = Variable<String>(uloga);
    map['pin_hash'] = Variable<String>(pinHash);
    map['aktivan'] = Variable<bool>(aktivan);
    map['datum_kreiranja'] = Variable<String>(datumKreiranja);
    return map;
  }

  KorisniciCompanion toCompanion(bool nullToAbsent) {
    return KorisniciCompanion(
      id: Value(id),
      imePrezime: Value(imePrezime),
      uloga: Value(uloga),
      pinHash: Value(pinHash),
      aktivan: Value(aktivan),
      datumKreiranja: Value(datumKreiranja),
    );
  }

  factory KorisniciData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KorisniciData(
      id: serializer.fromJson<int>(json['id']),
      imePrezime: serializer.fromJson<String>(json['imePrezime']),
      uloga: serializer.fromJson<String>(json['uloga']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      aktivan: serializer.fromJson<bool>(json['aktivan']),
      datumKreiranja: serializer.fromJson<String>(json['datumKreiranja']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imePrezime': serializer.toJson<String>(imePrezime),
      'uloga': serializer.toJson<String>(uloga),
      'pinHash': serializer.toJson<String>(pinHash),
      'aktivan': serializer.toJson<bool>(aktivan),
      'datumKreiranja': serializer.toJson<String>(datumKreiranja),
    };
  }

  KorisniciData copyWith({
    int? id,
    String? imePrezime,
    String? uloga,
    String? pinHash,
    bool? aktivan,
    String? datumKreiranja,
  }) => KorisniciData(
    id: id ?? this.id,
    imePrezime: imePrezime ?? this.imePrezime,
    uloga: uloga ?? this.uloga,
    pinHash: pinHash ?? this.pinHash,
    aktivan: aktivan ?? this.aktivan,
    datumKreiranja: datumKreiranja ?? this.datumKreiranja,
  );
  KorisniciData copyWithCompanion(KorisniciCompanion data) {
    return KorisniciData(
      id: data.id.present ? data.id.value : this.id,
      imePrezime: data.imePrezime.present
          ? data.imePrezime.value
          : this.imePrezime,
      uloga: data.uloga.present ? data.uloga.value : this.uloga,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      aktivan: data.aktivan.present ? data.aktivan.value : this.aktivan,
      datumKreiranja: data.datumKreiranja.present
          ? data.datumKreiranja.value
          : this.datumKreiranja,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KorisniciData(')
          ..write('id: $id, ')
          ..write('imePrezime: $imePrezime, ')
          ..write('uloga: $uloga, ')
          ..write('pinHash: $pinHash, ')
          ..write('aktivan: $aktivan, ')
          ..write('datumKreiranja: $datumKreiranja')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, imePrezime, uloga, pinHash, aktivan, datumKreiranja);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KorisniciData &&
          other.id == this.id &&
          other.imePrezime == this.imePrezime &&
          other.uloga == this.uloga &&
          other.pinHash == this.pinHash &&
          other.aktivan == this.aktivan &&
          other.datumKreiranja == this.datumKreiranja);
}

class KorisniciCompanion extends UpdateCompanion<KorisniciData> {
  final Value<int> id;
  final Value<String> imePrezime;
  final Value<String> uloga;
  final Value<String> pinHash;
  final Value<bool> aktivan;
  final Value<String> datumKreiranja;
  const KorisniciCompanion({
    this.id = const Value.absent(),
    this.imePrezime = const Value.absent(),
    this.uloga = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.aktivan = const Value.absent(),
    this.datumKreiranja = const Value.absent(),
  });
  KorisniciCompanion.insert({
    this.id = const Value.absent(),
    required String imePrezime,
    required String uloga,
    required String pinHash,
    this.aktivan = const Value.absent(),
    required String datumKreiranja,
  }) : imePrezime = Value(imePrezime),
       uloga = Value(uloga),
       pinHash = Value(pinHash),
       datumKreiranja = Value(datumKreiranja);
  static Insertable<KorisniciData> custom({
    Expression<int>? id,
    Expression<String>? imePrezime,
    Expression<String>? uloga,
    Expression<String>? pinHash,
    Expression<bool>? aktivan,
    Expression<String>? datumKreiranja,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imePrezime != null) 'ime_prezime': imePrezime,
      if (uloga != null) 'uloga': uloga,
      if (pinHash != null) 'pin_hash': pinHash,
      if (aktivan != null) 'aktivan': aktivan,
      if (datumKreiranja != null) 'datum_kreiranja': datumKreiranja,
    });
  }

  KorisniciCompanion copyWith({
    Value<int>? id,
    Value<String>? imePrezime,
    Value<String>? uloga,
    Value<String>? pinHash,
    Value<bool>? aktivan,
    Value<String>? datumKreiranja,
  }) {
    return KorisniciCompanion(
      id: id ?? this.id,
      imePrezime: imePrezime ?? this.imePrezime,
      uloga: uloga ?? this.uloga,
      pinHash: pinHash ?? this.pinHash,
      aktivan: aktivan ?? this.aktivan,
      datumKreiranja: datumKreiranja ?? this.datumKreiranja,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imePrezime.present) {
      map['ime_prezime'] = Variable<String>(imePrezime.value);
    }
    if (uloga.present) {
      map['uloga'] = Variable<String>(uloga.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (aktivan.present) {
      map['aktivan'] = Variable<bool>(aktivan.value);
    }
    if (datumKreiranja.present) {
      map['datum_kreiranja'] = Variable<String>(datumKreiranja.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KorisniciCompanion(')
          ..write('id: $id, ')
          ..write('imePrezime: $imePrezime, ')
          ..write('uloga: $uloga, ')
          ..write('pinHash: $pinHash, ')
          ..write('aktivan: $aktivan, ')
          ..write('datumKreiranja: $datumKreiranja')
          ..write(')'))
        .toString();
  }
}

class $FirmaPodaciTable extends FirmaPodaci
    with TableInfo<$FirmaPodaciTable, FirmaPodaciData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FirmaPodaciTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nazivMeta = const VerificationMeta('naziv');
  @override
  late final GeneratedColumn<String> naziv = GeneratedColumn<String>(
    'naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _adresaMeta = const VerificationMeta('adresa');
  @override
  late final GeneratedColumn<String> adresa = GeneratedColumn<String>(
    'adresa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pibMeta = const VerificationMeta('pib');
  @override
  late final GeneratedColumn<String> pib = GeneratedColumn<String>(
    'pib',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mbMeta = const VerificationMeta('mb');
  @override
  late final GeneratedColumn<String> mb = GeneratedColumn<String>(
    'mb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sifraDelatnostiMeta = const VerificationMeta(
    'sifraDelatnosti',
  );
  @override
  late final GeneratedColumn<String> sifraDelatnosti = GeneratedColumn<String>(
    'sifra_delatnosti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _telefonMeta = const VerificationMeta(
    'telefon',
  );
  @override
  late final GeneratedColumn<String> telefon = GeneratedColumn<String>(
    'telefon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _odgovornoLiceMeta = const VerificationMeta(
    'odgovornoLice',
  );
  @override
  late final GeneratedColumn<String> odgovornoLice = GeneratedColumn<String>(
    'odgovorno_lice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sajtMeta = const VerificationMeta('sajt');
  @override
  late final GeneratedColumn<String> sajt = GeneratedColumn<String>(
    'sajt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<Uint8List> logo = GeneratedColumn<Uint8List>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    naziv,
    adresa,
    pib,
    mb,
    sifraDelatnosti,
    telefon,
    odgovornoLice,
    email,
    sajt,
    logo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'firma_podaci';
  @override
  VerificationContext validateIntegrity(
    Insertable<FirmaPodaciData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('naziv')) {
      context.handle(
        _nazivMeta,
        naziv.isAcceptableOrUnknown(data['naziv']!, _nazivMeta),
      );
    }
    if (data.containsKey('adresa')) {
      context.handle(
        _adresaMeta,
        adresa.isAcceptableOrUnknown(data['adresa']!, _adresaMeta),
      );
    }
    if (data.containsKey('pib')) {
      context.handle(
        _pibMeta,
        pib.isAcceptableOrUnknown(data['pib']!, _pibMeta),
      );
    }
    if (data.containsKey('mb')) {
      context.handle(_mbMeta, mb.isAcceptableOrUnknown(data['mb']!, _mbMeta));
    }
    if (data.containsKey('sifra_delatnosti')) {
      context.handle(
        _sifraDelatnostiMeta,
        sifraDelatnosti.isAcceptableOrUnknown(
          data['sifra_delatnosti']!,
          _sifraDelatnostiMeta,
        ),
      );
    }
    if (data.containsKey('telefon')) {
      context.handle(
        _telefonMeta,
        telefon.isAcceptableOrUnknown(data['telefon']!, _telefonMeta),
      );
    }
    if (data.containsKey('odgovorno_lice')) {
      context.handle(
        _odgovornoLiceMeta,
        odgovornoLice.isAcceptableOrUnknown(
          data['odgovorno_lice']!,
          _odgovornoLiceMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('sajt')) {
      context.handle(
        _sajtMeta,
        sajt.isAcceptableOrUnknown(data['sajt']!, _sajtMeta),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FirmaPodaciData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FirmaPodaciData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      naziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naziv'],
      )!,
      adresa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adresa'],
      )!,
      pib: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pib'],
      )!,
      mb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mb'],
      )!,
      sifraDelatnosti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sifra_delatnosti'],
      )!,
      telefon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefon'],
      )!,
      odgovornoLice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}odgovorno_lice'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      sajt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sajt'],
      )!,
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}logo'],
      ),
    );
  }

  @override
  $FirmaPodaciTable createAlias(String alias) {
    return $FirmaPodaciTable(attachedDatabase, alias);
  }
}

class FirmaPodaciData extends DataClass implements Insertable<FirmaPodaciData> {
  final int id;
  final String naziv;
  final String adresa;
  final String pib;
  final String mb;
  final String sifraDelatnosti;
  final String telefon;
  final String odgovornoLice;
  final String email;
  final String sajt;
  final Uint8List? logo;
  const FirmaPodaciData({
    required this.id,
    required this.naziv,
    required this.adresa,
    required this.pib,
    required this.mb,
    required this.sifraDelatnosti,
    required this.telefon,
    required this.odgovornoLice,
    required this.email,
    required this.sajt,
    this.logo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['naziv'] = Variable<String>(naziv);
    map['adresa'] = Variable<String>(adresa);
    map['pib'] = Variable<String>(pib);
    map['mb'] = Variable<String>(mb);
    map['sifra_delatnosti'] = Variable<String>(sifraDelatnosti);
    map['telefon'] = Variable<String>(telefon);
    map['odgovorno_lice'] = Variable<String>(odgovornoLice);
    map['email'] = Variable<String>(email);
    map['sajt'] = Variable<String>(sajt);
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<Uint8List>(logo);
    }
    return map;
  }

  FirmaPodaciCompanion toCompanion(bool nullToAbsent) {
    return FirmaPodaciCompanion(
      id: Value(id),
      naziv: Value(naziv),
      adresa: Value(adresa),
      pib: Value(pib),
      mb: Value(mb),
      sifraDelatnosti: Value(sifraDelatnosti),
      telefon: Value(telefon),
      odgovornoLice: Value(odgovornoLice),
      email: Value(email),
      sajt: Value(sajt),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
    );
  }

  factory FirmaPodaciData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FirmaPodaciData(
      id: serializer.fromJson<int>(json['id']),
      naziv: serializer.fromJson<String>(json['naziv']),
      adresa: serializer.fromJson<String>(json['adresa']),
      pib: serializer.fromJson<String>(json['pib']),
      mb: serializer.fromJson<String>(json['mb']),
      sifraDelatnosti: serializer.fromJson<String>(json['sifraDelatnosti']),
      telefon: serializer.fromJson<String>(json['telefon']),
      odgovornoLice: serializer.fromJson<String>(json['odgovornoLice']),
      email: serializer.fromJson<String>(json['email']),
      sajt: serializer.fromJson<String>(json['sajt']),
      logo: serializer.fromJson<Uint8List?>(json['logo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'naziv': serializer.toJson<String>(naziv),
      'adresa': serializer.toJson<String>(adresa),
      'pib': serializer.toJson<String>(pib),
      'mb': serializer.toJson<String>(mb),
      'sifraDelatnosti': serializer.toJson<String>(sifraDelatnosti),
      'telefon': serializer.toJson<String>(telefon),
      'odgovornoLice': serializer.toJson<String>(odgovornoLice),
      'email': serializer.toJson<String>(email),
      'sajt': serializer.toJson<String>(sajt),
      'logo': serializer.toJson<Uint8List?>(logo),
    };
  }

  FirmaPodaciData copyWith({
    int? id,
    String? naziv,
    String? adresa,
    String? pib,
    String? mb,
    String? sifraDelatnosti,
    String? telefon,
    String? odgovornoLice,
    String? email,
    String? sajt,
    Value<Uint8List?> logo = const Value.absent(),
  }) => FirmaPodaciData(
    id: id ?? this.id,
    naziv: naziv ?? this.naziv,
    adresa: adresa ?? this.adresa,
    pib: pib ?? this.pib,
    mb: mb ?? this.mb,
    sifraDelatnosti: sifraDelatnosti ?? this.sifraDelatnosti,
    telefon: telefon ?? this.telefon,
    odgovornoLice: odgovornoLice ?? this.odgovornoLice,
    email: email ?? this.email,
    sajt: sajt ?? this.sajt,
    logo: logo.present ? logo.value : this.logo,
  );
  FirmaPodaciData copyWithCompanion(FirmaPodaciCompanion data) {
    return FirmaPodaciData(
      id: data.id.present ? data.id.value : this.id,
      naziv: data.naziv.present ? data.naziv.value : this.naziv,
      adresa: data.adresa.present ? data.adresa.value : this.adresa,
      pib: data.pib.present ? data.pib.value : this.pib,
      mb: data.mb.present ? data.mb.value : this.mb,
      sifraDelatnosti: data.sifraDelatnosti.present
          ? data.sifraDelatnosti.value
          : this.sifraDelatnosti,
      telefon: data.telefon.present ? data.telefon.value : this.telefon,
      odgovornoLice: data.odgovornoLice.present
          ? data.odgovornoLice.value
          : this.odgovornoLice,
      email: data.email.present ? data.email.value : this.email,
      sajt: data.sajt.present ? data.sajt.value : this.sajt,
      logo: data.logo.present ? data.logo.value : this.logo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FirmaPodaciData(')
          ..write('id: $id, ')
          ..write('naziv: $naziv, ')
          ..write('adresa: $adresa, ')
          ..write('pib: $pib, ')
          ..write('mb: $mb, ')
          ..write('sifraDelatnosti: $sifraDelatnosti, ')
          ..write('telefon: $telefon, ')
          ..write('odgovornoLice: $odgovornoLice, ')
          ..write('email: $email, ')
          ..write('sajt: $sajt, ')
          ..write('logo: $logo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    naziv,
    adresa,
    pib,
    mb,
    sifraDelatnosti,
    telefon,
    odgovornoLice,
    email,
    sajt,
    $driftBlobEquality.hash(logo),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FirmaPodaciData &&
          other.id == this.id &&
          other.naziv == this.naziv &&
          other.adresa == this.adresa &&
          other.pib == this.pib &&
          other.mb == this.mb &&
          other.sifraDelatnosti == this.sifraDelatnosti &&
          other.telefon == this.telefon &&
          other.odgovornoLice == this.odgovornoLice &&
          other.email == this.email &&
          other.sajt == this.sajt &&
          $driftBlobEquality.equals(other.logo, this.logo));
}

class FirmaPodaciCompanion extends UpdateCompanion<FirmaPodaciData> {
  final Value<int> id;
  final Value<String> naziv;
  final Value<String> adresa;
  final Value<String> pib;
  final Value<String> mb;
  final Value<String> sifraDelatnosti;
  final Value<String> telefon;
  final Value<String> odgovornoLice;
  final Value<String> email;
  final Value<String> sajt;
  final Value<Uint8List?> logo;
  const FirmaPodaciCompanion({
    this.id = const Value.absent(),
    this.naziv = const Value.absent(),
    this.adresa = const Value.absent(),
    this.pib = const Value.absent(),
    this.mb = const Value.absent(),
    this.sifraDelatnosti = const Value.absent(),
    this.telefon = const Value.absent(),
    this.odgovornoLice = const Value.absent(),
    this.email = const Value.absent(),
    this.sajt = const Value.absent(),
    this.logo = const Value.absent(),
  });
  FirmaPodaciCompanion.insert({
    this.id = const Value.absent(),
    this.naziv = const Value.absent(),
    this.adresa = const Value.absent(),
    this.pib = const Value.absent(),
    this.mb = const Value.absent(),
    this.sifraDelatnosti = const Value.absent(),
    this.telefon = const Value.absent(),
    this.odgovornoLice = const Value.absent(),
    this.email = const Value.absent(),
    this.sajt = const Value.absent(),
    this.logo = const Value.absent(),
  });
  static Insertable<FirmaPodaciData> custom({
    Expression<int>? id,
    Expression<String>? naziv,
    Expression<String>? adresa,
    Expression<String>? pib,
    Expression<String>? mb,
    Expression<String>? sifraDelatnosti,
    Expression<String>? telefon,
    Expression<String>? odgovornoLice,
    Expression<String>? email,
    Expression<String>? sajt,
    Expression<Uint8List>? logo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (naziv != null) 'naziv': naziv,
      if (adresa != null) 'adresa': adresa,
      if (pib != null) 'pib': pib,
      if (mb != null) 'mb': mb,
      if (sifraDelatnosti != null) 'sifra_delatnosti': sifraDelatnosti,
      if (telefon != null) 'telefon': telefon,
      if (odgovornoLice != null) 'odgovorno_lice': odgovornoLice,
      if (email != null) 'email': email,
      if (sajt != null) 'sajt': sajt,
      if (logo != null) 'logo': logo,
    });
  }

  FirmaPodaciCompanion copyWith({
    Value<int>? id,
    Value<String>? naziv,
    Value<String>? adresa,
    Value<String>? pib,
    Value<String>? mb,
    Value<String>? sifraDelatnosti,
    Value<String>? telefon,
    Value<String>? odgovornoLice,
    Value<String>? email,
    Value<String>? sajt,
    Value<Uint8List?>? logo,
  }) {
    return FirmaPodaciCompanion(
      id: id ?? this.id,
      naziv: naziv ?? this.naziv,
      adresa: adresa ?? this.adresa,
      pib: pib ?? this.pib,
      mb: mb ?? this.mb,
      sifraDelatnosti: sifraDelatnosti ?? this.sifraDelatnosti,
      telefon: telefon ?? this.telefon,
      odgovornoLice: odgovornoLice ?? this.odgovornoLice,
      email: email ?? this.email,
      sajt: sajt ?? this.sajt,
      logo: logo ?? this.logo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (naziv.present) {
      map['naziv'] = Variable<String>(naziv.value);
    }
    if (adresa.present) {
      map['adresa'] = Variable<String>(adresa.value);
    }
    if (pib.present) {
      map['pib'] = Variable<String>(pib.value);
    }
    if (mb.present) {
      map['mb'] = Variable<String>(mb.value);
    }
    if (sifraDelatnosti.present) {
      map['sifra_delatnosti'] = Variable<String>(sifraDelatnosti.value);
    }
    if (telefon.present) {
      map['telefon'] = Variable<String>(telefon.value);
    }
    if (odgovornoLice.present) {
      map['odgovorno_lice'] = Variable<String>(odgovornoLice.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (sajt.present) {
      map['sajt'] = Variable<String>(sajt.value);
    }
    if (logo.present) {
      map['logo'] = Variable<Uint8List>(logo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FirmaPodaciCompanion(')
          ..write('id: $id, ')
          ..write('naziv: $naziv, ')
          ..write('adresa: $adresa, ')
          ..write('pib: $pib, ')
          ..write('mb: $mb, ')
          ..write('sifraDelatnosti: $sifraDelatnosti, ')
          ..write('telefon: $telefon, ')
          ..write('odgovornoLice: $odgovornoLice, ')
          ..write('email: $email, ')
          ..write('sajt: $sajt, ')
          ..write('logo: $logo')
          ..write(')'))
        .toString();
  }
}

class $AppPodesavanjaTable extends AppPodesavanja
    with TableInfo<$AppPodesavanjaTable, AppPodesavanjaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPodesavanjaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ziroRacunMeta = const VerificationMeta(
    'ziroRacun',
  );
  @override
  late final GeneratedColumn<String> ziroRacun = GeneratedColumn<String>(
    'ziro_racun',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nazivBankeMeta = const VerificationMeta(
    'nazivBanke',
  );
  @override
  late final GeneratedColumn<String> nazivBanke = GeneratedColumn<String>(
    'naziv_banke',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _qrPrimalacNazivMeta = const VerificationMeta(
    'qrPrimalacNaziv',
  );
  @override
  late final GeneratedColumn<String> qrPrimalacNaziv = GeneratedColumn<String>(
    'qr_primalac_naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _qrSifraPlacanjaMeta = const VerificationMeta(
    'qrSifraPlacanja',
  );
  @override
  late final GeneratedColumn<String> qrSifraPlacanja = GeneratedColumn<String>(
    'qr_sifra_placanja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('289'),
  );
  static const VerificationMeta _qrSvrhaPlacanjaMeta = const VerificationMeta(
    'qrSvrhaPlacanja',
  );
  @override
  late final GeneratedColumn<String> qrSvrhaPlacanja = GeneratedColumn<String>(
    'qr_svrha_placanja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pozivNaBrojTipMeta = const VerificationMeta(
    'pozivNaBrojTip',
  );
  @override
  late final GeneratedColumn<String> pozivNaBrojTip = GeneratedColumn<String>(
    'poziv_na_broj_tip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BROJ_PREDMETA'),
  );
  static const VerificationMeta _refundacijaPioIznosMeta =
      const VerificationMeta('refundacijaPioIznos');
  @override
  late final GeneratedColumn<double> refundacijaPioIznos =
      GeneratedColumn<double>(
        'refundacija_pio_iznos',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _stanjeRobeOperativnoOmogucenoMeta =
      const VerificationMeta('stanjeRobeOperativnoOmoguceno');
  @override
  late final GeneratedColumn<bool> stanjeRobeOperativnoOmoguceno =
      GeneratedColumn<bool>(
        'stanje_robe_operativno_omoguceno',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("stanje_robe_operativno_omoguceno" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ziroRacun,
    nazivBanke,
    qrPrimalacNaziv,
    qrSifraPlacanja,
    qrSvrhaPlacanja,
    pozivNaBrojTip,
    refundacijaPioIznos,
    stanjeRobeOperativnoOmoguceno,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_podesavanja';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPodesavanjaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ziro_racun')) {
      context.handle(
        _ziroRacunMeta,
        ziroRacun.isAcceptableOrUnknown(data['ziro_racun']!, _ziroRacunMeta),
      );
    }
    if (data.containsKey('naziv_banke')) {
      context.handle(
        _nazivBankeMeta,
        nazivBanke.isAcceptableOrUnknown(data['naziv_banke']!, _nazivBankeMeta),
      );
    }
    if (data.containsKey('qr_primalac_naziv')) {
      context.handle(
        _qrPrimalacNazivMeta,
        qrPrimalacNaziv.isAcceptableOrUnknown(
          data['qr_primalac_naziv']!,
          _qrPrimalacNazivMeta,
        ),
      );
    }
    if (data.containsKey('qr_sifra_placanja')) {
      context.handle(
        _qrSifraPlacanjaMeta,
        qrSifraPlacanja.isAcceptableOrUnknown(
          data['qr_sifra_placanja']!,
          _qrSifraPlacanjaMeta,
        ),
      );
    }
    if (data.containsKey('qr_svrha_placanja')) {
      context.handle(
        _qrSvrhaPlacanjaMeta,
        qrSvrhaPlacanja.isAcceptableOrUnknown(
          data['qr_svrha_placanja']!,
          _qrSvrhaPlacanjaMeta,
        ),
      );
    }
    if (data.containsKey('poziv_na_broj_tip')) {
      context.handle(
        _pozivNaBrojTipMeta,
        pozivNaBrojTip.isAcceptableOrUnknown(
          data['poziv_na_broj_tip']!,
          _pozivNaBrojTipMeta,
        ),
      );
    }
    if (data.containsKey('refundacija_pio_iznos')) {
      context.handle(
        _refundacijaPioIznosMeta,
        refundacijaPioIznos.isAcceptableOrUnknown(
          data['refundacija_pio_iznos']!,
          _refundacijaPioIznosMeta,
        ),
      );
    }
    if (data.containsKey('stanje_robe_operativno_omoguceno')) {
      context.handle(
        _stanjeRobeOperativnoOmogucenoMeta,
        stanjeRobeOperativnoOmoguceno.isAcceptableOrUnknown(
          data['stanje_robe_operativno_omoguceno']!,
          _stanjeRobeOperativnoOmogucenoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppPodesavanjaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPodesavanjaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ziroRacun: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ziro_racun'],
      )!,
      nazivBanke: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naziv_banke'],
      )!,
      qrPrimalacNaziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_primalac_naziv'],
      )!,
      qrSifraPlacanja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_sifra_placanja'],
      )!,
      qrSvrhaPlacanja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_svrha_placanja'],
      )!,
      pozivNaBrojTip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poziv_na_broj_tip'],
      )!,
      refundacijaPioIznos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}refundacija_pio_iznos'],
      )!,
      stanjeRobeOperativnoOmoguceno: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stanje_robe_operativno_omoguceno'],
      )!,
    );
  }

  @override
  $AppPodesavanjaTable createAlias(String alias) {
    return $AppPodesavanjaTable(attachedDatabase, alias);
  }
}

class AppPodesavanjaData extends DataClass
    implements Insertable<AppPodesavanjaData> {
  final int id;
  final String ziroRacun;
  final String nazivBanke;
  final String qrPrimalacNaziv;
  final String qrSifraPlacanja;
  final String qrSvrhaPlacanja;
  final String pozivNaBrojTip;
  final double refundacijaPioIznos;
  final bool stanjeRobeOperativnoOmoguceno;
  const AppPodesavanjaData({
    required this.id,
    required this.ziroRacun,
    required this.nazivBanke,
    required this.qrPrimalacNaziv,
    required this.qrSifraPlacanja,
    required this.qrSvrhaPlacanja,
    required this.pozivNaBrojTip,
    required this.refundacijaPioIznos,
    required this.stanjeRobeOperativnoOmoguceno,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ziro_racun'] = Variable<String>(ziroRacun);
    map['naziv_banke'] = Variable<String>(nazivBanke);
    map['qr_primalac_naziv'] = Variable<String>(qrPrimalacNaziv);
    map['qr_sifra_placanja'] = Variable<String>(qrSifraPlacanja);
    map['qr_svrha_placanja'] = Variable<String>(qrSvrhaPlacanja);
    map['poziv_na_broj_tip'] = Variable<String>(pozivNaBrojTip);
    map['refundacija_pio_iznos'] = Variable<double>(refundacijaPioIznos);
    map['stanje_robe_operativno_omoguceno'] = Variable<bool>(
      stanjeRobeOperativnoOmoguceno,
    );
    return map;
  }

  AppPodesavanjaCompanion toCompanion(bool nullToAbsent) {
    return AppPodesavanjaCompanion(
      id: Value(id),
      ziroRacun: Value(ziroRacun),
      nazivBanke: Value(nazivBanke),
      qrPrimalacNaziv: Value(qrPrimalacNaziv),
      qrSifraPlacanja: Value(qrSifraPlacanja),
      qrSvrhaPlacanja: Value(qrSvrhaPlacanja),
      pozivNaBrojTip: Value(pozivNaBrojTip),
      refundacijaPioIznos: Value(refundacijaPioIznos),
      stanjeRobeOperativnoOmoguceno: Value(stanjeRobeOperativnoOmoguceno),
    );
  }

  factory AppPodesavanjaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPodesavanjaData(
      id: serializer.fromJson<int>(json['id']),
      ziroRacun: serializer.fromJson<String>(json['ziroRacun']),
      nazivBanke: serializer.fromJson<String>(json['nazivBanke']),
      qrPrimalacNaziv: serializer.fromJson<String>(json['qrPrimalacNaziv']),
      qrSifraPlacanja: serializer.fromJson<String>(json['qrSifraPlacanja']),
      qrSvrhaPlacanja: serializer.fromJson<String>(json['qrSvrhaPlacanja']),
      pozivNaBrojTip: serializer.fromJson<String>(json['pozivNaBrojTip']),
      refundacijaPioIznos: serializer.fromJson<double>(
        json['refundacijaPioIznos'],
      ),
      stanjeRobeOperativnoOmoguceno: serializer.fromJson<bool>(
        json['stanjeRobeOperativnoOmoguceno'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ziroRacun': serializer.toJson<String>(ziroRacun),
      'nazivBanke': serializer.toJson<String>(nazivBanke),
      'qrPrimalacNaziv': serializer.toJson<String>(qrPrimalacNaziv),
      'qrSifraPlacanja': serializer.toJson<String>(qrSifraPlacanja),
      'qrSvrhaPlacanja': serializer.toJson<String>(qrSvrhaPlacanja),
      'pozivNaBrojTip': serializer.toJson<String>(pozivNaBrojTip),
      'refundacijaPioIznos': serializer.toJson<double>(refundacijaPioIznos),
      'stanjeRobeOperativnoOmoguceno': serializer.toJson<bool>(
        stanjeRobeOperativnoOmoguceno,
      ),
    };
  }

  AppPodesavanjaData copyWith({
    int? id,
    String? ziroRacun,
    String? nazivBanke,
    String? qrPrimalacNaziv,
    String? qrSifraPlacanja,
    String? qrSvrhaPlacanja,
    String? pozivNaBrojTip,
    double? refundacijaPioIznos,
    bool? stanjeRobeOperativnoOmoguceno,
  }) => AppPodesavanjaData(
    id: id ?? this.id,
    ziroRacun: ziroRacun ?? this.ziroRacun,
    nazivBanke: nazivBanke ?? this.nazivBanke,
    qrPrimalacNaziv: qrPrimalacNaziv ?? this.qrPrimalacNaziv,
    qrSifraPlacanja: qrSifraPlacanja ?? this.qrSifraPlacanja,
    qrSvrhaPlacanja: qrSvrhaPlacanja ?? this.qrSvrhaPlacanja,
    pozivNaBrojTip: pozivNaBrojTip ?? this.pozivNaBrojTip,
    refundacijaPioIznos: refundacijaPioIznos ?? this.refundacijaPioIznos,
    stanjeRobeOperativnoOmoguceno:
        stanjeRobeOperativnoOmoguceno ?? this.stanjeRobeOperativnoOmoguceno,
  );
  AppPodesavanjaData copyWithCompanion(AppPodesavanjaCompanion data) {
    return AppPodesavanjaData(
      id: data.id.present ? data.id.value : this.id,
      ziroRacun: data.ziroRacun.present ? data.ziroRacun.value : this.ziroRacun,
      nazivBanke: data.nazivBanke.present
          ? data.nazivBanke.value
          : this.nazivBanke,
      qrPrimalacNaziv: data.qrPrimalacNaziv.present
          ? data.qrPrimalacNaziv.value
          : this.qrPrimalacNaziv,
      qrSifraPlacanja: data.qrSifraPlacanja.present
          ? data.qrSifraPlacanja.value
          : this.qrSifraPlacanja,
      qrSvrhaPlacanja: data.qrSvrhaPlacanja.present
          ? data.qrSvrhaPlacanja.value
          : this.qrSvrhaPlacanja,
      pozivNaBrojTip: data.pozivNaBrojTip.present
          ? data.pozivNaBrojTip.value
          : this.pozivNaBrojTip,
      refundacijaPioIznos: data.refundacijaPioIznos.present
          ? data.refundacijaPioIznos.value
          : this.refundacijaPioIznos,
      stanjeRobeOperativnoOmoguceno: data.stanjeRobeOperativnoOmoguceno.present
          ? data.stanjeRobeOperativnoOmoguceno.value
          : this.stanjeRobeOperativnoOmoguceno,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPodesavanjaData(')
          ..write('id: $id, ')
          ..write('ziroRacun: $ziroRacun, ')
          ..write('nazivBanke: $nazivBanke, ')
          ..write('qrPrimalacNaziv: $qrPrimalacNaziv, ')
          ..write('qrSifraPlacanja: $qrSifraPlacanja, ')
          ..write('qrSvrhaPlacanja: $qrSvrhaPlacanja, ')
          ..write('pozivNaBrojTip: $pozivNaBrojTip, ')
          ..write('refundacijaPioIznos: $refundacijaPioIznos, ')
          ..write(
            'stanjeRobeOperativnoOmoguceno: $stanjeRobeOperativnoOmoguceno',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ziroRacun,
    nazivBanke,
    qrPrimalacNaziv,
    qrSifraPlacanja,
    qrSvrhaPlacanja,
    pozivNaBrojTip,
    refundacijaPioIznos,
    stanjeRobeOperativnoOmoguceno,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPodesavanjaData &&
          other.id == this.id &&
          other.ziroRacun == this.ziroRacun &&
          other.nazivBanke == this.nazivBanke &&
          other.qrPrimalacNaziv == this.qrPrimalacNaziv &&
          other.qrSifraPlacanja == this.qrSifraPlacanja &&
          other.qrSvrhaPlacanja == this.qrSvrhaPlacanja &&
          other.pozivNaBrojTip == this.pozivNaBrojTip &&
          other.refundacijaPioIznos == this.refundacijaPioIznos &&
          other.stanjeRobeOperativnoOmoguceno ==
              this.stanjeRobeOperativnoOmoguceno);
}

class AppPodesavanjaCompanion extends UpdateCompanion<AppPodesavanjaData> {
  final Value<int> id;
  final Value<String> ziroRacun;
  final Value<String> nazivBanke;
  final Value<String> qrPrimalacNaziv;
  final Value<String> qrSifraPlacanja;
  final Value<String> qrSvrhaPlacanja;
  final Value<String> pozivNaBrojTip;
  final Value<double> refundacijaPioIznos;
  final Value<bool> stanjeRobeOperativnoOmoguceno;
  const AppPodesavanjaCompanion({
    this.id = const Value.absent(),
    this.ziroRacun = const Value.absent(),
    this.nazivBanke = const Value.absent(),
    this.qrPrimalacNaziv = const Value.absent(),
    this.qrSifraPlacanja = const Value.absent(),
    this.qrSvrhaPlacanja = const Value.absent(),
    this.pozivNaBrojTip = const Value.absent(),
    this.refundacijaPioIznos = const Value.absent(),
    this.stanjeRobeOperativnoOmoguceno = const Value.absent(),
  });
  AppPodesavanjaCompanion.insert({
    this.id = const Value.absent(),
    this.ziroRacun = const Value.absent(),
    this.nazivBanke = const Value.absent(),
    this.qrPrimalacNaziv = const Value.absent(),
    this.qrSifraPlacanja = const Value.absent(),
    this.qrSvrhaPlacanja = const Value.absent(),
    this.pozivNaBrojTip = const Value.absent(),
    this.refundacijaPioIznos = const Value.absent(),
    this.stanjeRobeOperativnoOmoguceno = const Value.absent(),
  });
  static Insertable<AppPodesavanjaData> custom({
    Expression<int>? id,
    Expression<String>? ziroRacun,
    Expression<String>? nazivBanke,
    Expression<String>? qrPrimalacNaziv,
    Expression<String>? qrSifraPlacanja,
    Expression<String>? qrSvrhaPlacanja,
    Expression<String>? pozivNaBrojTip,
    Expression<double>? refundacijaPioIznos,
    Expression<bool>? stanjeRobeOperativnoOmoguceno,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ziroRacun != null) 'ziro_racun': ziroRacun,
      if (nazivBanke != null) 'naziv_banke': nazivBanke,
      if (qrPrimalacNaziv != null) 'qr_primalac_naziv': qrPrimalacNaziv,
      if (qrSifraPlacanja != null) 'qr_sifra_placanja': qrSifraPlacanja,
      if (qrSvrhaPlacanja != null) 'qr_svrha_placanja': qrSvrhaPlacanja,
      if (pozivNaBrojTip != null) 'poziv_na_broj_tip': pozivNaBrojTip,
      if (refundacijaPioIznos != null)
        'refundacija_pio_iznos': refundacijaPioIznos,
      if (stanjeRobeOperativnoOmoguceno != null)
        'stanje_robe_operativno_omoguceno': stanjeRobeOperativnoOmoguceno,
    });
  }

  AppPodesavanjaCompanion copyWith({
    Value<int>? id,
    Value<String>? ziroRacun,
    Value<String>? nazivBanke,
    Value<String>? qrPrimalacNaziv,
    Value<String>? qrSifraPlacanja,
    Value<String>? qrSvrhaPlacanja,
    Value<String>? pozivNaBrojTip,
    Value<double>? refundacijaPioIznos,
    Value<bool>? stanjeRobeOperativnoOmoguceno,
  }) {
    return AppPodesavanjaCompanion(
      id: id ?? this.id,
      ziroRacun: ziroRacun ?? this.ziroRacun,
      nazivBanke: nazivBanke ?? this.nazivBanke,
      qrPrimalacNaziv: qrPrimalacNaziv ?? this.qrPrimalacNaziv,
      qrSifraPlacanja: qrSifraPlacanja ?? this.qrSifraPlacanja,
      qrSvrhaPlacanja: qrSvrhaPlacanja ?? this.qrSvrhaPlacanja,
      pozivNaBrojTip: pozivNaBrojTip ?? this.pozivNaBrojTip,
      refundacijaPioIznos: refundacijaPioIznos ?? this.refundacijaPioIznos,
      stanjeRobeOperativnoOmoguceno:
          stanjeRobeOperativnoOmoguceno ?? this.stanjeRobeOperativnoOmoguceno,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ziroRacun.present) {
      map['ziro_racun'] = Variable<String>(ziroRacun.value);
    }
    if (nazivBanke.present) {
      map['naziv_banke'] = Variable<String>(nazivBanke.value);
    }
    if (qrPrimalacNaziv.present) {
      map['qr_primalac_naziv'] = Variable<String>(qrPrimalacNaziv.value);
    }
    if (qrSifraPlacanja.present) {
      map['qr_sifra_placanja'] = Variable<String>(qrSifraPlacanja.value);
    }
    if (qrSvrhaPlacanja.present) {
      map['qr_svrha_placanja'] = Variable<String>(qrSvrhaPlacanja.value);
    }
    if (pozivNaBrojTip.present) {
      map['poziv_na_broj_tip'] = Variable<String>(pozivNaBrojTip.value);
    }
    if (refundacijaPioIznos.present) {
      map['refundacija_pio_iznos'] = Variable<double>(
        refundacijaPioIznos.value,
      );
    }
    if (stanjeRobeOperativnoOmoguceno.present) {
      map['stanje_robe_operativno_omoguceno'] = Variable<bool>(
        stanjeRobeOperativnoOmoguceno.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPodesavanjaCompanion(')
          ..write('id: $id, ')
          ..write('ziroRacun: $ziroRacun, ')
          ..write('nazivBanke: $nazivBanke, ')
          ..write('qrPrimalacNaziv: $qrPrimalacNaziv, ')
          ..write('qrSifraPlacanja: $qrSifraPlacanja, ')
          ..write('qrSvrhaPlacanja: $qrSvrhaPlacanja, ')
          ..write('pozivNaBrojTip: $pozivNaBrojTip, ')
          ..write('refundacijaPioIznos: $refundacijaPioIznos, ')
          ..write(
            'stanjeRobeOperativnoOmoguceno: $stanjeRobeOperativnoOmoguceno',
          )
          ..write(')'))
        .toString();
  }
}

class $PredmetiTable extends Predmeti
    with TableInfo<$PredmetiTable, PredmetiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredmetiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _brojPredmetaMeta = const VerificationMeta(
    'brojPredmeta',
  );
  @override
  late final GeneratedColumn<String> brojPredmeta = GeneratedColumn<String>(
    'broj_predmeta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OTVOREN'),
  );
  static const VerificationMeta _datumKreiranjaMeta = const VerificationMeta(
    'datumKreiranja',
  );
  @override
  late final GeneratedColumn<String> datumKreiranja = GeneratedColumn<String>(
    'datum_kreiranja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _savetnikIdMeta = const VerificationMeta(
    'savetnikId',
  );
  @override
  late final GeneratedColumn<int> savetnikId = GeneratedColumn<int>(
    'savetnik_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verzijaMeta = const VerificationMeta(
    'verzija',
  );
  @override
  late final GeneratedColumn<int> verzija = GeneratedColumn<int>(
    'verzija',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _businessScenarioIdMeta =
      const VerificationMeta('businessScenarioId');
  @override
  late final GeneratedColumn<String> businessScenarioId =
      GeneratedColumn<String>(
        'business_scenario_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('default_funeral_ceremony_policy'),
      );
  static const VerificationMeta _sourceIdentityMeta = const VerificationMeta(
    'sourceIdentity',
  );
  @override
  late final GeneratedColumn<String> sourceIdentity = GeneratedColumn<String>(
    'source_identity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_opc'),
  );
  static const VerificationMeta _createdByKorisnikIdMeta =
      const VerificationMeta('createdByKorisnikId');
  @override
  late final GeneratedColumn<int> createdByKorisnikId = GeneratedColumn<int>(
    'created_by_korisnik_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastBusinessModifiedByKorisnikIdMeta =
      const VerificationMeta('lastBusinessModifiedByKorisnikId');
  @override
  late final GeneratedColumn<int> lastBusinessModifiedByKorisnikId =
      GeneratedColumn<int>(
        'last_business_modified_by_korisnik_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastBusinessModifiedAtMeta =
      const VerificationMeta('lastBusinessModifiedAt');
  @override
  late final GeneratedColumn<String> lastBusinessModifiedAt =
      GeneratedColumn<String>(
        'last_business_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _imeMeta = const VerificationMeta('ime');
  @override
  late final GeneratedColumn<String> ime = GeneratedColumn<String>(
    'ime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _prezimeMeta = const VerificationMeta(
    'prezime',
  );
  @override
  late final GeneratedColumn<String> prezime = GeneratedColumn<String>(
    'prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _srednjeMeta = const VerificationMeta(
    'srednje',
  );
  @override
  late final GeneratedColumn<String> srednje = GeneratedColumn<String>(
    'srednje',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _devojackoPrezimeMeta = const VerificationMeta(
    'devojackoPrezime',
  );
  @override
  late final GeneratedColumn<String> devojackoPrezime = GeneratedColumn<String>(
    'devojacko_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jmbgMeta = const VerificationMeta('jmbg');
  @override
  late final GeneratedColumn<String> jmbg = GeneratedColumn<String>(
    'jmbg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _polMeta = const VerificationMeta('pol');
  @override
  late final GeneratedColumn<String> pol = GeneratedColumn<String>(
    'pol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('M'),
  );
  static const VerificationMeta _datumRodjenjaMeta = const VerificationMeta(
    'datumRodjenja',
  );
  @override
  late final GeneratedColumn<String> datumRodjenja = GeneratedColumn<String>(
    'datum_rodjenja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mestoRodjenjaMeta = const VerificationMeta(
    'mestoRodjenja',
  );
  @override
  late final GeneratedColumn<String> mestoRodjenja = GeneratedColumn<String>(
    'mesto_rodjenja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _datumSmrtiMeta = const VerificationMeta(
    'datumSmrti',
  );
  @override
  late final GeneratedColumn<String> datumSmrti = GeneratedColumn<String>(
    'datum_smrti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mestoSmrtiMeta = const VerificationMeta(
    'mestoSmrti',
  );
  @override
  late final GeneratedColumn<String> mestoSmrti = GeneratedColumn<String>(
    'mesto_smrti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _uzrokSmrtiMeta = const VerificationMeta(
    'uzrokSmrti',
  );
  @override
  late final GeneratedColumn<String> uzrokSmrti = GeneratedColumn<String>(
    'uzrok_smrti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _adresaMeta = const VerificationMeta('adresa');
  @override
  late final GeneratedColumn<String> adresa = GeneratedColumn<String>(
    'adresa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imeOcaMeta = const VerificationMeta('imeOca');
  @override
  late final GeneratedColumn<String> imeOca = GeneratedColumn<String>(
    'ime_oca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imeMajkeMeta = const VerificationMeta(
    'imeMajke',
  );
  @override
  late final GeneratedColumn<String> imeMajke = GeneratedColumn<String>(
    'ime_majke',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bracnoStanjeMeta = const VerificationMeta(
    'bracnoStanje',
  );
  @override
  late final GeneratedColumn<String> bracnoStanje = GeneratedColumn<String>(
    'bracno_stanje',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bracniDrugImeMeta = const VerificationMeta(
    'bracniDrugIme',
  );
  @override
  late final GeneratedColumn<String> bracniDrugIme = GeneratedColumn<String>(
    'bracni_drug_ime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bracniDrugPrezimeMeta = const VerificationMeta(
    'bracniDrugPrezime',
  );
  @override
  late final GeneratedColumn<String> bracniDrugPrezime =
      GeneratedColumn<String>(
        'bracni_drug_prezime',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _bracniDrugPolMeta = const VerificationMeta(
    'bracniDrugPol',
  );
  @override
  late final GeneratedColumn<String> bracniDrugPol = GeneratedColumn<String>(
    'bracni_drug_pol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bracniDrugJmbgMeta = const VerificationMeta(
    'bracniDrugJmbg',
  );
  @override
  late final GeneratedColumn<String> bracniDrugJmbg = GeneratedColumn<String>(
    'bracni_drug_jmbg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bracniDrugDevojackoMeta =
      const VerificationMeta('bracniDrugDevojacko');
  @override
  late final GeneratedColumn<String> bracniDrugDevojacko =
      GeneratedColumn<String>(
        'bracni_drug_devojacko',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _zanimanjeMeta = const VerificationMeta(
    'zanimanje',
  );
  @override
  late final GeneratedColumn<String> zanimanje = GeneratedColumn<String>(
    'zanimanje',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _zanimanjeNaPartiMeta = const VerificationMeta(
    'zanimanjeNaParti',
  );
  @override
  late final GeneratedColumn<bool> zanimanjeNaParti = GeneratedColumn<bool>(
    'zanimanje_na_parti',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("zanimanje_na_parti" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _titulaMeta = const VerificationMeta('titula');
  @override
  late final GeneratedColumn<String> titula = GeneratedColumn<String>(
    'titula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titulaIspredMeta = const VerificationMeta(
    'titulaIspred',
  );
  @override
  late final GeneratedColumn<bool> titulaIspred = GeneratedColumn<bool>(
    'titula_ispred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("titula_ispred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cinMeta = const VerificationMeta('cin');
  @override
  late final GeneratedColumn<String> cin = GeneratedColumn<String>(
    'cin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cinNaPartiMeta = const VerificationMeta(
    'cinNaParti',
  );
  @override
  late final GeneratedColumn<bool> cinNaParti = GeneratedColumn<bool>(
    'cin_na_parti',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cin_na_parti" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _srednjeNaPartiMeta = const VerificationMeta(
    'srednjeNaParti',
  );
  @override
  late final GeneratedColumn<bool> srednjeNaParti = GeneratedColumn<bool>(
    'srednje_na_parti',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("srednje_na_parti" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nadimakMeta = const VerificationMeta(
    'nadimak',
  );
  @override
  late final GeneratedColumn<String> nadimak = GeneratedColumn<String>(
    'nadimak',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nadimakNaPartiMeta = const VerificationMeta(
    'nadimakNaParti',
  );
  @override
  late final GeneratedColumn<bool> nadimakNaParti = GeneratedColumn<bool>(
    'nadimak_na_parti',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nadimak_na_parti" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nadimakCrticaMeta = const VerificationMeta(
    'nadimakCrtica',
  );
  @override
  late final GeneratedColumn<bool> nadimakCrtica = GeneratedColumn<bool>(
    'nadimak_crtica',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nadimak_crtica" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _radniStatusMeta = const VerificationMeta(
    'radniStatus',
  );
  @override
  late final GeneratedColumn<String> radniStatus = GeneratedColumn<String>(
    'radni_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _penzionerMeta = const VerificationMeta(
    'penzioner',
  );
  @override
  late final GeneratedColumn<String> penzioner = GeneratedColumn<String>(
    'penzioner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NE'),
  );
  static const VerificationMeta _penzionerSrbijeMeta = const VerificationMeta(
    'penzionerSrbije',
  );
  @override
  late final GeneratedColumn<String> penzionerSrbije = GeneratedColumn<String>(
    'penzioner_srbije',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NE'),
  );
  static const VerificationMeta _vojniPenzionerMeta = const VerificationMeta(
    'vojniPenzioner',
  );
  @override
  late final GeneratedColumn<String> vojniPenzioner = GeneratedColumn<String>(
    'vojni_penzioner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NE'),
  );
  static const VerificationMeta _vojnePocastiMeta = const VerificationMeta(
    'vojnePocasti',
  );
  @override
  late final GeneratedColumn<String> vojnePocasti = GeneratedColumn<String>(
    'vojne_pocasti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NE'),
  );
  static const VerificationMeta _posmrtnaPomocMeta = const VerificationMeta(
    'posmrtnaPomoc',
  );
  @override
  late final GeneratedColumn<String> posmrtnaPomoc = GeneratedColumn<String>(
    'posmrtna_pomoc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NE'),
  );
  static const VerificationMeta _refundacijaPioMeta = const VerificationMeta(
    'refundacijaPio',
  );
  @override
  late final GeneratedColumn<double> refundacijaPio = GeneratedColumn<double>(
    'refundacija_pio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _narucilacRefundiraMeta =
      const VerificationMeta('narucilacRefundira');
  @override
  late final GeneratedColumn<String> narucilacRefundira =
      GeneratedColumn<String>(
        'narucilac_refundira',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('NE'),
      );
  static const VerificationMeta _bracniDrugOstvarujePravoMeta =
      const VerificationMeta('bracniDrugOstvarujePravo');
  @override
  late final GeneratedColumn<String> bracniDrugOstvarujePravo =
      GeneratedColumn<String>(
        'bracni_drug_ostvaruje_pravo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('NE'),
      );
  static const VerificationMeta _bracniDrugJePenzionerMeta =
      const VerificationMeta('bracniDrugJePenzioner');
  @override
  late final GeneratedColumn<String> bracniDrugJePenzioner =
      GeneratedColumn<String>(
        'bracni_drug_je_penzioner',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('NE'),
      );
  static const VerificationMeta _penzionerNapomenaMeta = const VerificationMeta(
    'penzionerNapomena',
  );
  @override
  late final GeneratedColumn<String> penzionerNapomena =
      GeneratedColumn<String>(
        'penzioner_napomena',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _naruTipMeta = const VerificationMeta(
    'naruTip',
  );
  @override
  late final GeneratedColumn<String> naruTip = GeneratedColumn<String>(
    'naru_tip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruImeMeta = const VerificationMeta(
    'naruIme',
  );
  @override
  late final GeneratedColumn<String> naruIme = GeneratedColumn<String>(
    'naru_ime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPrezimeMeta = const VerificationMeta(
    'naruPrezime',
  );
  @override
  late final GeneratedColumn<String> naruPrezime = GeneratedColumn<String>(
    'naru_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruImePrezimeMeta = const VerificationMeta(
    'naruImePrezime',
  );
  @override
  late final GeneratedColumn<String> naruImePrezime = GeneratedColumn<String>(
    'naru_ime_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruJmbgMeta = const VerificationMeta(
    'naruJmbg',
  );
  @override
  late final GeneratedColumn<String> naruJmbg = GeneratedColumn<String>(
    'naru_jmbg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruAdresaMeta = const VerificationMeta(
    'naruAdresa',
  );
  @override
  late final GeneratedColumn<String> naruAdresa = GeneratedColumn<String>(
    'naru_adresa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruBrojLkMeta = const VerificationMeta(
    'naruBrojLk',
  );
  @override
  late final GeneratedColumn<String> naruBrojLk = GeneratedColumn<String>(
    'naru_broj_lk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruTelefon1Meta = const VerificationMeta(
    'naruTelefon1',
  );
  @override
  late final GeneratedColumn<String> naruTelefon1 = GeneratedColumn<String>(
    'naru_telefon1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruTelefon2Meta = const VerificationMeta(
    'naruTelefon2',
  );
  @override
  late final GeneratedColumn<String> naruTelefon2 = GeneratedColumn<String>(
    'naru_telefon2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruEmailMeta = const VerificationMeta(
    'naruEmail',
  );
  @override
  late final GeneratedColumn<String> naruEmail = GeneratedColumn<String>(
    'naru_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlNazivMeta = const VerificationMeta(
    'naruPlNaziv',
  );
  @override
  late final GeneratedColumn<String> naruPlNaziv = GeneratedColumn<String>(
    'naru_pl_naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlAdresaMeta = const VerificationMeta(
    'naruPlAdresa',
  );
  @override
  late final GeneratedColumn<String> naruPlAdresa = GeneratedColumn<String>(
    'naru_pl_adresa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlPibMeta = const VerificationMeta(
    'naruPlPib',
  );
  @override
  late final GeneratedColumn<String> naruPlPib = GeneratedColumn<String>(
    'naru_pl_pib',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlMbMeta = const VerificationMeta(
    'naruPlMb',
  );
  @override
  late final GeneratedColumn<String> naruPlMb = GeneratedColumn<String>(
    'naru_pl_mb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlOdgovornoLiceMeta =
      const VerificationMeta('naruPlOdgovornoLice');
  @override
  late final GeneratedColumn<String> naruPlOdgovornoLice =
      GeneratedColumn<String>(
        'naru_pl_odgovorno_lice',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _naruPlTelefon1Meta = const VerificationMeta(
    'naruPlTelefon1',
  );
  @override
  late final GeneratedColumn<String> naruPlTelefon1 = GeneratedColumn<String>(
    'naru_pl_telefon1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlTelefon2Meta = const VerificationMeta(
    'naruPlTelefon2',
  );
  @override
  late final GeneratedColumn<String> naruPlTelefon2 = GeneratedColumn<String>(
    'naru_pl_telefon2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruPlEmailMeta = const VerificationMeta(
    'naruPlEmail',
  );
  @override
  late final GeneratedColumn<String> naruPlEmail = GeneratedColumn<String>(
    'naru_pl_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _naruIstiZaJkpMeta = const VerificationMeta(
    'naruIstiZaJkp',
  );
  @override
  late final GeneratedColumn<bool> naruIstiZaJkp = GeneratedColumn<bool>(
    'naru_isti_za_jkp',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("naru_isti_za_jkp" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _jkpTipMeta = const VerificationMeta('jkpTip');
  @override
  late final GeneratedColumn<String> jkpTip = GeneratedColumn<String>(
    'jkp_tip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpImeMeta = const VerificationMeta('jkpIme');
  @override
  late final GeneratedColumn<String> jkpIme = GeneratedColumn<String>(
    'jkp_ime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPrezimeMeta = const VerificationMeta(
    'jkpPrezime',
  );
  @override
  late final GeneratedColumn<String> jkpPrezime = GeneratedColumn<String>(
    'jkp_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpImePrezimeMeta = const VerificationMeta(
    'jkpImePrezime',
  );
  @override
  late final GeneratedColumn<String> jkpImePrezime = GeneratedColumn<String>(
    'jkp_ime_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpJmbgMeta = const VerificationMeta(
    'jkpJmbg',
  );
  @override
  late final GeneratedColumn<String> jkpJmbg = GeneratedColumn<String>(
    'jkp_jmbg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpAdresaMeta = const VerificationMeta(
    'jkpAdresa',
  );
  @override
  late final GeneratedColumn<String> jkpAdresa = GeneratedColumn<String>(
    'jkp_adresa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpBrojLkMeta = const VerificationMeta(
    'jkpBrojLk',
  );
  @override
  late final GeneratedColumn<String> jkpBrojLk = GeneratedColumn<String>(
    'jkp_broj_lk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpTelefon1Meta = const VerificationMeta(
    'jkpTelefon1',
  );
  @override
  late final GeneratedColumn<String> jkpTelefon1 = GeneratedColumn<String>(
    'jkp_telefon1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpTelefon2Meta = const VerificationMeta(
    'jkpTelefon2',
  );
  @override
  late final GeneratedColumn<String> jkpTelefon2 = GeneratedColumn<String>(
    'jkp_telefon2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpEmailMeta = const VerificationMeta(
    'jkpEmail',
  );
  @override
  late final GeneratedColumn<String> jkpEmail = GeneratedColumn<String>(
    'jkp_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPlNazivMeta = const VerificationMeta(
    'jkpPlNaziv',
  );
  @override
  late final GeneratedColumn<String> jkpPlNaziv = GeneratedColumn<String>(
    'jkp_pl_naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPlAdresaMeta = const VerificationMeta(
    'jkpPlAdresa',
  );
  @override
  late final GeneratedColumn<String> jkpPlAdresa = GeneratedColumn<String>(
    'jkp_pl_adresa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPlPibMeta = const VerificationMeta(
    'jkpPlPib',
  );
  @override
  late final GeneratedColumn<String> jkpPlPib = GeneratedColumn<String>(
    'jkp_pl_pib',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPlMbMeta = const VerificationMeta(
    'jkpPlMb',
  );
  @override
  late final GeneratedColumn<String> jkpPlMb = GeneratedColumn<String>(
    'jkp_pl_mb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPlOdgovornoLiceMeta =
      const VerificationMeta('jkpPlOdgovornoLice');
  @override
  late final GeneratedColumn<String> jkpPlOdgovornoLice =
      GeneratedColumn<String>(
        'jkp_pl_odgovorno_lice',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _jkpPlTelefon1Meta = const VerificationMeta(
    'jkpPlTelefon1',
  );
  @override
  late final GeneratedColumn<String> jkpPlTelefon1 = GeneratedColumn<String>(
    'jkp_pl_telefon1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jkpPlEmailMeta = const VerificationMeta(
    'jkpPlEmail',
  );
  @override
  late final GeneratedColumn<String> jkpPlEmail = GeneratedColumn<String>(
    'jkp_pl_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _grobljeMeta = const VerificationMeta(
    'groblje',
  );
  @override
  late final GeneratedColumn<String> groblje = GeneratedColumn<String>(
    'groblje',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tipGrobljaMeta = const VerificationMeta(
    'tipGroblja',
  );
  @override
  late final GeneratedColumn<String> tipGroblja = GeneratedColumn<String>(
    'tip_groblja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GRADSKO'),
  );
  static const VerificationMeta _vrstaCeremonijeMeta = const VerificationMeta(
    'vrstaCeremonije',
  );
  @override
  late final GeneratedColumn<String> vrstaCeremonije = GeneratedColumn<String>(
    'vrsta_ceremonije',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SAHRANA'),
  );
  static const VerificationMeta _datumCeremonijeMeta = const VerificationMeta(
    'datumCeremonije',
  );
  @override
  late final GeneratedColumn<String> datumCeremonije = GeneratedColumn<String>(
    'datum_ceremonije',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vremeCeremonijeMeta = const VerificationMeta(
    'vremeCeremonije',
  );
  @override
  late final GeneratedColumn<String> vremeCeremonije = GeneratedColumn<String>(
    'vreme_ceremonije',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _opeloMeta = const VerificationMeta('opelo');
  @override
  late final GeneratedColumn<String> opelo = GeneratedColumn<String>(
    'opelo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NE'),
  );
  static const VerificationMeta _opeloMestoMeta = const VerificationMeta(
    'opeloMesto',
  );
  @override
  late final GeneratedColumn<String> opeloMesto = GeneratedColumn<String>(
    'opelo_mesto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vremeOpelaMeta = const VerificationMeta(
    'vremeOpela',
  );
  @override
  late final GeneratedColumn<String> vremeOpela = GeneratedColumn<String>(
    'vreme_opela',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vremeIspracajaMeta = const VerificationMeta(
    'vremeIspracaja',
  );
  @override
  late final GeneratedColumn<String> vremeIspracaja = GeneratedColumn<String>(
    'vreme_ispracaja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _grobnoMestoMeta = const VerificationMeta(
    'grobnoMesto',
  );
  @override
  late final GeneratedColumn<String> grobnoMesto = GeneratedColumn<String>(
    'grobno_mesto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NOVO'),
  );
  static const VerificationMeta _tipGrobnogMestaMeta = const VerificationMeta(
    'tipGrobnogMesta',
  );
  @override
  late final GeneratedColumn<String> tipGrobnogMesta = GeneratedColumn<String>(
    'tip_grobnog_mesta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GROB'),
  );
  static const VerificationMeta _parcelaMeta = const VerificationMeta(
    'parcela',
  );
  @override
  late final GeneratedColumn<String> parcela = GeneratedColumn<String>(
    'parcela',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _grobBrojMeta = const VerificationMeta(
    'grobBroj',
  );
  @override
  late final GeneratedColumn<String> grobBroj = GeneratedColumn<String>(
    'grob_broj',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _redGrobMeta = const VerificationMeta(
    'redGrob',
  );
  @override
  late final GeneratedColumn<String> redGrob = GeneratedColumn<String>(
    'red_grob',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _npkMeta = const VerificationMeta('npk');
  @override
  late final GeneratedColumn<String> npk = GeneratedColumn<String>(
    'npk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _grobnicaMeta = const VerificationMeta(
    'grobnica',
  );
  @override
  late final GeneratedColumn<String> grobnica = GeneratedColumn<String>(
    'grobnica',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urnaSifraMeta = const VerificationMeta(
    'urnaSifra',
  );
  @override
  late final GeneratedColumn<String> urnaSifra = GeneratedColumn<String>(
    'urna_sifra',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tipPolaganjaMeta = const VerificationMeta(
    'tipPolaganja',
  );
  @override
  late final GeneratedColumn<String> tipPolaganja = GeneratedColumn<String>(
    'tip_polaganja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NAKNADNO'),
  );
  static const VerificationMeta _urnaParcelaMeta = const VerificationMeta(
    'urnaParcela',
  );
  @override
  late final GeneratedColumn<String> urnaParcela = GeneratedColumn<String>(
    'urna_parcela',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urnaBrojMeta = const VerificationMeta(
    'urnaBroj',
  );
  @override
  late final GeneratedColumn<String> urnaBroj = GeneratedColumn<String>(
    'urna_broj',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urnaRedMeta = const VerificationMeta(
    'urnaRed',
  );
  @override
  late final GeneratedColumn<String> urnaRed = GeneratedColumn<String>(
    'urna_red',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urnaNpkMeta = const VerificationMeta(
    'urnaNpk',
  );
  @override
  late final GeneratedColumn<String> urnaNpk = GeneratedColumn<String>(
    'urna_npk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sahranaVanSrbijeMeta = const VerificationMeta(
    'sahranaVanSrbije',
  );
  @override
  late final GeneratedColumn<bool> sahranaVanSrbije = GeneratedColumn<bool>(
    'sahrana_van_srbije',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sahrana_van_srbije" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _svisZemljaMeta = const VerificationMeta(
    'svisZemlja',
  );
  @override
  late final GeneratedColumn<String> svisZemlja = GeneratedColumn<String>(
    'svis_zemlja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _svisGradMeta = const VerificationMeta(
    'svisGrad',
  );
  @override
  late final GeneratedColumn<String> svisGrad = GeneratedColumn<String>(
    'svis_grad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _docekPosmrtnihOstatakaMeta =
      const VerificationMeta('docekPosmrtnihOstataka');
  @override
  late final GeneratedColumn<bool> docekPosmrtnihOstataka =
      GeneratedColumn<bool>(
        'docek_posmrtnih_ostataka',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("docek_posmrtnih_ostataka" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _docekMestoMeta = const VerificationMeta(
    'docekMesto',
  );
  @override
  late final GeneratedColumn<String> docekMesto = GeneratedColumn<String>(
    'docek_mesto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _docekVremeMeta = const VerificationMeta(
    'docekVreme',
  );
  @override
  late final GeneratedColumn<String> docekVreme = GeneratedColumn<String>(
    'docek_vreme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _simbolMeta = const VerificationMeta('simbol');
  @override
  late final GeneratedColumn<String> simbol = GeneratedColumn<String>(
    'simbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PRAVOSLAVNI_KRST_SVETOSAVSKI'),
  );
  static const VerificationMeta _pismoMeta = const VerificationMeta('pismo');
  @override
  late final GeneratedColumn<String> pismo = GeneratedColumn<String>(
    'pismo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('LATINICA'),
  );
  static const VerificationMeta _parteImeMeta = const VerificationMeta(
    'parteIme',
  );
  @override
  late final GeneratedColumn<String> parteIme = GeneratedColumn<String>(
    'parte_ime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ozaloseniMeta = const VerificationMeta(
    'ozaloseni',
  );
  @override
  late final GeneratedColumn<String> ozaloseni = GeneratedColumn<String>(
    'ozaloseni',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avansMeta = const VerificationMeta('avans');
  @override
  late final GeneratedColumn<double> avans = GeneratedColumn<double>(
    'avans',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _troskoviJkpMeta = const VerificationMeta(
    'troskoviJkp',
  );
  @override
  late final GeneratedColumn<double> troskoviJkp = GeneratedColumn<double>(
    'troskovi_jkp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _jkpPlacaSamostalnoMeta =
      const VerificationMeta('jkpPlacaSamostalno');
  @override
  late final GeneratedColumn<bool> jkpPlacaSamostalno = GeneratedColumn<bool>(
    'jkp_placa_samostalno',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("jkp_placa_samostalno" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _popustMeta = const VerificationMeta('popust');
  @override
  late final GeneratedColumn<double> popust = GeneratedColumn<double>(
    'popust',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _nacinPlacanjaMeta = const VerificationMeta(
    'nacinPlacanja',
  );
  @override
  late final GeneratedColumn<String> nacinPlacanja = GeneratedColumn<String>(
    'nacin_placanja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _napomenaPlacanjaMeta = const VerificationMeta(
    'napomenaPlacanja',
  );
  @override
  late final GeneratedColumn<String> napomenaPlacanja = GeneratedColumn<String>(
    'napomena_placanja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _napomenaMeta = const VerificationMeta(
    'napomena',
  );
  @override
  late final GeneratedColumn<String> napomena = GeneratedColumn<String>(
    'napomena',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exportVerzijaMeta = const VerificationMeta(
    'exportVerzija',
  );
  @override
  late final GeneratedColumn<int> exportVerzija = GeneratedColumn<int>(
    'export_verzija',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    brojPredmeta,
    status,
    datumKreiranja,
    savetnikId,
    verzija,
    businessScenarioId,
    sourceIdentity,
    createdByKorisnikId,
    lastBusinessModifiedByKorisnikId,
    lastBusinessModifiedAt,
    ime,
    prezime,
    srednje,
    devojackoPrezime,
    jmbg,
    pol,
    datumRodjenja,
    mestoRodjenja,
    datumSmrti,
    mestoSmrti,
    uzrokSmrti,
    adresa,
    imeOca,
    imeMajke,
    bracnoStanje,
    bracniDrugIme,
    bracniDrugPrezime,
    bracniDrugPol,
    bracniDrugJmbg,
    bracniDrugDevojacko,
    zanimanje,
    zanimanjeNaParti,
    titula,
    titulaIspred,
    cin,
    cinNaParti,
    srednjeNaParti,
    nadimak,
    nadimakNaParti,
    nadimakCrtica,
    radniStatus,
    penzioner,
    penzionerSrbije,
    vojniPenzioner,
    vojnePocasti,
    posmrtnaPomoc,
    refundacijaPio,
    narucilacRefundira,
    bracniDrugOstvarujePravo,
    bracniDrugJePenzioner,
    penzionerNapomena,
    naruTip,
    naruIme,
    naruPrezime,
    naruImePrezime,
    naruJmbg,
    naruAdresa,
    naruBrojLk,
    naruTelefon1,
    naruTelefon2,
    naruEmail,
    naruPlNaziv,
    naruPlAdresa,
    naruPlPib,
    naruPlMb,
    naruPlOdgovornoLice,
    naruPlTelefon1,
    naruPlTelefon2,
    naruPlEmail,
    naruIstiZaJkp,
    jkpTip,
    jkpIme,
    jkpPrezime,
    jkpImePrezime,
    jkpJmbg,
    jkpAdresa,
    jkpBrojLk,
    jkpTelefon1,
    jkpTelefon2,
    jkpEmail,
    jkpPlNaziv,
    jkpPlAdresa,
    jkpPlPib,
    jkpPlMb,
    jkpPlOdgovornoLice,
    jkpPlTelefon1,
    jkpPlEmail,
    groblje,
    tipGroblja,
    vrstaCeremonije,
    datumCeremonije,
    vremeCeremonije,
    opelo,
    opeloMesto,
    vremeOpela,
    vremeIspracaja,
    grobnoMesto,
    tipGrobnogMesta,
    parcela,
    grobBroj,
    redGrob,
    npk,
    grobnica,
    urnaSifra,
    tipPolaganja,
    urnaParcela,
    urnaBroj,
    urnaRed,
    urnaNpk,
    sahranaVanSrbije,
    svisZemlja,
    svisGrad,
    docekPosmrtnihOstataka,
    docekMesto,
    docekVreme,
    simbol,
    pismo,
    parteIme,
    ozaloseni,
    avans,
    troskoviJkp,
    jkpPlacaSamostalno,
    popust,
    nacinPlacanja,
    napomenaPlacanja,
    napomena,
    exportVerzija,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predmeti';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredmetiData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('broj_predmeta')) {
      context.handle(
        _brojPredmetaMeta,
        brojPredmeta.isAcceptableOrUnknown(
          data['broj_predmeta']!,
          _brojPredmetaMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('datum_kreiranja')) {
      context.handle(
        _datumKreiranjaMeta,
        datumKreiranja.isAcceptableOrUnknown(
          data['datum_kreiranja']!,
          _datumKreiranjaMeta,
        ),
      );
    }
    if (data.containsKey('savetnik_id')) {
      context.handle(
        _savetnikIdMeta,
        savetnikId.isAcceptableOrUnknown(data['savetnik_id']!, _savetnikIdMeta),
      );
    }
    if (data.containsKey('verzija')) {
      context.handle(
        _verzijaMeta,
        verzija.isAcceptableOrUnknown(data['verzija']!, _verzijaMeta),
      );
    }
    if (data.containsKey('business_scenario_id')) {
      context.handle(
        _businessScenarioIdMeta,
        businessScenarioId.isAcceptableOrUnknown(
          data['business_scenario_id']!,
          _businessScenarioIdMeta,
        ),
      );
    }
    if (data.containsKey('source_identity')) {
      context.handle(
        _sourceIdentityMeta,
        sourceIdentity.isAcceptableOrUnknown(
          data['source_identity']!,
          _sourceIdentityMeta,
        ),
      );
    }
    if (data.containsKey('created_by_korisnik_id')) {
      context.handle(
        _createdByKorisnikIdMeta,
        createdByKorisnikId.isAcceptableOrUnknown(
          data['created_by_korisnik_id']!,
          _createdByKorisnikIdMeta,
        ),
      );
    }
    if (data.containsKey('last_business_modified_by_korisnik_id')) {
      context.handle(
        _lastBusinessModifiedByKorisnikIdMeta,
        lastBusinessModifiedByKorisnikId.isAcceptableOrUnknown(
          data['last_business_modified_by_korisnik_id']!,
          _lastBusinessModifiedByKorisnikIdMeta,
        ),
      );
    }
    if (data.containsKey('last_business_modified_at')) {
      context.handle(
        _lastBusinessModifiedAtMeta,
        lastBusinessModifiedAt.isAcceptableOrUnknown(
          data['last_business_modified_at']!,
          _lastBusinessModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('ime')) {
      context.handle(
        _imeMeta,
        ime.isAcceptableOrUnknown(data['ime']!, _imeMeta),
      );
    }
    if (data.containsKey('prezime')) {
      context.handle(
        _prezimeMeta,
        prezime.isAcceptableOrUnknown(data['prezime']!, _prezimeMeta),
      );
    }
    if (data.containsKey('srednje')) {
      context.handle(
        _srednjeMeta,
        srednje.isAcceptableOrUnknown(data['srednje']!, _srednjeMeta),
      );
    }
    if (data.containsKey('devojacko_prezime')) {
      context.handle(
        _devojackoPrezimeMeta,
        devojackoPrezime.isAcceptableOrUnknown(
          data['devojacko_prezime']!,
          _devojackoPrezimeMeta,
        ),
      );
    }
    if (data.containsKey('jmbg')) {
      context.handle(
        _jmbgMeta,
        jmbg.isAcceptableOrUnknown(data['jmbg']!, _jmbgMeta),
      );
    }
    if (data.containsKey('pol')) {
      context.handle(
        _polMeta,
        pol.isAcceptableOrUnknown(data['pol']!, _polMeta),
      );
    }
    if (data.containsKey('datum_rodjenja')) {
      context.handle(
        _datumRodjenjaMeta,
        datumRodjenja.isAcceptableOrUnknown(
          data['datum_rodjenja']!,
          _datumRodjenjaMeta,
        ),
      );
    }
    if (data.containsKey('mesto_rodjenja')) {
      context.handle(
        _mestoRodjenjaMeta,
        mestoRodjenja.isAcceptableOrUnknown(
          data['mesto_rodjenja']!,
          _mestoRodjenjaMeta,
        ),
      );
    }
    if (data.containsKey('datum_smrti')) {
      context.handle(
        _datumSmrtiMeta,
        datumSmrti.isAcceptableOrUnknown(data['datum_smrti']!, _datumSmrtiMeta),
      );
    }
    if (data.containsKey('mesto_smrti')) {
      context.handle(
        _mestoSmrtiMeta,
        mestoSmrti.isAcceptableOrUnknown(data['mesto_smrti']!, _mestoSmrtiMeta),
      );
    }
    if (data.containsKey('uzrok_smrti')) {
      context.handle(
        _uzrokSmrtiMeta,
        uzrokSmrti.isAcceptableOrUnknown(data['uzrok_smrti']!, _uzrokSmrtiMeta),
      );
    }
    if (data.containsKey('adresa')) {
      context.handle(
        _adresaMeta,
        adresa.isAcceptableOrUnknown(data['adresa']!, _adresaMeta),
      );
    }
    if (data.containsKey('ime_oca')) {
      context.handle(
        _imeOcaMeta,
        imeOca.isAcceptableOrUnknown(data['ime_oca']!, _imeOcaMeta),
      );
    }
    if (data.containsKey('ime_majke')) {
      context.handle(
        _imeMajkeMeta,
        imeMajke.isAcceptableOrUnknown(data['ime_majke']!, _imeMajkeMeta),
      );
    }
    if (data.containsKey('bracno_stanje')) {
      context.handle(
        _bracnoStanjeMeta,
        bracnoStanje.isAcceptableOrUnknown(
          data['bracno_stanje']!,
          _bracnoStanjeMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_ime')) {
      context.handle(
        _bracniDrugImeMeta,
        bracniDrugIme.isAcceptableOrUnknown(
          data['bracni_drug_ime']!,
          _bracniDrugImeMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_prezime')) {
      context.handle(
        _bracniDrugPrezimeMeta,
        bracniDrugPrezime.isAcceptableOrUnknown(
          data['bracni_drug_prezime']!,
          _bracniDrugPrezimeMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_pol')) {
      context.handle(
        _bracniDrugPolMeta,
        bracniDrugPol.isAcceptableOrUnknown(
          data['bracni_drug_pol']!,
          _bracniDrugPolMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_jmbg')) {
      context.handle(
        _bracniDrugJmbgMeta,
        bracniDrugJmbg.isAcceptableOrUnknown(
          data['bracni_drug_jmbg']!,
          _bracniDrugJmbgMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_devojacko')) {
      context.handle(
        _bracniDrugDevojackoMeta,
        bracniDrugDevojacko.isAcceptableOrUnknown(
          data['bracni_drug_devojacko']!,
          _bracniDrugDevojackoMeta,
        ),
      );
    }
    if (data.containsKey('zanimanje')) {
      context.handle(
        _zanimanjeMeta,
        zanimanje.isAcceptableOrUnknown(data['zanimanje']!, _zanimanjeMeta),
      );
    }
    if (data.containsKey('zanimanje_na_parti')) {
      context.handle(
        _zanimanjeNaPartiMeta,
        zanimanjeNaParti.isAcceptableOrUnknown(
          data['zanimanje_na_parti']!,
          _zanimanjeNaPartiMeta,
        ),
      );
    }
    if (data.containsKey('titula')) {
      context.handle(
        _titulaMeta,
        titula.isAcceptableOrUnknown(data['titula']!, _titulaMeta),
      );
    }
    if (data.containsKey('titula_ispred')) {
      context.handle(
        _titulaIspredMeta,
        titulaIspred.isAcceptableOrUnknown(
          data['titula_ispred']!,
          _titulaIspredMeta,
        ),
      );
    }
    if (data.containsKey('cin')) {
      context.handle(
        _cinMeta,
        cin.isAcceptableOrUnknown(data['cin']!, _cinMeta),
      );
    }
    if (data.containsKey('cin_na_parti')) {
      context.handle(
        _cinNaPartiMeta,
        cinNaParti.isAcceptableOrUnknown(
          data['cin_na_parti']!,
          _cinNaPartiMeta,
        ),
      );
    }
    if (data.containsKey('srednje_na_parti')) {
      context.handle(
        _srednjeNaPartiMeta,
        srednjeNaParti.isAcceptableOrUnknown(
          data['srednje_na_parti']!,
          _srednjeNaPartiMeta,
        ),
      );
    }
    if (data.containsKey('nadimak')) {
      context.handle(
        _nadimakMeta,
        nadimak.isAcceptableOrUnknown(data['nadimak']!, _nadimakMeta),
      );
    }
    if (data.containsKey('nadimak_na_parti')) {
      context.handle(
        _nadimakNaPartiMeta,
        nadimakNaParti.isAcceptableOrUnknown(
          data['nadimak_na_parti']!,
          _nadimakNaPartiMeta,
        ),
      );
    }
    if (data.containsKey('nadimak_crtica')) {
      context.handle(
        _nadimakCrticaMeta,
        nadimakCrtica.isAcceptableOrUnknown(
          data['nadimak_crtica']!,
          _nadimakCrticaMeta,
        ),
      );
    }
    if (data.containsKey('radni_status')) {
      context.handle(
        _radniStatusMeta,
        radniStatus.isAcceptableOrUnknown(
          data['radni_status']!,
          _radniStatusMeta,
        ),
      );
    }
    if (data.containsKey('penzioner')) {
      context.handle(
        _penzionerMeta,
        penzioner.isAcceptableOrUnknown(data['penzioner']!, _penzionerMeta),
      );
    }
    if (data.containsKey('penzioner_srbije')) {
      context.handle(
        _penzionerSrbijeMeta,
        penzionerSrbije.isAcceptableOrUnknown(
          data['penzioner_srbije']!,
          _penzionerSrbijeMeta,
        ),
      );
    }
    if (data.containsKey('vojni_penzioner')) {
      context.handle(
        _vojniPenzionerMeta,
        vojniPenzioner.isAcceptableOrUnknown(
          data['vojni_penzioner']!,
          _vojniPenzionerMeta,
        ),
      );
    }
    if (data.containsKey('vojne_pocasti')) {
      context.handle(
        _vojnePocastiMeta,
        vojnePocasti.isAcceptableOrUnknown(
          data['vojne_pocasti']!,
          _vojnePocastiMeta,
        ),
      );
    }
    if (data.containsKey('posmrtna_pomoc')) {
      context.handle(
        _posmrtnaPomocMeta,
        posmrtnaPomoc.isAcceptableOrUnknown(
          data['posmrtna_pomoc']!,
          _posmrtnaPomocMeta,
        ),
      );
    }
    if (data.containsKey('refundacija_pio')) {
      context.handle(
        _refundacijaPioMeta,
        refundacijaPio.isAcceptableOrUnknown(
          data['refundacija_pio']!,
          _refundacijaPioMeta,
        ),
      );
    }
    if (data.containsKey('narucilac_refundira')) {
      context.handle(
        _narucilacRefundiraMeta,
        narucilacRefundira.isAcceptableOrUnknown(
          data['narucilac_refundira']!,
          _narucilacRefundiraMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_ostvaruje_pravo')) {
      context.handle(
        _bracniDrugOstvarujePravoMeta,
        bracniDrugOstvarujePravo.isAcceptableOrUnknown(
          data['bracni_drug_ostvaruje_pravo']!,
          _bracniDrugOstvarujePravoMeta,
        ),
      );
    }
    if (data.containsKey('bracni_drug_je_penzioner')) {
      context.handle(
        _bracniDrugJePenzionerMeta,
        bracniDrugJePenzioner.isAcceptableOrUnknown(
          data['bracni_drug_je_penzioner']!,
          _bracniDrugJePenzionerMeta,
        ),
      );
    }
    if (data.containsKey('penzioner_napomena')) {
      context.handle(
        _penzionerNapomenaMeta,
        penzionerNapomena.isAcceptableOrUnknown(
          data['penzioner_napomena']!,
          _penzionerNapomenaMeta,
        ),
      );
    }
    if (data.containsKey('naru_tip')) {
      context.handle(
        _naruTipMeta,
        naruTip.isAcceptableOrUnknown(data['naru_tip']!, _naruTipMeta),
      );
    }
    if (data.containsKey('naru_ime')) {
      context.handle(
        _naruImeMeta,
        naruIme.isAcceptableOrUnknown(data['naru_ime']!, _naruImeMeta),
      );
    }
    if (data.containsKey('naru_prezime')) {
      context.handle(
        _naruPrezimeMeta,
        naruPrezime.isAcceptableOrUnknown(
          data['naru_prezime']!,
          _naruPrezimeMeta,
        ),
      );
    }
    if (data.containsKey('naru_ime_prezime')) {
      context.handle(
        _naruImePrezimeMeta,
        naruImePrezime.isAcceptableOrUnknown(
          data['naru_ime_prezime']!,
          _naruImePrezimeMeta,
        ),
      );
    }
    if (data.containsKey('naru_jmbg')) {
      context.handle(
        _naruJmbgMeta,
        naruJmbg.isAcceptableOrUnknown(data['naru_jmbg']!, _naruJmbgMeta),
      );
    }
    if (data.containsKey('naru_adresa')) {
      context.handle(
        _naruAdresaMeta,
        naruAdresa.isAcceptableOrUnknown(data['naru_adresa']!, _naruAdresaMeta),
      );
    }
    if (data.containsKey('naru_broj_lk')) {
      context.handle(
        _naruBrojLkMeta,
        naruBrojLk.isAcceptableOrUnknown(
          data['naru_broj_lk']!,
          _naruBrojLkMeta,
        ),
      );
    }
    if (data.containsKey('naru_telefon1')) {
      context.handle(
        _naruTelefon1Meta,
        naruTelefon1.isAcceptableOrUnknown(
          data['naru_telefon1']!,
          _naruTelefon1Meta,
        ),
      );
    }
    if (data.containsKey('naru_telefon2')) {
      context.handle(
        _naruTelefon2Meta,
        naruTelefon2.isAcceptableOrUnknown(
          data['naru_telefon2']!,
          _naruTelefon2Meta,
        ),
      );
    }
    if (data.containsKey('naru_email')) {
      context.handle(
        _naruEmailMeta,
        naruEmail.isAcceptableOrUnknown(data['naru_email']!, _naruEmailMeta),
      );
    }
    if (data.containsKey('naru_pl_naziv')) {
      context.handle(
        _naruPlNazivMeta,
        naruPlNaziv.isAcceptableOrUnknown(
          data['naru_pl_naziv']!,
          _naruPlNazivMeta,
        ),
      );
    }
    if (data.containsKey('naru_pl_adresa')) {
      context.handle(
        _naruPlAdresaMeta,
        naruPlAdresa.isAcceptableOrUnknown(
          data['naru_pl_adresa']!,
          _naruPlAdresaMeta,
        ),
      );
    }
    if (data.containsKey('naru_pl_pib')) {
      context.handle(
        _naruPlPibMeta,
        naruPlPib.isAcceptableOrUnknown(data['naru_pl_pib']!, _naruPlPibMeta),
      );
    }
    if (data.containsKey('naru_pl_mb')) {
      context.handle(
        _naruPlMbMeta,
        naruPlMb.isAcceptableOrUnknown(data['naru_pl_mb']!, _naruPlMbMeta),
      );
    }
    if (data.containsKey('naru_pl_odgovorno_lice')) {
      context.handle(
        _naruPlOdgovornoLiceMeta,
        naruPlOdgovornoLice.isAcceptableOrUnknown(
          data['naru_pl_odgovorno_lice']!,
          _naruPlOdgovornoLiceMeta,
        ),
      );
    }
    if (data.containsKey('naru_pl_telefon1')) {
      context.handle(
        _naruPlTelefon1Meta,
        naruPlTelefon1.isAcceptableOrUnknown(
          data['naru_pl_telefon1']!,
          _naruPlTelefon1Meta,
        ),
      );
    }
    if (data.containsKey('naru_pl_telefon2')) {
      context.handle(
        _naruPlTelefon2Meta,
        naruPlTelefon2.isAcceptableOrUnknown(
          data['naru_pl_telefon2']!,
          _naruPlTelefon2Meta,
        ),
      );
    }
    if (data.containsKey('naru_pl_email')) {
      context.handle(
        _naruPlEmailMeta,
        naruPlEmail.isAcceptableOrUnknown(
          data['naru_pl_email']!,
          _naruPlEmailMeta,
        ),
      );
    }
    if (data.containsKey('naru_isti_za_jkp')) {
      context.handle(
        _naruIstiZaJkpMeta,
        naruIstiZaJkp.isAcceptableOrUnknown(
          data['naru_isti_za_jkp']!,
          _naruIstiZaJkpMeta,
        ),
      );
    }
    if (data.containsKey('jkp_tip')) {
      context.handle(
        _jkpTipMeta,
        jkpTip.isAcceptableOrUnknown(data['jkp_tip']!, _jkpTipMeta),
      );
    }
    if (data.containsKey('jkp_ime')) {
      context.handle(
        _jkpImeMeta,
        jkpIme.isAcceptableOrUnknown(data['jkp_ime']!, _jkpImeMeta),
      );
    }
    if (data.containsKey('jkp_prezime')) {
      context.handle(
        _jkpPrezimeMeta,
        jkpPrezime.isAcceptableOrUnknown(data['jkp_prezime']!, _jkpPrezimeMeta),
      );
    }
    if (data.containsKey('jkp_ime_prezime')) {
      context.handle(
        _jkpImePrezimeMeta,
        jkpImePrezime.isAcceptableOrUnknown(
          data['jkp_ime_prezime']!,
          _jkpImePrezimeMeta,
        ),
      );
    }
    if (data.containsKey('jkp_jmbg')) {
      context.handle(
        _jkpJmbgMeta,
        jkpJmbg.isAcceptableOrUnknown(data['jkp_jmbg']!, _jkpJmbgMeta),
      );
    }
    if (data.containsKey('jkp_adresa')) {
      context.handle(
        _jkpAdresaMeta,
        jkpAdresa.isAcceptableOrUnknown(data['jkp_adresa']!, _jkpAdresaMeta),
      );
    }
    if (data.containsKey('jkp_broj_lk')) {
      context.handle(
        _jkpBrojLkMeta,
        jkpBrojLk.isAcceptableOrUnknown(data['jkp_broj_lk']!, _jkpBrojLkMeta),
      );
    }
    if (data.containsKey('jkp_telefon1')) {
      context.handle(
        _jkpTelefon1Meta,
        jkpTelefon1.isAcceptableOrUnknown(
          data['jkp_telefon1']!,
          _jkpTelefon1Meta,
        ),
      );
    }
    if (data.containsKey('jkp_telefon2')) {
      context.handle(
        _jkpTelefon2Meta,
        jkpTelefon2.isAcceptableOrUnknown(
          data['jkp_telefon2']!,
          _jkpTelefon2Meta,
        ),
      );
    }
    if (data.containsKey('jkp_email')) {
      context.handle(
        _jkpEmailMeta,
        jkpEmail.isAcceptableOrUnknown(data['jkp_email']!, _jkpEmailMeta),
      );
    }
    if (data.containsKey('jkp_pl_naziv')) {
      context.handle(
        _jkpPlNazivMeta,
        jkpPlNaziv.isAcceptableOrUnknown(
          data['jkp_pl_naziv']!,
          _jkpPlNazivMeta,
        ),
      );
    }
    if (data.containsKey('jkp_pl_adresa')) {
      context.handle(
        _jkpPlAdresaMeta,
        jkpPlAdresa.isAcceptableOrUnknown(
          data['jkp_pl_adresa']!,
          _jkpPlAdresaMeta,
        ),
      );
    }
    if (data.containsKey('jkp_pl_pib')) {
      context.handle(
        _jkpPlPibMeta,
        jkpPlPib.isAcceptableOrUnknown(data['jkp_pl_pib']!, _jkpPlPibMeta),
      );
    }
    if (data.containsKey('jkp_pl_mb')) {
      context.handle(
        _jkpPlMbMeta,
        jkpPlMb.isAcceptableOrUnknown(data['jkp_pl_mb']!, _jkpPlMbMeta),
      );
    }
    if (data.containsKey('jkp_pl_odgovorno_lice')) {
      context.handle(
        _jkpPlOdgovornoLiceMeta,
        jkpPlOdgovornoLice.isAcceptableOrUnknown(
          data['jkp_pl_odgovorno_lice']!,
          _jkpPlOdgovornoLiceMeta,
        ),
      );
    }
    if (data.containsKey('jkp_pl_telefon1')) {
      context.handle(
        _jkpPlTelefon1Meta,
        jkpPlTelefon1.isAcceptableOrUnknown(
          data['jkp_pl_telefon1']!,
          _jkpPlTelefon1Meta,
        ),
      );
    }
    if (data.containsKey('jkp_pl_email')) {
      context.handle(
        _jkpPlEmailMeta,
        jkpPlEmail.isAcceptableOrUnknown(
          data['jkp_pl_email']!,
          _jkpPlEmailMeta,
        ),
      );
    }
    if (data.containsKey('groblje')) {
      context.handle(
        _grobljeMeta,
        groblje.isAcceptableOrUnknown(data['groblje']!, _grobljeMeta),
      );
    }
    if (data.containsKey('tip_groblja')) {
      context.handle(
        _tipGrobljaMeta,
        tipGroblja.isAcceptableOrUnknown(data['tip_groblja']!, _tipGrobljaMeta),
      );
    }
    if (data.containsKey('vrsta_ceremonije')) {
      context.handle(
        _vrstaCeremonijeMeta,
        vrstaCeremonije.isAcceptableOrUnknown(
          data['vrsta_ceremonije']!,
          _vrstaCeremonijeMeta,
        ),
      );
    }
    if (data.containsKey('datum_ceremonije')) {
      context.handle(
        _datumCeremonijeMeta,
        datumCeremonije.isAcceptableOrUnknown(
          data['datum_ceremonije']!,
          _datumCeremonijeMeta,
        ),
      );
    }
    if (data.containsKey('vreme_ceremonije')) {
      context.handle(
        _vremeCeremonijeMeta,
        vremeCeremonije.isAcceptableOrUnknown(
          data['vreme_ceremonije']!,
          _vremeCeremonijeMeta,
        ),
      );
    }
    if (data.containsKey('opelo')) {
      context.handle(
        _opeloMeta,
        opelo.isAcceptableOrUnknown(data['opelo']!, _opeloMeta),
      );
    }
    if (data.containsKey('opelo_mesto')) {
      context.handle(
        _opeloMestoMeta,
        opeloMesto.isAcceptableOrUnknown(data['opelo_mesto']!, _opeloMestoMeta),
      );
    }
    if (data.containsKey('vreme_opela')) {
      context.handle(
        _vremeOpelaMeta,
        vremeOpela.isAcceptableOrUnknown(data['vreme_opela']!, _vremeOpelaMeta),
      );
    }
    if (data.containsKey('vreme_ispracaja')) {
      context.handle(
        _vremeIspracajaMeta,
        vremeIspracaja.isAcceptableOrUnknown(
          data['vreme_ispracaja']!,
          _vremeIspracajaMeta,
        ),
      );
    }
    if (data.containsKey('grobno_mesto')) {
      context.handle(
        _grobnoMestoMeta,
        grobnoMesto.isAcceptableOrUnknown(
          data['grobno_mesto']!,
          _grobnoMestoMeta,
        ),
      );
    }
    if (data.containsKey('tip_grobnog_mesta')) {
      context.handle(
        _tipGrobnogMestaMeta,
        tipGrobnogMesta.isAcceptableOrUnknown(
          data['tip_grobnog_mesta']!,
          _tipGrobnogMestaMeta,
        ),
      );
    }
    if (data.containsKey('parcela')) {
      context.handle(
        _parcelaMeta,
        parcela.isAcceptableOrUnknown(data['parcela']!, _parcelaMeta),
      );
    }
    if (data.containsKey('grob_broj')) {
      context.handle(
        _grobBrojMeta,
        grobBroj.isAcceptableOrUnknown(data['grob_broj']!, _grobBrojMeta),
      );
    }
    if (data.containsKey('red_grob')) {
      context.handle(
        _redGrobMeta,
        redGrob.isAcceptableOrUnknown(data['red_grob']!, _redGrobMeta),
      );
    }
    if (data.containsKey('npk')) {
      context.handle(
        _npkMeta,
        npk.isAcceptableOrUnknown(data['npk']!, _npkMeta),
      );
    }
    if (data.containsKey('grobnica')) {
      context.handle(
        _grobnicaMeta,
        grobnica.isAcceptableOrUnknown(data['grobnica']!, _grobnicaMeta),
      );
    }
    if (data.containsKey('urna_sifra')) {
      context.handle(
        _urnaSifraMeta,
        urnaSifra.isAcceptableOrUnknown(data['urna_sifra']!, _urnaSifraMeta),
      );
    }
    if (data.containsKey('tip_polaganja')) {
      context.handle(
        _tipPolaganjaMeta,
        tipPolaganja.isAcceptableOrUnknown(
          data['tip_polaganja']!,
          _tipPolaganjaMeta,
        ),
      );
    }
    if (data.containsKey('urna_parcela')) {
      context.handle(
        _urnaParcelaMeta,
        urnaParcela.isAcceptableOrUnknown(
          data['urna_parcela']!,
          _urnaParcelaMeta,
        ),
      );
    }
    if (data.containsKey('urna_broj')) {
      context.handle(
        _urnaBrojMeta,
        urnaBroj.isAcceptableOrUnknown(data['urna_broj']!, _urnaBrojMeta),
      );
    }
    if (data.containsKey('urna_red')) {
      context.handle(
        _urnaRedMeta,
        urnaRed.isAcceptableOrUnknown(data['urna_red']!, _urnaRedMeta),
      );
    }
    if (data.containsKey('urna_npk')) {
      context.handle(
        _urnaNpkMeta,
        urnaNpk.isAcceptableOrUnknown(data['urna_npk']!, _urnaNpkMeta),
      );
    }
    if (data.containsKey('sahrana_van_srbije')) {
      context.handle(
        _sahranaVanSrbijeMeta,
        sahranaVanSrbije.isAcceptableOrUnknown(
          data['sahrana_van_srbije']!,
          _sahranaVanSrbijeMeta,
        ),
      );
    }
    if (data.containsKey('svis_zemlja')) {
      context.handle(
        _svisZemljaMeta,
        svisZemlja.isAcceptableOrUnknown(data['svis_zemlja']!, _svisZemljaMeta),
      );
    }
    if (data.containsKey('svis_grad')) {
      context.handle(
        _svisGradMeta,
        svisGrad.isAcceptableOrUnknown(data['svis_grad']!, _svisGradMeta),
      );
    }
    if (data.containsKey('docek_posmrtnih_ostataka')) {
      context.handle(
        _docekPosmrtnihOstatakaMeta,
        docekPosmrtnihOstataka.isAcceptableOrUnknown(
          data['docek_posmrtnih_ostataka']!,
          _docekPosmrtnihOstatakaMeta,
        ),
      );
    }
    if (data.containsKey('docek_mesto')) {
      context.handle(
        _docekMestoMeta,
        docekMesto.isAcceptableOrUnknown(data['docek_mesto']!, _docekMestoMeta),
      );
    }
    if (data.containsKey('docek_vreme')) {
      context.handle(
        _docekVremeMeta,
        docekVreme.isAcceptableOrUnknown(data['docek_vreme']!, _docekVremeMeta),
      );
    }
    if (data.containsKey('simbol')) {
      context.handle(
        _simbolMeta,
        simbol.isAcceptableOrUnknown(data['simbol']!, _simbolMeta),
      );
    }
    if (data.containsKey('pismo')) {
      context.handle(
        _pismoMeta,
        pismo.isAcceptableOrUnknown(data['pismo']!, _pismoMeta),
      );
    }
    if (data.containsKey('parte_ime')) {
      context.handle(
        _parteImeMeta,
        parteIme.isAcceptableOrUnknown(data['parte_ime']!, _parteImeMeta),
      );
    }
    if (data.containsKey('ozaloseni')) {
      context.handle(
        _ozaloseniMeta,
        ozaloseni.isAcceptableOrUnknown(data['ozaloseni']!, _ozaloseniMeta),
      );
    }
    if (data.containsKey('avans')) {
      context.handle(
        _avansMeta,
        avans.isAcceptableOrUnknown(data['avans']!, _avansMeta),
      );
    }
    if (data.containsKey('troskovi_jkp')) {
      context.handle(
        _troskoviJkpMeta,
        troskoviJkp.isAcceptableOrUnknown(
          data['troskovi_jkp']!,
          _troskoviJkpMeta,
        ),
      );
    }
    if (data.containsKey('jkp_placa_samostalno')) {
      context.handle(
        _jkpPlacaSamostalnoMeta,
        jkpPlacaSamostalno.isAcceptableOrUnknown(
          data['jkp_placa_samostalno']!,
          _jkpPlacaSamostalnoMeta,
        ),
      );
    }
    if (data.containsKey('popust')) {
      context.handle(
        _popustMeta,
        popust.isAcceptableOrUnknown(data['popust']!, _popustMeta),
      );
    }
    if (data.containsKey('nacin_placanja')) {
      context.handle(
        _nacinPlacanjaMeta,
        nacinPlacanja.isAcceptableOrUnknown(
          data['nacin_placanja']!,
          _nacinPlacanjaMeta,
        ),
      );
    }
    if (data.containsKey('napomena_placanja')) {
      context.handle(
        _napomenaPlacanjaMeta,
        napomenaPlacanja.isAcceptableOrUnknown(
          data['napomena_placanja']!,
          _napomenaPlacanjaMeta,
        ),
      );
    }
    if (data.containsKey('napomena')) {
      context.handle(
        _napomenaMeta,
        napomena.isAcceptableOrUnknown(data['napomena']!, _napomenaMeta),
      );
    }
    if (data.containsKey('export_verzija')) {
      context.handle(
        _exportVerzijaMeta,
        exportVerzija.isAcceptableOrUnknown(
          data['export_verzija']!,
          _exportVerzijaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredmetiData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredmetiData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      brojPredmeta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broj_predmeta'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      datumKreiranja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_kreiranja'],
      )!,
      savetnikId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savetnik_id'],
      ),
      verzija: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verzija'],
      )!,
      businessScenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_scenario_id'],
      )!,
      sourceIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_identity'],
      )!,
      createdByKorisnikId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_korisnik_id'],
      ),
      lastBusinessModifiedByKorisnikId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_business_modified_by_korisnik_id'],
      ),
      lastBusinessModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_business_modified_at'],
      ),
      ime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ime'],
      )!,
      prezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prezime'],
      )!,
      srednje: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}srednje'],
      )!,
      devojackoPrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devojacko_prezime'],
      )!,
      jmbg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jmbg'],
      )!,
      pol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pol'],
      )!,
      datumRodjenja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_rodjenja'],
      )!,
      mestoRodjenja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesto_rodjenja'],
      )!,
      datumSmrti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_smrti'],
      )!,
      mestoSmrti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesto_smrti'],
      )!,
      uzrokSmrti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uzrok_smrti'],
      )!,
      adresa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adresa'],
      )!,
      imeOca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ime_oca'],
      )!,
      imeMajke: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ime_majke'],
      )!,
      bracnoStanje: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracno_stanje'],
      )!,
      bracniDrugIme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_ime'],
      )!,
      bracniDrugPrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_prezime'],
      )!,
      bracniDrugPol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_pol'],
      )!,
      bracniDrugJmbg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_jmbg'],
      )!,
      bracniDrugDevojacko: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_devojacko'],
      )!,
      zanimanje: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zanimanje'],
      )!,
      zanimanjeNaParti: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}zanimanje_na_parti'],
      )!,
      titula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titula'],
      )!,
      titulaIspred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}titula_ispred'],
      )!,
      cin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cin'],
      )!,
      cinNaParti: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cin_na_parti'],
      )!,
      srednjeNaParti: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}srednje_na_parti'],
      )!,
      nadimak: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nadimak'],
      )!,
      nadimakNaParti: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nadimak_na_parti'],
      )!,
      nadimakCrtica: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nadimak_crtica'],
      )!,
      radniStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radni_status'],
      )!,
      penzioner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}penzioner'],
      )!,
      penzionerSrbije: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}penzioner_srbije'],
      )!,
      vojniPenzioner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vojni_penzioner'],
      )!,
      vojnePocasti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vojne_pocasti'],
      )!,
      posmrtnaPomoc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posmrtna_pomoc'],
      )!,
      refundacijaPio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}refundacija_pio'],
      )!,
      narucilacRefundira: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narucilac_refundira'],
      )!,
      bracniDrugOstvarujePravo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_ostvaruje_pravo'],
      )!,
      bracniDrugJePenzioner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracni_drug_je_penzioner'],
      )!,
      penzionerNapomena: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}penzioner_napomena'],
      )!,
      naruTip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_tip'],
      )!,
      naruIme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_ime'],
      )!,
      naruPrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_prezime'],
      )!,
      naruImePrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_ime_prezime'],
      )!,
      naruJmbg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_jmbg'],
      )!,
      naruAdresa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_adresa'],
      )!,
      naruBrojLk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_broj_lk'],
      )!,
      naruTelefon1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_telefon1'],
      )!,
      naruTelefon2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_telefon2'],
      )!,
      naruEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_email'],
      )!,
      naruPlNaziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_naziv'],
      )!,
      naruPlAdresa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_adresa'],
      )!,
      naruPlPib: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_pib'],
      )!,
      naruPlMb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_mb'],
      )!,
      naruPlOdgovornoLice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_odgovorno_lice'],
      )!,
      naruPlTelefon1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_telefon1'],
      )!,
      naruPlTelefon2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_telefon2'],
      )!,
      naruPlEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naru_pl_email'],
      )!,
      naruIstiZaJkp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}naru_isti_za_jkp'],
      )!,
      jkpTip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_tip'],
      )!,
      jkpIme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_ime'],
      )!,
      jkpPrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_prezime'],
      )!,
      jkpImePrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_ime_prezime'],
      )!,
      jkpJmbg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_jmbg'],
      )!,
      jkpAdresa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_adresa'],
      )!,
      jkpBrojLk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_broj_lk'],
      )!,
      jkpTelefon1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_telefon1'],
      )!,
      jkpTelefon2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_telefon2'],
      )!,
      jkpEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_email'],
      )!,
      jkpPlNaziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_naziv'],
      )!,
      jkpPlAdresa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_adresa'],
      )!,
      jkpPlPib: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_pib'],
      )!,
      jkpPlMb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_mb'],
      )!,
      jkpPlOdgovornoLice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_odgovorno_lice'],
      )!,
      jkpPlTelefon1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_telefon1'],
      )!,
      jkpPlEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jkp_pl_email'],
      )!,
      groblje: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}groblje'],
      )!,
      tipGroblja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tip_groblja'],
      )!,
      vrstaCeremonije: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vrsta_ceremonije'],
      )!,
      datumCeremonije: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_ceremonije'],
      )!,
      vremeCeremonije: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vreme_ceremonije'],
      )!,
      opelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opelo'],
      )!,
      opeloMesto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opelo_mesto'],
      )!,
      vremeOpela: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vreme_opela'],
      )!,
      vremeIspracaja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vreme_ispracaja'],
      )!,
      grobnoMesto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grobno_mesto'],
      )!,
      tipGrobnogMesta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tip_grobnog_mesta'],
      )!,
      parcela: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcela'],
      )!,
      grobBroj: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grob_broj'],
      )!,
      redGrob: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}red_grob'],
      )!,
      npk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}npk'],
      )!,
      grobnica: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grobnica'],
      )!,
      urnaSifra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urna_sifra'],
      )!,
      tipPolaganja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tip_polaganja'],
      )!,
      urnaParcela: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urna_parcela'],
      )!,
      urnaBroj: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urna_broj'],
      )!,
      urnaRed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urna_red'],
      )!,
      urnaNpk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urna_npk'],
      )!,
      sahranaVanSrbije: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sahrana_van_srbije'],
      )!,
      svisZemlja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}svis_zemlja'],
      )!,
      svisGrad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}svis_grad'],
      )!,
      docekPosmrtnihOstataka: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}docek_posmrtnih_ostataka'],
      )!,
      docekMesto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}docek_mesto'],
      )!,
      docekVreme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}docek_vreme'],
      )!,
      simbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}simbol'],
      )!,
      pismo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pismo'],
      )!,
      parteIme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parte_ime'],
      )!,
      ozaloseni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ozaloseni'],
      )!,
      avans: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avans'],
      )!,
      troskoviJkp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}troskovi_jkp'],
      )!,
      jkpPlacaSamostalno: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}jkp_placa_samostalno'],
      )!,
      popust: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}popust'],
      )!,
      nacinPlacanja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nacin_placanja'],
      )!,
      napomenaPlacanja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}napomena_placanja'],
      )!,
      napomena: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}napomena'],
      )!,
      exportVerzija: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}export_verzija'],
      )!,
    );
  }

  @override
  $PredmetiTable createAlias(String alias) {
    return $PredmetiTable(attachedDatabase, alias);
  }
}

class PredmetiData extends DataClass implements Insertable<PredmetiData> {
  final int id;
  final String brojPredmeta;
  final String status;
  final String datumKreiranja;
  final int? savetnikId;
  final int verzija;
  final String businessScenarioId;
  final String sourceIdentity;
  final int? createdByKorisnikId;
  final int? lastBusinessModifiedByKorisnikId;
  final String? lastBusinessModifiedAt;
  final String ime;
  final String prezime;
  final String srednje;
  final String devojackoPrezime;
  final String jmbg;
  final String pol;
  final String datumRodjenja;
  final String mestoRodjenja;
  final String datumSmrti;
  final String mestoSmrti;
  final String uzrokSmrti;
  final String adresa;
  final String imeOca;
  final String imeMajke;
  final String bracnoStanje;
  final String bracniDrugIme;
  final String bracniDrugPrezime;
  final String bracniDrugPol;
  final String bracniDrugJmbg;
  final String bracniDrugDevojacko;
  final String zanimanje;
  final bool zanimanjeNaParti;
  final String titula;
  final bool titulaIspred;
  final String cin;
  final bool cinNaParti;
  final bool srednjeNaParti;
  final String nadimak;
  final bool nadimakNaParti;
  final bool nadimakCrtica;
  final String radniStatus;
  final String penzioner;
  final String penzionerSrbije;
  final String vojniPenzioner;
  final String vojnePocasti;
  final String posmrtnaPomoc;
  final double refundacijaPio;
  final String narucilacRefundira;
  final String bracniDrugOstvarujePravo;
  final String bracniDrugJePenzioner;
  final String penzionerNapomena;
  final String naruTip;
  final String naruIme;
  final String naruPrezime;
  final String naruImePrezime;
  final String naruJmbg;
  final String naruAdresa;
  final String naruBrojLk;
  final String naruTelefon1;
  final String naruTelefon2;
  final String naruEmail;
  final String naruPlNaziv;
  final String naruPlAdresa;
  final String naruPlPib;
  final String naruPlMb;
  final String naruPlOdgovornoLice;
  final String naruPlTelefon1;
  final String naruPlTelefon2;
  final String naruPlEmail;
  final bool naruIstiZaJkp;
  final String jkpTip;
  final String jkpIme;
  final String jkpPrezime;
  final String jkpImePrezime;
  final String jkpJmbg;
  final String jkpAdresa;
  final String jkpBrojLk;
  final String jkpTelefon1;
  final String jkpTelefon2;
  final String jkpEmail;
  final String jkpPlNaziv;
  final String jkpPlAdresa;
  final String jkpPlPib;
  final String jkpPlMb;
  final String jkpPlOdgovornoLice;
  final String jkpPlTelefon1;
  final String jkpPlEmail;
  final String groblje;
  final String tipGroblja;
  final String vrstaCeremonije;
  final String datumCeremonije;
  final String vremeCeremonije;
  final String opelo;
  final String opeloMesto;
  final String vremeOpela;
  final String vremeIspracaja;
  final String grobnoMesto;
  final String tipGrobnogMesta;
  final String parcela;
  final String grobBroj;
  final String redGrob;
  final String npk;
  final String grobnica;
  final String urnaSifra;
  final String tipPolaganja;
  final String urnaParcela;
  final String urnaBroj;
  final String urnaRed;
  final String urnaNpk;
  final bool sahranaVanSrbije;
  final String svisZemlja;
  final String svisGrad;
  final bool docekPosmrtnihOstataka;
  final String docekMesto;
  final String docekVreme;
  final String simbol;
  final String pismo;
  final String parteIme;
  final String ozaloseni;
  final double avans;
  final double troskoviJkp;
  final bool jkpPlacaSamostalno;
  final double popust;
  final String nacinPlacanja;
  final String napomenaPlacanja;
  final String napomena;

  /// Verzija JSON izvoza jednog PREDMETA — uvećava se pri svakom exportu.
  final int exportVerzija;
  const PredmetiData({
    required this.id,
    required this.brojPredmeta,
    required this.status,
    required this.datumKreiranja,
    this.savetnikId,
    required this.verzija,
    required this.businessScenarioId,
    required this.sourceIdentity,
    this.createdByKorisnikId,
    this.lastBusinessModifiedByKorisnikId,
    this.lastBusinessModifiedAt,
    required this.ime,
    required this.prezime,
    required this.srednje,
    required this.devojackoPrezime,
    required this.jmbg,
    required this.pol,
    required this.datumRodjenja,
    required this.mestoRodjenja,
    required this.datumSmrti,
    required this.mestoSmrti,
    required this.uzrokSmrti,
    required this.adresa,
    required this.imeOca,
    required this.imeMajke,
    required this.bracnoStanje,
    required this.bracniDrugIme,
    required this.bracniDrugPrezime,
    required this.bracniDrugPol,
    required this.bracniDrugJmbg,
    required this.bracniDrugDevojacko,
    required this.zanimanje,
    required this.zanimanjeNaParti,
    required this.titula,
    required this.titulaIspred,
    required this.cin,
    required this.cinNaParti,
    required this.srednjeNaParti,
    required this.nadimak,
    required this.nadimakNaParti,
    required this.nadimakCrtica,
    required this.radniStatus,
    required this.penzioner,
    required this.penzionerSrbije,
    required this.vojniPenzioner,
    required this.vojnePocasti,
    required this.posmrtnaPomoc,
    required this.refundacijaPio,
    required this.narucilacRefundira,
    required this.bracniDrugOstvarujePravo,
    required this.bracniDrugJePenzioner,
    required this.penzionerNapomena,
    required this.naruTip,
    required this.naruIme,
    required this.naruPrezime,
    required this.naruImePrezime,
    required this.naruJmbg,
    required this.naruAdresa,
    required this.naruBrojLk,
    required this.naruTelefon1,
    required this.naruTelefon2,
    required this.naruEmail,
    required this.naruPlNaziv,
    required this.naruPlAdresa,
    required this.naruPlPib,
    required this.naruPlMb,
    required this.naruPlOdgovornoLice,
    required this.naruPlTelefon1,
    required this.naruPlTelefon2,
    required this.naruPlEmail,
    required this.naruIstiZaJkp,
    required this.jkpTip,
    required this.jkpIme,
    required this.jkpPrezime,
    required this.jkpImePrezime,
    required this.jkpJmbg,
    required this.jkpAdresa,
    required this.jkpBrojLk,
    required this.jkpTelefon1,
    required this.jkpTelefon2,
    required this.jkpEmail,
    required this.jkpPlNaziv,
    required this.jkpPlAdresa,
    required this.jkpPlPib,
    required this.jkpPlMb,
    required this.jkpPlOdgovornoLice,
    required this.jkpPlTelefon1,
    required this.jkpPlEmail,
    required this.groblje,
    required this.tipGroblja,
    required this.vrstaCeremonije,
    required this.datumCeremonije,
    required this.vremeCeremonije,
    required this.opelo,
    required this.opeloMesto,
    required this.vremeOpela,
    required this.vremeIspracaja,
    required this.grobnoMesto,
    required this.tipGrobnogMesta,
    required this.parcela,
    required this.grobBroj,
    required this.redGrob,
    required this.npk,
    required this.grobnica,
    required this.urnaSifra,
    required this.tipPolaganja,
    required this.urnaParcela,
    required this.urnaBroj,
    required this.urnaRed,
    required this.urnaNpk,
    required this.sahranaVanSrbije,
    required this.svisZemlja,
    required this.svisGrad,
    required this.docekPosmrtnihOstataka,
    required this.docekMesto,
    required this.docekVreme,
    required this.simbol,
    required this.pismo,
    required this.parteIme,
    required this.ozaloseni,
    required this.avans,
    required this.troskoviJkp,
    required this.jkpPlacaSamostalno,
    required this.popust,
    required this.nacinPlacanja,
    required this.napomenaPlacanja,
    required this.napomena,
    required this.exportVerzija,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['broj_predmeta'] = Variable<String>(brojPredmeta);
    map['status'] = Variable<String>(status);
    map['datum_kreiranja'] = Variable<String>(datumKreiranja);
    if (!nullToAbsent || savetnikId != null) {
      map['savetnik_id'] = Variable<int>(savetnikId);
    }
    map['verzija'] = Variable<int>(verzija);
    map['business_scenario_id'] = Variable<String>(businessScenarioId);
    map['source_identity'] = Variable<String>(sourceIdentity);
    if (!nullToAbsent || createdByKorisnikId != null) {
      map['created_by_korisnik_id'] = Variable<int>(createdByKorisnikId);
    }
    if (!nullToAbsent || lastBusinessModifiedByKorisnikId != null) {
      map['last_business_modified_by_korisnik_id'] = Variable<int>(
        lastBusinessModifiedByKorisnikId,
      );
    }
    if (!nullToAbsent || lastBusinessModifiedAt != null) {
      map['last_business_modified_at'] = Variable<String>(
        lastBusinessModifiedAt,
      );
    }
    map['ime'] = Variable<String>(ime);
    map['prezime'] = Variable<String>(prezime);
    map['srednje'] = Variable<String>(srednje);
    map['devojacko_prezime'] = Variable<String>(devojackoPrezime);
    map['jmbg'] = Variable<String>(jmbg);
    map['pol'] = Variable<String>(pol);
    map['datum_rodjenja'] = Variable<String>(datumRodjenja);
    map['mesto_rodjenja'] = Variable<String>(mestoRodjenja);
    map['datum_smrti'] = Variable<String>(datumSmrti);
    map['mesto_smrti'] = Variable<String>(mestoSmrti);
    map['uzrok_smrti'] = Variable<String>(uzrokSmrti);
    map['adresa'] = Variable<String>(adresa);
    map['ime_oca'] = Variable<String>(imeOca);
    map['ime_majke'] = Variable<String>(imeMajke);
    map['bracno_stanje'] = Variable<String>(bracnoStanje);
    map['bracni_drug_ime'] = Variable<String>(bracniDrugIme);
    map['bracni_drug_prezime'] = Variable<String>(bracniDrugPrezime);
    map['bracni_drug_pol'] = Variable<String>(bracniDrugPol);
    map['bracni_drug_jmbg'] = Variable<String>(bracniDrugJmbg);
    map['bracni_drug_devojacko'] = Variable<String>(bracniDrugDevojacko);
    map['zanimanje'] = Variable<String>(zanimanje);
    map['zanimanje_na_parti'] = Variable<bool>(zanimanjeNaParti);
    map['titula'] = Variable<String>(titula);
    map['titula_ispred'] = Variable<bool>(titulaIspred);
    map['cin'] = Variable<String>(cin);
    map['cin_na_parti'] = Variable<bool>(cinNaParti);
    map['srednje_na_parti'] = Variable<bool>(srednjeNaParti);
    map['nadimak'] = Variable<String>(nadimak);
    map['nadimak_na_parti'] = Variable<bool>(nadimakNaParti);
    map['nadimak_crtica'] = Variable<bool>(nadimakCrtica);
    map['radni_status'] = Variable<String>(radniStatus);
    map['penzioner'] = Variable<String>(penzioner);
    map['penzioner_srbije'] = Variable<String>(penzionerSrbije);
    map['vojni_penzioner'] = Variable<String>(vojniPenzioner);
    map['vojne_pocasti'] = Variable<String>(vojnePocasti);
    map['posmrtna_pomoc'] = Variable<String>(posmrtnaPomoc);
    map['refundacija_pio'] = Variable<double>(refundacijaPio);
    map['narucilac_refundira'] = Variable<String>(narucilacRefundira);
    map['bracni_drug_ostvaruje_pravo'] = Variable<String>(
      bracniDrugOstvarujePravo,
    );
    map['bracni_drug_je_penzioner'] = Variable<String>(bracniDrugJePenzioner);
    map['penzioner_napomena'] = Variable<String>(penzionerNapomena);
    map['naru_tip'] = Variable<String>(naruTip);
    map['naru_ime'] = Variable<String>(naruIme);
    map['naru_prezime'] = Variable<String>(naruPrezime);
    map['naru_ime_prezime'] = Variable<String>(naruImePrezime);
    map['naru_jmbg'] = Variable<String>(naruJmbg);
    map['naru_adresa'] = Variable<String>(naruAdresa);
    map['naru_broj_lk'] = Variable<String>(naruBrojLk);
    map['naru_telefon1'] = Variable<String>(naruTelefon1);
    map['naru_telefon2'] = Variable<String>(naruTelefon2);
    map['naru_email'] = Variable<String>(naruEmail);
    map['naru_pl_naziv'] = Variable<String>(naruPlNaziv);
    map['naru_pl_adresa'] = Variable<String>(naruPlAdresa);
    map['naru_pl_pib'] = Variable<String>(naruPlPib);
    map['naru_pl_mb'] = Variable<String>(naruPlMb);
    map['naru_pl_odgovorno_lice'] = Variable<String>(naruPlOdgovornoLice);
    map['naru_pl_telefon1'] = Variable<String>(naruPlTelefon1);
    map['naru_pl_telefon2'] = Variable<String>(naruPlTelefon2);
    map['naru_pl_email'] = Variable<String>(naruPlEmail);
    map['naru_isti_za_jkp'] = Variable<bool>(naruIstiZaJkp);
    map['jkp_tip'] = Variable<String>(jkpTip);
    map['jkp_ime'] = Variable<String>(jkpIme);
    map['jkp_prezime'] = Variable<String>(jkpPrezime);
    map['jkp_ime_prezime'] = Variable<String>(jkpImePrezime);
    map['jkp_jmbg'] = Variable<String>(jkpJmbg);
    map['jkp_adresa'] = Variable<String>(jkpAdresa);
    map['jkp_broj_lk'] = Variable<String>(jkpBrojLk);
    map['jkp_telefon1'] = Variable<String>(jkpTelefon1);
    map['jkp_telefon2'] = Variable<String>(jkpTelefon2);
    map['jkp_email'] = Variable<String>(jkpEmail);
    map['jkp_pl_naziv'] = Variable<String>(jkpPlNaziv);
    map['jkp_pl_adresa'] = Variable<String>(jkpPlAdresa);
    map['jkp_pl_pib'] = Variable<String>(jkpPlPib);
    map['jkp_pl_mb'] = Variable<String>(jkpPlMb);
    map['jkp_pl_odgovorno_lice'] = Variable<String>(jkpPlOdgovornoLice);
    map['jkp_pl_telefon1'] = Variable<String>(jkpPlTelefon1);
    map['jkp_pl_email'] = Variable<String>(jkpPlEmail);
    map['groblje'] = Variable<String>(groblje);
    map['tip_groblja'] = Variable<String>(tipGroblja);
    map['vrsta_ceremonije'] = Variable<String>(vrstaCeremonije);
    map['datum_ceremonije'] = Variable<String>(datumCeremonije);
    map['vreme_ceremonije'] = Variable<String>(vremeCeremonije);
    map['opelo'] = Variable<String>(opelo);
    map['opelo_mesto'] = Variable<String>(opeloMesto);
    map['vreme_opela'] = Variable<String>(vremeOpela);
    map['vreme_ispracaja'] = Variable<String>(vremeIspracaja);
    map['grobno_mesto'] = Variable<String>(grobnoMesto);
    map['tip_grobnog_mesta'] = Variable<String>(tipGrobnogMesta);
    map['parcela'] = Variable<String>(parcela);
    map['grob_broj'] = Variable<String>(grobBroj);
    map['red_grob'] = Variable<String>(redGrob);
    map['npk'] = Variable<String>(npk);
    map['grobnica'] = Variable<String>(grobnica);
    map['urna_sifra'] = Variable<String>(urnaSifra);
    map['tip_polaganja'] = Variable<String>(tipPolaganja);
    map['urna_parcela'] = Variable<String>(urnaParcela);
    map['urna_broj'] = Variable<String>(urnaBroj);
    map['urna_red'] = Variable<String>(urnaRed);
    map['urna_npk'] = Variable<String>(urnaNpk);
    map['sahrana_van_srbije'] = Variable<bool>(sahranaVanSrbije);
    map['svis_zemlja'] = Variable<String>(svisZemlja);
    map['svis_grad'] = Variable<String>(svisGrad);
    map['docek_posmrtnih_ostataka'] = Variable<bool>(docekPosmrtnihOstataka);
    map['docek_mesto'] = Variable<String>(docekMesto);
    map['docek_vreme'] = Variable<String>(docekVreme);
    map['simbol'] = Variable<String>(simbol);
    map['pismo'] = Variable<String>(pismo);
    map['parte_ime'] = Variable<String>(parteIme);
    map['ozaloseni'] = Variable<String>(ozaloseni);
    map['avans'] = Variable<double>(avans);
    map['troskovi_jkp'] = Variable<double>(troskoviJkp);
    map['jkp_placa_samostalno'] = Variable<bool>(jkpPlacaSamostalno);
    map['popust'] = Variable<double>(popust);
    map['nacin_placanja'] = Variable<String>(nacinPlacanja);
    map['napomena_placanja'] = Variable<String>(napomenaPlacanja);
    map['napomena'] = Variable<String>(napomena);
    map['export_verzija'] = Variable<int>(exportVerzija);
    return map;
  }

  PredmetiCompanion toCompanion(bool nullToAbsent) {
    return PredmetiCompanion(
      id: Value(id),
      brojPredmeta: Value(brojPredmeta),
      status: Value(status),
      datumKreiranja: Value(datumKreiranja),
      savetnikId: savetnikId == null && nullToAbsent
          ? const Value.absent()
          : Value(savetnikId),
      verzija: Value(verzija),
      businessScenarioId: Value(businessScenarioId),
      sourceIdentity: Value(sourceIdentity),
      createdByKorisnikId: createdByKorisnikId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByKorisnikId),
      lastBusinessModifiedByKorisnikId:
          lastBusinessModifiedByKorisnikId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBusinessModifiedByKorisnikId),
      lastBusinessModifiedAt: lastBusinessModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBusinessModifiedAt),
      ime: Value(ime),
      prezime: Value(prezime),
      srednje: Value(srednje),
      devojackoPrezime: Value(devojackoPrezime),
      jmbg: Value(jmbg),
      pol: Value(pol),
      datumRodjenja: Value(datumRodjenja),
      mestoRodjenja: Value(mestoRodjenja),
      datumSmrti: Value(datumSmrti),
      mestoSmrti: Value(mestoSmrti),
      uzrokSmrti: Value(uzrokSmrti),
      adresa: Value(adresa),
      imeOca: Value(imeOca),
      imeMajke: Value(imeMajke),
      bracnoStanje: Value(bracnoStanje),
      bracniDrugIme: Value(bracniDrugIme),
      bracniDrugPrezime: Value(bracniDrugPrezime),
      bracniDrugPol: Value(bracniDrugPol),
      bracniDrugJmbg: Value(bracniDrugJmbg),
      bracniDrugDevojacko: Value(bracniDrugDevojacko),
      zanimanje: Value(zanimanje),
      zanimanjeNaParti: Value(zanimanjeNaParti),
      titula: Value(titula),
      titulaIspred: Value(titulaIspred),
      cin: Value(cin),
      cinNaParti: Value(cinNaParti),
      srednjeNaParti: Value(srednjeNaParti),
      nadimak: Value(nadimak),
      nadimakNaParti: Value(nadimakNaParti),
      nadimakCrtica: Value(nadimakCrtica),
      radniStatus: Value(radniStatus),
      penzioner: Value(penzioner),
      penzionerSrbije: Value(penzionerSrbije),
      vojniPenzioner: Value(vojniPenzioner),
      vojnePocasti: Value(vojnePocasti),
      posmrtnaPomoc: Value(posmrtnaPomoc),
      refundacijaPio: Value(refundacijaPio),
      narucilacRefundira: Value(narucilacRefundira),
      bracniDrugOstvarujePravo: Value(bracniDrugOstvarujePravo),
      bracniDrugJePenzioner: Value(bracniDrugJePenzioner),
      penzionerNapomena: Value(penzionerNapomena),
      naruTip: Value(naruTip),
      naruIme: Value(naruIme),
      naruPrezime: Value(naruPrezime),
      naruImePrezime: Value(naruImePrezime),
      naruJmbg: Value(naruJmbg),
      naruAdresa: Value(naruAdresa),
      naruBrojLk: Value(naruBrojLk),
      naruTelefon1: Value(naruTelefon1),
      naruTelefon2: Value(naruTelefon2),
      naruEmail: Value(naruEmail),
      naruPlNaziv: Value(naruPlNaziv),
      naruPlAdresa: Value(naruPlAdresa),
      naruPlPib: Value(naruPlPib),
      naruPlMb: Value(naruPlMb),
      naruPlOdgovornoLice: Value(naruPlOdgovornoLice),
      naruPlTelefon1: Value(naruPlTelefon1),
      naruPlTelefon2: Value(naruPlTelefon2),
      naruPlEmail: Value(naruPlEmail),
      naruIstiZaJkp: Value(naruIstiZaJkp),
      jkpTip: Value(jkpTip),
      jkpIme: Value(jkpIme),
      jkpPrezime: Value(jkpPrezime),
      jkpImePrezime: Value(jkpImePrezime),
      jkpJmbg: Value(jkpJmbg),
      jkpAdresa: Value(jkpAdresa),
      jkpBrojLk: Value(jkpBrojLk),
      jkpTelefon1: Value(jkpTelefon1),
      jkpTelefon2: Value(jkpTelefon2),
      jkpEmail: Value(jkpEmail),
      jkpPlNaziv: Value(jkpPlNaziv),
      jkpPlAdresa: Value(jkpPlAdresa),
      jkpPlPib: Value(jkpPlPib),
      jkpPlMb: Value(jkpPlMb),
      jkpPlOdgovornoLice: Value(jkpPlOdgovornoLice),
      jkpPlTelefon1: Value(jkpPlTelefon1),
      jkpPlEmail: Value(jkpPlEmail),
      groblje: Value(groblje),
      tipGroblja: Value(tipGroblja),
      vrstaCeremonije: Value(vrstaCeremonije),
      datumCeremonije: Value(datumCeremonije),
      vremeCeremonije: Value(vremeCeremonije),
      opelo: Value(opelo),
      opeloMesto: Value(opeloMesto),
      vremeOpela: Value(vremeOpela),
      vremeIspracaja: Value(vremeIspracaja),
      grobnoMesto: Value(grobnoMesto),
      tipGrobnogMesta: Value(tipGrobnogMesta),
      parcela: Value(parcela),
      grobBroj: Value(grobBroj),
      redGrob: Value(redGrob),
      npk: Value(npk),
      grobnica: Value(grobnica),
      urnaSifra: Value(urnaSifra),
      tipPolaganja: Value(tipPolaganja),
      urnaParcela: Value(urnaParcela),
      urnaBroj: Value(urnaBroj),
      urnaRed: Value(urnaRed),
      urnaNpk: Value(urnaNpk),
      sahranaVanSrbije: Value(sahranaVanSrbije),
      svisZemlja: Value(svisZemlja),
      svisGrad: Value(svisGrad),
      docekPosmrtnihOstataka: Value(docekPosmrtnihOstataka),
      docekMesto: Value(docekMesto),
      docekVreme: Value(docekVreme),
      simbol: Value(simbol),
      pismo: Value(pismo),
      parteIme: Value(parteIme),
      ozaloseni: Value(ozaloseni),
      avans: Value(avans),
      troskoviJkp: Value(troskoviJkp),
      jkpPlacaSamostalno: Value(jkpPlacaSamostalno),
      popust: Value(popust),
      nacinPlacanja: Value(nacinPlacanja),
      napomenaPlacanja: Value(napomenaPlacanja),
      napomena: Value(napomena),
      exportVerzija: Value(exportVerzija),
    );
  }

  factory PredmetiData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredmetiData(
      id: serializer.fromJson<int>(json['id']),
      brojPredmeta: serializer.fromJson<String>(json['brojPredmeta']),
      status: serializer.fromJson<String>(json['status']),
      datumKreiranja: serializer.fromJson<String>(json['datumKreiranja']),
      savetnikId: serializer.fromJson<int?>(json['savetnikId']),
      verzija: serializer.fromJson<int>(json['verzija']),
      businessScenarioId: serializer.fromJson<String>(
        json['businessScenarioId'],
      ),
      sourceIdentity: serializer.fromJson<String>(json['sourceIdentity']),
      createdByKorisnikId: serializer.fromJson<int?>(
        json['createdByKorisnikId'],
      ),
      lastBusinessModifiedByKorisnikId: serializer.fromJson<int?>(
        json['lastBusinessModifiedByKorisnikId'],
      ),
      lastBusinessModifiedAt: serializer.fromJson<String?>(
        json['lastBusinessModifiedAt'],
      ),
      ime: serializer.fromJson<String>(json['ime']),
      prezime: serializer.fromJson<String>(json['prezime']),
      srednje: serializer.fromJson<String>(json['srednje']),
      devojackoPrezime: serializer.fromJson<String>(json['devojackoPrezime']),
      jmbg: serializer.fromJson<String>(json['jmbg']),
      pol: serializer.fromJson<String>(json['pol']),
      datumRodjenja: serializer.fromJson<String>(json['datumRodjenja']),
      mestoRodjenja: serializer.fromJson<String>(json['mestoRodjenja']),
      datumSmrti: serializer.fromJson<String>(json['datumSmrti']),
      mestoSmrti: serializer.fromJson<String>(json['mestoSmrti']),
      uzrokSmrti: serializer.fromJson<String>(json['uzrokSmrti']),
      adresa: serializer.fromJson<String>(json['adresa']),
      imeOca: serializer.fromJson<String>(json['imeOca']),
      imeMajke: serializer.fromJson<String>(json['imeMajke']),
      bracnoStanje: serializer.fromJson<String>(json['bracnoStanje']),
      bracniDrugIme: serializer.fromJson<String>(json['bracniDrugIme']),
      bracniDrugPrezime: serializer.fromJson<String>(json['bracniDrugPrezime']),
      bracniDrugPol: serializer.fromJson<String>(json['bracniDrugPol']),
      bracniDrugJmbg: serializer.fromJson<String>(json['bracniDrugJmbg']),
      bracniDrugDevojacko: serializer.fromJson<String>(
        json['bracniDrugDevojacko'],
      ),
      zanimanje: serializer.fromJson<String>(json['zanimanje']),
      zanimanjeNaParti: serializer.fromJson<bool>(json['zanimanjeNaParti']),
      titula: serializer.fromJson<String>(json['titula']),
      titulaIspred: serializer.fromJson<bool>(json['titulaIspred']),
      cin: serializer.fromJson<String>(json['cin']),
      cinNaParti: serializer.fromJson<bool>(json['cinNaParti']),
      srednjeNaParti: serializer.fromJson<bool>(json['srednjeNaParti']),
      nadimak: serializer.fromJson<String>(json['nadimak']),
      nadimakNaParti: serializer.fromJson<bool>(json['nadimakNaParti']),
      nadimakCrtica: serializer.fromJson<bool>(json['nadimakCrtica']),
      radniStatus: serializer.fromJson<String>(json['radniStatus']),
      penzioner: serializer.fromJson<String>(json['penzioner']),
      penzionerSrbije: serializer.fromJson<String>(json['penzionerSrbije']),
      vojniPenzioner: serializer.fromJson<String>(json['vojniPenzioner']),
      vojnePocasti: serializer.fromJson<String>(json['vojnePocasti']),
      posmrtnaPomoc: serializer.fromJson<String>(json['posmrtnaPomoc']),
      refundacijaPio: serializer.fromJson<double>(json['refundacijaPio']),
      narucilacRefundira: serializer.fromJson<String>(
        json['narucilacRefundira'],
      ),
      bracniDrugOstvarujePravo: serializer.fromJson<String>(
        json['bracniDrugOstvarujePravo'],
      ),
      bracniDrugJePenzioner: serializer.fromJson<String>(
        json['bracniDrugJePenzioner'],
      ),
      penzionerNapomena: serializer.fromJson<String>(json['penzionerNapomena']),
      naruTip: serializer.fromJson<String>(json['naruTip']),
      naruIme: serializer.fromJson<String>(json['naruIme']),
      naruPrezime: serializer.fromJson<String>(json['naruPrezime']),
      naruImePrezime: serializer.fromJson<String>(json['naruImePrezime']),
      naruJmbg: serializer.fromJson<String>(json['naruJmbg']),
      naruAdresa: serializer.fromJson<String>(json['naruAdresa']),
      naruBrojLk: serializer.fromJson<String>(json['naruBrojLk']),
      naruTelefon1: serializer.fromJson<String>(json['naruTelefon1']),
      naruTelefon2: serializer.fromJson<String>(json['naruTelefon2']),
      naruEmail: serializer.fromJson<String>(json['naruEmail']),
      naruPlNaziv: serializer.fromJson<String>(json['naruPlNaziv']),
      naruPlAdresa: serializer.fromJson<String>(json['naruPlAdresa']),
      naruPlPib: serializer.fromJson<String>(json['naruPlPib']),
      naruPlMb: serializer.fromJson<String>(json['naruPlMb']),
      naruPlOdgovornoLice: serializer.fromJson<String>(
        json['naruPlOdgovornoLice'],
      ),
      naruPlTelefon1: serializer.fromJson<String>(json['naruPlTelefon1']),
      naruPlTelefon2: serializer.fromJson<String>(json['naruPlTelefon2']),
      naruPlEmail: serializer.fromJson<String>(json['naruPlEmail']),
      naruIstiZaJkp: serializer.fromJson<bool>(json['naruIstiZaJkp']),
      jkpTip: serializer.fromJson<String>(json['jkpTip']),
      jkpIme: serializer.fromJson<String>(json['jkpIme']),
      jkpPrezime: serializer.fromJson<String>(json['jkpPrezime']),
      jkpImePrezime: serializer.fromJson<String>(json['jkpImePrezime']),
      jkpJmbg: serializer.fromJson<String>(json['jkpJmbg']),
      jkpAdresa: serializer.fromJson<String>(json['jkpAdresa']),
      jkpBrojLk: serializer.fromJson<String>(json['jkpBrojLk']),
      jkpTelefon1: serializer.fromJson<String>(json['jkpTelefon1']),
      jkpTelefon2: serializer.fromJson<String>(json['jkpTelefon2']),
      jkpEmail: serializer.fromJson<String>(json['jkpEmail']),
      jkpPlNaziv: serializer.fromJson<String>(json['jkpPlNaziv']),
      jkpPlAdresa: serializer.fromJson<String>(json['jkpPlAdresa']),
      jkpPlPib: serializer.fromJson<String>(json['jkpPlPib']),
      jkpPlMb: serializer.fromJson<String>(json['jkpPlMb']),
      jkpPlOdgovornoLice: serializer.fromJson<String>(
        json['jkpPlOdgovornoLice'],
      ),
      jkpPlTelefon1: serializer.fromJson<String>(json['jkpPlTelefon1']),
      jkpPlEmail: serializer.fromJson<String>(json['jkpPlEmail']),
      groblje: serializer.fromJson<String>(json['groblje']),
      tipGroblja: serializer.fromJson<String>(json['tipGroblja']),
      vrstaCeremonije: serializer.fromJson<String>(json['vrstaCeremonije']),
      datumCeremonije: serializer.fromJson<String>(json['datumCeremonije']),
      vremeCeremonije: serializer.fromJson<String>(json['vremeCeremonije']),
      opelo: serializer.fromJson<String>(json['opelo']),
      opeloMesto: serializer.fromJson<String>(json['opeloMesto']),
      vremeOpela: serializer.fromJson<String>(json['vremeOpela']),
      vremeIspracaja: serializer.fromJson<String>(json['vremeIspracaja']),
      grobnoMesto: serializer.fromJson<String>(json['grobnoMesto']),
      tipGrobnogMesta: serializer.fromJson<String>(json['tipGrobnogMesta']),
      parcela: serializer.fromJson<String>(json['parcela']),
      grobBroj: serializer.fromJson<String>(json['grobBroj']),
      redGrob: serializer.fromJson<String>(json['redGrob']),
      npk: serializer.fromJson<String>(json['npk']),
      grobnica: serializer.fromJson<String>(json['grobnica']),
      urnaSifra: serializer.fromJson<String>(json['urnaSifra']),
      tipPolaganja: serializer.fromJson<String>(json['tipPolaganja']),
      urnaParcela: serializer.fromJson<String>(json['urnaParcela']),
      urnaBroj: serializer.fromJson<String>(json['urnaBroj']),
      urnaRed: serializer.fromJson<String>(json['urnaRed']),
      urnaNpk: serializer.fromJson<String>(json['urnaNpk']),
      sahranaVanSrbije: serializer.fromJson<bool>(json['sahranaVanSrbije']),
      svisZemlja: serializer.fromJson<String>(json['svisZemlja']),
      svisGrad: serializer.fromJson<String>(json['svisGrad']),
      docekPosmrtnihOstataka: serializer.fromJson<bool>(
        json['docekPosmrtnihOstataka'],
      ),
      docekMesto: serializer.fromJson<String>(json['docekMesto']),
      docekVreme: serializer.fromJson<String>(json['docekVreme']),
      simbol: serializer.fromJson<String>(json['simbol']),
      pismo: serializer.fromJson<String>(json['pismo']),
      parteIme: serializer.fromJson<String>(json['parteIme']),
      ozaloseni: serializer.fromJson<String>(json['ozaloseni']),
      avans: serializer.fromJson<double>(json['avans']),
      troskoviJkp: serializer.fromJson<double>(json['troskoviJkp']),
      jkpPlacaSamostalno: serializer.fromJson<bool>(json['jkpPlacaSamostalno']),
      popust: serializer.fromJson<double>(json['popust']),
      nacinPlacanja: serializer.fromJson<String>(json['nacinPlacanja']),
      napomenaPlacanja: serializer.fromJson<String>(json['napomenaPlacanja']),
      napomena: serializer.fromJson<String>(json['napomena']),
      exportVerzija: serializer.fromJson<int>(json['exportVerzija']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'brojPredmeta': serializer.toJson<String>(brojPredmeta),
      'status': serializer.toJson<String>(status),
      'datumKreiranja': serializer.toJson<String>(datumKreiranja),
      'savetnikId': serializer.toJson<int?>(savetnikId),
      'verzija': serializer.toJson<int>(verzija),
      'businessScenarioId': serializer.toJson<String>(businessScenarioId),
      'sourceIdentity': serializer.toJson<String>(sourceIdentity),
      'createdByKorisnikId': serializer.toJson<int?>(createdByKorisnikId),
      'lastBusinessModifiedByKorisnikId': serializer.toJson<int?>(
        lastBusinessModifiedByKorisnikId,
      ),
      'lastBusinessModifiedAt': serializer.toJson<String?>(
        lastBusinessModifiedAt,
      ),
      'ime': serializer.toJson<String>(ime),
      'prezime': serializer.toJson<String>(prezime),
      'srednje': serializer.toJson<String>(srednje),
      'devojackoPrezime': serializer.toJson<String>(devojackoPrezime),
      'jmbg': serializer.toJson<String>(jmbg),
      'pol': serializer.toJson<String>(pol),
      'datumRodjenja': serializer.toJson<String>(datumRodjenja),
      'mestoRodjenja': serializer.toJson<String>(mestoRodjenja),
      'datumSmrti': serializer.toJson<String>(datumSmrti),
      'mestoSmrti': serializer.toJson<String>(mestoSmrti),
      'uzrokSmrti': serializer.toJson<String>(uzrokSmrti),
      'adresa': serializer.toJson<String>(adresa),
      'imeOca': serializer.toJson<String>(imeOca),
      'imeMajke': serializer.toJson<String>(imeMajke),
      'bracnoStanje': serializer.toJson<String>(bracnoStanje),
      'bracniDrugIme': serializer.toJson<String>(bracniDrugIme),
      'bracniDrugPrezime': serializer.toJson<String>(bracniDrugPrezime),
      'bracniDrugPol': serializer.toJson<String>(bracniDrugPol),
      'bracniDrugJmbg': serializer.toJson<String>(bracniDrugJmbg),
      'bracniDrugDevojacko': serializer.toJson<String>(bracniDrugDevojacko),
      'zanimanje': serializer.toJson<String>(zanimanje),
      'zanimanjeNaParti': serializer.toJson<bool>(zanimanjeNaParti),
      'titula': serializer.toJson<String>(titula),
      'titulaIspred': serializer.toJson<bool>(titulaIspred),
      'cin': serializer.toJson<String>(cin),
      'cinNaParti': serializer.toJson<bool>(cinNaParti),
      'srednjeNaParti': serializer.toJson<bool>(srednjeNaParti),
      'nadimak': serializer.toJson<String>(nadimak),
      'nadimakNaParti': serializer.toJson<bool>(nadimakNaParti),
      'nadimakCrtica': serializer.toJson<bool>(nadimakCrtica),
      'radniStatus': serializer.toJson<String>(radniStatus),
      'penzioner': serializer.toJson<String>(penzioner),
      'penzionerSrbije': serializer.toJson<String>(penzionerSrbije),
      'vojniPenzioner': serializer.toJson<String>(vojniPenzioner),
      'vojnePocasti': serializer.toJson<String>(vojnePocasti),
      'posmrtnaPomoc': serializer.toJson<String>(posmrtnaPomoc),
      'refundacijaPio': serializer.toJson<double>(refundacijaPio),
      'narucilacRefundira': serializer.toJson<String>(narucilacRefundira),
      'bracniDrugOstvarujePravo': serializer.toJson<String>(
        bracniDrugOstvarujePravo,
      ),
      'bracniDrugJePenzioner': serializer.toJson<String>(bracniDrugJePenzioner),
      'penzionerNapomena': serializer.toJson<String>(penzionerNapomena),
      'naruTip': serializer.toJson<String>(naruTip),
      'naruIme': serializer.toJson<String>(naruIme),
      'naruPrezime': serializer.toJson<String>(naruPrezime),
      'naruImePrezime': serializer.toJson<String>(naruImePrezime),
      'naruJmbg': serializer.toJson<String>(naruJmbg),
      'naruAdresa': serializer.toJson<String>(naruAdresa),
      'naruBrojLk': serializer.toJson<String>(naruBrojLk),
      'naruTelefon1': serializer.toJson<String>(naruTelefon1),
      'naruTelefon2': serializer.toJson<String>(naruTelefon2),
      'naruEmail': serializer.toJson<String>(naruEmail),
      'naruPlNaziv': serializer.toJson<String>(naruPlNaziv),
      'naruPlAdresa': serializer.toJson<String>(naruPlAdresa),
      'naruPlPib': serializer.toJson<String>(naruPlPib),
      'naruPlMb': serializer.toJson<String>(naruPlMb),
      'naruPlOdgovornoLice': serializer.toJson<String>(naruPlOdgovornoLice),
      'naruPlTelefon1': serializer.toJson<String>(naruPlTelefon1),
      'naruPlTelefon2': serializer.toJson<String>(naruPlTelefon2),
      'naruPlEmail': serializer.toJson<String>(naruPlEmail),
      'naruIstiZaJkp': serializer.toJson<bool>(naruIstiZaJkp),
      'jkpTip': serializer.toJson<String>(jkpTip),
      'jkpIme': serializer.toJson<String>(jkpIme),
      'jkpPrezime': serializer.toJson<String>(jkpPrezime),
      'jkpImePrezime': serializer.toJson<String>(jkpImePrezime),
      'jkpJmbg': serializer.toJson<String>(jkpJmbg),
      'jkpAdresa': serializer.toJson<String>(jkpAdresa),
      'jkpBrojLk': serializer.toJson<String>(jkpBrojLk),
      'jkpTelefon1': serializer.toJson<String>(jkpTelefon1),
      'jkpTelefon2': serializer.toJson<String>(jkpTelefon2),
      'jkpEmail': serializer.toJson<String>(jkpEmail),
      'jkpPlNaziv': serializer.toJson<String>(jkpPlNaziv),
      'jkpPlAdresa': serializer.toJson<String>(jkpPlAdresa),
      'jkpPlPib': serializer.toJson<String>(jkpPlPib),
      'jkpPlMb': serializer.toJson<String>(jkpPlMb),
      'jkpPlOdgovornoLice': serializer.toJson<String>(jkpPlOdgovornoLice),
      'jkpPlTelefon1': serializer.toJson<String>(jkpPlTelefon1),
      'jkpPlEmail': serializer.toJson<String>(jkpPlEmail),
      'groblje': serializer.toJson<String>(groblje),
      'tipGroblja': serializer.toJson<String>(tipGroblja),
      'vrstaCeremonije': serializer.toJson<String>(vrstaCeremonije),
      'datumCeremonije': serializer.toJson<String>(datumCeremonije),
      'vremeCeremonije': serializer.toJson<String>(vremeCeremonije),
      'opelo': serializer.toJson<String>(opelo),
      'opeloMesto': serializer.toJson<String>(opeloMesto),
      'vremeOpela': serializer.toJson<String>(vremeOpela),
      'vremeIspracaja': serializer.toJson<String>(vremeIspracaja),
      'grobnoMesto': serializer.toJson<String>(grobnoMesto),
      'tipGrobnogMesta': serializer.toJson<String>(tipGrobnogMesta),
      'parcela': serializer.toJson<String>(parcela),
      'grobBroj': serializer.toJson<String>(grobBroj),
      'redGrob': serializer.toJson<String>(redGrob),
      'npk': serializer.toJson<String>(npk),
      'grobnica': serializer.toJson<String>(grobnica),
      'urnaSifra': serializer.toJson<String>(urnaSifra),
      'tipPolaganja': serializer.toJson<String>(tipPolaganja),
      'urnaParcela': serializer.toJson<String>(urnaParcela),
      'urnaBroj': serializer.toJson<String>(urnaBroj),
      'urnaRed': serializer.toJson<String>(urnaRed),
      'urnaNpk': serializer.toJson<String>(urnaNpk),
      'sahranaVanSrbije': serializer.toJson<bool>(sahranaVanSrbije),
      'svisZemlja': serializer.toJson<String>(svisZemlja),
      'svisGrad': serializer.toJson<String>(svisGrad),
      'docekPosmrtnihOstataka': serializer.toJson<bool>(docekPosmrtnihOstataka),
      'docekMesto': serializer.toJson<String>(docekMesto),
      'docekVreme': serializer.toJson<String>(docekVreme),
      'simbol': serializer.toJson<String>(simbol),
      'pismo': serializer.toJson<String>(pismo),
      'parteIme': serializer.toJson<String>(parteIme),
      'ozaloseni': serializer.toJson<String>(ozaloseni),
      'avans': serializer.toJson<double>(avans),
      'troskoviJkp': serializer.toJson<double>(troskoviJkp),
      'jkpPlacaSamostalno': serializer.toJson<bool>(jkpPlacaSamostalno),
      'popust': serializer.toJson<double>(popust),
      'nacinPlacanja': serializer.toJson<String>(nacinPlacanja),
      'napomenaPlacanja': serializer.toJson<String>(napomenaPlacanja),
      'napomena': serializer.toJson<String>(napomena),
      'exportVerzija': serializer.toJson<int>(exportVerzija),
    };
  }

  PredmetiData copyWith({
    int? id,
    String? brojPredmeta,
    String? status,
    String? datumKreiranja,
    Value<int?> savetnikId = const Value.absent(),
    int? verzija,
    String? businessScenarioId,
    String? sourceIdentity,
    Value<int?> createdByKorisnikId = const Value.absent(),
    Value<int?> lastBusinessModifiedByKorisnikId = const Value.absent(),
    Value<String?> lastBusinessModifiedAt = const Value.absent(),
    String? ime,
    String? prezime,
    String? srednje,
    String? devojackoPrezime,
    String? jmbg,
    String? pol,
    String? datumRodjenja,
    String? mestoRodjenja,
    String? datumSmrti,
    String? mestoSmrti,
    String? uzrokSmrti,
    String? adresa,
    String? imeOca,
    String? imeMajke,
    String? bracnoStanje,
    String? bracniDrugIme,
    String? bracniDrugPrezime,
    String? bracniDrugPol,
    String? bracniDrugJmbg,
    String? bracniDrugDevojacko,
    String? zanimanje,
    bool? zanimanjeNaParti,
    String? titula,
    bool? titulaIspred,
    String? cin,
    bool? cinNaParti,
    bool? srednjeNaParti,
    String? nadimak,
    bool? nadimakNaParti,
    bool? nadimakCrtica,
    String? radniStatus,
    String? penzioner,
    String? penzionerSrbije,
    String? vojniPenzioner,
    String? vojnePocasti,
    String? posmrtnaPomoc,
    double? refundacijaPio,
    String? narucilacRefundira,
    String? bracniDrugOstvarujePravo,
    String? bracniDrugJePenzioner,
    String? penzionerNapomena,
    String? naruTip,
    String? naruIme,
    String? naruPrezime,
    String? naruImePrezime,
    String? naruJmbg,
    String? naruAdresa,
    String? naruBrojLk,
    String? naruTelefon1,
    String? naruTelefon2,
    String? naruEmail,
    String? naruPlNaziv,
    String? naruPlAdresa,
    String? naruPlPib,
    String? naruPlMb,
    String? naruPlOdgovornoLice,
    String? naruPlTelefon1,
    String? naruPlTelefon2,
    String? naruPlEmail,
    bool? naruIstiZaJkp,
    String? jkpTip,
    String? jkpIme,
    String? jkpPrezime,
    String? jkpImePrezime,
    String? jkpJmbg,
    String? jkpAdresa,
    String? jkpBrojLk,
    String? jkpTelefon1,
    String? jkpTelefon2,
    String? jkpEmail,
    String? jkpPlNaziv,
    String? jkpPlAdresa,
    String? jkpPlPib,
    String? jkpPlMb,
    String? jkpPlOdgovornoLice,
    String? jkpPlTelefon1,
    String? jkpPlEmail,
    String? groblje,
    String? tipGroblja,
    String? vrstaCeremonije,
    String? datumCeremonije,
    String? vremeCeremonije,
    String? opelo,
    String? opeloMesto,
    String? vremeOpela,
    String? vremeIspracaja,
    String? grobnoMesto,
    String? tipGrobnogMesta,
    String? parcela,
    String? grobBroj,
    String? redGrob,
    String? npk,
    String? grobnica,
    String? urnaSifra,
    String? tipPolaganja,
    String? urnaParcela,
    String? urnaBroj,
    String? urnaRed,
    String? urnaNpk,
    bool? sahranaVanSrbije,
    String? svisZemlja,
    String? svisGrad,
    bool? docekPosmrtnihOstataka,
    String? docekMesto,
    String? docekVreme,
    String? simbol,
    String? pismo,
    String? parteIme,
    String? ozaloseni,
    double? avans,
    double? troskoviJkp,
    bool? jkpPlacaSamostalno,
    double? popust,
    String? nacinPlacanja,
    String? napomenaPlacanja,
    String? napomena,
    int? exportVerzija,
  }) => PredmetiData(
    id: id ?? this.id,
    brojPredmeta: brojPredmeta ?? this.brojPredmeta,
    status: status ?? this.status,
    datumKreiranja: datumKreiranja ?? this.datumKreiranja,
    savetnikId: savetnikId.present ? savetnikId.value : this.savetnikId,
    verzija: verzija ?? this.verzija,
    businessScenarioId: businessScenarioId ?? this.businessScenarioId,
    sourceIdentity: sourceIdentity ?? this.sourceIdentity,
    createdByKorisnikId: createdByKorisnikId.present
        ? createdByKorisnikId.value
        : this.createdByKorisnikId,
    lastBusinessModifiedByKorisnikId: lastBusinessModifiedByKorisnikId.present
        ? lastBusinessModifiedByKorisnikId.value
        : this.lastBusinessModifiedByKorisnikId,
    lastBusinessModifiedAt: lastBusinessModifiedAt.present
        ? lastBusinessModifiedAt.value
        : this.lastBusinessModifiedAt,
    ime: ime ?? this.ime,
    prezime: prezime ?? this.prezime,
    srednje: srednje ?? this.srednje,
    devojackoPrezime: devojackoPrezime ?? this.devojackoPrezime,
    jmbg: jmbg ?? this.jmbg,
    pol: pol ?? this.pol,
    datumRodjenja: datumRodjenja ?? this.datumRodjenja,
    mestoRodjenja: mestoRodjenja ?? this.mestoRodjenja,
    datumSmrti: datumSmrti ?? this.datumSmrti,
    mestoSmrti: mestoSmrti ?? this.mestoSmrti,
    uzrokSmrti: uzrokSmrti ?? this.uzrokSmrti,
    adresa: adresa ?? this.adresa,
    imeOca: imeOca ?? this.imeOca,
    imeMajke: imeMajke ?? this.imeMajke,
    bracnoStanje: bracnoStanje ?? this.bracnoStanje,
    bracniDrugIme: bracniDrugIme ?? this.bracniDrugIme,
    bracniDrugPrezime: bracniDrugPrezime ?? this.bracniDrugPrezime,
    bracniDrugPol: bracniDrugPol ?? this.bracniDrugPol,
    bracniDrugJmbg: bracniDrugJmbg ?? this.bracniDrugJmbg,
    bracniDrugDevojacko: bracniDrugDevojacko ?? this.bracniDrugDevojacko,
    zanimanje: zanimanje ?? this.zanimanje,
    zanimanjeNaParti: zanimanjeNaParti ?? this.zanimanjeNaParti,
    titula: titula ?? this.titula,
    titulaIspred: titulaIspred ?? this.titulaIspred,
    cin: cin ?? this.cin,
    cinNaParti: cinNaParti ?? this.cinNaParti,
    srednjeNaParti: srednjeNaParti ?? this.srednjeNaParti,
    nadimak: nadimak ?? this.nadimak,
    nadimakNaParti: nadimakNaParti ?? this.nadimakNaParti,
    nadimakCrtica: nadimakCrtica ?? this.nadimakCrtica,
    radniStatus: radniStatus ?? this.radniStatus,
    penzioner: penzioner ?? this.penzioner,
    penzionerSrbije: penzionerSrbije ?? this.penzionerSrbije,
    vojniPenzioner: vojniPenzioner ?? this.vojniPenzioner,
    vojnePocasti: vojnePocasti ?? this.vojnePocasti,
    posmrtnaPomoc: posmrtnaPomoc ?? this.posmrtnaPomoc,
    refundacijaPio: refundacijaPio ?? this.refundacijaPio,
    narucilacRefundira: narucilacRefundira ?? this.narucilacRefundira,
    bracniDrugOstvarujePravo:
        bracniDrugOstvarujePravo ?? this.bracniDrugOstvarujePravo,
    bracniDrugJePenzioner: bracniDrugJePenzioner ?? this.bracniDrugJePenzioner,
    penzionerNapomena: penzionerNapomena ?? this.penzionerNapomena,
    naruTip: naruTip ?? this.naruTip,
    naruIme: naruIme ?? this.naruIme,
    naruPrezime: naruPrezime ?? this.naruPrezime,
    naruImePrezime: naruImePrezime ?? this.naruImePrezime,
    naruJmbg: naruJmbg ?? this.naruJmbg,
    naruAdresa: naruAdresa ?? this.naruAdresa,
    naruBrojLk: naruBrojLk ?? this.naruBrojLk,
    naruTelefon1: naruTelefon1 ?? this.naruTelefon1,
    naruTelefon2: naruTelefon2 ?? this.naruTelefon2,
    naruEmail: naruEmail ?? this.naruEmail,
    naruPlNaziv: naruPlNaziv ?? this.naruPlNaziv,
    naruPlAdresa: naruPlAdresa ?? this.naruPlAdresa,
    naruPlPib: naruPlPib ?? this.naruPlPib,
    naruPlMb: naruPlMb ?? this.naruPlMb,
    naruPlOdgovornoLice: naruPlOdgovornoLice ?? this.naruPlOdgovornoLice,
    naruPlTelefon1: naruPlTelefon1 ?? this.naruPlTelefon1,
    naruPlTelefon2: naruPlTelefon2 ?? this.naruPlTelefon2,
    naruPlEmail: naruPlEmail ?? this.naruPlEmail,
    naruIstiZaJkp: naruIstiZaJkp ?? this.naruIstiZaJkp,
    jkpTip: jkpTip ?? this.jkpTip,
    jkpIme: jkpIme ?? this.jkpIme,
    jkpPrezime: jkpPrezime ?? this.jkpPrezime,
    jkpImePrezime: jkpImePrezime ?? this.jkpImePrezime,
    jkpJmbg: jkpJmbg ?? this.jkpJmbg,
    jkpAdresa: jkpAdresa ?? this.jkpAdresa,
    jkpBrojLk: jkpBrojLk ?? this.jkpBrojLk,
    jkpTelefon1: jkpTelefon1 ?? this.jkpTelefon1,
    jkpTelefon2: jkpTelefon2 ?? this.jkpTelefon2,
    jkpEmail: jkpEmail ?? this.jkpEmail,
    jkpPlNaziv: jkpPlNaziv ?? this.jkpPlNaziv,
    jkpPlAdresa: jkpPlAdresa ?? this.jkpPlAdresa,
    jkpPlPib: jkpPlPib ?? this.jkpPlPib,
    jkpPlMb: jkpPlMb ?? this.jkpPlMb,
    jkpPlOdgovornoLice: jkpPlOdgovornoLice ?? this.jkpPlOdgovornoLice,
    jkpPlTelefon1: jkpPlTelefon1 ?? this.jkpPlTelefon1,
    jkpPlEmail: jkpPlEmail ?? this.jkpPlEmail,
    groblje: groblje ?? this.groblje,
    tipGroblja: tipGroblja ?? this.tipGroblja,
    vrstaCeremonije: vrstaCeremonije ?? this.vrstaCeremonije,
    datumCeremonije: datumCeremonije ?? this.datumCeremonije,
    vremeCeremonije: vremeCeremonije ?? this.vremeCeremonije,
    opelo: opelo ?? this.opelo,
    opeloMesto: opeloMesto ?? this.opeloMesto,
    vremeOpela: vremeOpela ?? this.vremeOpela,
    vremeIspracaja: vremeIspracaja ?? this.vremeIspracaja,
    grobnoMesto: grobnoMesto ?? this.grobnoMesto,
    tipGrobnogMesta: tipGrobnogMesta ?? this.tipGrobnogMesta,
    parcela: parcela ?? this.parcela,
    grobBroj: grobBroj ?? this.grobBroj,
    redGrob: redGrob ?? this.redGrob,
    npk: npk ?? this.npk,
    grobnica: grobnica ?? this.grobnica,
    urnaSifra: urnaSifra ?? this.urnaSifra,
    tipPolaganja: tipPolaganja ?? this.tipPolaganja,
    urnaParcela: urnaParcela ?? this.urnaParcela,
    urnaBroj: urnaBroj ?? this.urnaBroj,
    urnaRed: urnaRed ?? this.urnaRed,
    urnaNpk: urnaNpk ?? this.urnaNpk,
    sahranaVanSrbije: sahranaVanSrbije ?? this.sahranaVanSrbije,
    svisZemlja: svisZemlja ?? this.svisZemlja,
    svisGrad: svisGrad ?? this.svisGrad,
    docekPosmrtnihOstataka:
        docekPosmrtnihOstataka ?? this.docekPosmrtnihOstataka,
    docekMesto: docekMesto ?? this.docekMesto,
    docekVreme: docekVreme ?? this.docekVreme,
    simbol: simbol ?? this.simbol,
    pismo: pismo ?? this.pismo,
    parteIme: parteIme ?? this.parteIme,
    ozaloseni: ozaloseni ?? this.ozaloseni,
    avans: avans ?? this.avans,
    troskoviJkp: troskoviJkp ?? this.troskoviJkp,
    jkpPlacaSamostalno: jkpPlacaSamostalno ?? this.jkpPlacaSamostalno,
    popust: popust ?? this.popust,
    nacinPlacanja: nacinPlacanja ?? this.nacinPlacanja,
    napomenaPlacanja: napomenaPlacanja ?? this.napomenaPlacanja,
    napomena: napomena ?? this.napomena,
    exportVerzija: exportVerzija ?? this.exportVerzija,
  );
  PredmetiData copyWithCompanion(PredmetiCompanion data) {
    return PredmetiData(
      id: data.id.present ? data.id.value : this.id,
      brojPredmeta: data.brojPredmeta.present
          ? data.brojPredmeta.value
          : this.brojPredmeta,
      status: data.status.present ? data.status.value : this.status,
      datumKreiranja: data.datumKreiranja.present
          ? data.datumKreiranja.value
          : this.datumKreiranja,
      savetnikId: data.savetnikId.present
          ? data.savetnikId.value
          : this.savetnikId,
      verzija: data.verzija.present ? data.verzija.value : this.verzija,
      businessScenarioId: data.businessScenarioId.present
          ? data.businessScenarioId.value
          : this.businessScenarioId,
      sourceIdentity: data.sourceIdentity.present
          ? data.sourceIdentity.value
          : this.sourceIdentity,
      createdByKorisnikId: data.createdByKorisnikId.present
          ? data.createdByKorisnikId.value
          : this.createdByKorisnikId,
      lastBusinessModifiedByKorisnikId:
          data.lastBusinessModifiedByKorisnikId.present
          ? data.lastBusinessModifiedByKorisnikId.value
          : this.lastBusinessModifiedByKorisnikId,
      lastBusinessModifiedAt: data.lastBusinessModifiedAt.present
          ? data.lastBusinessModifiedAt.value
          : this.lastBusinessModifiedAt,
      ime: data.ime.present ? data.ime.value : this.ime,
      prezime: data.prezime.present ? data.prezime.value : this.prezime,
      srednje: data.srednje.present ? data.srednje.value : this.srednje,
      devojackoPrezime: data.devojackoPrezime.present
          ? data.devojackoPrezime.value
          : this.devojackoPrezime,
      jmbg: data.jmbg.present ? data.jmbg.value : this.jmbg,
      pol: data.pol.present ? data.pol.value : this.pol,
      datumRodjenja: data.datumRodjenja.present
          ? data.datumRodjenja.value
          : this.datumRodjenja,
      mestoRodjenja: data.mestoRodjenja.present
          ? data.mestoRodjenja.value
          : this.mestoRodjenja,
      datumSmrti: data.datumSmrti.present
          ? data.datumSmrti.value
          : this.datumSmrti,
      mestoSmrti: data.mestoSmrti.present
          ? data.mestoSmrti.value
          : this.mestoSmrti,
      uzrokSmrti: data.uzrokSmrti.present
          ? data.uzrokSmrti.value
          : this.uzrokSmrti,
      adresa: data.adresa.present ? data.adresa.value : this.adresa,
      imeOca: data.imeOca.present ? data.imeOca.value : this.imeOca,
      imeMajke: data.imeMajke.present ? data.imeMajke.value : this.imeMajke,
      bracnoStanje: data.bracnoStanje.present
          ? data.bracnoStanje.value
          : this.bracnoStanje,
      bracniDrugIme: data.bracniDrugIme.present
          ? data.bracniDrugIme.value
          : this.bracniDrugIme,
      bracniDrugPrezime: data.bracniDrugPrezime.present
          ? data.bracniDrugPrezime.value
          : this.bracniDrugPrezime,
      bracniDrugPol: data.bracniDrugPol.present
          ? data.bracniDrugPol.value
          : this.bracniDrugPol,
      bracniDrugJmbg: data.bracniDrugJmbg.present
          ? data.bracniDrugJmbg.value
          : this.bracniDrugJmbg,
      bracniDrugDevojacko: data.bracniDrugDevojacko.present
          ? data.bracniDrugDevojacko.value
          : this.bracniDrugDevojacko,
      zanimanje: data.zanimanje.present ? data.zanimanje.value : this.zanimanje,
      zanimanjeNaParti: data.zanimanjeNaParti.present
          ? data.zanimanjeNaParti.value
          : this.zanimanjeNaParti,
      titula: data.titula.present ? data.titula.value : this.titula,
      titulaIspred: data.titulaIspred.present
          ? data.titulaIspred.value
          : this.titulaIspred,
      cin: data.cin.present ? data.cin.value : this.cin,
      cinNaParti: data.cinNaParti.present
          ? data.cinNaParti.value
          : this.cinNaParti,
      srednjeNaParti: data.srednjeNaParti.present
          ? data.srednjeNaParti.value
          : this.srednjeNaParti,
      nadimak: data.nadimak.present ? data.nadimak.value : this.nadimak,
      nadimakNaParti: data.nadimakNaParti.present
          ? data.nadimakNaParti.value
          : this.nadimakNaParti,
      nadimakCrtica: data.nadimakCrtica.present
          ? data.nadimakCrtica.value
          : this.nadimakCrtica,
      radniStatus: data.radniStatus.present
          ? data.radniStatus.value
          : this.radniStatus,
      penzioner: data.penzioner.present ? data.penzioner.value : this.penzioner,
      penzionerSrbije: data.penzionerSrbije.present
          ? data.penzionerSrbije.value
          : this.penzionerSrbije,
      vojniPenzioner: data.vojniPenzioner.present
          ? data.vojniPenzioner.value
          : this.vojniPenzioner,
      vojnePocasti: data.vojnePocasti.present
          ? data.vojnePocasti.value
          : this.vojnePocasti,
      posmrtnaPomoc: data.posmrtnaPomoc.present
          ? data.posmrtnaPomoc.value
          : this.posmrtnaPomoc,
      refundacijaPio: data.refundacijaPio.present
          ? data.refundacijaPio.value
          : this.refundacijaPio,
      narucilacRefundira: data.narucilacRefundira.present
          ? data.narucilacRefundira.value
          : this.narucilacRefundira,
      bracniDrugOstvarujePravo: data.bracniDrugOstvarujePravo.present
          ? data.bracniDrugOstvarujePravo.value
          : this.bracniDrugOstvarujePravo,
      bracniDrugJePenzioner: data.bracniDrugJePenzioner.present
          ? data.bracniDrugJePenzioner.value
          : this.bracniDrugJePenzioner,
      penzionerNapomena: data.penzionerNapomena.present
          ? data.penzionerNapomena.value
          : this.penzionerNapomena,
      naruTip: data.naruTip.present ? data.naruTip.value : this.naruTip,
      naruIme: data.naruIme.present ? data.naruIme.value : this.naruIme,
      naruPrezime: data.naruPrezime.present
          ? data.naruPrezime.value
          : this.naruPrezime,
      naruImePrezime: data.naruImePrezime.present
          ? data.naruImePrezime.value
          : this.naruImePrezime,
      naruJmbg: data.naruJmbg.present ? data.naruJmbg.value : this.naruJmbg,
      naruAdresa: data.naruAdresa.present
          ? data.naruAdresa.value
          : this.naruAdresa,
      naruBrojLk: data.naruBrojLk.present
          ? data.naruBrojLk.value
          : this.naruBrojLk,
      naruTelefon1: data.naruTelefon1.present
          ? data.naruTelefon1.value
          : this.naruTelefon1,
      naruTelefon2: data.naruTelefon2.present
          ? data.naruTelefon2.value
          : this.naruTelefon2,
      naruEmail: data.naruEmail.present ? data.naruEmail.value : this.naruEmail,
      naruPlNaziv: data.naruPlNaziv.present
          ? data.naruPlNaziv.value
          : this.naruPlNaziv,
      naruPlAdresa: data.naruPlAdresa.present
          ? data.naruPlAdresa.value
          : this.naruPlAdresa,
      naruPlPib: data.naruPlPib.present ? data.naruPlPib.value : this.naruPlPib,
      naruPlMb: data.naruPlMb.present ? data.naruPlMb.value : this.naruPlMb,
      naruPlOdgovornoLice: data.naruPlOdgovornoLice.present
          ? data.naruPlOdgovornoLice.value
          : this.naruPlOdgovornoLice,
      naruPlTelefon1: data.naruPlTelefon1.present
          ? data.naruPlTelefon1.value
          : this.naruPlTelefon1,
      naruPlTelefon2: data.naruPlTelefon2.present
          ? data.naruPlTelefon2.value
          : this.naruPlTelefon2,
      naruPlEmail: data.naruPlEmail.present
          ? data.naruPlEmail.value
          : this.naruPlEmail,
      naruIstiZaJkp: data.naruIstiZaJkp.present
          ? data.naruIstiZaJkp.value
          : this.naruIstiZaJkp,
      jkpTip: data.jkpTip.present ? data.jkpTip.value : this.jkpTip,
      jkpIme: data.jkpIme.present ? data.jkpIme.value : this.jkpIme,
      jkpPrezime: data.jkpPrezime.present
          ? data.jkpPrezime.value
          : this.jkpPrezime,
      jkpImePrezime: data.jkpImePrezime.present
          ? data.jkpImePrezime.value
          : this.jkpImePrezime,
      jkpJmbg: data.jkpJmbg.present ? data.jkpJmbg.value : this.jkpJmbg,
      jkpAdresa: data.jkpAdresa.present ? data.jkpAdresa.value : this.jkpAdresa,
      jkpBrojLk: data.jkpBrojLk.present ? data.jkpBrojLk.value : this.jkpBrojLk,
      jkpTelefon1: data.jkpTelefon1.present
          ? data.jkpTelefon1.value
          : this.jkpTelefon1,
      jkpTelefon2: data.jkpTelefon2.present
          ? data.jkpTelefon2.value
          : this.jkpTelefon2,
      jkpEmail: data.jkpEmail.present ? data.jkpEmail.value : this.jkpEmail,
      jkpPlNaziv: data.jkpPlNaziv.present
          ? data.jkpPlNaziv.value
          : this.jkpPlNaziv,
      jkpPlAdresa: data.jkpPlAdresa.present
          ? data.jkpPlAdresa.value
          : this.jkpPlAdresa,
      jkpPlPib: data.jkpPlPib.present ? data.jkpPlPib.value : this.jkpPlPib,
      jkpPlMb: data.jkpPlMb.present ? data.jkpPlMb.value : this.jkpPlMb,
      jkpPlOdgovornoLice: data.jkpPlOdgovornoLice.present
          ? data.jkpPlOdgovornoLice.value
          : this.jkpPlOdgovornoLice,
      jkpPlTelefon1: data.jkpPlTelefon1.present
          ? data.jkpPlTelefon1.value
          : this.jkpPlTelefon1,
      jkpPlEmail: data.jkpPlEmail.present
          ? data.jkpPlEmail.value
          : this.jkpPlEmail,
      groblje: data.groblje.present ? data.groblje.value : this.groblje,
      tipGroblja: data.tipGroblja.present
          ? data.tipGroblja.value
          : this.tipGroblja,
      vrstaCeremonije: data.vrstaCeremonije.present
          ? data.vrstaCeremonije.value
          : this.vrstaCeremonije,
      datumCeremonije: data.datumCeremonije.present
          ? data.datumCeremonije.value
          : this.datumCeremonije,
      vremeCeremonije: data.vremeCeremonije.present
          ? data.vremeCeremonije.value
          : this.vremeCeremonije,
      opelo: data.opelo.present ? data.opelo.value : this.opelo,
      opeloMesto: data.opeloMesto.present
          ? data.opeloMesto.value
          : this.opeloMesto,
      vremeOpela: data.vremeOpela.present
          ? data.vremeOpela.value
          : this.vremeOpela,
      vremeIspracaja: data.vremeIspracaja.present
          ? data.vremeIspracaja.value
          : this.vremeIspracaja,
      grobnoMesto: data.grobnoMesto.present
          ? data.grobnoMesto.value
          : this.grobnoMesto,
      tipGrobnogMesta: data.tipGrobnogMesta.present
          ? data.tipGrobnogMesta.value
          : this.tipGrobnogMesta,
      parcela: data.parcela.present ? data.parcela.value : this.parcela,
      grobBroj: data.grobBroj.present ? data.grobBroj.value : this.grobBroj,
      redGrob: data.redGrob.present ? data.redGrob.value : this.redGrob,
      npk: data.npk.present ? data.npk.value : this.npk,
      grobnica: data.grobnica.present ? data.grobnica.value : this.grobnica,
      urnaSifra: data.urnaSifra.present ? data.urnaSifra.value : this.urnaSifra,
      tipPolaganja: data.tipPolaganja.present
          ? data.tipPolaganja.value
          : this.tipPolaganja,
      urnaParcela: data.urnaParcela.present
          ? data.urnaParcela.value
          : this.urnaParcela,
      urnaBroj: data.urnaBroj.present ? data.urnaBroj.value : this.urnaBroj,
      urnaRed: data.urnaRed.present ? data.urnaRed.value : this.urnaRed,
      urnaNpk: data.urnaNpk.present ? data.urnaNpk.value : this.urnaNpk,
      sahranaVanSrbije: data.sahranaVanSrbije.present
          ? data.sahranaVanSrbije.value
          : this.sahranaVanSrbije,
      svisZemlja: data.svisZemlja.present
          ? data.svisZemlja.value
          : this.svisZemlja,
      svisGrad: data.svisGrad.present ? data.svisGrad.value : this.svisGrad,
      docekPosmrtnihOstataka: data.docekPosmrtnihOstataka.present
          ? data.docekPosmrtnihOstataka.value
          : this.docekPosmrtnihOstataka,
      docekMesto: data.docekMesto.present
          ? data.docekMesto.value
          : this.docekMesto,
      docekVreme: data.docekVreme.present
          ? data.docekVreme.value
          : this.docekVreme,
      simbol: data.simbol.present ? data.simbol.value : this.simbol,
      pismo: data.pismo.present ? data.pismo.value : this.pismo,
      parteIme: data.parteIme.present ? data.parteIme.value : this.parteIme,
      ozaloseni: data.ozaloseni.present ? data.ozaloseni.value : this.ozaloseni,
      avans: data.avans.present ? data.avans.value : this.avans,
      troskoviJkp: data.troskoviJkp.present
          ? data.troskoviJkp.value
          : this.troskoviJkp,
      jkpPlacaSamostalno: data.jkpPlacaSamostalno.present
          ? data.jkpPlacaSamostalno.value
          : this.jkpPlacaSamostalno,
      popust: data.popust.present ? data.popust.value : this.popust,
      nacinPlacanja: data.nacinPlacanja.present
          ? data.nacinPlacanja.value
          : this.nacinPlacanja,
      napomenaPlacanja: data.napomenaPlacanja.present
          ? data.napomenaPlacanja.value
          : this.napomenaPlacanja,
      napomena: data.napomena.present ? data.napomena.value : this.napomena,
      exportVerzija: data.exportVerzija.present
          ? data.exportVerzija.value
          : this.exportVerzija,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredmetiData(')
          ..write('id: $id, ')
          ..write('brojPredmeta: $brojPredmeta, ')
          ..write('status: $status, ')
          ..write('datumKreiranja: $datumKreiranja, ')
          ..write('savetnikId: $savetnikId, ')
          ..write('verzija: $verzija, ')
          ..write('businessScenarioId: $businessScenarioId, ')
          ..write('sourceIdentity: $sourceIdentity, ')
          ..write('createdByKorisnikId: $createdByKorisnikId, ')
          ..write(
            'lastBusinessModifiedByKorisnikId: $lastBusinessModifiedByKorisnikId, ',
          )
          ..write('lastBusinessModifiedAt: $lastBusinessModifiedAt, ')
          ..write('ime: $ime, ')
          ..write('prezime: $prezime, ')
          ..write('srednje: $srednje, ')
          ..write('devojackoPrezime: $devojackoPrezime, ')
          ..write('jmbg: $jmbg, ')
          ..write('pol: $pol, ')
          ..write('datumRodjenja: $datumRodjenja, ')
          ..write('mestoRodjenja: $mestoRodjenja, ')
          ..write('datumSmrti: $datumSmrti, ')
          ..write('mestoSmrti: $mestoSmrti, ')
          ..write('uzrokSmrti: $uzrokSmrti, ')
          ..write('adresa: $adresa, ')
          ..write('imeOca: $imeOca, ')
          ..write('imeMajke: $imeMajke, ')
          ..write('bracnoStanje: $bracnoStanje, ')
          ..write('bracniDrugIme: $bracniDrugIme, ')
          ..write('bracniDrugPrezime: $bracniDrugPrezime, ')
          ..write('bracniDrugPol: $bracniDrugPol, ')
          ..write('bracniDrugJmbg: $bracniDrugJmbg, ')
          ..write('bracniDrugDevojacko: $bracniDrugDevojacko, ')
          ..write('zanimanje: $zanimanje, ')
          ..write('zanimanjeNaParti: $zanimanjeNaParti, ')
          ..write('titula: $titula, ')
          ..write('titulaIspred: $titulaIspred, ')
          ..write('cin: $cin, ')
          ..write('cinNaParti: $cinNaParti, ')
          ..write('srednjeNaParti: $srednjeNaParti, ')
          ..write('nadimak: $nadimak, ')
          ..write('nadimakNaParti: $nadimakNaParti, ')
          ..write('nadimakCrtica: $nadimakCrtica, ')
          ..write('radniStatus: $radniStatus, ')
          ..write('penzioner: $penzioner, ')
          ..write('penzionerSrbije: $penzionerSrbije, ')
          ..write('vojniPenzioner: $vojniPenzioner, ')
          ..write('vojnePocasti: $vojnePocasti, ')
          ..write('posmrtnaPomoc: $posmrtnaPomoc, ')
          ..write('refundacijaPio: $refundacijaPio, ')
          ..write('narucilacRefundira: $narucilacRefundira, ')
          ..write('bracniDrugOstvarujePravo: $bracniDrugOstvarujePravo, ')
          ..write('bracniDrugJePenzioner: $bracniDrugJePenzioner, ')
          ..write('penzionerNapomena: $penzionerNapomena, ')
          ..write('naruTip: $naruTip, ')
          ..write('naruIme: $naruIme, ')
          ..write('naruPrezime: $naruPrezime, ')
          ..write('naruImePrezime: $naruImePrezime, ')
          ..write('naruJmbg: $naruJmbg, ')
          ..write('naruAdresa: $naruAdresa, ')
          ..write('naruBrojLk: $naruBrojLk, ')
          ..write('naruTelefon1: $naruTelefon1, ')
          ..write('naruTelefon2: $naruTelefon2, ')
          ..write('naruEmail: $naruEmail, ')
          ..write('naruPlNaziv: $naruPlNaziv, ')
          ..write('naruPlAdresa: $naruPlAdresa, ')
          ..write('naruPlPib: $naruPlPib, ')
          ..write('naruPlMb: $naruPlMb, ')
          ..write('naruPlOdgovornoLice: $naruPlOdgovornoLice, ')
          ..write('naruPlTelefon1: $naruPlTelefon1, ')
          ..write('naruPlTelefon2: $naruPlTelefon2, ')
          ..write('naruPlEmail: $naruPlEmail, ')
          ..write('naruIstiZaJkp: $naruIstiZaJkp, ')
          ..write('jkpTip: $jkpTip, ')
          ..write('jkpIme: $jkpIme, ')
          ..write('jkpPrezime: $jkpPrezime, ')
          ..write('jkpImePrezime: $jkpImePrezime, ')
          ..write('jkpJmbg: $jkpJmbg, ')
          ..write('jkpAdresa: $jkpAdresa, ')
          ..write('jkpBrojLk: $jkpBrojLk, ')
          ..write('jkpTelefon1: $jkpTelefon1, ')
          ..write('jkpTelefon2: $jkpTelefon2, ')
          ..write('jkpEmail: $jkpEmail, ')
          ..write('jkpPlNaziv: $jkpPlNaziv, ')
          ..write('jkpPlAdresa: $jkpPlAdresa, ')
          ..write('jkpPlPib: $jkpPlPib, ')
          ..write('jkpPlMb: $jkpPlMb, ')
          ..write('jkpPlOdgovornoLice: $jkpPlOdgovornoLice, ')
          ..write('jkpPlTelefon1: $jkpPlTelefon1, ')
          ..write('jkpPlEmail: $jkpPlEmail, ')
          ..write('groblje: $groblje, ')
          ..write('tipGroblja: $tipGroblja, ')
          ..write('vrstaCeremonije: $vrstaCeremonije, ')
          ..write('datumCeremonije: $datumCeremonije, ')
          ..write('vremeCeremonije: $vremeCeremonije, ')
          ..write('opelo: $opelo, ')
          ..write('opeloMesto: $opeloMesto, ')
          ..write('vremeOpela: $vremeOpela, ')
          ..write('vremeIspracaja: $vremeIspracaja, ')
          ..write('grobnoMesto: $grobnoMesto, ')
          ..write('tipGrobnogMesta: $tipGrobnogMesta, ')
          ..write('parcela: $parcela, ')
          ..write('grobBroj: $grobBroj, ')
          ..write('redGrob: $redGrob, ')
          ..write('npk: $npk, ')
          ..write('grobnica: $grobnica, ')
          ..write('urnaSifra: $urnaSifra, ')
          ..write('tipPolaganja: $tipPolaganja, ')
          ..write('urnaParcela: $urnaParcela, ')
          ..write('urnaBroj: $urnaBroj, ')
          ..write('urnaRed: $urnaRed, ')
          ..write('urnaNpk: $urnaNpk, ')
          ..write('sahranaVanSrbije: $sahranaVanSrbije, ')
          ..write('svisZemlja: $svisZemlja, ')
          ..write('svisGrad: $svisGrad, ')
          ..write('docekPosmrtnihOstataka: $docekPosmrtnihOstataka, ')
          ..write('docekMesto: $docekMesto, ')
          ..write('docekVreme: $docekVreme, ')
          ..write('simbol: $simbol, ')
          ..write('pismo: $pismo, ')
          ..write('parteIme: $parteIme, ')
          ..write('ozaloseni: $ozaloseni, ')
          ..write('avans: $avans, ')
          ..write('troskoviJkp: $troskoviJkp, ')
          ..write('jkpPlacaSamostalno: $jkpPlacaSamostalno, ')
          ..write('popust: $popust, ')
          ..write('nacinPlacanja: $nacinPlacanja, ')
          ..write('napomenaPlacanja: $napomenaPlacanja, ')
          ..write('napomena: $napomena, ')
          ..write('exportVerzija: $exportVerzija')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    brojPredmeta,
    status,
    datumKreiranja,
    savetnikId,
    verzija,
    businessScenarioId,
    sourceIdentity,
    createdByKorisnikId,
    lastBusinessModifiedByKorisnikId,
    lastBusinessModifiedAt,
    ime,
    prezime,
    srednje,
    devojackoPrezime,
    jmbg,
    pol,
    datumRodjenja,
    mestoRodjenja,
    datumSmrti,
    mestoSmrti,
    uzrokSmrti,
    adresa,
    imeOca,
    imeMajke,
    bracnoStanje,
    bracniDrugIme,
    bracniDrugPrezime,
    bracniDrugPol,
    bracniDrugJmbg,
    bracniDrugDevojacko,
    zanimanje,
    zanimanjeNaParti,
    titula,
    titulaIspred,
    cin,
    cinNaParti,
    srednjeNaParti,
    nadimak,
    nadimakNaParti,
    nadimakCrtica,
    radniStatus,
    penzioner,
    penzionerSrbije,
    vojniPenzioner,
    vojnePocasti,
    posmrtnaPomoc,
    refundacijaPio,
    narucilacRefundira,
    bracniDrugOstvarujePravo,
    bracniDrugJePenzioner,
    penzionerNapomena,
    naruTip,
    naruIme,
    naruPrezime,
    naruImePrezime,
    naruJmbg,
    naruAdresa,
    naruBrojLk,
    naruTelefon1,
    naruTelefon2,
    naruEmail,
    naruPlNaziv,
    naruPlAdresa,
    naruPlPib,
    naruPlMb,
    naruPlOdgovornoLice,
    naruPlTelefon1,
    naruPlTelefon2,
    naruPlEmail,
    naruIstiZaJkp,
    jkpTip,
    jkpIme,
    jkpPrezime,
    jkpImePrezime,
    jkpJmbg,
    jkpAdresa,
    jkpBrojLk,
    jkpTelefon1,
    jkpTelefon2,
    jkpEmail,
    jkpPlNaziv,
    jkpPlAdresa,
    jkpPlPib,
    jkpPlMb,
    jkpPlOdgovornoLice,
    jkpPlTelefon1,
    jkpPlEmail,
    groblje,
    tipGroblja,
    vrstaCeremonije,
    datumCeremonije,
    vremeCeremonije,
    opelo,
    opeloMesto,
    vremeOpela,
    vremeIspracaja,
    grobnoMesto,
    tipGrobnogMesta,
    parcela,
    grobBroj,
    redGrob,
    npk,
    grobnica,
    urnaSifra,
    tipPolaganja,
    urnaParcela,
    urnaBroj,
    urnaRed,
    urnaNpk,
    sahranaVanSrbije,
    svisZemlja,
    svisGrad,
    docekPosmrtnihOstataka,
    docekMesto,
    docekVreme,
    simbol,
    pismo,
    parteIme,
    ozaloseni,
    avans,
    troskoviJkp,
    jkpPlacaSamostalno,
    popust,
    nacinPlacanja,
    napomenaPlacanja,
    napomena,
    exportVerzija,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredmetiData &&
          other.id == this.id &&
          other.brojPredmeta == this.brojPredmeta &&
          other.status == this.status &&
          other.datumKreiranja == this.datumKreiranja &&
          other.savetnikId == this.savetnikId &&
          other.verzija == this.verzija &&
          other.businessScenarioId == this.businessScenarioId &&
          other.sourceIdentity == this.sourceIdentity &&
          other.createdByKorisnikId == this.createdByKorisnikId &&
          other.lastBusinessModifiedByKorisnikId ==
              this.lastBusinessModifiedByKorisnikId &&
          other.lastBusinessModifiedAt == this.lastBusinessModifiedAt &&
          other.ime == this.ime &&
          other.prezime == this.prezime &&
          other.srednje == this.srednje &&
          other.devojackoPrezime == this.devojackoPrezime &&
          other.jmbg == this.jmbg &&
          other.pol == this.pol &&
          other.datumRodjenja == this.datumRodjenja &&
          other.mestoRodjenja == this.mestoRodjenja &&
          other.datumSmrti == this.datumSmrti &&
          other.mestoSmrti == this.mestoSmrti &&
          other.uzrokSmrti == this.uzrokSmrti &&
          other.adresa == this.adresa &&
          other.imeOca == this.imeOca &&
          other.imeMajke == this.imeMajke &&
          other.bracnoStanje == this.bracnoStanje &&
          other.bracniDrugIme == this.bracniDrugIme &&
          other.bracniDrugPrezime == this.bracniDrugPrezime &&
          other.bracniDrugPol == this.bracniDrugPol &&
          other.bracniDrugJmbg == this.bracniDrugJmbg &&
          other.bracniDrugDevojacko == this.bracniDrugDevojacko &&
          other.zanimanje == this.zanimanje &&
          other.zanimanjeNaParti == this.zanimanjeNaParti &&
          other.titula == this.titula &&
          other.titulaIspred == this.titulaIspred &&
          other.cin == this.cin &&
          other.cinNaParti == this.cinNaParti &&
          other.srednjeNaParti == this.srednjeNaParti &&
          other.nadimak == this.nadimak &&
          other.nadimakNaParti == this.nadimakNaParti &&
          other.nadimakCrtica == this.nadimakCrtica &&
          other.radniStatus == this.radniStatus &&
          other.penzioner == this.penzioner &&
          other.penzionerSrbije == this.penzionerSrbije &&
          other.vojniPenzioner == this.vojniPenzioner &&
          other.vojnePocasti == this.vojnePocasti &&
          other.posmrtnaPomoc == this.posmrtnaPomoc &&
          other.refundacijaPio == this.refundacijaPio &&
          other.narucilacRefundira == this.narucilacRefundira &&
          other.bracniDrugOstvarujePravo == this.bracniDrugOstvarujePravo &&
          other.bracniDrugJePenzioner == this.bracniDrugJePenzioner &&
          other.penzionerNapomena == this.penzionerNapomena &&
          other.naruTip == this.naruTip &&
          other.naruIme == this.naruIme &&
          other.naruPrezime == this.naruPrezime &&
          other.naruImePrezime == this.naruImePrezime &&
          other.naruJmbg == this.naruJmbg &&
          other.naruAdresa == this.naruAdresa &&
          other.naruBrojLk == this.naruBrojLk &&
          other.naruTelefon1 == this.naruTelefon1 &&
          other.naruTelefon2 == this.naruTelefon2 &&
          other.naruEmail == this.naruEmail &&
          other.naruPlNaziv == this.naruPlNaziv &&
          other.naruPlAdresa == this.naruPlAdresa &&
          other.naruPlPib == this.naruPlPib &&
          other.naruPlMb == this.naruPlMb &&
          other.naruPlOdgovornoLice == this.naruPlOdgovornoLice &&
          other.naruPlTelefon1 == this.naruPlTelefon1 &&
          other.naruPlTelefon2 == this.naruPlTelefon2 &&
          other.naruPlEmail == this.naruPlEmail &&
          other.naruIstiZaJkp == this.naruIstiZaJkp &&
          other.jkpTip == this.jkpTip &&
          other.jkpIme == this.jkpIme &&
          other.jkpPrezime == this.jkpPrezime &&
          other.jkpImePrezime == this.jkpImePrezime &&
          other.jkpJmbg == this.jkpJmbg &&
          other.jkpAdresa == this.jkpAdresa &&
          other.jkpBrojLk == this.jkpBrojLk &&
          other.jkpTelefon1 == this.jkpTelefon1 &&
          other.jkpTelefon2 == this.jkpTelefon2 &&
          other.jkpEmail == this.jkpEmail &&
          other.jkpPlNaziv == this.jkpPlNaziv &&
          other.jkpPlAdresa == this.jkpPlAdresa &&
          other.jkpPlPib == this.jkpPlPib &&
          other.jkpPlMb == this.jkpPlMb &&
          other.jkpPlOdgovornoLice == this.jkpPlOdgovornoLice &&
          other.jkpPlTelefon1 == this.jkpPlTelefon1 &&
          other.jkpPlEmail == this.jkpPlEmail &&
          other.groblje == this.groblje &&
          other.tipGroblja == this.tipGroblja &&
          other.vrstaCeremonije == this.vrstaCeremonije &&
          other.datumCeremonije == this.datumCeremonije &&
          other.vremeCeremonije == this.vremeCeremonije &&
          other.opelo == this.opelo &&
          other.opeloMesto == this.opeloMesto &&
          other.vremeOpela == this.vremeOpela &&
          other.vremeIspracaja == this.vremeIspracaja &&
          other.grobnoMesto == this.grobnoMesto &&
          other.tipGrobnogMesta == this.tipGrobnogMesta &&
          other.parcela == this.parcela &&
          other.grobBroj == this.grobBroj &&
          other.redGrob == this.redGrob &&
          other.npk == this.npk &&
          other.grobnica == this.grobnica &&
          other.urnaSifra == this.urnaSifra &&
          other.tipPolaganja == this.tipPolaganja &&
          other.urnaParcela == this.urnaParcela &&
          other.urnaBroj == this.urnaBroj &&
          other.urnaRed == this.urnaRed &&
          other.urnaNpk == this.urnaNpk &&
          other.sahranaVanSrbije == this.sahranaVanSrbije &&
          other.svisZemlja == this.svisZemlja &&
          other.svisGrad == this.svisGrad &&
          other.docekPosmrtnihOstataka == this.docekPosmrtnihOstataka &&
          other.docekMesto == this.docekMesto &&
          other.docekVreme == this.docekVreme &&
          other.simbol == this.simbol &&
          other.pismo == this.pismo &&
          other.parteIme == this.parteIme &&
          other.ozaloseni == this.ozaloseni &&
          other.avans == this.avans &&
          other.troskoviJkp == this.troskoviJkp &&
          other.jkpPlacaSamostalno == this.jkpPlacaSamostalno &&
          other.popust == this.popust &&
          other.nacinPlacanja == this.nacinPlacanja &&
          other.napomenaPlacanja == this.napomenaPlacanja &&
          other.napomena == this.napomena &&
          other.exportVerzija == this.exportVerzija);
}

class PredmetiCompanion extends UpdateCompanion<PredmetiData> {
  final Value<int> id;
  final Value<String> brojPredmeta;
  final Value<String> status;
  final Value<String> datumKreiranja;
  final Value<int?> savetnikId;
  final Value<int> verzija;
  final Value<String> businessScenarioId;
  final Value<String> sourceIdentity;
  final Value<int?> createdByKorisnikId;
  final Value<int?> lastBusinessModifiedByKorisnikId;
  final Value<String?> lastBusinessModifiedAt;
  final Value<String> ime;
  final Value<String> prezime;
  final Value<String> srednje;
  final Value<String> devojackoPrezime;
  final Value<String> jmbg;
  final Value<String> pol;
  final Value<String> datumRodjenja;
  final Value<String> mestoRodjenja;
  final Value<String> datumSmrti;
  final Value<String> mestoSmrti;
  final Value<String> uzrokSmrti;
  final Value<String> adresa;
  final Value<String> imeOca;
  final Value<String> imeMajke;
  final Value<String> bracnoStanje;
  final Value<String> bracniDrugIme;
  final Value<String> bracniDrugPrezime;
  final Value<String> bracniDrugPol;
  final Value<String> bracniDrugJmbg;
  final Value<String> bracniDrugDevojacko;
  final Value<String> zanimanje;
  final Value<bool> zanimanjeNaParti;
  final Value<String> titula;
  final Value<bool> titulaIspred;
  final Value<String> cin;
  final Value<bool> cinNaParti;
  final Value<bool> srednjeNaParti;
  final Value<String> nadimak;
  final Value<bool> nadimakNaParti;
  final Value<bool> nadimakCrtica;
  final Value<String> radniStatus;
  final Value<String> penzioner;
  final Value<String> penzionerSrbije;
  final Value<String> vojniPenzioner;
  final Value<String> vojnePocasti;
  final Value<String> posmrtnaPomoc;
  final Value<double> refundacijaPio;
  final Value<String> narucilacRefundira;
  final Value<String> bracniDrugOstvarujePravo;
  final Value<String> bracniDrugJePenzioner;
  final Value<String> penzionerNapomena;
  final Value<String> naruTip;
  final Value<String> naruIme;
  final Value<String> naruPrezime;
  final Value<String> naruImePrezime;
  final Value<String> naruJmbg;
  final Value<String> naruAdresa;
  final Value<String> naruBrojLk;
  final Value<String> naruTelefon1;
  final Value<String> naruTelefon2;
  final Value<String> naruEmail;
  final Value<String> naruPlNaziv;
  final Value<String> naruPlAdresa;
  final Value<String> naruPlPib;
  final Value<String> naruPlMb;
  final Value<String> naruPlOdgovornoLice;
  final Value<String> naruPlTelefon1;
  final Value<String> naruPlTelefon2;
  final Value<String> naruPlEmail;
  final Value<bool> naruIstiZaJkp;
  final Value<String> jkpTip;
  final Value<String> jkpIme;
  final Value<String> jkpPrezime;
  final Value<String> jkpImePrezime;
  final Value<String> jkpJmbg;
  final Value<String> jkpAdresa;
  final Value<String> jkpBrojLk;
  final Value<String> jkpTelefon1;
  final Value<String> jkpTelefon2;
  final Value<String> jkpEmail;
  final Value<String> jkpPlNaziv;
  final Value<String> jkpPlAdresa;
  final Value<String> jkpPlPib;
  final Value<String> jkpPlMb;
  final Value<String> jkpPlOdgovornoLice;
  final Value<String> jkpPlTelefon1;
  final Value<String> jkpPlEmail;
  final Value<String> groblje;
  final Value<String> tipGroblja;
  final Value<String> vrstaCeremonije;
  final Value<String> datumCeremonije;
  final Value<String> vremeCeremonije;
  final Value<String> opelo;
  final Value<String> opeloMesto;
  final Value<String> vremeOpela;
  final Value<String> vremeIspracaja;
  final Value<String> grobnoMesto;
  final Value<String> tipGrobnogMesta;
  final Value<String> parcela;
  final Value<String> grobBroj;
  final Value<String> redGrob;
  final Value<String> npk;
  final Value<String> grobnica;
  final Value<String> urnaSifra;
  final Value<String> tipPolaganja;
  final Value<String> urnaParcela;
  final Value<String> urnaBroj;
  final Value<String> urnaRed;
  final Value<String> urnaNpk;
  final Value<bool> sahranaVanSrbije;
  final Value<String> svisZemlja;
  final Value<String> svisGrad;
  final Value<bool> docekPosmrtnihOstataka;
  final Value<String> docekMesto;
  final Value<String> docekVreme;
  final Value<String> simbol;
  final Value<String> pismo;
  final Value<String> parteIme;
  final Value<String> ozaloseni;
  final Value<double> avans;
  final Value<double> troskoviJkp;
  final Value<bool> jkpPlacaSamostalno;
  final Value<double> popust;
  final Value<String> nacinPlacanja;
  final Value<String> napomenaPlacanja;
  final Value<String> napomena;
  final Value<int> exportVerzija;
  const PredmetiCompanion({
    this.id = const Value.absent(),
    this.brojPredmeta = const Value.absent(),
    this.status = const Value.absent(),
    this.datumKreiranja = const Value.absent(),
    this.savetnikId = const Value.absent(),
    this.verzija = const Value.absent(),
    this.businessScenarioId = const Value.absent(),
    this.sourceIdentity = const Value.absent(),
    this.createdByKorisnikId = const Value.absent(),
    this.lastBusinessModifiedByKorisnikId = const Value.absent(),
    this.lastBusinessModifiedAt = const Value.absent(),
    this.ime = const Value.absent(),
    this.prezime = const Value.absent(),
    this.srednje = const Value.absent(),
    this.devojackoPrezime = const Value.absent(),
    this.jmbg = const Value.absent(),
    this.pol = const Value.absent(),
    this.datumRodjenja = const Value.absent(),
    this.mestoRodjenja = const Value.absent(),
    this.datumSmrti = const Value.absent(),
    this.mestoSmrti = const Value.absent(),
    this.uzrokSmrti = const Value.absent(),
    this.adresa = const Value.absent(),
    this.imeOca = const Value.absent(),
    this.imeMajke = const Value.absent(),
    this.bracnoStanje = const Value.absent(),
    this.bracniDrugIme = const Value.absent(),
    this.bracniDrugPrezime = const Value.absent(),
    this.bracniDrugPol = const Value.absent(),
    this.bracniDrugJmbg = const Value.absent(),
    this.bracniDrugDevojacko = const Value.absent(),
    this.zanimanje = const Value.absent(),
    this.zanimanjeNaParti = const Value.absent(),
    this.titula = const Value.absent(),
    this.titulaIspred = const Value.absent(),
    this.cin = const Value.absent(),
    this.cinNaParti = const Value.absent(),
    this.srednjeNaParti = const Value.absent(),
    this.nadimak = const Value.absent(),
    this.nadimakNaParti = const Value.absent(),
    this.nadimakCrtica = const Value.absent(),
    this.radniStatus = const Value.absent(),
    this.penzioner = const Value.absent(),
    this.penzionerSrbije = const Value.absent(),
    this.vojniPenzioner = const Value.absent(),
    this.vojnePocasti = const Value.absent(),
    this.posmrtnaPomoc = const Value.absent(),
    this.refundacijaPio = const Value.absent(),
    this.narucilacRefundira = const Value.absent(),
    this.bracniDrugOstvarujePravo = const Value.absent(),
    this.bracniDrugJePenzioner = const Value.absent(),
    this.penzionerNapomena = const Value.absent(),
    this.naruTip = const Value.absent(),
    this.naruIme = const Value.absent(),
    this.naruPrezime = const Value.absent(),
    this.naruImePrezime = const Value.absent(),
    this.naruJmbg = const Value.absent(),
    this.naruAdresa = const Value.absent(),
    this.naruBrojLk = const Value.absent(),
    this.naruTelefon1 = const Value.absent(),
    this.naruTelefon2 = const Value.absent(),
    this.naruEmail = const Value.absent(),
    this.naruPlNaziv = const Value.absent(),
    this.naruPlAdresa = const Value.absent(),
    this.naruPlPib = const Value.absent(),
    this.naruPlMb = const Value.absent(),
    this.naruPlOdgovornoLice = const Value.absent(),
    this.naruPlTelefon1 = const Value.absent(),
    this.naruPlTelefon2 = const Value.absent(),
    this.naruPlEmail = const Value.absent(),
    this.naruIstiZaJkp = const Value.absent(),
    this.jkpTip = const Value.absent(),
    this.jkpIme = const Value.absent(),
    this.jkpPrezime = const Value.absent(),
    this.jkpImePrezime = const Value.absent(),
    this.jkpJmbg = const Value.absent(),
    this.jkpAdresa = const Value.absent(),
    this.jkpBrojLk = const Value.absent(),
    this.jkpTelefon1 = const Value.absent(),
    this.jkpTelefon2 = const Value.absent(),
    this.jkpEmail = const Value.absent(),
    this.jkpPlNaziv = const Value.absent(),
    this.jkpPlAdresa = const Value.absent(),
    this.jkpPlPib = const Value.absent(),
    this.jkpPlMb = const Value.absent(),
    this.jkpPlOdgovornoLice = const Value.absent(),
    this.jkpPlTelefon1 = const Value.absent(),
    this.jkpPlEmail = const Value.absent(),
    this.groblje = const Value.absent(),
    this.tipGroblja = const Value.absent(),
    this.vrstaCeremonije = const Value.absent(),
    this.datumCeremonije = const Value.absent(),
    this.vremeCeremonije = const Value.absent(),
    this.opelo = const Value.absent(),
    this.opeloMesto = const Value.absent(),
    this.vremeOpela = const Value.absent(),
    this.vremeIspracaja = const Value.absent(),
    this.grobnoMesto = const Value.absent(),
    this.tipGrobnogMesta = const Value.absent(),
    this.parcela = const Value.absent(),
    this.grobBroj = const Value.absent(),
    this.redGrob = const Value.absent(),
    this.npk = const Value.absent(),
    this.grobnica = const Value.absent(),
    this.urnaSifra = const Value.absent(),
    this.tipPolaganja = const Value.absent(),
    this.urnaParcela = const Value.absent(),
    this.urnaBroj = const Value.absent(),
    this.urnaRed = const Value.absent(),
    this.urnaNpk = const Value.absent(),
    this.sahranaVanSrbije = const Value.absent(),
    this.svisZemlja = const Value.absent(),
    this.svisGrad = const Value.absent(),
    this.docekPosmrtnihOstataka = const Value.absent(),
    this.docekMesto = const Value.absent(),
    this.docekVreme = const Value.absent(),
    this.simbol = const Value.absent(),
    this.pismo = const Value.absent(),
    this.parteIme = const Value.absent(),
    this.ozaloseni = const Value.absent(),
    this.avans = const Value.absent(),
    this.troskoviJkp = const Value.absent(),
    this.jkpPlacaSamostalno = const Value.absent(),
    this.popust = const Value.absent(),
    this.nacinPlacanja = const Value.absent(),
    this.napomenaPlacanja = const Value.absent(),
    this.napomena = const Value.absent(),
    this.exportVerzija = const Value.absent(),
  });
  PredmetiCompanion.insert({
    this.id = const Value.absent(),
    this.brojPredmeta = const Value.absent(),
    this.status = const Value.absent(),
    this.datumKreiranja = const Value.absent(),
    this.savetnikId = const Value.absent(),
    this.verzija = const Value.absent(),
    this.businessScenarioId = const Value.absent(),
    this.sourceIdentity = const Value.absent(),
    this.createdByKorisnikId = const Value.absent(),
    this.lastBusinessModifiedByKorisnikId = const Value.absent(),
    this.lastBusinessModifiedAt = const Value.absent(),
    this.ime = const Value.absent(),
    this.prezime = const Value.absent(),
    this.srednje = const Value.absent(),
    this.devojackoPrezime = const Value.absent(),
    this.jmbg = const Value.absent(),
    this.pol = const Value.absent(),
    this.datumRodjenja = const Value.absent(),
    this.mestoRodjenja = const Value.absent(),
    this.datumSmrti = const Value.absent(),
    this.mestoSmrti = const Value.absent(),
    this.uzrokSmrti = const Value.absent(),
    this.adresa = const Value.absent(),
    this.imeOca = const Value.absent(),
    this.imeMajke = const Value.absent(),
    this.bracnoStanje = const Value.absent(),
    this.bracniDrugIme = const Value.absent(),
    this.bracniDrugPrezime = const Value.absent(),
    this.bracniDrugPol = const Value.absent(),
    this.bracniDrugJmbg = const Value.absent(),
    this.bracniDrugDevojacko = const Value.absent(),
    this.zanimanje = const Value.absent(),
    this.zanimanjeNaParti = const Value.absent(),
    this.titula = const Value.absent(),
    this.titulaIspred = const Value.absent(),
    this.cin = const Value.absent(),
    this.cinNaParti = const Value.absent(),
    this.srednjeNaParti = const Value.absent(),
    this.nadimak = const Value.absent(),
    this.nadimakNaParti = const Value.absent(),
    this.nadimakCrtica = const Value.absent(),
    this.radniStatus = const Value.absent(),
    this.penzioner = const Value.absent(),
    this.penzionerSrbije = const Value.absent(),
    this.vojniPenzioner = const Value.absent(),
    this.vojnePocasti = const Value.absent(),
    this.posmrtnaPomoc = const Value.absent(),
    this.refundacijaPio = const Value.absent(),
    this.narucilacRefundira = const Value.absent(),
    this.bracniDrugOstvarujePravo = const Value.absent(),
    this.bracniDrugJePenzioner = const Value.absent(),
    this.penzionerNapomena = const Value.absent(),
    this.naruTip = const Value.absent(),
    this.naruIme = const Value.absent(),
    this.naruPrezime = const Value.absent(),
    this.naruImePrezime = const Value.absent(),
    this.naruJmbg = const Value.absent(),
    this.naruAdresa = const Value.absent(),
    this.naruBrojLk = const Value.absent(),
    this.naruTelefon1 = const Value.absent(),
    this.naruTelefon2 = const Value.absent(),
    this.naruEmail = const Value.absent(),
    this.naruPlNaziv = const Value.absent(),
    this.naruPlAdresa = const Value.absent(),
    this.naruPlPib = const Value.absent(),
    this.naruPlMb = const Value.absent(),
    this.naruPlOdgovornoLice = const Value.absent(),
    this.naruPlTelefon1 = const Value.absent(),
    this.naruPlTelefon2 = const Value.absent(),
    this.naruPlEmail = const Value.absent(),
    this.naruIstiZaJkp = const Value.absent(),
    this.jkpTip = const Value.absent(),
    this.jkpIme = const Value.absent(),
    this.jkpPrezime = const Value.absent(),
    this.jkpImePrezime = const Value.absent(),
    this.jkpJmbg = const Value.absent(),
    this.jkpAdresa = const Value.absent(),
    this.jkpBrojLk = const Value.absent(),
    this.jkpTelefon1 = const Value.absent(),
    this.jkpTelefon2 = const Value.absent(),
    this.jkpEmail = const Value.absent(),
    this.jkpPlNaziv = const Value.absent(),
    this.jkpPlAdresa = const Value.absent(),
    this.jkpPlPib = const Value.absent(),
    this.jkpPlMb = const Value.absent(),
    this.jkpPlOdgovornoLice = const Value.absent(),
    this.jkpPlTelefon1 = const Value.absent(),
    this.jkpPlEmail = const Value.absent(),
    this.groblje = const Value.absent(),
    this.tipGroblja = const Value.absent(),
    this.vrstaCeremonije = const Value.absent(),
    this.datumCeremonije = const Value.absent(),
    this.vremeCeremonije = const Value.absent(),
    this.opelo = const Value.absent(),
    this.opeloMesto = const Value.absent(),
    this.vremeOpela = const Value.absent(),
    this.vremeIspracaja = const Value.absent(),
    this.grobnoMesto = const Value.absent(),
    this.tipGrobnogMesta = const Value.absent(),
    this.parcela = const Value.absent(),
    this.grobBroj = const Value.absent(),
    this.redGrob = const Value.absent(),
    this.npk = const Value.absent(),
    this.grobnica = const Value.absent(),
    this.urnaSifra = const Value.absent(),
    this.tipPolaganja = const Value.absent(),
    this.urnaParcela = const Value.absent(),
    this.urnaBroj = const Value.absent(),
    this.urnaRed = const Value.absent(),
    this.urnaNpk = const Value.absent(),
    this.sahranaVanSrbije = const Value.absent(),
    this.svisZemlja = const Value.absent(),
    this.svisGrad = const Value.absent(),
    this.docekPosmrtnihOstataka = const Value.absent(),
    this.docekMesto = const Value.absent(),
    this.docekVreme = const Value.absent(),
    this.simbol = const Value.absent(),
    this.pismo = const Value.absent(),
    this.parteIme = const Value.absent(),
    this.ozaloseni = const Value.absent(),
    this.avans = const Value.absent(),
    this.troskoviJkp = const Value.absent(),
    this.jkpPlacaSamostalno = const Value.absent(),
    this.popust = const Value.absent(),
    this.nacinPlacanja = const Value.absent(),
    this.napomenaPlacanja = const Value.absent(),
    this.napomena = const Value.absent(),
    this.exportVerzija = const Value.absent(),
  });
  static Insertable<PredmetiData> custom({
    Expression<int>? id,
    Expression<String>? brojPredmeta,
    Expression<String>? status,
    Expression<String>? datumKreiranja,
    Expression<int>? savetnikId,
    Expression<int>? verzija,
    Expression<String>? businessScenarioId,
    Expression<String>? sourceIdentity,
    Expression<int>? createdByKorisnikId,
    Expression<int>? lastBusinessModifiedByKorisnikId,
    Expression<String>? lastBusinessModifiedAt,
    Expression<String>? ime,
    Expression<String>? prezime,
    Expression<String>? srednje,
    Expression<String>? devojackoPrezime,
    Expression<String>? jmbg,
    Expression<String>? pol,
    Expression<String>? datumRodjenja,
    Expression<String>? mestoRodjenja,
    Expression<String>? datumSmrti,
    Expression<String>? mestoSmrti,
    Expression<String>? uzrokSmrti,
    Expression<String>? adresa,
    Expression<String>? imeOca,
    Expression<String>? imeMajke,
    Expression<String>? bracnoStanje,
    Expression<String>? bracniDrugIme,
    Expression<String>? bracniDrugPrezime,
    Expression<String>? bracniDrugPol,
    Expression<String>? bracniDrugJmbg,
    Expression<String>? bracniDrugDevojacko,
    Expression<String>? zanimanje,
    Expression<bool>? zanimanjeNaParti,
    Expression<String>? titula,
    Expression<bool>? titulaIspred,
    Expression<String>? cin,
    Expression<bool>? cinNaParti,
    Expression<bool>? srednjeNaParti,
    Expression<String>? nadimak,
    Expression<bool>? nadimakNaParti,
    Expression<bool>? nadimakCrtica,
    Expression<String>? radniStatus,
    Expression<String>? penzioner,
    Expression<String>? penzionerSrbije,
    Expression<String>? vojniPenzioner,
    Expression<String>? vojnePocasti,
    Expression<String>? posmrtnaPomoc,
    Expression<double>? refundacijaPio,
    Expression<String>? narucilacRefundira,
    Expression<String>? bracniDrugOstvarujePravo,
    Expression<String>? bracniDrugJePenzioner,
    Expression<String>? penzionerNapomena,
    Expression<String>? naruTip,
    Expression<String>? naruIme,
    Expression<String>? naruPrezime,
    Expression<String>? naruImePrezime,
    Expression<String>? naruJmbg,
    Expression<String>? naruAdresa,
    Expression<String>? naruBrojLk,
    Expression<String>? naruTelefon1,
    Expression<String>? naruTelefon2,
    Expression<String>? naruEmail,
    Expression<String>? naruPlNaziv,
    Expression<String>? naruPlAdresa,
    Expression<String>? naruPlPib,
    Expression<String>? naruPlMb,
    Expression<String>? naruPlOdgovornoLice,
    Expression<String>? naruPlTelefon1,
    Expression<String>? naruPlTelefon2,
    Expression<String>? naruPlEmail,
    Expression<bool>? naruIstiZaJkp,
    Expression<String>? jkpTip,
    Expression<String>? jkpIme,
    Expression<String>? jkpPrezime,
    Expression<String>? jkpImePrezime,
    Expression<String>? jkpJmbg,
    Expression<String>? jkpAdresa,
    Expression<String>? jkpBrojLk,
    Expression<String>? jkpTelefon1,
    Expression<String>? jkpTelefon2,
    Expression<String>? jkpEmail,
    Expression<String>? jkpPlNaziv,
    Expression<String>? jkpPlAdresa,
    Expression<String>? jkpPlPib,
    Expression<String>? jkpPlMb,
    Expression<String>? jkpPlOdgovornoLice,
    Expression<String>? jkpPlTelefon1,
    Expression<String>? jkpPlEmail,
    Expression<String>? groblje,
    Expression<String>? tipGroblja,
    Expression<String>? vrstaCeremonije,
    Expression<String>? datumCeremonije,
    Expression<String>? vremeCeremonije,
    Expression<String>? opelo,
    Expression<String>? opeloMesto,
    Expression<String>? vremeOpela,
    Expression<String>? vremeIspracaja,
    Expression<String>? grobnoMesto,
    Expression<String>? tipGrobnogMesta,
    Expression<String>? parcela,
    Expression<String>? grobBroj,
    Expression<String>? redGrob,
    Expression<String>? npk,
    Expression<String>? grobnica,
    Expression<String>? urnaSifra,
    Expression<String>? tipPolaganja,
    Expression<String>? urnaParcela,
    Expression<String>? urnaBroj,
    Expression<String>? urnaRed,
    Expression<String>? urnaNpk,
    Expression<bool>? sahranaVanSrbije,
    Expression<String>? svisZemlja,
    Expression<String>? svisGrad,
    Expression<bool>? docekPosmrtnihOstataka,
    Expression<String>? docekMesto,
    Expression<String>? docekVreme,
    Expression<String>? simbol,
    Expression<String>? pismo,
    Expression<String>? parteIme,
    Expression<String>? ozaloseni,
    Expression<double>? avans,
    Expression<double>? troskoviJkp,
    Expression<bool>? jkpPlacaSamostalno,
    Expression<double>? popust,
    Expression<String>? nacinPlacanja,
    Expression<String>? napomenaPlacanja,
    Expression<String>? napomena,
    Expression<int>? exportVerzija,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brojPredmeta != null) 'broj_predmeta': brojPredmeta,
      if (status != null) 'status': status,
      if (datumKreiranja != null) 'datum_kreiranja': datumKreiranja,
      if (savetnikId != null) 'savetnik_id': savetnikId,
      if (verzija != null) 'verzija': verzija,
      if (businessScenarioId != null)
        'business_scenario_id': businessScenarioId,
      if (sourceIdentity != null) 'source_identity': sourceIdentity,
      if (createdByKorisnikId != null)
        'created_by_korisnik_id': createdByKorisnikId,
      if (lastBusinessModifiedByKorisnikId != null)
        'last_business_modified_by_korisnik_id':
            lastBusinessModifiedByKorisnikId,
      if (lastBusinessModifiedAt != null)
        'last_business_modified_at': lastBusinessModifiedAt,
      if (ime != null) 'ime': ime,
      if (prezime != null) 'prezime': prezime,
      if (srednje != null) 'srednje': srednje,
      if (devojackoPrezime != null) 'devojacko_prezime': devojackoPrezime,
      if (jmbg != null) 'jmbg': jmbg,
      if (pol != null) 'pol': pol,
      if (datumRodjenja != null) 'datum_rodjenja': datumRodjenja,
      if (mestoRodjenja != null) 'mesto_rodjenja': mestoRodjenja,
      if (datumSmrti != null) 'datum_smrti': datumSmrti,
      if (mestoSmrti != null) 'mesto_smrti': mestoSmrti,
      if (uzrokSmrti != null) 'uzrok_smrti': uzrokSmrti,
      if (adresa != null) 'adresa': adresa,
      if (imeOca != null) 'ime_oca': imeOca,
      if (imeMajke != null) 'ime_majke': imeMajke,
      if (bracnoStanje != null) 'bracno_stanje': bracnoStanje,
      if (bracniDrugIme != null) 'bracni_drug_ime': bracniDrugIme,
      if (bracniDrugPrezime != null) 'bracni_drug_prezime': bracniDrugPrezime,
      if (bracniDrugPol != null) 'bracni_drug_pol': bracniDrugPol,
      if (bracniDrugJmbg != null) 'bracni_drug_jmbg': bracniDrugJmbg,
      if (bracniDrugDevojacko != null)
        'bracni_drug_devojacko': bracniDrugDevojacko,
      if (zanimanje != null) 'zanimanje': zanimanje,
      if (zanimanjeNaParti != null) 'zanimanje_na_parti': zanimanjeNaParti,
      if (titula != null) 'titula': titula,
      if (titulaIspred != null) 'titula_ispred': titulaIspred,
      if (cin != null) 'cin': cin,
      if (cinNaParti != null) 'cin_na_parti': cinNaParti,
      if (srednjeNaParti != null) 'srednje_na_parti': srednjeNaParti,
      if (nadimak != null) 'nadimak': nadimak,
      if (nadimakNaParti != null) 'nadimak_na_parti': nadimakNaParti,
      if (nadimakCrtica != null) 'nadimak_crtica': nadimakCrtica,
      if (radniStatus != null) 'radni_status': radniStatus,
      if (penzioner != null) 'penzioner': penzioner,
      if (penzionerSrbije != null) 'penzioner_srbije': penzionerSrbije,
      if (vojniPenzioner != null) 'vojni_penzioner': vojniPenzioner,
      if (vojnePocasti != null) 'vojne_pocasti': vojnePocasti,
      if (posmrtnaPomoc != null) 'posmrtna_pomoc': posmrtnaPomoc,
      if (refundacijaPio != null) 'refundacija_pio': refundacijaPio,
      if (narucilacRefundira != null) 'narucilac_refundira': narucilacRefundira,
      if (bracniDrugOstvarujePravo != null)
        'bracni_drug_ostvaruje_pravo': bracniDrugOstvarujePravo,
      if (bracniDrugJePenzioner != null)
        'bracni_drug_je_penzioner': bracniDrugJePenzioner,
      if (penzionerNapomena != null) 'penzioner_napomena': penzionerNapomena,
      if (naruTip != null) 'naru_tip': naruTip,
      if (naruIme != null) 'naru_ime': naruIme,
      if (naruPrezime != null) 'naru_prezime': naruPrezime,
      if (naruImePrezime != null) 'naru_ime_prezime': naruImePrezime,
      if (naruJmbg != null) 'naru_jmbg': naruJmbg,
      if (naruAdresa != null) 'naru_adresa': naruAdresa,
      if (naruBrojLk != null) 'naru_broj_lk': naruBrojLk,
      if (naruTelefon1 != null) 'naru_telefon1': naruTelefon1,
      if (naruTelefon2 != null) 'naru_telefon2': naruTelefon2,
      if (naruEmail != null) 'naru_email': naruEmail,
      if (naruPlNaziv != null) 'naru_pl_naziv': naruPlNaziv,
      if (naruPlAdresa != null) 'naru_pl_adresa': naruPlAdresa,
      if (naruPlPib != null) 'naru_pl_pib': naruPlPib,
      if (naruPlMb != null) 'naru_pl_mb': naruPlMb,
      if (naruPlOdgovornoLice != null)
        'naru_pl_odgovorno_lice': naruPlOdgovornoLice,
      if (naruPlTelefon1 != null) 'naru_pl_telefon1': naruPlTelefon1,
      if (naruPlTelefon2 != null) 'naru_pl_telefon2': naruPlTelefon2,
      if (naruPlEmail != null) 'naru_pl_email': naruPlEmail,
      if (naruIstiZaJkp != null) 'naru_isti_za_jkp': naruIstiZaJkp,
      if (jkpTip != null) 'jkp_tip': jkpTip,
      if (jkpIme != null) 'jkp_ime': jkpIme,
      if (jkpPrezime != null) 'jkp_prezime': jkpPrezime,
      if (jkpImePrezime != null) 'jkp_ime_prezime': jkpImePrezime,
      if (jkpJmbg != null) 'jkp_jmbg': jkpJmbg,
      if (jkpAdresa != null) 'jkp_adresa': jkpAdresa,
      if (jkpBrojLk != null) 'jkp_broj_lk': jkpBrojLk,
      if (jkpTelefon1 != null) 'jkp_telefon1': jkpTelefon1,
      if (jkpTelefon2 != null) 'jkp_telefon2': jkpTelefon2,
      if (jkpEmail != null) 'jkp_email': jkpEmail,
      if (jkpPlNaziv != null) 'jkp_pl_naziv': jkpPlNaziv,
      if (jkpPlAdresa != null) 'jkp_pl_adresa': jkpPlAdresa,
      if (jkpPlPib != null) 'jkp_pl_pib': jkpPlPib,
      if (jkpPlMb != null) 'jkp_pl_mb': jkpPlMb,
      if (jkpPlOdgovornoLice != null)
        'jkp_pl_odgovorno_lice': jkpPlOdgovornoLice,
      if (jkpPlTelefon1 != null) 'jkp_pl_telefon1': jkpPlTelefon1,
      if (jkpPlEmail != null) 'jkp_pl_email': jkpPlEmail,
      if (groblje != null) 'groblje': groblje,
      if (tipGroblja != null) 'tip_groblja': tipGroblja,
      if (vrstaCeremonije != null) 'vrsta_ceremonije': vrstaCeremonije,
      if (datumCeremonije != null) 'datum_ceremonije': datumCeremonije,
      if (vremeCeremonije != null) 'vreme_ceremonije': vremeCeremonije,
      if (opelo != null) 'opelo': opelo,
      if (opeloMesto != null) 'opelo_mesto': opeloMesto,
      if (vremeOpela != null) 'vreme_opela': vremeOpela,
      if (vremeIspracaja != null) 'vreme_ispracaja': vremeIspracaja,
      if (grobnoMesto != null) 'grobno_mesto': grobnoMesto,
      if (tipGrobnogMesta != null) 'tip_grobnog_mesta': tipGrobnogMesta,
      if (parcela != null) 'parcela': parcela,
      if (grobBroj != null) 'grob_broj': grobBroj,
      if (redGrob != null) 'red_grob': redGrob,
      if (npk != null) 'npk': npk,
      if (grobnica != null) 'grobnica': grobnica,
      if (urnaSifra != null) 'urna_sifra': urnaSifra,
      if (tipPolaganja != null) 'tip_polaganja': tipPolaganja,
      if (urnaParcela != null) 'urna_parcela': urnaParcela,
      if (urnaBroj != null) 'urna_broj': urnaBroj,
      if (urnaRed != null) 'urna_red': urnaRed,
      if (urnaNpk != null) 'urna_npk': urnaNpk,
      if (sahranaVanSrbije != null) 'sahrana_van_srbije': sahranaVanSrbije,
      if (svisZemlja != null) 'svis_zemlja': svisZemlja,
      if (svisGrad != null) 'svis_grad': svisGrad,
      if (docekPosmrtnihOstataka != null)
        'docek_posmrtnih_ostataka': docekPosmrtnihOstataka,
      if (docekMesto != null) 'docek_mesto': docekMesto,
      if (docekVreme != null) 'docek_vreme': docekVreme,
      if (simbol != null) 'simbol': simbol,
      if (pismo != null) 'pismo': pismo,
      if (parteIme != null) 'parte_ime': parteIme,
      if (ozaloseni != null) 'ozaloseni': ozaloseni,
      if (avans != null) 'avans': avans,
      if (troskoviJkp != null) 'troskovi_jkp': troskoviJkp,
      if (jkpPlacaSamostalno != null)
        'jkp_placa_samostalno': jkpPlacaSamostalno,
      if (popust != null) 'popust': popust,
      if (nacinPlacanja != null) 'nacin_placanja': nacinPlacanja,
      if (napomenaPlacanja != null) 'napomena_placanja': napomenaPlacanja,
      if (napomena != null) 'napomena': napomena,
      if (exportVerzija != null) 'export_verzija': exportVerzija,
    });
  }

  PredmetiCompanion copyWith({
    Value<int>? id,
    Value<String>? brojPredmeta,
    Value<String>? status,
    Value<String>? datumKreiranja,
    Value<int?>? savetnikId,
    Value<int>? verzija,
    Value<String>? businessScenarioId,
    Value<String>? sourceIdentity,
    Value<int?>? createdByKorisnikId,
    Value<int?>? lastBusinessModifiedByKorisnikId,
    Value<String?>? lastBusinessModifiedAt,
    Value<String>? ime,
    Value<String>? prezime,
    Value<String>? srednje,
    Value<String>? devojackoPrezime,
    Value<String>? jmbg,
    Value<String>? pol,
    Value<String>? datumRodjenja,
    Value<String>? mestoRodjenja,
    Value<String>? datumSmrti,
    Value<String>? mestoSmrti,
    Value<String>? uzrokSmrti,
    Value<String>? adresa,
    Value<String>? imeOca,
    Value<String>? imeMajke,
    Value<String>? bracnoStanje,
    Value<String>? bracniDrugIme,
    Value<String>? bracniDrugPrezime,
    Value<String>? bracniDrugPol,
    Value<String>? bracniDrugJmbg,
    Value<String>? bracniDrugDevojacko,
    Value<String>? zanimanje,
    Value<bool>? zanimanjeNaParti,
    Value<String>? titula,
    Value<bool>? titulaIspred,
    Value<String>? cin,
    Value<bool>? cinNaParti,
    Value<bool>? srednjeNaParti,
    Value<String>? nadimak,
    Value<bool>? nadimakNaParti,
    Value<bool>? nadimakCrtica,
    Value<String>? radniStatus,
    Value<String>? penzioner,
    Value<String>? penzionerSrbije,
    Value<String>? vojniPenzioner,
    Value<String>? vojnePocasti,
    Value<String>? posmrtnaPomoc,
    Value<double>? refundacijaPio,
    Value<String>? narucilacRefundira,
    Value<String>? bracniDrugOstvarujePravo,
    Value<String>? bracniDrugJePenzioner,
    Value<String>? penzionerNapomena,
    Value<String>? naruTip,
    Value<String>? naruIme,
    Value<String>? naruPrezime,
    Value<String>? naruImePrezime,
    Value<String>? naruJmbg,
    Value<String>? naruAdresa,
    Value<String>? naruBrojLk,
    Value<String>? naruTelefon1,
    Value<String>? naruTelefon2,
    Value<String>? naruEmail,
    Value<String>? naruPlNaziv,
    Value<String>? naruPlAdresa,
    Value<String>? naruPlPib,
    Value<String>? naruPlMb,
    Value<String>? naruPlOdgovornoLice,
    Value<String>? naruPlTelefon1,
    Value<String>? naruPlTelefon2,
    Value<String>? naruPlEmail,
    Value<bool>? naruIstiZaJkp,
    Value<String>? jkpTip,
    Value<String>? jkpIme,
    Value<String>? jkpPrezime,
    Value<String>? jkpImePrezime,
    Value<String>? jkpJmbg,
    Value<String>? jkpAdresa,
    Value<String>? jkpBrojLk,
    Value<String>? jkpTelefon1,
    Value<String>? jkpTelefon2,
    Value<String>? jkpEmail,
    Value<String>? jkpPlNaziv,
    Value<String>? jkpPlAdresa,
    Value<String>? jkpPlPib,
    Value<String>? jkpPlMb,
    Value<String>? jkpPlOdgovornoLice,
    Value<String>? jkpPlTelefon1,
    Value<String>? jkpPlEmail,
    Value<String>? groblje,
    Value<String>? tipGroblja,
    Value<String>? vrstaCeremonije,
    Value<String>? datumCeremonije,
    Value<String>? vremeCeremonije,
    Value<String>? opelo,
    Value<String>? opeloMesto,
    Value<String>? vremeOpela,
    Value<String>? vremeIspracaja,
    Value<String>? grobnoMesto,
    Value<String>? tipGrobnogMesta,
    Value<String>? parcela,
    Value<String>? grobBroj,
    Value<String>? redGrob,
    Value<String>? npk,
    Value<String>? grobnica,
    Value<String>? urnaSifra,
    Value<String>? tipPolaganja,
    Value<String>? urnaParcela,
    Value<String>? urnaBroj,
    Value<String>? urnaRed,
    Value<String>? urnaNpk,
    Value<bool>? sahranaVanSrbije,
    Value<String>? svisZemlja,
    Value<String>? svisGrad,
    Value<bool>? docekPosmrtnihOstataka,
    Value<String>? docekMesto,
    Value<String>? docekVreme,
    Value<String>? simbol,
    Value<String>? pismo,
    Value<String>? parteIme,
    Value<String>? ozaloseni,
    Value<double>? avans,
    Value<double>? troskoviJkp,
    Value<bool>? jkpPlacaSamostalno,
    Value<double>? popust,
    Value<String>? nacinPlacanja,
    Value<String>? napomenaPlacanja,
    Value<String>? napomena,
    Value<int>? exportVerzija,
  }) {
    return PredmetiCompanion(
      id: id ?? this.id,
      brojPredmeta: brojPredmeta ?? this.brojPredmeta,
      status: status ?? this.status,
      datumKreiranja: datumKreiranja ?? this.datumKreiranja,
      savetnikId: savetnikId ?? this.savetnikId,
      verzija: verzija ?? this.verzija,
      businessScenarioId: businessScenarioId ?? this.businessScenarioId,
      sourceIdentity: sourceIdentity ?? this.sourceIdentity,
      createdByKorisnikId: createdByKorisnikId ?? this.createdByKorisnikId,
      lastBusinessModifiedByKorisnikId:
          lastBusinessModifiedByKorisnikId ??
          this.lastBusinessModifiedByKorisnikId,
      lastBusinessModifiedAt:
          lastBusinessModifiedAt ?? this.lastBusinessModifiedAt,
      ime: ime ?? this.ime,
      prezime: prezime ?? this.prezime,
      srednje: srednje ?? this.srednje,
      devojackoPrezime: devojackoPrezime ?? this.devojackoPrezime,
      jmbg: jmbg ?? this.jmbg,
      pol: pol ?? this.pol,
      datumRodjenja: datumRodjenja ?? this.datumRodjenja,
      mestoRodjenja: mestoRodjenja ?? this.mestoRodjenja,
      datumSmrti: datumSmrti ?? this.datumSmrti,
      mestoSmrti: mestoSmrti ?? this.mestoSmrti,
      uzrokSmrti: uzrokSmrti ?? this.uzrokSmrti,
      adresa: adresa ?? this.adresa,
      imeOca: imeOca ?? this.imeOca,
      imeMajke: imeMajke ?? this.imeMajke,
      bracnoStanje: bracnoStanje ?? this.bracnoStanje,
      bracniDrugIme: bracniDrugIme ?? this.bracniDrugIme,
      bracniDrugPrezime: bracniDrugPrezime ?? this.bracniDrugPrezime,
      bracniDrugPol: bracniDrugPol ?? this.bracniDrugPol,
      bracniDrugJmbg: bracniDrugJmbg ?? this.bracniDrugJmbg,
      bracniDrugDevojacko: bracniDrugDevojacko ?? this.bracniDrugDevojacko,
      zanimanje: zanimanje ?? this.zanimanje,
      zanimanjeNaParti: zanimanjeNaParti ?? this.zanimanjeNaParti,
      titula: titula ?? this.titula,
      titulaIspred: titulaIspred ?? this.titulaIspred,
      cin: cin ?? this.cin,
      cinNaParti: cinNaParti ?? this.cinNaParti,
      srednjeNaParti: srednjeNaParti ?? this.srednjeNaParti,
      nadimak: nadimak ?? this.nadimak,
      nadimakNaParti: nadimakNaParti ?? this.nadimakNaParti,
      nadimakCrtica: nadimakCrtica ?? this.nadimakCrtica,
      radniStatus: radniStatus ?? this.radniStatus,
      penzioner: penzioner ?? this.penzioner,
      penzionerSrbije: penzionerSrbije ?? this.penzionerSrbije,
      vojniPenzioner: vojniPenzioner ?? this.vojniPenzioner,
      vojnePocasti: vojnePocasti ?? this.vojnePocasti,
      posmrtnaPomoc: posmrtnaPomoc ?? this.posmrtnaPomoc,
      refundacijaPio: refundacijaPio ?? this.refundacijaPio,
      narucilacRefundira: narucilacRefundira ?? this.narucilacRefundira,
      bracniDrugOstvarujePravo:
          bracniDrugOstvarujePravo ?? this.bracniDrugOstvarujePravo,
      bracniDrugJePenzioner:
          bracniDrugJePenzioner ?? this.bracniDrugJePenzioner,
      penzionerNapomena: penzionerNapomena ?? this.penzionerNapomena,
      naruTip: naruTip ?? this.naruTip,
      naruIme: naruIme ?? this.naruIme,
      naruPrezime: naruPrezime ?? this.naruPrezime,
      naruImePrezime: naruImePrezime ?? this.naruImePrezime,
      naruJmbg: naruJmbg ?? this.naruJmbg,
      naruAdresa: naruAdresa ?? this.naruAdresa,
      naruBrojLk: naruBrojLk ?? this.naruBrojLk,
      naruTelefon1: naruTelefon1 ?? this.naruTelefon1,
      naruTelefon2: naruTelefon2 ?? this.naruTelefon2,
      naruEmail: naruEmail ?? this.naruEmail,
      naruPlNaziv: naruPlNaziv ?? this.naruPlNaziv,
      naruPlAdresa: naruPlAdresa ?? this.naruPlAdresa,
      naruPlPib: naruPlPib ?? this.naruPlPib,
      naruPlMb: naruPlMb ?? this.naruPlMb,
      naruPlOdgovornoLice: naruPlOdgovornoLice ?? this.naruPlOdgovornoLice,
      naruPlTelefon1: naruPlTelefon1 ?? this.naruPlTelefon1,
      naruPlTelefon2: naruPlTelefon2 ?? this.naruPlTelefon2,
      naruPlEmail: naruPlEmail ?? this.naruPlEmail,
      naruIstiZaJkp: naruIstiZaJkp ?? this.naruIstiZaJkp,
      jkpTip: jkpTip ?? this.jkpTip,
      jkpIme: jkpIme ?? this.jkpIme,
      jkpPrezime: jkpPrezime ?? this.jkpPrezime,
      jkpImePrezime: jkpImePrezime ?? this.jkpImePrezime,
      jkpJmbg: jkpJmbg ?? this.jkpJmbg,
      jkpAdresa: jkpAdresa ?? this.jkpAdresa,
      jkpBrojLk: jkpBrojLk ?? this.jkpBrojLk,
      jkpTelefon1: jkpTelefon1 ?? this.jkpTelefon1,
      jkpTelefon2: jkpTelefon2 ?? this.jkpTelefon2,
      jkpEmail: jkpEmail ?? this.jkpEmail,
      jkpPlNaziv: jkpPlNaziv ?? this.jkpPlNaziv,
      jkpPlAdresa: jkpPlAdresa ?? this.jkpPlAdresa,
      jkpPlPib: jkpPlPib ?? this.jkpPlPib,
      jkpPlMb: jkpPlMb ?? this.jkpPlMb,
      jkpPlOdgovornoLice: jkpPlOdgovornoLice ?? this.jkpPlOdgovornoLice,
      jkpPlTelefon1: jkpPlTelefon1 ?? this.jkpPlTelefon1,
      jkpPlEmail: jkpPlEmail ?? this.jkpPlEmail,
      groblje: groblje ?? this.groblje,
      tipGroblja: tipGroblja ?? this.tipGroblja,
      vrstaCeremonije: vrstaCeremonije ?? this.vrstaCeremonije,
      datumCeremonije: datumCeremonije ?? this.datumCeremonije,
      vremeCeremonije: vremeCeremonije ?? this.vremeCeremonije,
      opelo: opelo ?? this.opelo,
      opeloMesto: opeloMesto ?? this.opeloMesto,
      vremeOpela: vremeOpela ?? this.vremeOpela,
      vremeIspracaja: vremeIspracaja ?? this.vremeIspracaja,
      grobnoMesto: grobnoMesto ?? this.grobnoMesto,
      tipGrobnogMesta: tipGrobnogMesta ?? this.tipGrobnogMesta,
      parcela: parcela ?? this.parcela,
      grobBroj: grobBroj ?? this.grobBroj,
      redGrob: redGrob ?? this.redGrob,
      npk: npk ?? this.npk,
      grobnica: grobnica ?? this.grobnica,
      urnaSifra: urnaSifra ?? this.urnaSifra,
      tipPolaganja: tipPolaganja ?? this.tipPolaganja,
      urnaParcela: urnaParcela ?? this.urnaParcela,
      urnaBroj: urnaBroj ?? this.urnaBroj,
      urnaRed: urnaRed ?? this.urnaRed,
      urnaNpk: urnaNpk ?? this.urnaNpk,
      sahranaVanSrbije: sahranaVanSrbije ?? this.sahranaVanSrbije,
      svisZemlja: svisZemlja ?? this.svisZemlja,
      svisGrad: svisGrad ?? this.svisGrad,
      docekPosmrtnihOstataka:
          docekPosmrtnihOstataka ?? this.docekPosmrtnihOstataka,
      docekMesto: docekMesto ?? this.docekMesto,
      docekVreme: docekVreme ?? this.docekVreme,
      simbol: simbol ?? this.simbol,
      pismo: pismo ?? this.pismo,
      parteIme: parteIme ?? this.parteIme,
      ozaloseni: ozaloseni ?? this.ozaloseni,
      avans: avans ?? this.avans,
      troskoviJkp: troskoviJkp ?? this.troskoviJkp,
      jkpPlacaSamostalno: jkpPlacaSamostalno ?? this.jkpPlacaSamostalno,
      popust: popust ?? this.popust,
      nacinPlacanja: nacinPlacanja ?? this.nacinPlacanja,
      napomenaPlacanja: napomenaPlacanja ?? this.napomenaPlacanja,
      napomena: napomena ?? this.napomena,
      exportVerzija: exportVerzija ?? this.exportVerzija,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (brojPredmeta.present) {
      map['broj_predmeta'] = Variable<String>(brojPredmeta.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (datumKreiranja.present) {
      map['datum_kreiranja'] = Variable<String>(datumKreiranja.value);
    }
    if (savetnikId.present) {
      map['savetnik_id'] = Variable<int>(savetnikId.value);
    }
    if (verzija.present) {
      map['verzija'] = Variable<int>(verzija.value);
    }
    if (businessScenarioId.present) {
      map['business_scenario_id'] = Variable<String>(businessScenarioId.value);
    }
    if (sourceIdentity.present) {
      map['source_identity'] = Variable<String>(sourceIdentity.value);
    }
    if (createdByKorisnikId.present) {
      map['created_by_korisnik_id'] = Variable<int>(createdByKorisnikId.value);
    }
    if (lastBusinessModifiedByKorisnikId.present) {
      map['last_business_modified_by_korisnik_id'] = Variable<int>(
        lastBusinessModifiedByKorisnikId.value,
      );
    }
    if (lastBusinessModifiedAt.present) {
      map['last_business_modified_at'] = Variable<String>(
        lastBusinessModifiedAt.value,
      );
    }
    if (ime.present) {
      map['ime'] = Variable<String>(ime.value);
    }
    if (prezime.present) {
      map['prezime'] = Variable<String>(prezime.value);
    }
    if (srednje.present) {
      map['srednje'] = Variable<String>(srednje.value);
    }
    if (devojackoPrezime.present) {
      map['devojacko_prezime'] = Variable<String>(devojackoPrezime.value);
    }
    if (jmbg.present) {
      map['jmbg'] = Variable<String>(jmbg.value);
    }
    if (pol.present) {
      map['pol'] = Variable<String>(pol.value);
    }
    if (datumRodjenja.present) {
      map['datum_rodjenja'] = Variable<String>(datumRodjenja.value);
    }
    if (mestoRodjenja.present) {
      map['mesto_rodjenja'] = Variable<String>(mestoRodjenja.value);
    }
    if (datumSmrti.present) {
      map['datum_smrti'] = Variable<String>(datumSmrti.value);
    }
    if (mestoSmrti.present) {
      map['mesto_smrti'] = Variable<String>(mestoSmrti.value);
    }
    if (uzrokSmrti.present) {
      map['uzrok_smrti'] = Variable<String>(uzrokSmrti.value);
    }
    if (adresa.present) {
      map['adresa'] = Variable<String>(adresa.value);
    }
    if (imeOca.present) {
      map['ime_oca'] = Variable<String>(imeOca.value);
    }
    if (imeMajke.present) {
      map['ime_majke'] = Variable<String>(imeMajke.value);
    }
    if (bracnoStanje.present) {
      map['bracno_stanje'] = Variable<String>(bracnoStanje.value);
    }
    if (bracniDrugIme.present) {
      map['bracni_drug_ime'] = Variable<String>(bracniDrugIme.value);
    }
    if (bracniDrugPrezime.present) {
      map['bracni_drug_prezime'] = Variable<String>(bracniDrugPrezime.value);
    }
    if (bracniDrugPol.present) {
      map['bracni_drug_pol'] = Variable<String>(bracniDrugPol.value);
    }
    if (bracniDrugJmbg.present) {
      map['bracni_drug_jmbg'] = Variable<String>(bracniDrugJmbg.value);
    }
    if (bracniDrugDevojacko.present) {
      map['bracni_drug_devojacko'] = Variable<String>(
        bracniDrugDevojacko.value,
      );
    }
    if (zanimanje.present) {
      map['zanimanje'] = Variable<String>(zanimanje.value);
    }
    if (zanimanjeNaParti.present) {
      map['zanimanje_na_parti'] = Variable<bool>(zanimanjeNaParti.value);
    }
    if (titula.present) {
      map['titula'] = Variable<String>(titula.value);
    }
    if (titulaIspred.present) {
      map['titula_ispred'] = Variable<bool>(titulaIspred.value);
    }
    if (cin.present) {
      map['cin'] = Variable<String>(cin.value);
    }
    if (cinNaParti.present) {
      map['cin_na_parti'] = Variable<bool>(cinNaParti.value);
    }
    if (srednjeNaParti.present) {
      map['srednje_na_parti'] = Variable<bool>(srednjeNaParti.value);
    }
    if (nadimak.present) {
      map['nadimak'] = Variable<String>(nadimak.value);
    }
    if (nadimakNaParti.present) {
      map['nadimak_na_parti'] = Variable<bool>(nadimakNaParti.value);
    }
    if (nadimakCrtica.present) {
      map['nadimak_crtica'] = Variable<bool>(nadimakCrtica.value);
    }
    if (radniStatus.present) {
      map['radni_status'] = Variable<String>(radniStatus.value);
    }
    if (penzioner.present) {
      map['penzioner'] = Variable<String>(penzioner.value);
    }
    if (penzionerSrbije.present) {
      map['penzioner_srbije'] = Variable<String>(penzionerSrbije.value);
    }
    if (vojniPenzioner.present) {
      map['vojni_penzioner'] = Variable<String>(vojniPenzioner.value);
    }
    if (vojnePocasti.present) {
      map['vojne_pocasti'] = Variable<String>(vojnePocasti.value);
    }
    if (posmrtnaPomoc.present) {
      map['posmrtna_pomoc'] = Variable<String>(posmrtnaPomoc.value);
    }
    if (refundacijaPio.present) {
      map['refundacija_pio'] = Variable<double>(refundacijaPio.value);
    }
    if (narucilacRefundira.present) {
      map['narucilac_refundira'] = Variable<String>(narucilacRefundira.value);
    }
    if (bracniDrugOstvarujePravo.present) {
      map['bracni_drug_ostvaruje_pravo'] = Variable<String>(
        bracniDrugOstvarujePravo.value,
      );
    }
    if (bracniDrugJePenzioner.present) {
      map['bracni_drug_je_penzioner'] = Variable<String>(
        bracniDrugJePenzioner.value,
      );
    }
    if (penzionerNapomena.present) {
      map['penzioner_napomena'] = Variable<String>(penzionerNapomena.value);
    }
    if (naruTip.present) {
      map['naru_tip'] = Variable<String>(naruTip.value);
    }
    if (naruIme.present) {
      map['naru_ime'] = Variable<String>(naruIme.value);
    }
    if (naruPrezime.present) {
      map['naru_prezime'] = Variable<String>(naruPrezime.value);
    }
    if (naruImePrezime.present) {
      map['naru_ime_prezime'] = Variable<String>(naruImePrezime.value);
    }
    if (naruJmbg.present) {
      map['naru_jmbg'] = Variable<String>(naruJmbg.value);
    }
    if (naruAdresa.present) {
      map['naru_adresa'] = Variable<String>(naruAdresa.value);
    }
    if (naruBrojLk.present) {
      map['naru_broj_lk'] = Variable<String>(naruBrojLk.value);
    }
    if (naruTelefon1.present) {
      map['naru_telefon1'] = Variable<String>(naruTelefon1.value);
    }
    if (naruTelefon2.present) {
      map['naru_telefon2'] = Variable<String>(naruTelefon2.value);
    }
    if (naruEmail.present) {
      map['naru_email'] = Variable<String>(naruEmail.value);
    }
    if (naruPlNaziv.present) {
      map['naru_pl_naziv'] = Variable<String>(naruPlNaziv.value);
    }
    if (naruPlAdresa.present) {
      map['naru_pl_adresa'] = Variable<String>(naruPlAdresa.value);
    }
    if (naruPlPib.present) {
      map['naru_pl_pib'] = Variable<String>(naruPlPib.value);
    }
    if (naruPlMb.present) {
      map['naru_pl_mb'] = Variable<String>(naruPlMb.value);
    }
    if (naruPlOdgovornoLice.present) {
      map['naru_pl_odgovorno_lice'] = Variable<String>(
        naruPlOdgovornoLice.value,
      );
    }
    if (naruPlTelefon1.present) {
      map['naru_pl_telefon1'] = Variable<String>(naruPlTelefon1.value);
    }
    if (naruPlTelefon2.present) {
      map['naru_pl_telefon2'] = Variable<String>(naruPlTelefon2.value);
    }
    if (naruPlEmail.present) {
      map['naru_pl_email'] = Variable<String>(naruPlEmail.value);
    }
    if (naruIstiZaJkp.present) {
      map['naru_isti_za_jkp'] = Variable<bool>(naruIstiZaJkp.value);
    }
    if (jkpTip.present) {
      map['jkp_tip'] = Variable<String>(jkpTip.value);
    }
    if (jkpIme.present) {
      map['jkp_ime'] = Variable<String>(jkpIme.value);
    }
    if (jkpPrezime.present) {
      map['jkp_prezime'] = Variable<String>(jkpPrezime.value);
    }
    if (jkpImePrezime.present) {
      map['jkp_ime_prezime'] = Variable<String>(jkpImePrezime.value);
    }
    if (jkpJmbg.present) {
      map['jkp_jmbg'] = Variable<String>(jkpJmbg.value);
    }
    if (jkpAdresa.present) {
      map['jkp_adresa'] = Variable<String>(jkpAdresa.value);
    }
    if (jkpBrojLk.present) {
      map['jkp_broj_lk'] = Variable<String>(jkpBrojLk.value);
    }
    if (jkpTelefon1.present) {
      map['jkp_telefon1'] = Variable<String>(jkpTelefon1.value);
    }
    if (jkpTelefon2.present) {
      map['jkp_telefon2'] = Variable<String>(jkpTelefon2.value);
    }
    if (jkpEmail.present) {
      map['jkp_email'] = Variable<String>(jkpEmail.value);
    }
    if (jkpPlNaziv.present) {
      map['jkp_pl_naziv'] = Variable<String>(jkpPlNaziv.value);
    }
    if (jkpPlAdresa.present) {
      map['jkp_pl_adresa'] = Variable<String>(jkpPlAdresa.value);
    }
    if (jkpPlPib.present) {
      map['jkp_pl_pib'] = Variable<String>(jkpPlPib.value);
    }
    if (jkpPlMb.present) {
      map['jkp_pl_mb'] = Variable<String>(jkpPlMb.value);
    }
    if (jkpPlOdgovornoLice.present) {
      map['jkp_pl_odgovorno_lice'] = Variable<String>(jkpPlOdgovornoLice.value);
    }
    if (jkpPlTelefon1.present) {
      map['jkp_pl_telefon1'] = Variable<String>(jkpPlTelefon1.value);
    }
    if (jkpPlEmail.present) {
      map['jkp_pl_email'] = Variable<String>(jkpPlEmail.value);
    }
    if (groblje.present) {
      map['groblje'] = Variable<String>(groblje.value);
    }
    if (tipGroblja.present) {
      map['tip_groblja'] = Variable<String>(tipGroblja.value);
    }
    if (vrstaCeremonije.present) {
      map['vrsta_ceremonije'] = Variable<String>(vrstaCeremonije.value);
    }
    if (datumCeremonije.present) {
      map['datum_ceremonije'] = Variable<String>(datumCeremonije.value);
    }
    if (vremeCeremonije.present) {
      map['vreme_ceremonije'] = Variable<String>(vremeCeremonije.value);
    }
    if (opelo.present) {
      map['opelo'] = Variable<String>(opelo.value);
    }
    if (opeloMesto.present) {
      map['opelo_mesto'] = Variable<String>(opeloMesto.value);
    }
    if (vremeOpela.present) {
      map['vreme_opela'] = Variable<String>(vremeOpela.value);
    }
    if (vremeIspracaja.present) {
      map['vreme_ispracaja'] = Variable<String>(vremeIspracaja.value);
    }
    if (grobnoMesto.present) {
      map['grobno_mesto'] = Variable<String>(grobnoMesto.value);
    }
    if (tipGrobnogMesta.present) {
      map['tip_grobnog_mesta'] = Variable<String>(tipGrobnogMesta.value);
    }
    if (parcela.present) {
      map['parcela'] = Variable<String>(parcela.value);
    }
    if (grobBroj.present) {
      map['grob_broj'] = Variable<String>(grobBroj.value);
    }
    if (redGrob.present) {
      map['red_grob'] = Variable<String>(redGrob.value);
    }
    if (npk.present) {
      map['npk'] = Variable<String>(npk.value);
    }
    if (grobnica.present) {
      map['grobnica'] = Variable<String>(grobnica.value);
    }
    if (urnaSifra.present) {
      map['urna_sifra'] = Variable<String>(urnaSifra.value);
    }
    if (tipPolaganja.present) {
      map['tip_polaganja'] = Variable<String>(tipPolaganja.value);
    }
    if (urnaParcela.present) {
      map['urna_parcela'] = Variable<String>(urnaParcela.value);
    }
    if (urnaBroj.present) {
      map['urna_broj'] = Variable<String>(urnaBroj.value);
    }
    if (urnaRed.present) {
      map['urna_red'] = Variable<String>(urnaRed.value);
    }
    if (urnaNpk.present) {
      map['urna_npk'] = Variable<String>(urnaNpk.value);
    }
    if (sahranaVanSrbije.present) {
      map['sahrana_van_srbije'] = Variable<bool>(sahranaVanSrbije.value);
    }
    if (svisZemlja.present) {
      map['svis_zemlja'] = Variable<String>(svisZemlja.value);
    }
    if (svisGrad.present) {
      map['svis_grad'] = Variable<String>(svisGrad.value);
    }
    if (docekPosmrtnihOstataka.present) {
      map['docek_posmrtnih_ostataka'] = Variable<bool>(
        docekPosmrtnihOstataka.value,
      );
    }
    if (docekMesto.present) {
      map['docek_mesto'] = Variable<String>(docekMesto.value);
    }
    if (docekVreme.present) {
      map['docek_vreme'] = Variable<String>(docekVreme.value);
    }
    if (simbol.present) {
      map['simbol'] = Variable<String>(simbol.value);
    }
    if (pismo.present) {
      map['pismo'] = Variable<String>(pismo.value);
    }
    if (parteIme.present) {
      map['parte_ime'] = Variable<String>(parteIme.value);
    }
    if (ozaloseni.present) {
      map['ozaloseni'] = Variable<String>(ozaloseni.value);
    }
    if (avans.present) {
      map['avans'] = Variable<double>(avans.value);
    }
    if (troskoviJkp.present) {
      map['troskovi_jkp'] = Variable<double>(troskoviJkp.value);
    }
    if (jkpPlacaSamostalno.present) {
      map['jkp_placa_samostalno'] = Variable<bool>(jkpPlacaSamostalno.value);
    }
    if (popust.present) {
      map['popust'] = Variable<double>(popust.value);
    }
    if (nacinPlacanja.present) {
      map['nacin_placanja'] = Variable<String>(nacinPlacanja.value);
    }
    if (napomenaPlacanja.present) {
      map['napomena_placanja'] = Variable<String>(napomenaPlacanja.value);
    }
    if (napomena.present) {
      map['napomena'] = Variable<String>(napomena.value);
    }
    if (exportVerzija.present) {
      map['export_verzija'] = Variable<int>(exportVerzija.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredmetiCompanion(')
          ..write('id: $id, ')
          ..write('brojPredmeta: $brojPredmeta, ')
          ..write('status: $status, ')
          ..write('datumKreiranja: $datumKreiranja, ')
          ..write('savetnikId: $savetnikId, ')
          ..write('verzija: $verzija, ')
          ..write('businessScenarioId: $businessScenarioId, ')
          ..write('sourceIdentity: $sourceIdentity, ')
          ..write('createdByKorisnikId: $createdByKorisnikId, ')
          ..write(
            'lastBusinessModifiedByKorisnikId: $lastBusinessModifiedByKorisnikId, ',
          )
          ..write('lastBusinessModifiedAt: $lastBusinessModifiedAt, ')
          ..write('ime: $ime, ')
          ..write('prezime: $prezime, ')
          ..write('srednje: $srednje, ')
          ..write('devojackoPrezime: $devojackoPrezime, ')
          ..write('jmbg: $jmbg, ')
          ..write('pol: $pol, ')
          ..write('datumRodjenja: $datumRodjenja, ')
          ..write('mestoRodjenja: $mestoRodjenja, ')
          ..write('datumSmrti: $datumSmrti, ')
          ..write('mestoSmrti: $mestoSmrti, ')
          ..write('uzrokSmrti: $uzrokSmrti, ')
          ..write('adresa: $adresa, ')
          ..write('imeOca: $imeOca, ')
          ..write('imeMajke: $imeMajke, ')
          ..write('bracnoStanje: $bracnoStanje, ')
          ..write('bracniDrugIme: $bracniDrugIme, ')
          ..write('bracniDrugPrezime: $bracniDrugPrezime, ')
          ..write('bracniDrugPol: $bracniDrugPol, ')
          ..write('bracniDrugJmbg: $bracniDrugJmbg, ')
          ..write('bracniDrugDevojacko: $bracniDrugDevojacko, ')
          ..write('zanimanje: $zanimanje, ')
          ..write('zanimanjeNaParti: $zanimanjeNaParti, ')
          ..write('titula: $titula, ')
          ..write('titulaIspred: $titulaIspred, ')
          ..write('cin: $cin, ')
          ..write('cinNaParti: $cinNaParti, ')
          ..write('srednjeNaParti: $srednjeNaParti, ')
          ..write('nadimak: $nadimak, ')
          ..write('nadimakNaParti: $nadimakNaParti, ')
          ..write('nadimakCrtica: $nadimakCrtica, ')
          ..write('radniStatus: $radniStatus, ')
          ..write('penzioner: $penzioner, ')
          ..write('penzionerSrbije: $penzionerSrbije, ')
          ..write('vojniPenzioner: $vojniPenzioner, ')
          ..write('vojnePocasti: $vojnePocasti, ')
          ..write('posmrtnaPomoc: $posmrtnaPomoc, ')
          ..write('refundacijaPio: $refundacijaPio, ')
          ..write('narucilacRefundira: $narucilacRefundira, ')
          ..write('bracniDrugOstvarujePravo: $bracniDrugOstvarujePravo, ')
          ..write('bracniDrugJePenzioner: $bracniDrugJePenzioner, ')
          ..write('penzionerNapomena: $penzionerNapomena, ')
          ..write('naruTip: $naruTip, ')
          ..write('naruIme: $naruIme, ')
          ..write('naruPrezime: $naruPrezime, ')
          ..write('naruImePrezime: $naruImePrezime, ')
          ..write('naruJmbg: $naruJmbg, ')
          ..write('naruAdresa: $naruAdresa, ')
          ..write('naruBrojLk: $naruBrojLk, ')
          ..write('naruTelefon1: $naruTelefon1, ')
          ..write('naruTelefon2: $naruTelefon2, ')
          ..write('naruEmail: $naruEmail, ')
          ..write('naruPlNaziv: $naruPlNaziv, ')
          ..write('naruPlAdresa: $naruPlAdresa, ')
          ..write('naruPlPib: $naruPlPib, ')
          ..write('naruPlMb: $naruPlMb, ')
          ..write('naruPlOdgovornoLice: $naruPlOdgovornoLice, ')
          ..write('naruPlTelefon1: $naruPlTelefon1, ')
          ..write('naruPlTelefon2: $naruPlTelefon2, ')
          ..write('naruPlEmail: $naruPlEmail, ')
          ..write('naruIstiZaJkp: $naruIstiZaJkp, ')
          ..write('jkpTip: $jkpTip, ')
          ..write('jkpIme: $jkpIme, ')
          ..write('jkpPrezime: $jkpPrezime, ')
          ..write('jkpImePrezime: $jkpImePrezime, ')
          ..write('jkpJmbg: $jkpJmbg, ')
          ..write('jkpAdresa: $jkpAdresa, ')
          ..write('jkpBrojLk: $jkpBrojLk, ')
          ..write('jkpTelefon1: $jkpTelefon1, ')
          ..write('jkpTelefon2: $jkpTelefon2, ')
          ..write('jkpEmail: $jkpEmail, ')
          ..write('jkpPlNaziv: $jkpPlNaziv, ')
          ..write('jkpPlAdresa: $jkpPlAdresa, ')
          ..write('jkpPlPib: $jkpPlPib, ')
          ..write('jkpPlMb: $jkpPlMb, ')
          ..write('jkpPlOdgovornoLice: $jkpPlOdgovornoLice, ')
          ..write('jkpPlTelefon1: $jkpPlTelefon1, ')
          ..write('jkpPlEmail: $jkpPlEmail, ')
          ..write('groblje: $groblje, ')
          ..write('tipGroblja: $tipGroblja, ')
          ..write('vrstaCeremonije: $vrstaCeremonije, ')
          ..write('datumCeremonije: $datumCeremonije, ')
          ..write('vremeCeremonije: $vremeCeremonije, ')
          ..write('opelo: $opelo, ')
          ..write('opeloMesto: $opeloMesto, ')
          ..write('vremeOpela: $vremeOpela, ')
          ..write('vremeIspracaja: $vremeIspracaja, ')
          ..write('grobnoMesto: $grobnoMesto, ')
          ..write('tipGrobnogMesta: $tipGrobnogMesta, ')
          ..write('parcela: $parcela, ')
          ..write('grobBroj: $grobBroj, ')
          ..write('redGrob: $redGrob, ')
          ..write('npk: $npk, ')
          ..write('grobnica: $grobnica, ')
          ..write('urnaSifra: $urnaSifra, ')
          ..write('tipPolaganja: $tipPolaganja, ')
          ..write('urnaParcela: $urnaParcela, ')
          ..write('urnaBroj: $urnaBroj, ')
          ..write('urnaRed: $urnaRed, ')
          ..write('urnaNpk: $urnaNpk, ')
          ..write('sahranaVanSrbije: $sahranaVanSrbije, ')
          ..write('svisZemlja: $svisZemlja, ')
          ..write('svisGrad: $svisGrad, ')
          ..write('docekPosmrtnihOstataka: $docekPosmrtnihOstataka, ')
          ..write('docekMesto: $docekMesto, ')
          ..write('docekVreme: $docekVreme, ')
          ..write('simbol: $simbol, ')
          ..write('pismo: $pismo, ')
          ..write('parteIme: $parteIme, ')
          ..write('ozaloseni: $ozaloseni, ')
          ..write('avans: $avans, ')
          ..write('troskoviJkp: $troskoviJkp, ')
          ..write('jkpPlacaSamostalno: $jkpPlacaSamostalno, ')
          ..write('popust: $popust, ')
          ..write('nacinPlacanja: $nacinPlacanja, ')
          ..write('napomenaPlacanja: $napomenaPlacanja, ')
          ..write('napomena: $napomena, ')
          ..write('exportVerzija: $exportVerzija')
          ..write(')'))
        .toString();
  }
}

class $KontaktLicaTable extends KontaktLica
    with TableInfo<$KontaktLicaTable, KontaktLicaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KontaktLicaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predmetIdMeta = const VerificationMeta(
    'predmetId',
  );
  @override
  late final GeneratedColumn<int> predmetId = GeneratedColumn<int>(
    'predmet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES predmeti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _blokMeta = const VerificationMeta('blok');
  @override
  late final GeneratedColumn<String> blok = GeneratedColumn<String>(
    'blok',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imePrezimeMeta = const VerificationMeta(
    'imePrezime',
  );
  @override
  late final GeneratedColumn<String> imePrezime = GeneratedColumn<String>(
    'ime_prezime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _telefonMeta = const VerificationMeta(
    'telefon',
  );
  @override
  late final GeneratedColumn<String> telefon = GeneratedColumn<String>(
    'telefon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _napomenaMeta = const VerificationMeta(
    'napomena',
  );
  @override
  late final GeneratedColumn<String> napomena = GeneratedColumn<String>(
    'napomena',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _redosledMeta = const VerificationMeta(
    'redosled',
  );
  @override
  late final GeneratedColumn<int> redosled = GeneratedColumn<int>(
    'redosled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predmetId,
    blok,
    imePrezime,
    telefon,
    email,
    napomena,
    redosled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kontakt_lica';
  @override
  VerificationContext validateIntegrity(
    Insertable<KontaktLicaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predmet_id')) {
      context.handle(
        _predmetIdMeta,
        predmetId.isAcceptableOrUnknown(data['predmet_id']!, _predmetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_predmetIdMeta);
    }
    if (data.containsKey('blok')) {
      context.handle(
        _blokMeta,
        blok.isAcceptableOrUnknown(data['blok']!, _blokMeta),
      );
    } else if (isInserting) {
      context.missing(_blokMeta);
    }
    if (data.containsKey('ime_prezime')) {
      context.handle(
        _imePrezimeMeta,
        imePrezime.isAcceptableOrUnknown(data['ime_prezime']!, _imePrezimeMeta),
      );
    }
    if (data.containsKey('telefon')) {
      context.handle(
        _telefonMeta,
        telefon.isAcceptableOrUnknown(data['telefon']!, _telefonMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('napomena')) {
      context.handle(
        _napomenaMeta,
        napomena.isAcceptableOrUnknown(data['napomena']!, _napomenaMeta),
      );
    }
    if (data.containsKey('redosled')) {
      context.handle(
        _redosledMeta,
        redosled.isAcceptableOrUnknown(data['redosled']!, _redosledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KontaktLicaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KontaktLicaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predmetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predmet_id'],
      )!,
      blok: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blok'],
      )!,
      imePrezime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ime_prezime'],
      )!,
      telefon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefon'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      napomena: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}napomena'],
      )!,
      redosled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redosled'],
      )!,
    );
  }

  @override
  $KontaktLicaTable createAlias(String alias) {
    return $KontaktLicaTable(attachedDatabase, alias);
  }
}

class KontaktLicaData extends DataClass implements Insertable<KontaktLicaData> {
  final int id;
  final int predmetId;
  final String blok;
  final String imePrezime;
  final String telefon;
  final String email;
  final String napomena;
  final int redosled;
  const KontaktLicaData({
    required this.id,
    required this.predmetId,
    required this.blok,
    required this.imePrezime,
    required this.telefon,
    required this.email,
    required this.napomena,
    required this.redosled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predmet_id'] = Variable<int>(predmetId);
    map['blok'] = Variable<String>(blok);
    map['ime_prezime'] = Variable<String>(imePrezime);
    map['telefon'] = Variable<String>(telefon);
    map['email'] = Variable<String>(email);
    map['napomena'] = Variable<String>(napomena);
    map['redosled'] = Variable<int>(redosled);
    return map;
  }

  KontaktLicaCompanion toCompanion(bool nullToAbsent) {
    return KontaktLicaCompanion(
      id: Value(id),
      predmetId: Value(predmetId),
      blok: Value(blok),
      imePrezime: Value(imePrezime),
      telefon: Value(telefon),
      email: Value(email),
      napomena: Value(napomena),
      redosled: Value(redosled),
    );
  }

  factory KontaktLicaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KontaktLicaData(
      id: serializer.fromJson<int>(json['id']),
      predmetId: serializer.fromJson<int>(json['predmetId']),
      blok: serializer.fromJson<String>(json['blok']),
      imePrezime: serializer.fromJson<String>(json['imePrezime']),
      telefon: serializer.fromJson<String>(json['telefon']),
      email: serializer.fromJson<String>(json['email']),
      napomena: serializer.fromJson<String>(json['napomena']),
      redosled: serializer.fromJson<int>(json['redosled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predmetId': serializer.toJson<int>(predmetId),
      'blok': serializer.toJson<String>(blok),
      'imePrezime': serializer.toJson<String>(imePrezime),
      'telefon': serializer.toJson<String>(telefon),
      'email': serializer.toJson<String>(email),
      'napomena': serializer.toJson<String>(napomena),
      'redosled': serializer.toJson<int>(redosled),
    };
  }

  KontaktLicaData copyWith({
    int? id,
    int? predmetId,
    String? blok,
    String? imePrezime,
    String? telefon,
    String? email,
    String? napomena,
    int? redosled,
  }) => KontaktLicaData(
    id: id ?? this.id,
    predmetId: predmetId ?? this.predmetId,
    blok: blok ?? this.blok,
    imePrezime: imePrezime ?? this.imePrezime,
    telefon: telefon ?? this.telefon,
    email: email ?? this.email,
    napomena: napomena ?? this.napomena,
    redosled: redosled ?? this.redosled,
  );
  KontaktLicaData copyWithCompanion(KontaktLicaCompanion data) {
    return KontaktLicaData(
      id: data.id.present ? data.id.value : this.id,
      predmetId: data.predmetId.present ? data.predmetId.value : this.predmetId,
      blok: data.blok.present ? data.blok.value : this.blok,
      imePrezime: data.imePrezime.present
          ? data.imePrezime.value
          : this.imePrezime,
      telefon: data.telefon.present ? data.telefon.value : this.telefon,
      email: data.email.present ? data.email.value : this.email,
      napomena: data.napomena.present ? data.napomena.value : this.napomena,
      redosled: data.redosled.present ? data.redosled.value : this.redosled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KontaktLicaData(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('blok: $blok, ')
          ..write('imePrezime: $imePrezime, ')
          ..write('telefon: $telefon, ')
          ..write('email: $email, ')
          ..write('napomena: $napomena, ')
          ..write('redosled: $redosled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predmetId,
    blok,
    imePrezime,
    telefon,
    email,
    napomena,
    redosled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KontaktLicaData &&
          other.id == this.id &&
          other.predmetId == this.predmetId &&
          other.blok == this.blok &&
          other.imePrezime == this.imePrezime &&
          other.telefon == this.telefon &&
          other.email == this.email &&
          other.napomena == this.napomena &&
          other.redosled == this.redosled);
}

class KontaktLicaCompanion extends UpdateCompanion<KontaktLicaData> {
  final Value<int> id;
  final Value<int> predmetId;
  final Value<String> blok;
  final Value<String> imePrezime;
  final Value<String> telefon;
  final Value<String> email;
  final Value<String> napomena;
  final Value<int> redosled;
  const KontaktLicaCompanion({
    this.id = const Value.absent(),
    this.predmetId = const Value.absent(),
    this.blok = const Value.absent(),
    this.imePrezime = const Value.absent(),
    this.telefon = const Value.absent(),
    this.email = const Value.absent(),
    this.napomena = const Value.absent(),
    this.redosled = const Value.absent(),
  });
  KontaktLicaCompanion.insert({
    this.id = const Value.absent(),
    required int predmetId,
    required String blok,
    this.imePrezime = const Value.absent(),
    this.telefon = const Value.absent(),
    this.email = const Value.absent(),
    this.napomena = const Value.absent(),
    this.redosled = const Value.absent(),
  }) : predmetId = Value(predmetId),
       blok = Value(blok);
  static Insertable<KontaktLicaData> custom({
    Expression<int>? id,
    Expression<int>? predmetId,
    Expression<String>? blok,
    Expression<String>? imePrezime,
    Expression<String>? telefon,
    Expression<String>? email,
    Expression<String>? napomena,
    Expression<int>? redosled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predmetId != null) 'predmet_id': predmetId,
      if (blok != null) 'blok': blok,
      if (imePrezime != null) 'ime_prezime': imePrezime,
      if (telefon != null) 'telefon': telefon,
      if (email != null) 'email': email,
      if (napomena != null) 'napomena': napomena,
      if (redosled != null) 'redosled': redosled,
    });
  }

  KontaktLicaCompanion copyWith({
    Value<int>? id,
    Value<int>? predmetId,
    Value<String>? blok,
    Value<String>? imePrezime,
    Value<String>? telefon,
    Value<String>? email,
    Value<String>? napomena,
    Value<int>? redosled,
  }) {
    return KontaktLicaCompanion(
      id: id ?? this.id,
      predmetId: predmetId ?? this.predmetId,
      blok: blok ?? this.blok,
      imePrezime: imePrezime ?? this.imePrezime,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
      napomena: napomena ?? this.napomena,
      redosled: redosled ?? this.redosled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predmetId.present) {
      map['predmet_id'] = Variable<int>(predmetId.value);
    }
    if (blok.present) {
      map['blok'] = Variable<String>(blok.value);
    }
    if (imePrezime.present) {
      map['ime_prezime'] = Variable<String>(imePrezime.value);
    }
    if (telefon.present) {
      map['telefon'] = Variable<String>(telefon.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (napomena.present) {
      map['napomena'] = Variable<String>(napomena.value);
    }
    if (redosled.present) {
      map['redosled'] = Variable<int>(redosled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KontaktLicaCompanion(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('blok: $blok, ')
          ..write('imePrezime: $imePrezime, ')
          ..write('telefon: $telefon, ')
          ..write('email: $email, ')
          ..write('napomena: $napomena, ')
          ..write('redosled: $redosled')
          ..write(')'))
        .toString();
  }
}

class $IriuTable extends Iriu with TableInfo<$IriuTable, IriuData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IriuTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predmetIdMeta = const VerificationMeta(
    'predmetId',
  );
  @override
  late final GeneratedColumn<int> predmetId = GeneratedColumn<int>(
    'predmet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES predmeti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _katalogStableArticleIdMeta =
      const VerificationMeta('katalogStableArticleId');
  @override
  late final GeneratedColumn<String> katalogStableArticleId =
      GeneratedColumn<String>(
        'katalog_stable_article_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _interniNazivMeta = const VerificationMeta(
    'interniNaziv',
  );
  @override
  late final GeneratedColumn<String> interniNaziv = GeneratedColumn<String>(
    'interni_naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nazivPrikazMeta = const VerificationMeta(
    'nazivPrikaz',
  );
  @override
  late final GeneratedColumn<String> nazivPrikaz = GeneratedColumn<String>(
    'naziv_prikaz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _komMeta = const VerificationMeta('kom');
  @override
  late final GeneratedColumn<String> kom = GeneratedColumn<String>(
    'kom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iznosMeta = const VerificationMeta('iznos');
  @override
  late final GeneratedColumn<double> iznos = GeneratedColumn<double>(
    'iznos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cekiranMeta = const VerificationMeta(
    'cekiran',
  );
  @override
  late final GeneratedColumn<bool> cekiran = GeneratedColumn<bool>(
    'cekiran',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cekiran" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _redosledMeta = const VerificationMeta(
    'redosled',
  );
  @override
  late final GeneratedColumn<int> redosled = GeneratedColumn<int>(
    'redosled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predmetId,
    katalogStableArticleId,
    interniNaziv,
    nazivPrikaz,
    kom,
    iznos,
    cekiran,
    redosled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'iriu';
  @override
  VerificationContext validateIntegrity(
    Insertable<IriuData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predmet_id')) {
      context.handle(
        _predmetIdMeta,
        predmetId.isAcceptableOrUnknown(data['predmet_id']!, _predmetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_predmetIdMeta);
    }
    if (data.containsKey('katalog_stable_article_id')) {
      context.handle(
        _katalogStableArticleIdMeta,
        katalogStableArticleId.isAcceptableOrUnknown(
          data['katalog_stable_article_id']!,
          _katalogStableArticleIdMeta,
        ),
      );
    }
    if (data.containsKey('interni_naziv')) {
      context.handle(
        _interniNazivMeta,
        interniNaziv.isAcceptableOrUnknown(
          data['interni_naziv']!,
          _interniNazivMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interniNazivMeta);
    }
    if (data.containsKey('naziv_prikaz')) {
      context.handle(
        _nazivPrikazMeta,
        nazivPrikaz.isAcceptableOrUnknown(
          data['naziv_prikaz']!,
          _nazivPrikazMeta,
        ),
      );
    }
    if (data.containsKey('kom')) {
      context.handle(
        _komMeta,
        kom.isAcceptableOrUnknown(data['kom']!, _komMeta),
      );
    }
    if (data.containsKey('iznos')) {
      context.handle(
        _iznosMeta,
        iznos.isAcceptableOrUnknown(data['iznos']!, _iznosMeta),
      );
    }
    if (data.containsKey('cekiran')) {
      context.handle(
        _cekiranMeta,
        cekiran.isAcceptableOrUnknown(data['cekiran']!, _cekiranMeta),
      );
    }
    if (data.containsKey('redosled')) {
      context.handle(
        _redosledMeta,
        redosled.isAcceptableOrUnknown(data['redosled']!, _redosledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IriuData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IriuData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predmetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predmet_id'],
      )!,
      katalogStableArticleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}katalog_stable_article_id'],
      ),
      interniNaziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interni_naziv'],
      )!,
      nazivPrikaz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naziv_prikaz'],
      )!,
      kom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kom'],
      )!,
      iznos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iznos'],
      )!,
      cekiran: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cekiran'],
      )!,
      redosled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redosled'],
      )!,
    );
  }

  @override
  $IriuTable createAlias(String alias) {
    return $IriuTable(attachedDatabase, alias);
  }
}

class IriuData extends DataClass implements Insertable<IriuData> {
  final int id;
  final int predmetId;
  final String? katalogStableArticleId;

  /// Interni naziv kategorije — nepromenjiv string (npr. SANDUK, LIMENI_ULOZAK).
  /// Koristi se za automatsku logiku i Nalog za opremanje.
  final String interniNaziv;

  /// Naziv za prikaz — vidljiv korisniku, editabilan.
  final String nazivPrikaz;

  /// Količina — slobodan tekst (informativno, ne ulazi u formulu).
  final String kom;

  /// Iznos se čuva kao REAL (float sa tačkom). Konverzija u srpski format SAMO pri prikazu.
  final double iznos;
  final bool cekiran;
  final int redosled;
  const IriuData({
    required this.id,
    required this.predmetId,
    this.katalogStableArticleId,
    required this.interniNaziv,
    required this.nazivPrikaz,
    required this.kom,
    required this.iznos,
    required this.cekiran,
    required this.redosled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predmet_id'] = Variable<int>(predmetId);
    if (!nullToAbsent || katalogStableArticleId != null) {
      map['katalog_stable_article_id'] = Variable<String>(
        katalogStableArticleId,
      );
    }
    map['interni_naziv'] = Variable<String>(interniNaziv);
    map['naziv_prikaz'] = Variable<String>(nazivPrikaz);
    map['kom'] = Variable<String>(kom);
    map['iznos'] = Variable<double>(iznos);
    map['cekiran'] = Variable<bool>(cekiran);
    map['redosled'] = Variable<int>(redosled);
    return map;
  }

  IriuCompanion toCompanion(bool nullToAbsent) {
    return IriuCompanion(
      id: Value(id),
      predmetId: Value(predmetId),
      katalogStableArticleId: katalogStableArticleId == null && nullToAbsent
          ? const Value.absent()
          : Value(katalogStableArticleId),
      interniNaziv: Value(interniNaziv),
      nazivPrikaz: Value(nazivPrikaz),
      kom: Value(kom),
      iznos: Value(iznos),
      cekiran: Value(cekiran),
      redosled: Value(redosled),
    );
  }

  factory IriuData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IriuData(
      id: serializer.fromJson<int>(json['id']),
      predmetId: serializer.fromJson<int>(json['predmetId']),
      katalogStableArticleId: serializer.fromJson<String?>(
        json['katalogStableArticleId'],
      ),
      interniNaziv: serializer.fromJson<String>(json['interniNaziv']),
      nazivPrikaz: serializer.fromJson<String>(json['nazivPrikaz']),
      kom: serializer.fromJson<String>(json['kom']),
      iznos: serializer.fromJson<double>(json['iznos']),
      cekiran: serializer.fromJson<bool>(json['cekiran']),
      redosled: serializer.fromJson<int>(json['redosled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predmetId': serializer.toJson<int>(predmetId),
      'katalogStableArticleId': serializer.toJson<String?>(
        katalogStableArticleId,
      ),
      'interniNaziv': serializer.toJson<String>(interniNaziv),
      'nazivPrikaz': serializer.toJson<String>(nazivPrikaz),
      'kom': serializer.toJson<String>(kom),
      'iznos': serializer.toJson<double>(iznos),
      'cekiran': serializer.toJson<bool>(cekiran),
      'redosled': serializer.toJson<int>(redosled),
    };
  }

  IriuData copyWith({
    int? id,
    int? predmetId,
    Value<String?> katalogStableArticleId = const Value.absent(),
    String? interniNaziv,
    String? nazivPrikaz,
    String? kom,
    double? iznos,
    bool? cekiran,
    int? redosled,
  }) => IriuData(
    id: id ?? this.id,
    predmetId: predmetId ?? this.predmetId,
    katalogStableArticleId: katalogStableArticleId.present
        ? katalogStableArticleId.value
        : this.katalogStableArticleId,
    interniNaziv: interniNaziv ?? this.interniNaziv,
    nazivPrikaz: nazivPrikaz ?? this.nazivPrikaz,
    kom: kom ?? this.kom,
    iznos: iznos ?? this.iznos,
    cekiran: cekiran ?? this.cekiran,
    redosled: redosled ?? this.redosled,
  );
  IriuData copyWithCompanion(IriuCompanion data) {
    return IriuData(
      id: data.id.present ? data.id.value : this.id,
      predmetId: data.predmetId.present ? data.predmetId.value : this.predmetId,
      katalogStableArticleId: data.katalogStableArticleId.present
          ? data.katalogStableArticleId.value
          : this.katalogStableArticleId,
      interniNaziv: data.interniNaziv.present
          ? data.interniNaziv.value
          : this.interniNaziv,
      nazivPrikaz: data.nazivPrikaz.present
          ? data.nazivPrikaz.value
          : this.nazivPrikaz,
      kom: data.kom.present ? data.kom.value : this.kom,
      iznos: data.iznos.present ? data.iznos.value : this.iznos,
      cekiran: data.cekiran.present ? data.cekiran.value : this.cekiran,
      redosled: data.redosled.present ? data.redosled.value : this.redosled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IriuData(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('katalogStableArticleId: $katalogStableArticleId, ')
          ..write('interniNaziv: $interniNaziv, ')
          ..write('nazivPrikaz: $nazivPrikaz, ')
          ..write('kom: $kom, ')
          ..write('iznos: $iznos, ')
          ..write('cekiran: $cekiran, ')
          ..write('redosled: $redosled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predmetId,
    katalogStableArticleId,
    interniNaziv,
    nazivPrikaz,
    kom,
    iznos,
    cekiran,
    redosled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IriuData &&
          other.id == this.id &&
          other.predmetId == this.predmetId &&
          other.katalogStableArticleId == this.katalogStableArticleId &&
          other.interniNaziv == this.interniNaziv &&
          other.nazivPrikaz == this.nazivPrikaz &&
          other.kom == this.kom &&
          other.iznos == this.iznos &&
          other.cekiran == this.cekiran &&
          other.redosled == this.redosled);
}

class IriuCompanion extends UpdateCompanion<IriuData> {
  final Value<int> id;
  final Value<int> predmetId;
  final Value<String?> katalogStableArticleId;
  final Value<String> interniNaziv;
  final Value<String> nazivPrikaz;
  final Value<String> kom;
  final Value<double> iznos;
  final Value<bool> cekiran;
  final Value<int> redosled;
  const IriuCompanion({
    this.id = const Value.absent(),
    this.predmetId = const Value.absent(),
    this.katalogStableArticleId = const Value.absent(),
    this.interniNaziv = const Value.absent(),
    this.nazivPrikaz = const Value.absent(),
    this.kom = const Value.absent(),
    this.iznos = const Value.absent(),
    this.cekiran = const Value.absent(),
    this.redosled = const Value.absent(),
  });
  IriuCompanion.insert({
    this.id = const Value.absent(),
    required int predmetId,
    this.katalogStableArticleId = const Value.absent(),
    required String interniNaziv,
    this.nazivPrikaz = const Value.absent(),
    this.kom = const Value.absent(),
    this.iznos = const Value.absent(),
    this.cekiran = const Value.absent(),
    this.redosled = const Value.absent(),
  }) : predmetId = Value(predmetId),
       interniNaziv = Value(interniNaziv);
  static Insertable<IriuData> custom({
    Expression<int>? id,
    Expression<int>? predmetId,
    Expression<String>? katalogStableArticleId,
    Expression<String>? interniNaziv,
    Expression<String>? nazivPrikaz,
    Expression<String>? kom,
    Expression<double>? iznos,
    Expression<bool>? cekiran,
    Expression<int>? redosled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predmetId != null) 'predmet_id': predmetId,
      if (katalogStableArticleId != null)
        'katalog_stable_article_id': katalogStableArticleId,
      if (interniNaziv != null) 'interni_naziv': interniNaziv,
      if (nazivPrikaz != null) 'naziv_prikaz': nazivPrikaz,
      if (kom != null) 'kom': kom,
      if (iznos != null) 'iznos': iznos,
      if (cekiran != null) 'cekiran': cekiran,
      if (redosled != null) 'redosled': redosled,
    });
  }

  IriuCompanion copyWith({
    Value<int>? id,
    Value<int>? predmetId,
    Value<String?>? katalogStableArticleId,
    Value<String>? interniNaziv,
    Value<String>? nazivPrikaz,
    Value<String>? kom,
    Value<double>? iznos,
    Value<bool>? cekiran,
    Value<int>? redosled,
  }) {
    return IriuCompanion(
      id: id ?? this.id,
      predmetId: predmetId ?? this.predmetId,
      katalogStableArticleId:
          katalogStableArticleId ?? this.katalogStableArticleId,
      interniNaziv: interniNaziv ?? this.interniNaziv,
      nazivPrikaz: nazivPrikaz ?? this.nazivPrikaz,
      kom: kom ?? this.kom,
      iznos: iznos ?? this.iznos,
      cekiran: cekiran ?? this.cekiran,
      redosled: redosled ?? this.redosled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predmetId.present) {
      map['predmet_id'] = Variable<int>(predmetId.value);
    }
    if (katalogStableArticleId.present) {
      map['katalog_stable_article_id'] = Variable<String>(
        katalogStableArticleId.value,
      );
    }
    if (interniNaziv.present) {
      map['interni_naziv'] = Variable<String>(interniNaziv.value);
    }
    if (nazivPrikaz.present) {
      map['naziv_prikaz'] = Variable<String>(nazivPrikaz.value);
    }
    if (kom.present) {
      map['kom'] = Variable<String>(kom.value);
    }
    if (iznos.present) {
      map['iznos'] = Variable<double>(iznos.value);
    }
    if (cekiran.present) {
      map['cekiran'] = Variable<bool>(cekiran.value);
    }
    if (redosled.present) {
      map['redosled'] = Variable<int>(redosled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IriuCompanion(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('katalogStableArticleId: $katalogStableArticleId, ')
          ..write('interniNaziv: $interniNaziv, ')
          ..write('nazivPrikaz: $nazivPrikaz, ')
          ..write('kom: $kom, ')
          ..write('iznos: $iznos, ')
          ..write('cekiran: $cekiran, ')
          ..write('redosled: $redosled')
          ..write(')'))
        .toString();
  }
}

class $IriuKatalogConfigTable extends IriuKatalogConfig
    with TableInfo<$IriuKatalogConfigTable, IriuKatalogConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IriuKatalogConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _interniNazivMeta = const VerificationMeta(
    'interniNaziv',
  );
  @override
  late final GeneratedColumn<String> interniNaziv = GeneratedColumn<String>(
    'interni_naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nazivPrikazMeta = const VerificationMeta(
    'nazivPrikaz',
  );
  @override
  late final GeneratedColumn<String> nazivPrikaz = GeneratedColumn<String>(
    'naziv_prikaz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vidljivMeta = const VerificationMeta(
    'vidljiv',
  );
  @override
  late final GeneratedColumn<bool> vidljiv = GeneratedColumn<bool>(
    'vidljiv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vidljiv" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _uvekPrikazatiMeta = const VerificationMeta(
    'uvekPrikazati',
  );
  @override
  late final GeneratedColumn<bool> uvekPrikazati = GeneratedColumn<bool>(
    'uvek_prikazati',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uvek_prikazati" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tipMeta = const VerificationMeta('tip');
  @override
  late final GeneratedColumn<String> tip = GeneratedColumn<String>(
    'tip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('FIKSNA'),
  );
  static const VerificationMeta _jeKorisnickaMeta = const VerificationMeta(
    'jeKorisnicka',
  );
  @override
  late final GeneratedColumn<bool> jeKorisnicka = GeneratedColumn<bool>(
    'je_korisnicka',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("je_korisnicka" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _redosledMeta = const VerificationMeta(
    'redosled',
  );
  @override
  late final GeneratedColumn<int> redosled = GeneratedColumn<int>(
    'redosled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    interniNaziv,
    nazivPrikaz,
    vidljiv,
    uvekPrikazati,
    tip,
    jeKorisnicka,
    redosled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'iriu_katalog_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<IriuKatalogConfigData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('interni_naziv')) {
      context.handle(
        _interniNazivMeta,
        interniNaziv.isAcceptableOrUnknown(
          data['interni_naziv']!,
          _interniNazivMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interniNazivMeta);
    }
    if (data.containsKey('naziv_prikaz')) {
      context.handle(
        _nazivPrikazMeta,
        nazivPrikaz.isAcceptableOrUnknown(
          data['naziv_prikaz']!,
          _nazivPrikazMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nazivPrikazMeta);
    }
    if (data.containsKey('vidljiv')) {
      context.handle(
        _vidljivMeta,
        vidljiv.isAcceptableOrUnknown(data['vidljiv']!, _vidljivMeta),
      );
    }
    if (data.containsKey('uvek_prikazati')) {
      context.handle(
        _uvekPrikazatiMeta,
        uvekPrikazati.isAcceptableOrUnknown(
          data['uvek_prikazati']!,
          _uvekPrikazatiMeta,
        ),
      );
    }
    if (data.containsKey('tip')) {
      context.handle(
        _tipMeta,
        tip.isAcceptableOrUnknown(data['tip']!, _tipMeta),
      );
    }
    if (data.containsKey('je_korisnicka')) {
      context.handle(
        _jeKorisnickaMeta,
        jeKorisnicka.isAcceptableOrUnknown(
          data['je_korisnicka']!,
          _jeKorisnickaMeta,
        ),
      );
    }
    if (data.containsKey('redosled')) {
      context.handle(
        _redosledMeta,
        redosled.isAcceptableOrUnknown(data['redosled']!, _redosledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {interniNaziv};
  @override
  IriuKatalogConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IriuKatalogConfigData(
      interniNaziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interni_naziv'],
      )!,
      nazivPrikaz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naziv_prikaz'],
      )!,
      vidljiv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vidljiv'],
      )!,
      uvekPrikazati: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uvek_prikazati'],
      )!,
      tip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tip'],
      )!,
      jeKorisnicka: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}je_korisnicka'],
      )!,
      redosled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}redosled'],
      )!,
    );
  }

  @override
  $IriuKatalogConfigTable createAlias(String alias) {
    return $IriuKatalogConfigTable(attachedDatabase, alias);
  }
}

class IriuKatalogConfigData extends DataClass
    implements Insertable<IriuKatalogConfigData> {
  /// Interni naziv — PK (npr. SANDUK, LIMENI_ULOZAK, AGENCIJSKE_USLUGE).
  final String interniNaziv;
  final String nazivPrikaz;
  final bool vidljiv;

  /// true = štampa se čak i ako je prazno; false = samo ako je popunjeno.
  final bool uvekPrikazati;
  final String tip;
  final bool jeKorisnicka;
  final int redosled;
  const IriuKatalogConfigData({
    required this.interniNaziv,
    required this.nazivPrikaz,
    required this.vidljiv,
    required this.uvekPrikazati,
    required this.tip,
    required this.jeKorisnicka,
    required this.redosled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['interni_naziv'] = Variable<String>(interniNaziv);
    map['naziv_prikaz'] = Variable<String>(nazivPrikaz);
    map['vidljiv'] = Variable<bool>(vidljiv);
    map['uvek_prikazati'] = Variable<bool>(uvekPrikazati);
    map['tip'] = Variable<String>(tip);
    map['je_korisnicka'] = Variable<bool>(jeKorisnicka);
    map['redosled'] = Variable<int>(redosled);
    return map;
  }

  IriuKatalogConfigCompanion toCompanion(bool nullToAbsent) {
    return IriuKatalogConfigCompanion(
      interniNaziv: Value(interniNaziv),
      nazivPrikaz: Value(nazivPrikaz),
      vidljiv: Value(vidljiv),
      uvekPrikazati: Value(uvekPrikazati),
      tip: Value(tip),
      jeKorisnicka: Value(jeKorisnicka),
      redosled: Value(redosled),
    );
  }

  factory IriuKatalogConfigData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IriuKatalogConfigData(
      interniNaziv: serializer.fromJson<String>(json['interniNaziv']),
      nazivPrikaz: serializer.fromJson<String>(json['nazivPrikaz']),
      vidljiv: serializer.fromJson<bool>(json['vidljiv']),
      uvekPrikazati: serializer.fromJson<bool>(json['uvekPrikazati']),
      tip: serializer.fromJson<String>(json['tip']),
      jeKorisnicka: serializer.fromJson<bool>(json['jeKorisnicka']),
      redosled: serializer.fromJson<int>(json['redosled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'interniNaziv': serializer.toJson<String>(interniNaziv),
      'nazivPrikaz': serializer.toJson<String>(nazivPrikaz),
      'vidljiv': serializer.toJson<bool>(vidljiv),
      'uvekPrikazati': serializer.toJson<bool>(uvekPrikazati),
      'tip': serializer.toJson<String>(tip),
      'jeKorisnicka': serializer.toJson<bool>(jeKorisnicka),
      'redosled': serializer.toJson<int>(redosled),
    };
  }

  IriuKatalogConfigData copyWith({
    String? interniNaziv,
    String? nazivPrikaz,
    bool? vidljiv,
    bool? uvekPrikazati,
    String? tip,
    bool? jeKorisnicka,
    int? redosled,
  }) => IriuKatalogConfigData(
    interniNaziv: interniNaziv ?? this.interniNaziv,
    nazivPrikaz: nazivPrikaz ?? this.nazivPrikaz,
    vidljiv: vidljiv ?? this.vidljiv,
    uvekPrikazati: uvekPrikazati ?? this.uvekPrikazati,
    tip: tip ?? this.tip,
    jeKorisnicka: jeKorisnicka ?? this.jeKorisnicka,
    redosled: redosled ?? this.redosled,
  );
  IriuKatalogConfigData copyWithCompanion(IriuKatalogConfigCompanion data) {
    return IriuKatalogConfigData(
      interniNaziv: data.interniNaziv.present
          ? data.interniNaziv.value
          : this.interniNaziv,
      nazivPrikaz: data.nazivPrikaz.present
          ? data.nazivPrikaz.value
          : this.nazivPrikaz,
      vidljiv: data.vidljiv.present ? data.vidljiv.value : this.vidljiv,
      uvekPrikazati: data.uvekPrikazati.present
          ? data.uvekPrikazati.value
          : this.uvekPrikazati,
      tip: data.tip.present ? data.tip.value : this.tip,
      jeKorisnicka: data.jeKorisnicka.present
          ? data.jeKorisnicka.value
          : this.jeKorisnicka,
      redosled: data.redosled.present ? data.redosled.value : this.redosled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IriuKatalogConfigData(')
          ..write('interniNaziv: $interniNaziv, ')
          ..write('nazivPrikaz: $nazivPrikaz, ')
          ..write('vidljiv: $vidljiv, ')
          ..write('uvekPrikazati: $uvekPrikazati, ')
          ..write('tip: $tip, ')
          ..write('jeKorisnicka: $jeKorisnicka, ')
          ..write('redosled: $redosled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    interniNaziv,
    nazivPrikaz,
    vidljiv,
    uvekPrikazati,
    tip,
    jeKorisnicka,
    redosled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IriuKatalogConfigData &&
          other.interniNaziv == this.interniNaziv &&
          other.nazivPrikaz == this.nazivPrikaz &&
          other.vidljiv == this.vidljiv &&
          other.uvekPrikazati == this.uvekPrikazati &&
          other.tip == this.tip &&
          other.jeKorisnicka == this.jeKorisnicka &&
          other.redosled == this.redosled);
}

class IriuKatalogConfigCompanion
    extends UpdateCompanion<IriuKatalogConfigData> {
  final Value<String> interniNaziv;
  final Value<String> nazivPrikaz;
  final Value<bool> vidljiv;
  final Value<bool> uvekPrikazati;
  final Value<String> tip;
  final Value<bool> jeKorisnicka;
  final Value<int> redosled;
  final Value<int> rowid;
  const IriuKatalogConfigCompanion({
    this.interniNaziv = const Value.absent(),
    this.nazivPrikaz = const Value.absent(),
    this.vidljiv = const Value.absent(),
    this.uvekPrikazati = const Value.absent(),
    this.tip = const Value.absent(),
    this.jeKorisnicka = const Value.absent(),
    this.redosled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IriuKatalogConfigCompanion.insert({
    required String interniNaziv,
    required String nazivPrikaz,
    this.vidljiv = const Value.absent(),
    this.uvekPrikazati = const Value.absent(),
    this.tip = const Value.absent(),
    this.jeKorisnicka = const Value.absent(),
    this.redosled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : interniNaziv = Value(interniNaziv),
       nazivPrikaz = Value(nazivPrikaz);
  static Insertable<IriuKatalogConfigData> custom({
    Expression<String>? interniNaziv,
    Expression<String>? nazivPrikaz,
    Expression<bool>? vidljiv,
    Expression<bool>? uvekPrikazati,
    Expression<String>? tip,
    Expression<bool>? jeKorisnicka,
    Expression<int>? redosled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (interniNaziv != null) 'interni_naziv': interniNaziv,
      if (nazivPrikaz != null) 'naziv_prikaz': nazivPrikaz,
      if (vidljiv != null) 'vidljiv': vidljiv,
      if (uvekPrikazati != null) 'uvek_prikazati': uvekPrikazati,
      if (tip != null) 'tip': tip,
      if (jeKorisnicka != null) 'je_korisnicka': jeKorisnicka,
      if (redosled != null) 'redosled': redosled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IriuKatalogConfigCompanion copyWith({
    Value<String>? interniNaziv,
    Value<String>? nazivPrikaz,
    Value<bool>? vidljiv,
    Value<bool>? uvekPrikazati,
    Value<String>? tip,
    Value<bool>? jeKorisnicka,
    Value<int>? redosled,
    Value<int>? rowid,
  }) {
    return IriuKatalogConfigCompanion(
      interniNaziv: interniNaziv ?? this.interniNaziv,
      nazivPrikaz: nazivPrikaz ?? this.nazivPrikaz,
      vidljiv: vidljiv ?? this.vidljiv,
      uvekPrikazati: uvekPrikazati ?? this.uvekPrikazati,
      tip: tip ?? this.tip,
      jeKorisnicka: jeKorisnicka ?? this.jeKorisnicka,
      redosled: redosled ?? this.redosled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (interniNaziv.present) {
      map['interni_naziv'] = Variable<String>(interniNaziv.value);
    }
    if (nazivPrikaz.present) {
      map['naziv_prikaz'] = Variable<String>(nazivPrikaz.value);
    }
    if (vidljiv.present) {
      map['vidljiv'] = Variable<bool>(vidljiv.value);
    }
    if (uvekPrikazati.present) {
      map['uvek_prikazati'] = Variable<bool>(uvekPrikazati.value);
    }
    if (tip.present) {
      map['tip'] = Variable<String>(tip.value);
    }
    if (jeKorisnicka.present) {
      map['je_korisnicka'] = Variable<bool>(jeKorisnicka.value);
    }
    if (redosled.present) {
      map['redosled'] = Variable<int>(redosled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IriuKatalogConfigCompanion(')
          ..write('interniNaziv: $interniNaziv, ')
          ..write('nazivPrikaz: $nazivPrikaz, ')
          ..write('vidljiv: $vidljiv, ')
          ..write('uvekPrikazati: $uvekPrikazati, ')
          ..write('tip: $tip, ')
          ..write('jeKorisnicka: $jeKorisnicka, ')
          ..write('redosled: $redosled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KatalogArtikliTable extends KatalogArtikli
    with TableInfo<$KatalogArtikliTable, KatalogArtikliData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KatalogArtikliTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stableArticleIdMeta = const VerificationMeta(
    'stableArticleId',
  );
  @override
  late final GeneratedColumn<String> stableArticleId = GeneratedColumn<String>(
    'stable_article_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interniNazivKategorijeMeta =
      const VerificationMeta('interniNazivKategorije');
  @override
  late final GeneratedColumn<String> interniNazivKategorije =
      GeneratedColumn<String>(
        'interni_naziv_kategorije',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nazivMeta = const VerificationMeta('naziv');
  @override
  late final GeneratedColumn<String> naziv = GeneratedColumn<String>(
    'naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cenaMeta = const VerificationMeta('cena');
  @override
  late final GeneratedColumn<double> cena = GeneratedColumn<double>(
    'cena',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fotografijaMeta = const VerificationMeta(
    'fotografija',
  );
  @override
  late final GeneratedColumn<Uint8List> fotografija =
      GeneratedColumn<Uint8List>(
        'fotografija',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fotografijaPathMeta = const VerificationMeta(
    'fotografijaPath',
  );
  @override
  late final GeneratedColumn<String> fotografijaPath = GeneratedColumn<String>(
    'fotografija_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stableArticleId,
    interniNazivKategorije,
    naziv,
    cena,
    fotografija,
    fotografijaPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'katalog_artikli';
  @override
  VerificationContext validateIntegrity(
    Insertable<KatalogArtikliData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stable_article_id')) {
      context.handle(
        _stableArticleIdMeta,
        stableArticleId.isAcceptableOrUnknown(
          data['stable_article_id']!,
          _stableArticleIdMeta,
        ),
      );
    }
    if (data.containsKey('interni_naziv_kategorije')) {
      context.handle(
        _interniNazivKategorijeMeta,
        interniNazivKategorije.isAcceptableOrUnknown(
          data['interni_naziv_kategorije']!,
          _interniNazivKategorijeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interniNazivKategorijeMeta);
    }
    if (data.containsKey('naziv')) {
      context.handle(
        _nazivMeta,
        naziv.isAcceptableOrUnknown(data['naziv']!, _nazivMeta),
      );
    } else if (isInserting) {
      context.missing(_nazivMeta);
    }
    if (data.containsKey('cena')) {
      context.handle(
        _cenaMeta,
        cena.isAcceptableOrUnknown(data['cena']!, _cenaMeta),
      );
    }
    if (data.containsKey('fotografija')) {
      context.handle(
        _fotografijaMeta,
        fotografija.isAcceptableOrUnknown(
          data['fotografija']!,
          _fotografijaMeta,
        ),
      );
    }
    if (data.containsKey('fotografija_path')) {
      context.handle(
        _fotografijaPathMeta,
        fotografijaPath.isAcceptableOrUnknown(
          data['fotografija_path']!,
          _fotografijaPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KatalogArtikliData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KatalogArtikliData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stableArticleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_article_id'],
      ),
      interniNazivKategorije: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interni_naziv_kategorije'],
      )!,
      naziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naziv'],
      )!,
      cena: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cena'],
      )!,
      fotografija: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}fotografija'],
      ),
      fotografijaPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fotografija_path'],
      ),
    );
  }

  @override
  $KatalogArtikliTable createAlias(String alias) {
    return $KatalogArtikliTable(attachedDatabase, alias);
  }
}

class KatalogArtikliData extends DataClass
    implements Insertable<KatalogArtikliData> {
  final int id;
  final String? stableArticleId;

  /// Interni naziv kategorije kojoj artikal pripada (npr. SANDUK, CVECE).
  final String interniNazivKategorije;
  final String naziv;
  final double cena;
  final Uint8List? fotografija;

  /// Asset path za fotografiju iz kataloga (npr. assets/katalog_foto/katalog_001.jpg).
  final String? fotografijaPath;
  const KatalogArtikliData({
    required this.id,
    this.stableArticleId,
    required this.interniNazivKategorije,
    required this.naziv,
    required this.cena,
    this.fotografija,
    this.fotografijaPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || stableArticleId != null) {
      map['stable_article_id'] = Variable<String>(stableArticleId);
    }
    map['interni_naziv_kategorije'] = Variable<String>(interniNazivKategorije);
    map['naziv'] = Variable<String>(naziv);
    map['cena'] = Variable<double>(cena);
    if (!nullToAbsent || fotografija != null) {
      map['fotografija'] = Variable<Uint8List>(fotografija);
    }
    if (!nullToAbsent || fotografijaPath != null) {
      map['fotografija_path'] = Variable<String>(fotografijaPath);
    }
    return map;
  }

  KatalogArtikliCompanion toCompanion(bool nullToAbsent) {
    return KatalogArtikliCompanion(
      id: Value(id),
      stableArticleId: stableArticleId == null && nullToAbsent
          ? const Value.absent()
          : Value(stableArticleId),
      interniNazivKategorije: Value(interniNazivKategorije),
      naziv: Value(naziv),
      cena: Value(cena),
      fotografija: fotografija == null && nullToAbsent
          ? const Value.absent()
          : Value(fotografija),
      fotografijaPath: fotografijaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotografijaPath),
    );
  }

  factory KatalogArtikliData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KatalogArtikliData(
      id: serializer.fromJson<int>(json['id']),
      stableArticleId: serializer.fromJson<String?>(json['stableArticleId']),
      interniNazivKategorije: serializer.fromJson<String>(
        json['interniNazivKategorije'],
      ),
      naziv: serializer.fromJson<String>(json['naziv']),
      cena: serializer.fromJson<double>(json['cena']),
      fotografija: serializer.fromJson<Uint8List?>(json['fotografija']),
      fotografijaPath: serializer.fromJson<String?>(json['fotografijaPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stableArticleId': serializer.toJson<String?>(stableArticleId),
      'interniNazivKategorije': serializer.toJson<String>(
        interniNazivKategorije,
      ),
      'naziv': serializer.toJson<String>(naziv),
      'cena': serializer.toJson<double>(cena),
      'fotografija': serializer.toJson<Uint8List?>(fotografija),
      'fotografijaPath': serializer.toJson<String?>(fotografijaPath),
    };
  }

  KatalogArtikliData copyWith({
    int? id,
    Value<String?> stableArticleId = const Value.absent(),
    String? interniNazivKategorije,
    String? naziv,
    double? cena,
    Value<Uint8List?> fotografija = const Value.absent(),
    Value<String?> fotografijaPath = const Value.absent(),
  }) => KatalogArtikliData(
    id: id ?? this.id,
    stableArticleId: stableArticleId.present
        ? stableArticleId.value
        : this.stableArticleId,
    interniNazivKategorije:
        interniNazivKategorije ?? this.interniNazivKategorije,
    naziv: naziv ?? this.naziv,
    cena: cena ?? this.cena,
    fotografija: fotografija.present ? fotografija.value : this.fotografija,
    fotografijaPath: fotografijaPath.present
        ? fotografijaPath.value
        : this.fotografijaPath,
  );
  KatalogArtikliData copyWithCompanion(KatalogArtikliCompanion data) {
    return KatalogArtikliData(
      id: data.id.present ? data.id.value : this.id,
      stableArticleId: data.stableArticleId.present
          ? data.stableArticleId.value
          : this.stableArticleId,
      interniNazivKategorije: data.interniNazivKategorije.present
          ? data.interniNazivKategorije.value
          : this.interniNazivKategorije,
      naziv: data.naziv.present ? data.naziv.value : this.naziv,
      cena: data.cena.present ? data.cena.value : this.cena,
      fotografija: data.fotografija.present
          ? data.fotografija.value
          : this.fotografija,
      fotografijaPath: data.fotografijaPath.present
          ? data.fotografijaPath.value
          : this.fotografijaPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KatalogArtikliData(')
          ..write('id: $id, ')
          ..write('stableArticleId: $stableArticleId, ')
          ..write('interniNazivKategorije: $interniNazivKategorije, ')
          ..write('naziv: $naziv, ')
          ..write('cena: $cena, ')
          ..write('fotografija: $fotografija, ')
          ..write('fotografijaPath: $fotografijaPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stableArticleId,
    interniNazivKategorije,
    naziv,
    cena,
    $driftBlobEquality.hash(fotografija),
    fotografijaPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KatalogArtikliData &&
          other.id == this.id &&
          other.stableArticleId == this.stableArticleId &&
          other.interniNazivKategorije == this.interniNazivKategorije &&
          other.naziv == this.naziv &&
          other.cena == this.cena &&
          $driftBlobEquality.equals(other.fotografija, this.fotografija) &&
          other.fotografijaPath == this.fotografijaPath);
}

class KatalogArtikliCompanion extends UpdateCompanion<KatalogArtikliData> {
  final Value<int> id;
  final Value<String?> stableArticleId;
  final Value<String> interniNazivKategorije;
  final Value<String> naziv;
  final Value<double> cena;
  final Value<Uint8List?> fotografija;
  final Value<String?> fotografijaPath;
  const KatalogArtikliCompanion({
    this.id = const Value.absent(),
    this.stableArticleId = const Value.absent(),
    this.interniNazivKategorije = const Value.absent(),
    this.naziv = const Value.absent(),
    this.cena = const Value.absent(),
    this.fotografija = const Value.absent(),
    this.fotografijaPath = const Value.absent(),
  });
  KatalogArtikliCompanion.insert({
    this.id = const Value.absent(),
    this.stableArticleId = const Value.absent(),
    required String interniNazivKategorije,
    required String naziv,
    this.cena = const Value.absent(),
    this.fotografija = const Value.absent(),
    this.fotografijaPath = const Value.absent(),
  }) : interniNazivKategorije = Value(interniNazivKategorije),
       naziv = Value(naziv);
  static Insertable<KatalogArtikliData> custom({
    Expression<int>? id,
    Expression<String>? stableArticleId,
    Expression<String>? interniNazivKategorije,
    Expression<String>? naziv,
    Expression<double>? cena,
    Expression<Uint8List>? fotografija,
    Expression<String>? fotografijaPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stableArticleId != null) 'stable_article_id': stableArticleId,
      if (interniNazivKategorije != null)
        'interni_naziv_kategorije': interniNazivKategorije,
      if (naziv != null) 'naziv': naziv,
      if (cena != null) 'cena': cena,
      if (fotografija != null) 'fotografija': fotografija,
      if (fotografijaPath != null) 'fotografija_path': fotografijaPath,
    });
  }

  KatalogArtikliCompanion copyWith({
    Value<int>? id,
    Value<String?>? stableArticleId,
    Value<String>? interniNazivKategorije,
    Value<String>? naziv,
    Value<double>? cena,
    Value<Uint8List?>? fotografija,
    Value<String?>? fotografijaPath,
  }) {
    return KatalogArtikliCompanion(
      id: id ?? this.id,
      stableArticleId: stableArticleId ?? this.stableArticleId,
      interniNazivKategorije:
          interniNazivKategorije ?? this.interniNazivKategorije,
      naziv: naziv ?? this.naziv,
      cena: cena ?? this.cena,
      fotografija: fotografija ?? this.fotografija,
      fotografijaPath: fotografijaPath ?? this.fotografijaPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stableArticleId.present) {
      map['stable_article_id'] = Variable<String>(stableArticleId.value);
    }
    if (interniNazivKategorije.present) {
      map['interni_naziv_kategorije'] = Variable<String>(
        interniNazivKategorije.value,
      );
    }
    if (naziv.present) {
      map['naziv'] = Variable<String>(naziv.value);
    }
    if (cena.present) {
      map['cena'] = Variable<double>(cena.value);
    }
    if (fotografija.present) {
      map['fotografija'] = Variable<Uint8List>(fotografija.value);
    }
    if (fotografijaPath.present) {
      map['fotografija_path'] = Variable<String>(fotografijaPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KatalogArtikliCompanion(')
          ..write('id: $id, ')
          ..write('stableArticleId: $stableArticleId, ')
          ..write('interniNazivKategorije: $interniNazivKategorije, ')
          ..write('naziv: $naziv, ')
          ..write('cena: $cena, ')
          ..write('fotografija: $fotografija, ')
          ..write('fotografijaPath: $fotografijaPath')
          ..write(')'))
        .toString();
  }
}

class $StanjeRobeStavkeTable extends StanjeRobeStavke
    with TableInfo<$StanjeRobeStavkeTable, StanjeRobeStavkeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StanjeRobeStavkeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stableArticleIdMeta = const VerificationMeta(
    'stableArticleId',
  );
  @override
  late final GeneratedColumn<String> stableArticleId = GeneratedColumn<String>(
    'stable_article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trenutnaKolicinaMeta = const VerificationMeta(
    'trenutnaKolicina',
  );
  @override
  late final GeneratedColumn<double> trenutnaKolicina = GeneratedColumn<double>(
    'trenutna_kolicina',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _minimalnaKolicinaMeta = const VerificationMeta(
    'minimalnaKolicina',
  );
  @override
  late final GeneratedColumn<double> minimalnaKolicina =
      GeneratedColumn<double>(
        'minimalna_kolicina',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _aktivnaMeta = const VerificationMeta(
    'aktivna',
  );
  @override
  late final GeneratedColumn<bool> aktivna = GeneratedColumn<bool>(
    'aktivna',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktivna" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _datumKreiranjaMeta = const VerificationMeta(
    'datumKreiranja',
  );
  @override
  late final GeneratedColumn<String> datumKreiranja = GeneratedColumn<String>(
    'datum_kreiranja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _datumAzuriranjaMeta = const VerificationMeta(
    'datumAzuriranja',
  );
  @override
  late final GeneratedColumn<String> datumAzuriranja = GeneratedColumn<String>(
    'datum_azuriranja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stableArticleId,
    trenutnaKolicina,
    minimalnaKolicina,
    aktivna,
    datumKreiranja,
    datumAzuriranja,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stanje_robe_stavke';
  @override
  VerificationContext validateIntegrity(
    Insertable<StanjeRobeStavkeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stable_article_id')) {
      context.handle(
        _stableArticleIdMeta,
        stableArticleId.isAcceptableOrUnknown(
          data['stable_article_id']!,
          _stableArticleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stableArticleIdMeta);
    }
    if (data.containsKey('trenutna_kolicina')) {
      context.handle(
        _trenutnaKolicinaMeta,
        trenutnaKolicina.isAcceptableOrUnknown(
          data['trenutna_kolicina']!,
          _trenutnaKolicinaMeta,
        ),
      );
    }
    if (data.containsKey('minimalna_kolicina')) {
      context.handle(
        _minimalnaKolicinaMeta,
        minimalnaKolicina.isAcceptableOrUnknown(
          data['minimalna_kolicina']!,
          _minimalnaKolicinaMeta,
        ),
      );
    }
    if (data.containsKey('aktivna')) {
      context.handle(
        _aktivnaMeta,
        aktivna.isAcceptableOrUnknown(data['aktivna']!, _aktivnaMeta),
      );
    }
    if (data.containsKey('datum_kreiranja')) {
      context.handle(
        _datumKreiranjaMeta,
        datumKreiranja.isAcceptableOrUnknown(
          data['datum_kreiranja']!,
          _datumKreiranjaMeta,
        ),
      );
    }
    if (data.containsKey('datum_azuriranja')) {
      context.handle(
        _datumAzuriranjaMeta,
        datumAzuriranja.isAcceptableOrUnknown(
          data['datum_azuriranja']!,
          _datumAzuriranjaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StanjeRobeStavkeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StanjeRobeStavkeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stableArticleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_article_id'],
      )!,
      trenutnaKolicina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trenutna_kolicina'],
      )!,
      minimalnaKolicina: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimalna_kolicina'],
      )!,
      aktivna: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktivna'],
      )!,
      datumKreiranja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_kreiranja'],
      )!,
      datumAzuriranja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_azuriranja'],
      )!,
    );
  }

  @override
  $StanjeRobeStavkeTable createAlias(String alias) {
    return $StanjeRobeStavkeTable(attachedDatabase, alias);
  }
}

class StanjeRobeStavkeData extends DataClass
    implements Insertable<StanjeRobeStavkeData> {
  final int id;
  final String stableArticleId;
  final double trenutnaKolicina;
  final double minimalnaKolicina;
  final bool aktivna;
  final String datumKreiranja;
  final String datumAzuriranja;
  const StanjeRobeStavkeData({
    required this.id,
    required this.stableArticleId,
    required this.trenutnaKolicina,
    required this.minimalnaKolicina,
    required this.aktivna,
    required this.datumKreiranja,
    required this.datumAzuriranja,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stable_article_id'] = Variable<String>(stableArticleId);
    map['trenutna_kolicina'] = Variable<double>(trenutnaKolicina);
    map['minimalna_kolicina'] = Variable<double>(minimalnaKolicina);
    map['aktivna'] = Variable<bool>(aktivna);
    map['datum_kreiranja'] = Variable<String>(datumKreiranja);
    map['datum_azuriranja'] = Variable<String>(datumAzuriranja);
    return map;
  }

  StanjeRobeStavkeCompanion toCompanion(bool nullToAbsent) {
    return StanjeRobeStavkeCompanion(
      id: Value(id),
      stableArticleId: Value(stableArticleId),
      trenutnaKolicina: Value(trenutnaKolicina),
      minimalnaKolicina: Value(minimalnaKolicina),
      aktivna: Value(aktivna),
      datumKreiranja: Value(datumKreiranja),
      datumAzuriranja: Value(datumAzuriranja),
    );
  }

  factory StanjeRobeStavkeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StanjeRobeStavkeData(
      id: serializer.fromJson<int>(json['id']),
      stableArticleId: serializer.fromJson<String>(json['stableArticleId']),
      trenutnaKolicina: serializer.fromJson<double>(json['trenutnaKolicina']),
      minimalnaKolicina: serializer.fromJson<double>(json['minimalnaKolicina']),
      aktivna: serializer.fromJson<bool>(json['aktivna']),
      datumKreiranja: serializer.fromJson<String>(json['datumKreiranja']),
      datumAzuriranja: serializer.fromJson<String>(json['datumAzuriranja']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stableArticleId': serializer.toJson<String>(stableArticleId),
      'trenutnaKolicina': serializer.toJson<double>(trenutnaKolicina),
      'minimalnaKolicina': serializer.toJson<double>(minimalnaKolicina),
      'aktivna': serializer.toJson<bool>(aktivna),
      'datumKreiranja': serializer.toJson<String>(datumKreiranja),
      'datumAzuriranja': serializer.toJson<String>(datumAzuriranja),
    };
  }

  StanjeRobeStavkeData copyWith({
    int? id,
    String? stableArticleId,
    double? trenutnaKolicina,
    double? minimalnaKolicina,
    bool? aktivna,
    String? datumKreiranja,
    String? datumAzuriranja,
  }) => StanjeRobeStavkeData(
    id: id ?? this.id,
    stableArticleId: stableArticleId ?? this.stableArticleId,
    trenutnaKolicina: trenutnaKolicina ?? this.trenutnaKolicina,
    minimalnaKolicina: minimalnaKolicina ?? this.minimalnaKolicina,
    aktivna: aktivna ?? this.aktivna,
    datumKreiranja: datumKreiranja ?? this.datumKreiranja,
    datumAzuriranja: datumAzuriranja ?? this.datumAzuriranja,
  );
  StanjeRobeStavkeData copyWithCompanion(StanjeRobeStavkeCompanion data) {
    return StanjeRobeStavkeData(
      id: data.id.present ? data.id.value : this.id,
      stableArticleId: data.stableArticleId.present
          ? data.stableArticleId.value
          : this.stableArticleId,
      trenutnaKolicina: data.trenutnaKolicina.present
          ? data.trenutnaKolicina.value
          : this.trenutnaKolicina,
      minimalnaKolicina: data.minimalnaKolicina.present
          ? data.minimalnaKolicina.value
          : this.minimalnaKolicina,
      aktivna: data.aktivna.present ? data.aktivna.value : this.aktivna,
      datumKreiranja: data.datumKreiranja.present
          ? data.datumKreiranja.value
          : this.datumKreiranja,
      datumAzuriranja: data.datumAzuriranja.present
          ? data.datumAzuriranja.value
          : this.datumAzuriranja,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StanjeRobeStavkeData(')
          ..write('id: $id, ')
          ..write('stableArticleId: $stableArticleId, ')
          ..write('trenutnaKolicina: $trenutnaKolicina, ')
          ..write('minimalnaKolicina: $minimalnaKolicina, ')
          ..write('aktivna: $aktivna, ')
          ..write('datumKreiranja: $datumKreiranja, ')
          ..write('datumAzuriranja: $datumAzuriranja')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stableArticleId,
    trenutnaKolicina,
    minimalnaKolicina,
    aktivna,
    datumKreiranja,
    datumAzuriranja,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StanjeRobeStavkeData &&
          other.id == this.id &&
          other.stableArticleId == this.stableArticleId &&
          other.trenutnaKolicina == this.trenutnaKolicina &&
          other.minimalnaKolicina == this.minimalnaKolicina &&
          other.aktivna == this.aktivna &&
          other.datumKreiranja == this.datumKreiranja &&
          other.datumAzuriranja == this.datumAzuriranja);
}

class StanjeRobeStavkeCompanion extends UpdateCompanion<StanjeRobeStavkeData> {
  final Value<int> id;
  final Value<String> stableArticleId;
  final Value<double> trenutnaKolicina;
  final Value<double> minimalnaKolicina;
  final Value<bool> aktivna;
  final Value<String> datumKreiranja;
  final Value<String> datumAzuriranja;
  const StanjeRobeStavkeCompanion({
    this.id = const Value.absent(),
    this.stableArticleId = const Value.absent(),
    this.trenutnaKolicina = const Value.absent(),
    this.minimalnaKolicina = const Value.absent(),
    this.aktivna = const Value.absent(),
    this.datumKreiranja = const Value.absent(),
    this.datumAzuriranja = const Value.absent(),
  });
  StanjeRobeStavkeCompanion.insert({
    this.id = const Value.absent(),
    required String stableArticleId,
    this.trenutnaKolicina = const Value.absent(),
    this.minimalnaKolicina = const Value.absent(),
    this.aktivna = const Value.absent(),
    this.datumKreiranja = const Value.absent(),
    this.datumAzuriranja = const Value.absent(),
  }) : stableArticleId = Value(stableArticleId);
  static Insertable<StanjeRobeStavkeData> custom({
    Expression<int>? id,
    Expression<String>? stableArticleId,
    Expression<double>? trenutnaKolicina,
    Expression<double>? minimalnaKolicina,
    Expression<bool>? aktivna,
    Expression<String>? datumKreiranja,
    Expression<String>? datumAzuriranja,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stableArticleId != null) 'stable_article_id': stableArticleId,
      if (trenutnaKolicina != null) 'trenutna_kolicina': trenutnaKolicina,
      if (minimalnaKolicina != null) 'minimalna_kolicina': minimalnaKolicina,
      if (aktivna != null) 'aktivna': aktivna,
      if (datumKreiranja != null) 'datum_kreiranja': datumKreiranja,
      if (datumAzuriranja != null) 'datum_azuriranja': datumAzuriranja,
    });
  }

  StanjeRobeStavkeCompanion copyWith({
    Value<int>? id,
    Value<String>? stableArticleId,
    Value<double>? trenutnaKolicina,
    Value<double>? minimalnaKolicina,
    Value<bool>? aktivna,
    Value<String>? datumKreiranja,
    Value<String>? datumAzuriranja,
  }) {
    return StanjeRobeStavkeCompanion(
      id: id ?? this.id,
      stableArticleId: stableArticleId ?? this.stableArticleId,
      trenutnaKolicina: trenutnaKolicina ?? this.trenutnaKolicina,
      minimalnaKolicina: minimalnaKolicina ?? this.minimalnaKolicina,
      aktivna: aktivna ?? this.aktivna,
      datumKreiranja: datumKreiranja ?? this.datumKreiranja,
      datumAzuriranja: datumAzuriranja ?? this.datumAzuriranja,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stableArticleId.present) {
      map['stable_article_id'] = Variable<String>(stableArticleId.value);
    }
    if (trenutnaKolicina.present) {
      map['trenutna_kolicina'] = Variable<double>(trenutnaKolicina.value);
    }
    if (minimalnaKolicina.present) {
      map['minimalna_kolicina'] = Variable<double>(minimalnaKolicina.value);
    }
    if (aktivna.present) {
      map['aktivna'] = Variable<bool>(aktivna.value);
    }
    if (datumKreiranja.present) {
      map['datum_kreiranja'] = Variable<String>(datumKreiranja.value);
    }
    if (datumAzuriranja.present) {
      map['datum_azuriranja'] = Variable<String>(datumAzuriranja.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StanjeRobeStavkeCompanion(')
          ..write('id: $id, ')
          ..write('stableArticleId: $stableArticleId, ')
          ..write('trenutnaKolicina: $trenutnaKolicina, ')
          ..write('minimalnaKolicina: $minimalnaKolicina, ')
          ..write('aktivna: $aktivna, ')
          ..write('datumKreiranja: $datumKreiranja, ')
          ..write('datumAzuriranja: $datumAzuriranja')
          ..write(')'))
        .toString();
  }
}

class $StanjeRobeAppliedEffectsTable extends StanjeRobeAppliedEffects
    with TableInfo<$StanjeRobeAppliedEffectsTable, StanjeRobeAppliedEffect> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StanjeRobeAppliedEffectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predmetIdMeta = const VerificationMeta(
    'predmetId',
  );
  @override
  late final GeneratedColumn<int> predmetId = GeneratedColumn<int>(
    'predmet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _iriuIdMeta = const VerificationMeta('iriuId');
  @override
  late final GeneratedColumn<int> iriuId = GeneratedColumn<int>(
    'iriu_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kategorijaMeta = const VerificationMeta(
    'kategorija',
  );
  @override
  late final GeneratedColumn<String> kategorija = GeneratedColumn<String>(
    'kategorija',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stableArticleIdMeta = const VerificationMeta(
    'stableArticleId',
  );
  @override
  late final GeneratedColumn<String> stableArticleId = GeneratedColumn<String>(
    'stable_article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectQuantityMeta = const VerificationMeta(
    'effectQuantity',
  );
  @override
  late final GeneratedColumn<double> effectQuantity = GeneratedColumn<double>(
    'effect_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _effectStatusMeta = const VerificationMeta(
    'effectStatus',
  );
  @override
  late final GeneratedColumn<String> effectStatus = GeneratedColumn<String>(
    'effect_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectReasonMeta = const VerificationMeta(
    'effectReason',
  );
  @override
  late final GeneratedColumn<String> effectReason = GeneratedColumn<String>(
    'effect_reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datumKreiranjaMeta = const VerificationMeta(
    'datumKreiranja',
  );
  @override
  late final GeneratedColumn<String> datumKreiranja = GeneratedColumn<String>(
    'datum_kreiranja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _datumAzuriranjaMeta = const VerificationMeta(
    'datumAzuriranja',
  );
  @override
  late final GeneratedColumn<String> datumAzuriranja = GeneratedColumn<String>(
    'datum_azuriranja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predmetId,
    iriuId,
    kategorija,
    stableArticleId,
    effectQuantity,
    effectStatus,
    effectReason,
    datumKreiranja,
    datumAzuriranja,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stanje_robe_applied_effects';
  @override
  VerificationContext validateIntegrity(
    Insertable<StanjeRobeAppliedEffect> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predmet_id')) {
      context.handle(
        _predmetIdMeta,
        predmetId.isAcceptableOrUnknown(data['predmet_id']!, _predmetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_predmetIdMeta);
    }
    if (data.containsKey('iriu_id')) {
      context.handle(
        _iriuIdMeta,
        iriuId.isAcceptableOrUnknown(data['iriu_id']!, _iriuIdMeta),
      );
    }
    if (data.containsKey('kategorija')) {
      context.handle(
        _kategorijaMeta,
        kategorija.isAcceptableOrUnknown(data['kategorija']!, _kategorijaMeta),
      );
    } else if (isInserting) {
      context.missing(_kategorijaMeta);
    }
    if (data.containsKey('stable_article_id')) {
      context.handle(
        _stableArticleIdMeta,
        stableArticleId.isAcceptableOrUnknown(
          data['stable_article_id']!,
          _stableArticleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stableArticleIdMeta);
    }
    if (data.containsKey('effect_quantity')) {
      context.handle(
        _effectQuantityMeta,
        effectQuantity.isAcceptableOrUnknown(
          data['effect_quantity']!,
          _effectQuantityMeta,
        ),
      );
    }
    if (data.containsKey('effect_status')) {
      context.handle(
        _effectStatusMeta,
        effectStatus.isAcceptableOrUnknown(
          data['effect_status']!,
          _effectStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectStatusMeta);
    }
    if (data.containsKey('effect_reason')) {
      context.handle(
        _effectReasonMeta,
        effectReason.isAcceptableOrUnknown(
          data['effect_reason']!,
          _effectReasonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectReasonMeta);
    }
    if (data.containsKey('datum_kreiranja')) {
      context.handle(
        _datumKreiranjaMeta,
        datumKreiranja.isAcceptableOrUnknown(
          data['datum_kreiranja']!,
          _datumKreiranjaMeta,
        ),
      );
    }
    if (data.containsKey('datum_azuriranja')) {
      context.handle(
        _datumAzuriranjaMeta,
        datumAzuriranja.isAcceptableOrUnknown(
          data['datum_azuriranja']!,
          _datumAzuriranjaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StanjeRobeAppliedEffect map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StanjeRobeAppliedEffect(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predmetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predmet_id'],
      )!,
      iriuId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iriu_id'],
      ),
      kategorija: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategorija'],
      )!,
      stableArticleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_article_id'],
      )!,
      effectQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}effect_quantity'],
      )!,
      effectStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect_status'],
      )!,
      effectReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect_reason'],
      )!,
      datumKreiranja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_kreiranja'],
      )!,
      datumAzuriranja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_azuriranja'],
      )!,
    );
  }

  @override
  $StanjeRobeAppliedEffectsTable createAlias(String alias) {
    return $StanjeRobeAppliedEffectsTable(attachedDatabase, alias);
  }
}

class StanjeRobeAppliedEffect extends DataClass
    implements Insertable<StanjeRobeAppliedEffect> {
  final int id;
  final int predmetId;
  final int? iriuId;
  final String kategorija;
  final String stableArticleId;
  final double effectQuantity;
  final String effectStatus;
  final String effectReason;
  final String datumKreiranja;
  final String datumAzuriranja;
  const StanjeRobeAppliedEffect({
    required this.id,
    required this.predmetId,
    this.iriuId,
    required this.kategorija,
    required this.stableArticleId,
    required this.effectQuantity,
    required this.effectStatus,
    required this.effectReason,
    required this.datumKreiranja,
    required this.datumAzuriranja,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predmet_id'] = Variable<int>(predmetId);
    if (!nullToAbsent || iriuId != null) {
      map['iriu_id'] = Variable<int>(iriuId);
    }
    map['kategorija'] = Variable<String>(kategorija);
    map['stable_article_id'] = Variable<String>(stableArticleId);
    map['effect_quantity'] = Variable<double>(effectQuantity);
    map['effect_status'] = Variable<String>(effectStatus);
    map['effect_reason'] = Variable<String>(effectReason);
    map['datum_kreiranja'] = Variable<String>(datumKreiranja);
    map['datum_azuriranja'] = Variable<String>(datumAzuriranja);
    return map;
  }

  StanjeRobeAppliedEffectsCompanion toCompanion(bool nullToAbsent) {
    return StanjeRobeAppliedEffectsCompanion(
      id: Value(id),
      predmetId: Value(predmetId),
      iriuId: iriuId == null && nullToAbsent
          ? const Value.absent()
          : Value(iriuId),
      kategorija: Value(kategorija),
      stableArticleId: Value(stableArticleId),
      effectQuantity: Value(effectQuantity),
      effectStatus: Value(effectStatus),
      effectReason: Value(effectReason),
      datumKreiranja: Value(datumKreiranja),
      datumAzuriranja: Value(datumAzuriranja),
    );
  }

  factory StanjeRobeAppliedEffect.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StanjeRobeAppliedEffect(
      id: serializer.fromJson<int>(json['id']),
      predmetId: serializer.fromJson<int>(json['predmetId']),
      iriuId: serializer.fromJson<int?>(json['iriuId']),
      kategorija: serializer.fromJson<String>(json['kategorija']),
      stableArticleId: serializer.fromJson<String>(json['stableArticleId']),
      effectQuantity: serializer.fromJson<double>(json['effectQuantity']),
      effectStatus: serializer.fromJson<String>(json['effectStatus']),
      effectReason: serializer.fromJson<String>(json['effectReason']),
      datumKreiranja: serializer.fromJson<String>(json['datumKreiranja']),
      datumAzuriranja: serializer.fromJson<String>(json['datumAzuriranja']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predmetId': serializer.toJson<int>(predmetId),
      'iriuId': serializer.toJson<int?>(iriuId),
      'kategorija': serializer.toJson<String>(kategorija),
      'stableArticleId': serializer.toJson<String>(stableArticleId),
      'effectQuantity': serializer.toJson<double>(effectQuantity),
      'effectStatus': serializer.toJson<String>(effectStatus),
      'effectReason': serializer.toJson<String>(effectReason),
      'datumKreiranja': serializer.toJson<String>(datumKreiranja),
      'datumAzuriranja': serializer.toJson<String>(datumAzuriranja),
    };
  }

  StanjeRobeAppliedEffect copyWith({
    int? id,
    int? predmetId,
    Value<int?> iriuId = const Value.absent(),
    String? kategorija,
    String? stableArticleId,
    double? effectQuantity,
    String? effectStatus,
    String? effectReason,
    String? datumKreiranja,
    String? datumAzuriranja,
  }) => StanjeRobeAppliedEffect(
    id: id ?? this.id,
    predmetId: predmetId ?? this.predmetId,
    iriuId: iriuId.present ? iriuId.value : this.iriuId,
    kategorija: kategorija ?? this.kategorija,
    stableArticleId: stableArticleId ?? this.stableArticleId,
    effectQuantity: effectQuantity ?? this.effectQuantity,
    effectStatus: effectStatus ?? this.effectStatus,
    effectReason: effectReason ?? this.effectReason,
    datumKreiranja: datumKreiranja ?? this.datumKreiranja,
    datumAzuriranja: datumAzuriranja ?? this.datumAzuriranja,
  );
  StanjeRobeAppliedEffect copyWithCompanion(
    StanjeRobeAppliedEffectsCompanion data,
  ) {
    return StanjeRobeAppliedEffect(
      id: data.id.present ? data.id.value : this.id,
      predmetId: data.predmetId.present ? data.predmetId.value : this.predmetId,
      iriuId: data.iriuId.present ? data.iriuId.value : this.iriuId,
      kategorija: data.kategorija.present
          ? data.kategorija.value
          : this.kategorija,
      stableArticleId: data.stableArticleId.present
          ? data.stableArticleId.value
          : this.stableArticleId,
      effectQuantity: data.effectQuantity.present
          ? data.effectQuantity.value
          : this.effectQuantity,
      effectStatus: data.effectStatus.present
          ? data.effectStatus.value
          : this.effectStatus,
      effectReason: data.effectReason.present
          ? data.effectReason.value
          : this.effectReason,
      datumKreiranja: data.datumKreiranja.present
          ? data.datumKreiranja.value
          : this.datumKreiranja,
      datumAzuriranja: data.datumAzuriranja.present
          ? data.datumAzuriranja.value
          : this.datumAzuriranja,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StanjeRobeAppliedEffect(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('iriuId: $iriuId, ')
          ..write('kategorija: $kategorija, ')
          ..write('stableArticleId: $stableArticleId, ')
          ..write('effectQuantity: $effectQuantity, ')
          ..write('effectStatus: $effectStatus, ')
          ..write('effectReason: $effectReason, ')
          ..write('datumKreiranja: $datumKreiranja, ')
          ..write('datumAzuriranja: $datumAzuriranja')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predmetId,
    iriuId,
    kategorija,
    stableArticleId,
    effectQuantity,
    effectStatus,
    effectReason,
    datumKreiranja,
    datumAzuriranja,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StanjeRobeAppliedEffect &&
          other.id == this.id &&
          other.predmetId == this.predmetId &&
          other.iriuId == this.iriuId &&
          other.kategorija == this.kategorija &&
          other.stableArticleId == this.stableArticleId &&
          other.effectQuantity == this.effectQuantity &&
          other.effectStatus == this.effectStatus &&
          other.effectReason == this.effectReason &&
          other.datumKreiranja == this.datumKreiranja &&
          other.datumAzuriranja == this.datumAzuriranja);
}

class StanjeRobeAppliedEffectsCompanion
    extends UpdateCompanion<StanjeRobeAppliedEffect> {
  final Value<int> id;
  final Value<int> predmetId;
  final Value<int?> iriuId;
  final Value<String> kategorija;
  final Value<String> stableArticleId;
  final Value<double> effectQuantity;
  final Value<String> effectStatus;
  final Value<String> effectReason;
  final Value<String> datumKreiranja;
  final Value<String> datumAzuriranja;
  const StanjeRobeAppliedEffectsCompanion({
    this.id = const Value.absent(),
    this.predmetId = const Value.absent(),
    this.iriuId = const Value.absent(),
    this.kategorija = const Value.absent(),
    this.stableArticleId = const Value.absent(),
    this.effectQuantity = const Value.absent(),
    this.effectStatus = const Value.absent(),
    this.effectReason = const Value.absent(),
    this.datumKreiranja = const Value.absent(),
    this.datumAzuriranja = const Value.absent(),
  });
  StanjeRobeAppliedEffectsCompanion.insert({
    this.id = const Value.absent(),
    required int predmetId,
    this.iriuId = const Value.absent(),
    required String kategorija,
    required String stableArticleId,
    this.effectQuantity = const Value.absent(),
    required String effectStatus,
    required String effectReason,
    this.datumKreiranja = const Value.absent(),
    this.datumAzuriranja = const Value.absent(),
  }) : predmetId = Value(predmetId),
       kategorija = Value(kategorija),
       stableArticleId = Value(stableArticleId),
       effectStatus = Value(effectStatus),
       effectReason = Value(effectReason);
  static Insertable<StanjeRobeAppliedEffect> custom({
    Expression<int>? id,
    Expression<int>? predmetId,
    Expression<int>? iriuId,
    Expression<String>? kategorija,
    Expression<String>? stableArticleId,
    Expression<double>? effectQuantity,
    Expression<String>? effectStatus,
    Expression<String>? effectReason,
    Expression<String>? datumKreiranja,
    Expression<String>? datumAzuriranja,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predmetId != null) 'predmet_id': predmetId,
      if (iriuId != null) 'iriu_id': iriuId,
      if (kategorija != null) 'kategorija': kategorija,
      if (stableArticleId != null) 'stable_article_id': stableArticleId,
      if (effectQuantity != null) 'effect_quantity': effectQuantity,
      if (effectStatus != null) 'effect_status': effectStatus,
      if (effectReason != null) 'effect_reason': effectReason,
      if (datumKreiranja != null) 'datum_kreiranja': datumKreiranja,
      if (datumAzuriranja != null) 'datum_azuriranja': datumAzuriranja,
    });
  }

  StanjeRobeAppliedEffectsCompanion copyWith({
    Value<int>? id,
    Value<int>? predmetId,
    Value<int?>? iriuId,
    Value<String>? kategorija,
    Value<String>? stableArticleId,
    Value<double>? effectQuantity,
    Value<String>? effectStatus,
    Value<String>? effectReason,
    Value<String>? datumKreiranja,
    Value<String>? datumAzuriranja,
  }) {
    return StanjeRobeAppliedEffectsCompanion(
      id: id ?? this.id,
      predmetId: predmetId ?? this.predmetId,
      iriuId: iriuId ?? this.iriuId,
      kategorija: kategorija ?? this.kategorija,
      stableArticleId: stableArticleId ?? this.stableArticleId,
      effectQuantity: effectQuantity ?? this.effectQuantity,
      effectStatus: effectStatus ?? this.effectStatus,
      effectReason: effectReason ?? this.effectReason,
      datumKreiranja: datumKreiranja ?? this.datumKreiranja,
      datumAzuriranja: datumAzuriranja ?? this.datumAzuriranja,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predmetId.present) {
      map['predmet_id'] = Variable<int>(predmetId.value);
    }
    if (iriuId.present) {
      map['iriu_id'] = Variable<int>(iriuId.value);
    }
    if (kategorija.present) {
      map['kategorija'] = Variable<String>(kategorija.value);
    }
    if (stableArticleId.present) {
      map['stable_article_id'] = Variable<String>(stableArticleId.value);
    }
    if (effectQuantity.present) {
      map['effect_quantity'] = Variable<double>(effectQuantity.value);
    }
    if (effectStatus.present) {
      map['effect_status'] = Variable<String>(effectStatus.value);
    }
    if (effectReason.present) {
      map['effect_reason'] = Variable<String>(effectReason.value);
    }
    if (datumKreiranja.present) {
      map['datum_kreiranja'] = Variable<String>(datumKreiranja.value);
    }
    if (datumAzuriranja.present) {
      map['datum_azuriranja'] = Variable<String>(datumAzuriranja.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StanjeRobeAppliedEffectsCompanion(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('iriuId: $iriuId, ')
          ..write('kategorija: $kategorija, ')
          ..write('stableArticleId: $stableArticleId, ')
          ..write('effectQuantity: $effectQuantity, ')
          ..write('effectStatus: $effectStatus, ')
          ..write('effectReason: $effectReason, ')
          ..write('datumKreiranja: $datumKreiranja, ')
          ..write('datumAzuriranja: $datumAzuriranja')
          ..write(')'))
        .toString();
  }
}

class $StanjeRobePoslediceTable extends StanjeRobePosledice
    with TableInfo<$StanjeRobePoslediceTable, StanjeRobePoslediceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StanjeRobePoslediceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predmetIdMeta = const VerificationMeta(
    'predmetId',
  );
  @override
  late final GeneratedColumn<int> predmetId = GeneratedColumn<int>(
    'predmet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES predmeti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _iriuIdMeta = const VerificationMeta('iriuId');
  @override
  late final GeneratedColumn<int> iriuId = GeneratedColumn<int>(
    'iriu_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES iriu (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kategorijaMeta = const VerificationMeta(
    'kategorija',
  );
  @override
  late final GeneratedColumn<String> kategorija = GeneratedColumn<String>(
    'kategorija',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _katalogStableArticleIdMeta =
      const VerificationMeta('katalogStableArticleId');
  @override
  late final GeneratedColumn<String> katalogStableArticleId =
      GeneratedColumn<String>(
        'katalog_stable_article_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _selectedNazivSnapshotMeta =
      const VerificationMeta('selectedNazivSnapshot');
  @override
  late final GeneratedColumn<String> selectedNazivSnapshot =
      GeneratedColumn<String>(
        'selected_naziv_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _selectedIznosSnapshotMeta =
      const VerificationMeta('selectedIznosSnapshot');
  @override
  late final GeneratedColumn<double> selectedIznosSnapshot =
      GeneratedColumn<double>(
        'selected_iznos_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _consequenceTypeMeta = const VerificationMeta(
    'consequenceType',
  );
  @override
  late final GeneratedColumn<String> consequenceType = GeneratedColumn<String>(
    'consequence_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<String> resolvedAt = GeneratedColumn<String>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedReasonMeta = const VerificationMeta(
    'resolvedReason',
  );
  @override
  late final GeneratedColumn<String> resolvedReason = GeneratedColumn<String>(
    'resolved_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceLifecycleEventMeta =
      const VerificationMeta('sourceLifecycleEvent');
  @override
  late final GeneratedColumn<String> sourceLifecycleEvent =
      GeneratedColumn<String>(
        'source_lifecycle_event',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _effectQuantityMeta = const VerificationMeta(
    'effectQuantity',
  );
  @override
  late final GeneratedColumn<double> effectQuantity = GeneratedColumn<double>(
    'effect_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _availableQuantityAtCreationMeta =
      const VerificationMeta('availableQuantityAtCreation');
  @override
  late final GeneratedColumn<double> availableQuantityAtCreation =
      GeneratedColumn<double>(
        'available_quantity_at_creation',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shortageQuantityAtCreationMeta =
      const VerificationMeta('shortageQuantityAtCreation');
  @override
  late final GeneratedColumn<double> shortageQuantityAtCreation =
      GeneratedColumn<double>(
        'shortage_quantity_at_creation',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predmetId,
    iriuId,
    kategorija,
    katalogStableArticleId,
    selectedNazivSnapshot,
    selectedIznosSnapshot,
    consequenceType,
    status,
    createdAt,
    updatedAt,
    resolvedAt,
    resolvedReason,
    sourceLifecycleEvent,
    effectQuantity,
    availableQuantityAtCreation,
    shortageQuantityAtCreation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stanje_robe_posledice';
  @override
  VerificationContext validateIntegrity(
    Insertable<StanjeRobePoslediceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predmet_id')) {
      context.handle(
        _predmetIdMeta,
        predmetId.isAcceptableOrUnknown(data['predmet_id']!, _predmetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_predmetIdMeta);
    }
    if (data.containsKey('iriu_id')) {
      context.handle(
        _iriuIdMeta,
        iriuId.isAcceptableOrUnknown(data['iriu_id']!, _iriuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_iriuIdMeta);
    }
    if (data.containsKey('kategorija')) {
      context.handle(
        _kategorijaMeta,
        kategorija.isAcceptableOrUnknown(data['kategorija']!, _kategorijaMeta),
      );
    } else if (isInserting) {
      context.missing(_kategorijaMeta);
    }
    if (data.containsKey('katalog_stable_article_id')) {
      context.handle(
        _katalogStableArticleIdMeta,
        katalogStableArticleId.isAcceptableOrUnknown(
          data['katalog_stable_article_id']!,
          _katalogStableArticleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_katalogStableArticleIdMeta);
    }
    if (data.containsKey('selected_naziv_snapshot')) {
      context.handle(
        _selectedNazivSnapshotMeta,
        selectedNazivSnapshot.isAcceptableOrUnknown(
          data['selected_naziv_snapshot']!,
          _selectedNazivSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedNazivSnapshotMeta);
    }
    if (data.containsKey('selected_iznos_snapshot')) {
      context.handle(
        _selectedIznosSnapshotMeta,
        selectedIznosSnapshot.isAcceptableOrUnknown(
          data['selected_iznos_snapshot']!,
          _selectedIznosSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('consequence_type')) {
      context.handle(
        _consequenceTypeMeta,
        consequenceType.isAcceptableOrUnknown(
          data['consequence_type']!,
          _consequenceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consequenceTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolved_reason')) {
      context.handle(
        _resolvedReasonMeta,
        resolvedReason.isAcceptableOrUnknown(
          data['resolved_reason']!,
          _resolvedReasonMeta,
        ),
      );
    }
    if (data.containsKey('source_lifecycle_event')) {
      context.handle(
        _sourceLifecycleEventMeta,
        sourceLifecycleEvent.isAcceptableOrUnknown(
          data['source_lifecycle_event']!,
          _sourceLifecycleEventMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLifecycleEventMeta);
    }
    if (data.containsKey('effect_quantity')) {
      context.handle(
        _effectQuantityMeta,
        effectQuantity.isAcceptableOrUnknown(
          data['effect_quantity']!,
          _effectQuantityMeta,
        ),
      );
    }
    if (data.containsKey('available_quantity_at_creation')) {
      context.handle(
        _availableQuantityAtCreationMeta,
        availableQuantityAtCreation.isAcceptableOrUnknown(
          data['available_quantity_at_creation']!,
          _availableQuantityAtCreationMeta,
        ),
      );
    }
    if (data.containsKey('shortage_quantity_at_creation')) {
      context.handle(
        _shortageQuantityAtCreationMeta,
        shortageQuantityAtCreation.isAcceptableOrUnknown(
          data['shortage_quantity_at_creation']!,
          _shortageQuantityAtCreationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StanjeRobePoslediceData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StanjeRobePoslediceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predmetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predmet_id'],
      )!,
      iriuId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iriu_id'],
      )!,
      kategorija: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategorija'],
      )!,
      katalogStableArticleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}katalog_stable_article_id'],
      )!,
      selectedNazivSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_naziv_snapshot'],
      )!,
      selectedIznosSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selected_iznos_snapshot'],
      )!,
      consequenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consequence_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_at'],
      ),
      resolvedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_reason'],
      ),
      sourceLifecycleEvent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_lifecycle_event'],
      )!,
      effectQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}effect_quantity'],
      )!,
      availableQuantityAtCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}available_quantity_at_creation'],
      ),
      shortageQuantityAtCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shortage_quantity_at_creation'],
      ),
    );
  }

  @override
  $StanjeRobePoslediceTable createAlias(String alias) {
    return $StanjeRobePoslediceTable(attachedDatabase, alias);
  }
}

class StanjeRobePoslediceData extends DataClass
    implements Insertable<StanjeRobePoslediceData> {
  final int id;
  final int predmetId;
  final int iriuId;
  final String kategorija;
  final String katalogStableArticleId;
  final String selectedNazivSnapshot;
  final double selectedIznosSnapshot;
  final String consequenceType;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? resolvedAt;
  final String? resolvedReason;
  final String sourceLifecycleEvent;
  final double effectQuantity;
  final double? availableQuantityAtCreation;
  final double? shortageQuantityAtCreation;
  const StanjeRobePoslediceData({
    required this.id,
    required this.predmetId,
    required this.iriuId,
    required this.kategorija,
    required this.katalogStableArticleId,
    required this.selectedNazivSnapshot,
    required this.selectedIznosSnapshot,
    required this.consequenceType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolvedReason,
    required this.sourceLifecycleEvent,
    required this.effectQuantity,
    this.availableQuantityAtCreation,
    this.shortageQuantityAtCreation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predmet_id'] = Variable<int>(predmetId);
    map['iriu_id'] = Variable<int>(iriuId);
    map['kategorija'] = Variable<String>(kategorija);
    map['katalog_stable_article_id'] = Variable<String>(katalogStableArticleId);
    map['selected_naziv_snapshot'] = Variable<String>(selectedNazivSnapshot);
    map['selected_iznos_snapshot'] = Variable<double>(selectedIznosSnapshot);
    map['consequence_type'] = Variable<String>(consequenceType);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<String>(resolvedAt);
    }
    if (!nullToAbsent || resolvedReason != null) {
      map['resolved_reason'] = Variable<String>(resolvedReason);
    }
    map['source_lifecycle_event'] = Variable<String>(sourceLifecycleEvent);
    map['effect_quantity'] = Variable<double>(effectQuantity);
    if (!nullToAbsent || availableQuantityAtCreation != null) {
      map['available_quantity_at_creation'] = Variable<double>(
        availableQuantityAtCreation,
      );
    }
    if (!nullToAbsent || shortageQuantityAtCreation != null) {
      map['shortage_quantity_at_creation'] = Variable<double>(
        shortageQuantityAtCreation,
      );
    }
    return map;
  }

  StanjeRobePoslediceCompanion toCompanion(bool nullToAbsent) {
    return StanjeRobePoslediceCompanion(
      id: Value(id),
      predmetId: Value(predmetId),
      iriuId: Value(iriuId),
      kategorija: Value(kategorija),
      katalogStableArticleId: Value(katalogStableArticleId),
      selectedNazivSnapshot: Value(selectedNazivSnapshot),
      selectedIznosSnapshot: Value(selectedIznosSnapshot),
      consequenceType: Value(consequenceType),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolvedReason: resolvedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedReason),
      sourceLifecycleEvent: Value(sourceLifecycleEvent),
      effectQuantity: Value(effectQuantity),
      availableQuantityAtCreation:
          availableQuantityAtCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(availableQuantityAtCreation),
      shortageQuantityAtCreation:
          shortageQuantityAtCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(shortageQuantityAtCreation),
    );
  }

  factory StanjeRobePoslediceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StanjeRobePoslediceData(
      id: serializer.fromJson<int>(json['id']),
      predmetId: serializer.fromJson<int>(json['predmetId']),
      iriuId: serializer.fromJson<int>(json['iriuId']),
      kategorija: serializer.fromJson<String>(json['kategorija']),
      katalogStableArticleId: serializer.fromJson<String>(
        json['katalogStableArticleId'],
      ),
      selectedNazivSnapshot: serializer.fromJson<String>(
        json['selectedNazivSnapshot'],
      ),
      selectedIznosSnapshot: serializer.fromJson<double>(
        json['selectedIznosSnapshot'],
      ),
      consequenceType: serializer.fromJson<String>(json['consequenceType']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      resolvedAt: serializer.fromJson<String?>(json['resolvedAt']),
      resolvedReason: serializer.fromJson<String?>(json['resolvedReason']),
      sourceLifecycleEvent: serializer.fromJson<String>(
        json['sourceLifecycleEvent'],
      ),
      effectQuantity: serializer.fromJson<double>(json['effectQuantity']),
      availableQuantityAtCreation: serializer.fromJson<double?>(
        json['availableQuantityAtCreation'],
      ),
      shortageQuantityAtCreation: serializer.fromJson<double?>(
        json['shortageQuantityAtCreation'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predmetId': serializer.toJson<int>(predmetId),
      'iriuId': serializer.toJson<int>(iriuId),
      'kategorija': serializer.toJson<String>(kategorija),
      'katalogStableArticleId': serializer.toJson<String>(
        katalogStableArticleId,
      ),
      'selectedNazivSnapshot': serializer.toJson<String>(selectedNazivSnapshot),
      'selectedIznosSnapshot': serializer.toJson<double>(selectedIznosSnapshot),
      'consequenceType': serializer.toJson<String>(consequenceType),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'resolvedAt': serializer.toJson<String?>(resolvedAt),
      'resolvedReason': serializer.toJson<String?>(resolvedReason),
      'sourceLifecycleEvent': serializer.toJson<String>(sourceLifecycleEvent),
      'effectQuantity': serializer.toJson<double>(effectQuantity),
      'availableQuantityAtCreation': serializer.toJson<double?>(
        availableQuantityAtCreation,
      ),
      'shortageQuantityAtCreation': serializer.toJson<double?>(
        shortageQuantityAtCreation,
      ),
    };
  }

  StanjeRobePoslediceData copyWith({
    int? id,
    int? predmetId,
    int? iriuId,
    String? kategorija,
    String? katalogStableArticleId,
    String? selectedNazivSnapshot,
    double? selectedIznosSnapshot,
    String? consequenceType,
    String? status,
    String? createdAt,
    String? updatedAt,
    Value<String?> resolvedAt = const Value.absent(),
    Value<String?> resolvedReason = const Value.absent(),
    String? sourceLifecycleEvent,
    double? effectQuantity,
    Value<double?> availableQuantityAtCreation = const Value.absent(),
    Value<double?> shortageQuantityAtCreation = const Value.absent(),
  }) => StanjeRobePoslediceData(
    id: id ?? this.id,
    predmetId: predmetId ?? this.predmetId,
    iriuId: iriuId ?? this.iriuId,
    kategorija: kategorija ?? this.kategorija,
    katalogStableArticleId:
        katalogStableArticleId ?? this.katalogStableArticleId,
    selectedNazivSnapshot: selectedNazivSnapshot ?? this.selectedNazivSnapshot,
    selectedIznosSnapshot: selectedIznosSnapshot ?? this.selectedIznosSnapshot,
    consequenceType: consequenceType ?? this.consequenceType,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolvedReason: resolvedReason.present
        ? resolvedReason.value
        : this.resolvedReason,
    sourceLifecycleEvent: sourceLifecycleEvent ?? this.sourceLifecycleEvent,
    effectQuantity: effectQuantity ?? this.effectQuantity,
    availableQuantityAtCreation: availableQuantityAtCreation.present
        ? availableQuantityAtCreation.value
        : this.availableQuantityAtCreation,
    shortageQuantityAtCreation: shortageQuantityAtCreation.present
        ? shortageQuantityAtCreation.value
        : this.shortageQuantityAtCreation,
  );
  StanjeRobePoslediceData copyWithCompanion(StanjeRobePoslediceCompanion data) {
    return StanjeRobePoslediceData(
      id: data.id.present ? data.id.value : this.id,
      predmetId: data.predmetId.present ? data.predmetId.value : this.predmetId,
      iriuId: data.iriuId.present ? data.iriuId.value : this.iriuId,
      kategorija: data.kategorija.present
          ? data.kategorija.value
          : this.kategorija,
      katalogStableArticleId: data.katalogStableArticleId.present
          ? data.katalogStableArticleId.value
          : this.katalogStableArticleId,
      selectedNazivSnapshot: data.selectedNazivSnapshot.present
          ? data.selectedNazivSnapshot.value
          : this.selectedNazivSnapshot,
      selectedIznosSnapshot: data.selectedIznosSnapshot.present
          ? data.selectedIznosSnapshot.value
          : this.selectedIznosSnapshot,
      consequenceType: data.consequenceType.present
          ? data.consequenceType.value
          : this.consequenceType,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolvedReason: data.resolvedReason.present
          ? data.resolvedReason.value
          : this.resolvedReason,
      sourceLifecycleEvent: data.sourceLifecycleEvent.present
          ? data.sourceLifecycleEvent.value
          : this.sourceLifecycleEvent,
      effectQuantity: data.effectQuantity.present
          ? data.effectQuantity.value
          : this.effectQuantity,
      availableQuantityAtCreation: data.availableQuantityAtCreation.present
          ? data.availableQuantityAtCreation.value
          : this.availableQuantityAtCreation,
      shortageQuantityAtCreation: data.shortageQuantityAtCreation.present
          ? data.shortageQuantityAtCreation.value
          : this.shortageQuantityAtCreation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StanjeRobePoslediceData(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('iriuId: $iriuId, ')
          ..write('kategorija: $kategorija, ')
          ..write('katalogStableArticleId: $katalogStableArticleId, ')
          ..write('selectedNazivSnapshot: $selectedNazivSnapshot, ')
          ..write('selectedIznosSnapshot: $selectedIznosSnapshot, ')
          ..write('consequenceType: $consequenceType, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedReason: $resolvedReason, ')
          ..write('sourceLifecycleEvent: $sourceLifecycleEvent, ')
          ..write('effectQuantity: $effectQuantity, ')
          ..write('availableQuantityAtCreation: $availableQuantityAtCreation, ')
          ..write('shortageQuantityAtCreation: $shortageQuantityAtCreation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predmetId,
    iriuId,
    kategorija,
    katalogStableArticleId,
    selectedNazivSnapshot,
    selectedIznosSnapshot,
    consequenceType,
    status,
    createdAt,
    updatedAt,
    resolvedAt,
    resolvedReason,
    sourceLifecycleEvent,
    effectQuantity,
    availableQuantityAtCreation,
    shortageQuantityAtCreation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StanjeRobePoslediceData &&
          other.id == this.id &&
          other.predmetId == this.predmetId &&
          other.iriuId == this.iriuId &&
          other.kategorija == this.kategorija &&
          other.katalogStableArticleId == this.katalogStableArticleId &&
          other.selectedNazivSnapshot == this.selectedNazivSnapshot &&
          other.selectedIznosSnapshot == this.selectedIznosSnapshot &&
          other.consequenceType == this.consequenceType &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolvedReason == this.resolvedReason &&
          other.sourceLifecycleEvent == this.sourceLifecycleEvent &&
          other.effectQuantity == this.effectQuantity &&
          other.availableQuantityAtCreation ==
              this.availableQuantityAtCreation &&
          other.shortageQuantityAtCreation == this.shortageQuantityAtCreation);
}

class StanjeRobePoslediceCompanion
    extends UpdateCompanion<StanjeRobePoslediceData> {
  final Value<int> id;
  final Value<int> predmetId;
  final Value<int> iriuId;
  final Value<String> kategorija;
  final Value<String> katalogStableArticleId;
  final Value<String> selectedNazivSnapshot;
  final Value<double> selectedIznosSnapshot;
  final Value<String> consequenceType;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> resolvedAt;
  final Value<String?> resolvedReason;
  final Value<String> sourceLifecycleEvent;
  final Value<double> effectQuantity;
  final Value<double?> availableQuantityAtCreation;
  final Value<double?> shortageQuantityAtCreation;
  const StanjeRobePoslediceCompanion({
    this.id = const Value.absent(),
    this.predmetId = const Value.absent(),
    this.iriuId = const Value.absent(),
    this.kategorija = const Value.absent(),
    this.katalogStableArticleId = const Value.absent(),
    this.selectedNazivSnapshot = const Value.absent(),
    this.selectedIznosSnapshot = const Value.absent(),
    this.consequenceType = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolvedReason = const Value.absent(),
    this.sourceLifecycleEvent = const Value.absent(),
    this.effectQuantity = const Value.absent(),
    this.availableQuantityAtCreation = const Value.absent(),
    this.shortageQuantityAtCreation = const Value.absent(),
  });
  StanjeRobePoslediceCompanion.insert({
    this.id = const Value.absent(),
    required int predmetId,
    required int iriuId,
    required String kategorija,
    required String katalogStableArticleId,
    required String selectedNazivSnapshot,
    this.selectedIznosSnapshot = const Value.absent(),
    required String consequenceType,
    required String status,
    required String createdAt,
    required String updatedAt,
    this.resolvedAt = const Value.absent(),
    this.resolvedReason = const Value.absent(),
    required String sourceLifecycleEvent,
    this.effectQuantity = const Value.absent(),
    this.availableQuantityAtCreation = const Value.absent(),
    this.shortageQuantityAtCreation = const Value.absent(),
  }) : predmetId = Value(predmetId),
       iriuId = Value(iriuId),
       kategorija = Value(kategorija),
       katalogStableArticleId = Value(katalogStableArticleId),
       selectedNazivSnapshot = Value(selectedNazivSnapshot),
       consequenceType = Value(consequenceType),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       sourceLifecycleEvent = Value(sourceLifecycleEvent);
  static Insertable<StanjeRobePoslediceData> custom({
    Expression<int>? id,
    Expression<int>? predmetId,
    Expression<int>? iriuId,
    Expression<String>? kategorija,
    Expression<String>? katalogStableArticleId,
    Expression<String>? selectedNazivSnapshot,
    Expression<double>? selectedIznosSnapshot,
    Expression<String>? consequenceType,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? resolvedAt,
    Expression<String>? resolvedReason,
    Expression<String>? sourceLifecycleEvent,
    Expression<double>? effectQuantity,
    Expression<double>? availableQuantityAtCreation,
    Expression<double>? shortageQuantityAtCreation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predmetId != null) 'predmet_id': predmetId,
      if (iriuId != null) 'iriu_id': iriuId,
      if (kategorija != null) 'kategorija': kategorija,
      if (katalogStableArticleId != null)
        'katalog_stable_article_id': katalogStableArticleId,
      if (selectedNazivSnapshot != null)
        'selected_naziv_snapshot': selectedNazivSnapshot,
      if (selectedIznosSnapshot != null)
        'selected_iznos_snapshot': selectedIznosSnapshot,
      if (consequenceType != null) 'consequence_type': consequenceType,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolvedReason != null) 'resolved_reason': resolvedReason,
      if (sourceLifecycleEvent != null)
        'source_lifecycle_event': sourceLifecycleEvent,
      if (effectQuantity != null) 'effect_quantity': effectQuantity,
      if (availableQuantityAtCreation != null)
        'available_quantity_at_creation': availableQuantityAtCreation,
      if (shortageQuantityAtCreation != null)
        'shortage_quantity_at_creation': shortageQuantityAtCreation,
    });
  }

  StanjeRobePoslediceCompanion copyWith({
    Value<int>? id,
    Value<int>? predmetId,
    Value<int>? iriuId,
    Value<String>? kategorija,
    Value<String>? katalogStableArticleId,
    Value<String>? selectedNazivSnapshot,
    Value<double>? selectedIznosSnapshot,
    Value<String>? consequenceType,
    Value<String>? status,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? resolvedAt,
    Value<String?>? resolvedReason,
    Value<String>? sourceLifecycleEvent,
    Value<double>? effectQuantity,
    Value<double?>? availableQuantityAtCreation,
    Value<double?>? shortageQuantityAtCreation,
  }) {
    return StanjeRobePoslediceCompanion(
      id: id ?? this.id,
      predmetId: predmetId ?? this.predmetId,
      iriuId: iriuId ?? this.iriuId,
      kategorija: kategorija ?? this.kategorija,
      katalogStableArticleId:
          katalogStableArticleId ?? this.katalogStableArticleId,
      selectedNazivSnapshot:
          selectedNazivSnapshot ?? this.selectedNazivSnapshot,
      selectedIznosSnapshot:
          selectedIznosSnapshot ?? this.selectedIznosSnapshot,
      consequenceType: consequenceType ?? this.consequenceType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedReason: resolvedReason ?? this.resolvedReason,
      sourceLifecycleEvent: sourceLifecycleEvent ?? this.sourceLifecycleEvent,
      effectQuantity: effectQuantity ?? this.effectQuantity,
      availableQuantityAtCreation:
          availableQuantityAtCreation ?? this.availableQuantityAtCreation,
      shortageQuantityAtCreation:
          shortageQuantityAtCreation ?? this.shortageQuantityAtCreation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predmetId.present) {
      map['predmet_id'] = Variable<int>(predmetId.value);
    }
    if (iriuId.present) {
      map['iriu_id'] = Variable<int>(iriuId.value);
    }
    if (kategorija.present) {
      map['kategorija'] = Variable<String>(kategorija.value);
    }
    if (katalogStableArticleId.present) {
      map['katalog_stable_article_id'] = Variable<String>(
        katalogStableArticleId.value,
      );
    }
    if (selectedNazivSnapshot.present) {
      map['selected_naziv_snapshot'] = Variable<String>(
        selectedNazivSnapshot.value,
      );
    }
    if (selectedIznosSnapshot.present) {
      map['selected_iznos_snapshot'] = Variable<double>(
        selectedIznosSnapshot.value,
      );
    }
    if (consequenceType.present) {
      map['consequence_type'] = Variable<String>(consequenceType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<String>(resolvedAt.value);
    }
    if (resolvedReason.present) {
      map['resolved_reason'] = Variable<String>(resolvedReason.value);
    }
    if (sourceLifecycleEvent.present) {
      map['source_lifecycle_event'] = Variable<String>(
        sourceLifecycleEvent.value,
      );
    }
    if (effectQuantity.present) {
      map['effect_quantity'] = Variable<double>(effectQuantity.value);
    }
    if (availableQuantityAtCreation.present) {
      map['available_quantity_at_creation'] = Variable<double>(
        availableQuantityAtCreation.value,
      );
    }
    if (shortageQuantityAtCreation.present) {
      map['shortage_quantity_at_creation'] = Variable<double>(
        shortageQuantityAtCreation.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StanjeRobePoslediceCompanion(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('iriuId: $iriuId, ')
          ..write('kategorija: $kategorija, ')
          ..write('katalogStableArticleId: $katalogStableArticleId, ')
          ..write('selectedNazivSnapshot: $selectedNazivSnapshot, ')
          ..write('selectedIznosSnapshot: $selectedIznosSnapshot, ')
          ..write('consequenceType: $consequenceType, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedReason: $resolvedReason, ')
          ..write('sourceLifecycleEvent: $sourceLifecycleEvent, ')
          ..write('effectQuantity: $effectQuantity, ')
          ..write('availableQuantityAtCreation: $availableQuantityAtCreation, ')
          ..write('shortageQuantityAtCreation: $shortageQuantityAtCreation')
          ..write(')'))
        .toString();
  }
}

class $PredlosciDokumenataTable extends PredlosciDokumenata
    with TableInfo<$PredlosciDokumenataTable, PredlosciDokumenataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredlosciDokumenataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nazivMeta = const VerificationMeta('naziv');
  @override
  late final GeneratedColumn<String> naziv = GeneratedColumn<String>(
    'naziv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentiMeta = const VerificationMeta(
    'segmenti',
  );
  @override
  late final GeneratedColumn<String> segmenti = GeneratedColumn<String>(
    'segmenti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PDF'),
  );
  static const VerificationMeta _predefinisanMeta = const VerificationMeta(
    'predefinisan',
  );
  @override
  late final GeneratedColumn<bool> predefinisan = GeneratedColumn<bool>(
    'predefinisan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("predefinisan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _napomeneUkljuceneMeta = const VerificationMeta(
    'napomeneUkljucene',
  );
  @override
  late final GeneratedColumn<bool> napomeneUkljucene = GeneratedColumn<bool>(
    'napomene_ukljucene',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("napomene_ukljucene" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _zakljucanMeta = const VerificationMeta(
    'zakljucan',
  );
  @override
  late final GeneratedColumn<bool> zakljucan = GeneratedColumn<bool>(
    'zakljucan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("zakljucan" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    naziv,
    segmenti,
    format,
    predefinisan,
    napomeneUkljucene,
    zakljucan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predlosci_dokumenata';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredlosciDokumenataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('naziv')) {
      context.handle(
        _nazivMeta,
        naziv.isAcceptableOrUnknown(data['naziv']!, _nazivMeta),
      );
    } else if (isInserting) {
      context.missing(_nazivMeta);
    }
    if (data.containsKey('segmenti')) {
      context.handle(
        _segmentiMeta,
        segmenti.isAcceptableOrUnknown(data['segmenti']!, _segmentiMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('predefinisan')) {
      context.handle(
        _predefinisanMeta,
        predefinisan.isAcceptableOrUnknown(
          data['predefinisan']!,
          _predefinisanMeta,
        ),
      );
    }
    if (data.containsKey('napomene_ukljucene')) {
      context.handle(
        _napomeneUkljuceneMeta,
        napomeneUkljucene.isAcceptableOrUnknown(
          data['napomene_ukljucene']!,
          _napomeneUkljuceneMeta,
        ),
      );
    }
    if (data.containsKey('zakljucan')) {
      context.handle(
        _zakljucanMeta,
        zakljucan.isAcceptableOrUnknown(data['zakljucan']!, _zakljucanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredlosciDokumenataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredlosciDokumenataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      naziv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naziv'],
      )!,
      segmenti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segmenti'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      predefinisan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}predefinisan'],
      )!,
      napomeneUkljucene: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}napomene_ukljucene'],
      )!,
      zakljucan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}zakljucan'],
      )!,
    );
  }

  @override
  $PredlosciDokumenataTable createAlias(String alias) {
    return $PredlosciDokumenataTable(attachedDatabase, alias);
  }
}

class PredlosciDokumenataData extends DataClass
    implements Insertable<PredlosciDokumenataData> {
  final int id;
  final String naziv;

  /// JSON lista segmenata: ["PREMINULO_LICE","NARUCILAC","CEREMONIJA","PARTE","IRIU","FINANSIJE"]
  final String segmenti;
  final String format;
  final bool predefinisan;
  final bool napomeneUkljucene;

  /// true = ne može da se briše niti menja (samo BELEŽNICA)
  final bool zakljucan;
  const PredlosciDokumenataData({
    required this.id,
    required this.naziv,
    required this.segmenti,
    required this.format,
    required this.predefinisan,
    required this.napomeneUkljucene,
    required this.zakljucan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['naziv'] = Variable<String>(naziv);
    map['segmenti'] = Variable<String>(segmenti);
    map['format'] = Variable<String>(format);
    map['predefinisan'] = Variable<bool>(predefinisan);
    map['napomene_ukljucene'] = Variable<bool>(napomeneUkljucene);
    map['zakljucan'] = Variable<bool>(zakljucan);
    return map;
  }

  PredlosciDokumenataCompanion toCompanion(bool nullToAbsent) {
    return PredlosciDokumenataCompanion(
      id: Value(id),
      naziv: Value(naziv),
      segmenti: Value(segmenti),
      format: Value(format),
      predefinisan: Value(predefinisan),
      napomeneUkljucene: Value(napomeneUkljucene),
      zakljucan: Value(zakljucan),
    );
  }

  factory PredlosciDokumenataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredlosciDokumenataData(
      id: serializer.fromJson<int>(json['id']),
      naziv: serializer.fromJson<String>(json['naziv']),
      segmenti: serializer.fromJson<String>(json['segmenti']),
      format: serializer.fromJson<String>(json['format']),
      predefinisan: serializer.fromJson<bool>(json['predefinisan']),
      napomeneUkljucene: serializer.fromJson<bool>(json['napomeneUkljucene']),
      zakljucan: serializer.fromJson<bool>(json['zakljucan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'naziv': serializer.toJson<String>(naziv),
      'segmenti': serializer.toJson<String>(segmenti),
      'format': serializer.toJson<String>(format),
      'predefinisan': serializer.toJson<bool>(predefinisan),
      'napomeneUkljucene': serializer.toJson<bool>(napomeneUkljucene),
      'zakljucan': serializer.toJson<bool>(zakljucan),
    };
  }

  PredlosciDokumenataData copyWith({
    int? id,
    String? naziv,
    String? segmenti,
    String? format,
    bool? predefinisan,
    bool? napomeneUkljucene,
    bool? zakljucan,
  }) => PredlosciDokumenataData(
    id: id ?? this.id,
    naziv: naziv ?? this.naziv,
    segmenti: segmenti ?? this.segmenti,
    format: format ?? this.format,
    predefinisan: predefinisan ?? this.predefinisan,
    napomeneUkljucene: napomeneUkljucene ?? this.napomeneUkljucene,
    zakljucan: zakljucan ?? this.zakljucan,
  );
  PredlosciDokumenataData copyWithCompanion(PredlosciDokumenataCompanion data) {
    return PredlosciDokumenataData(
      id: data.id.present ? data.id.value : this.id,
      naziv: data.naziv.present ? data.naziv.value : this.naziv,
      segmenti: data.segmenti.present ? data.segmenti.value : this.segmenti,
      format: data.format.present ? data.format.value : this.format,
      predefinisan: data.predefinisan.present
          ? data.predefinisan.value
          : this.predefinisan,
      napomeneUkljucene: data.napomeneUkljucene.present
          ? data.napomeneUkljucene.value
          : this.napomeneUkljucene,
      zakljucan: data.zakljucan.present ? data.zakljucan.value : this.zakljucan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredlosciDokumenataData(')
          ..write('id: $id, ')
          ..write('naziv: $naziv, ')
          ..write('segmenti: $segmenti, ')
          ..write('format: $format, ')
          ..write('predefinisan: $predefinisan, ')
          ..write('napomeneUkljucene: $napomeneUkljucene, ')
          ..write('zakljucan: $zakljucan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    naziv,
    segmenti,
    format,
    predefinisan,
    napomeneUkljucene,
    zakljucan,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredlosciDokumenataData &&
          other.id == this.id &&
          other.naziv == this.naziv &&
          other.segmenti == this.segmenti &&
          other.format == this.format &&
          other.predefinisan == this.predefinisan &&
          other.napomeneUkljucene == this.napomeneUkljucene &&
          other.zakljucan == this.zakljucan);
}

class PredlosciDokumenataCompanion
    extends UpdateCompanion<PredlosciDokumenataData> {
  final Value<int> id;
  final Value<String> naziv;
  final Value<String> segmenti;
  final Value<String> format;
  final Value<bool> predefinisan;
  final Value<bool> napomeneUkljucene;
  final Value<bool> zakljucan;
  const PredlosciDokumenataCompanion({
    this.id = const Value.absent(),
    this.naziv = const Value.absent(),
    this.segmenti = const Value.absent(),
    this.format = const Value.absent(),
    this.predefinisan = const Value.absent(),
    this.napomeneUkljucene = const Value.absent(),
    this.zakljucan = const Value.absent(),
  });
  PredlosciDokumenataCompanion.insert({
    this.id = const Value.absent(),
    required String naziv,
    this.segmenti = const Value.absent(),
    this.format = const Value.absent(),
    this.predefinisan = const Value.absent(),
    this.napomeneUkljucene = const Value.absent(),
    this.zakljucan = const Value.absent(),
  }) : naziv = Value(naziv);
  static Insertable<PredlosciDokumenataData> custom({
    Expression<int>? id,
    Expression<String>? naziv,
    Expression<String>? segmenti,
    Expression<String>? format,
    Expression<bool>? predefinisan,
    Expression<bool>? napomeneUkljucene,
    Expression<bool>? zakljucan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (naziv != null) 'naziv': naziv,
      if (segmenti != null) 'segmenti': segmenti,
      if (format != null) 'format': format,
      if (predefinisan != null) 'predefinisan': predefinisan,
      if (napomeneUkljucene != null) 'napomene_ukljucene': napomeneUkljucene,
      if (zakljucan != null) 'zakljucan': zakljucan,
    });
  }

  PredlosciDokumenataCompanion copyWith({
    Value<int>? id,
    Value<String>? naziv,
    Value<String>? segmenti,
    Value<String>? format,
    Value<bool>? predefinisan,
    Value<bool>? napomeneUkljucene,
    Value<bool>? zakljucan,
  }) {
    return PredlosciDokumenataCompanion(
      id: id ?? this.id,
      naziv: naziv ?? this.naziv,
      segmenti: segmenti ?? this.segmenti,
      format: format ?? this.format,
      predefinisan: predefinisan ?? this.predefinisan,
      napomeneUkljucene: napomeneUkljucene ?? this.napomeneUkljucene,
      zakljucan: zakljucan ?? this.zakljucan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (naziv.present) {
      map['naziv'] = Variable<String>(naziv.value);
    }
    if (segmenti.present) {
      map['segmenti'] = Variable<String>(segmenti.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (predefinisan.present) {
      map['predefinisan'] = Variable<bool>(predefinisan.value);
    }
    if (napomeneUkljucene.present) {
      map['napomene_ukljucene'] = Variable<bool>(napomeneUkljucene.value);
    }
    if (zakljucan.present) {
      map['zakljucan'] = Variable<bool>(zakljucan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredlosciDokumenataCompanion(')
          ..write('id: $id, ')
          ..write('naziv: $naziv, ')
          ..write('segmenti: $segmenti, ')
          ..write('format: $format, ')
          ..write('predefinisan: $predefinisan, ')
          ..write('napomeneUkljucene: $napomeneUkljucene, ')
          ..write('zakljucan: $zakljucan')
          ..write(')'))
        .toString();
  }
}

class $LogIzmenaTable extends LogIzmena
    with TableInfo<$LogIzmenaTable, LogIzmenaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogIzmenaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predmetIdMeta = const VerificationMeta(
    'predmetId',
  );
  @override
  late final GeneratedColumn<int> predmetId = GeneratedColumn<int>(
    'predmet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES predmeti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _korisnikIdMeta = const VerificationMeta(
    'korisnikId',
  );
  @override
  late final GeneratedColumn<int> korisnikId = GeneratedColumn<int>(
    'korisnik_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datumVremeMeta = const VerificationMeta(
    'datumVreme',
  );
  @override
  late final GeneratedColumn<String> datumVreme = GeneratedColumn<String>(
    'datum_vreme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poljeMeta = const VerificationMeta('polje');
  @override
  late final GeneratedColumn<String> polje = GeneratedColumn<String>(
    'polje',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staraVrednostMeta = const VerificationMeta(
    'staraVrednost',
  );
  @override
  late final GeneratedColumn<String> staraVrednost = GeneratedColumn<String>(
    'stara_vrednost',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _novaVrednostMeta = const VerificationMeta(
    'novaVrednost',
  );
  @override
  late final GeneratedColumn<String> novaVrednost = GeneratedColumn<String>(
    'nova_vrednost',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predmetId,
    korisnikId,
    datumVreme,
    polje,
    staraVrednost,
    novaVrednost,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_izmena';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogIzmenaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predmet_id')) {
      context.handle(
        _predmetIdMeta,
        predmetId.isAcceptableOrUnknown(data['predmet_id']!, _predmetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_predmetIdMeta);
    }
    if (data.containsKey('korisnik_id')) {
      context.handle(
        _korisnikIdMeta,
        korisnikId.isAcceptableOrUnknown(data['korisnik_id']!, _korisnikIdMeta),
      );
    } else if (isInserting) {
      context.missing(_korisnikIdMeta);
    }
    if (data.containsKey('datum_vreme')) {
      context.handle(
        _datumVremeMeta,
        datumVreme.isAcceptableOrUnknown(data['datum_vreme']!, _datumVremeMeta),
      );
    } else if (isInserting) {
      context.missing(_datumVremeMeta);
    }
    if (data.containsKey('polje')) {
      context.handle(
        _poljeMeta,
        polje.isAcceptableOrUnknown(data['polje']!, _poljeMeta),
      );
    } else if (isInserting) {
      context.missing(_poljeMeta);
    }
    if (data.containsKey('stara_vrednost')) {
      context.handle(
        _staraVrednostMeta,
        staraVrednost.isAcceptableOrUnknown(
          data['stara_vrednost']!,
          _staraVrednostMeta,
        ),
      );
    }
    if (data.containsKey('nova_vrednost')) {
      context.handle(
        _novaVrednostMeta,
        novaVrednost.isAcceptableOrUnknown(
          data['nova_vrednost']!,
          _novaVrednostMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogIzmenaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogIzmenaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      predmetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predmet_id'],
      )!,
      korisnikId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}korisnik_id'],
      )!,
      datumVreme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datum_vreme'],
      )!,
      polje: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polje'],
      )!,
      staraVrednost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stara_vrednost'],
      )!,
      novaVrednost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nova_vrednost'],
      )!,
    );
  }

  @override
  $LogIzmenaTable createAlias(String alias) {
    return $LogIzmenaTable(attachedDatabase, alias);
  }
}

class LogIzmenaData extends DataClass implements Insertable<LogIzmenaData> {
  final int id;
  final int predmetId;
  final int korisnikId;
  final String datumVreme;
  final String polje;
  final String staraVrednost;
  final String novaVrednost;
  const LogIzmenaData({
    required this.id,
    required this.predmetId,
    required this.korisnikId,
    required this.datumVreme,
    required this.polje,
    required this.staraVrednost,
    required this.novaVrednost,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predmet_id'] = Variable<int>(predmetId);
    map['korisnik_id'] = Variable<int>(korisnikId);
    map['datum_vreme'] = Variable<String>(datumVreme);
    map['polje'] = Variable<String>(polje);
    map['stara_vrednost'] = Variable<String>(staraVrednost);
    map['nova_vrednost'] = Variable<String>(novaVrednost);
    return map;
  }

  LogIzmenaCompanion toCompanion(bool nullToAbsent) {
    return LogIzmenaCompanion(
      id: Value(id),
      predmetId: Value(predmetId),
      korisnikId: Value(korisnikId),
      datumVreme: Value(datumVreme),
      polje: Value(polje),
      staraVrednost: Value(staraVrednost),
      novaVrednost: Value(novaVrednost),
    );
  }

  factory LogIzmenaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogIzmenaData(
      id: serializer.fromJson<int>(json['id']),
      predmetId: serializer.fromJson<int>(json['predmetId']),
      korisnikId: serializer.fromJson<int>(json['korisnikId']),
      datumVreme: serializer.fromJson<String>(json['datumVreme']),
      polje: serializer.fromJson<String>(json['polje']),
      staraVrednost: serializer.fromJson<String>(json['staraVrednost']),
      novaVrednost: serializer.fromJson<String>(json['novaVrednost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predmetId': serializer.toJson<int>(predmetId),
      'korisnikId': serializer.toJson<int>(korisnikId),
      'datumVreme': serializer.toJson<String>(datumVreme),
      'polje': serializer.toJson<String>(polje),
      'staraVrednost': serializer.toJson<String>(staraVrednost),
      'novaVrednost': serializer.toJson<String>(novaVrednost),
    };
  }

  LogIzmenaData copyWith({
    int? id,
    int? predmetId,
    int? korisnikId,
    String? datumVreme,
    String? polje,
    String? staraVrednost,
    String? novaVrednost,
  }) => LogIzmenaData(
    id: id ?? this.id,
    predmetId: predmetId ?? this.predmetId,
    korisnikId: korisnikId ?? this.korisnikId,
    datumVreme: datumVreme ?? this.datumVreme,
    polje: polje ?? this.polje,
    staraVrednost: staraVrednost ?? this.staraVrednost,
    novaVrednost: novaVrednost ?? this.novaVrednost,
  );
  LogIzmenaData copyWithCompanion(LogIzmenaCompanion data) {
    return LogIzmenaData(
      id: data.id.present ? data.id.value : this.id,
      predmetId: data.predmetId.present ? data.predmetId.value : this.predmetId,
      korisnikId: data.korisnikId.present
          ? data.korisnikId.value
          : this.korisnikId,
      datumVreme: data.datumVreme.present
          ? data.datumVreme.value
          : this.datumVreme,
      polje: data.polje.present ? data.polje.value : this.polje,
      staraVrednost: data.staraVrednost.present
          ? data.staraVrednost.value
          : this.staraVrednost,
      novaVrednost: data.novaVrednost.present
          ? data.novaVrednost.value
          : this.novaVrednost,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogIzmenaData(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('korisnikId: $korisnikId, ')
          ..write('datumVreme: $datumVreme, ')
          ..write('polje: $polje, ')
          ..write('staraVrednost: $staraVrednost, ')
          ..write('novaVrednost: $novaVrednost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predmetId,
    korisnikId,
    datumVreme,
    polje,
    staraVrednost,
    novaVrednost,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogIzmenaData &&
          other.id == this.id &&
          other.predmetId == this.predmetId &&
          other.korisnikId == this.korisnikId &&
          other.datumVreme == this.datumVreme &&
          other.polje == this.polje &&
          other.staraVrednost == this.staraVrednost &&
          other.novaVrednost == this.novaVrednost);
}

class LogIzmenaCompanion extends UpdateCompanion<LogIzmenaData> {
  final Value<int> id;
  final Value<int> predmetId;
  final Value<int> korisnikId;
  final Value<String> datumVreme;
  final Value<String> polje;
  final Value<String> staraVrednost;
  final Value<String> novaVrednost;
  const LogIzmenaCompanion({
    this.id = const Value.absent(),
    this.predmetId = const Value.absent(),
    this.korisnikId = const Value.absent(),
    this.datumVreme = const Value.absent(),
    this.polje = const Value.absent(),
    this.staraVrednost = const Value.absent(),
    this.novaVrednost = const Value.absent(),
  });
  LogIzmenaCompanion.insert({
    this.id = const Value.absent(),
    required int predmetId,
    required int korisnikId,
    required String datumVreme,
    required String polje,
    this.staraVrednost = const Value.absent(),
    this.novaVrednost = const Value.absent(),
  }) : predmetId = Value(predmetId),
       korisnikId = Value(korisnikId),
       datumVreme = Value(datumVreme),
       polje = Value(polje);
  static Insertable<LogIzmenaData> custom({
    Expression<int>? id,
    Expression<int>? predmetId,
    Expression<int>? korisnikId,
    Expression<String>? datumVreme,
    Expression<String>? polje,
    Expression<String>? staraVrednost,
    Expression<String>? novaVrednost,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predmetId != null) 'predmet_id': predmetId,
      if (korisnikId != null) 'korisnik_id': korisnikId,
      if (datumVreme != null) 'datum_vreme': datumVreme,
      if (polje != null) 'polje': polje,
      if (staraVrednost != null) 'stara_vrednost': staraVrednost,
      if (novaVrednost != null) 'nova_vrednost': novaVrednost,
    });
  }

  LogIzmenaCompanion copyWith({
    Value<int>? id,
    Value<int>? predmetId,
    Value<int>? korisnikId,
    Value<String>? datumVreme,
    Value<String>? polje,
    Value<String>? staraVrednost,
    Value<String>? novaVrednost,
  }) {
    return LogIzmenaCompanion(
      id: id ?? this.id,
      predmetId: predmetId ?? this.predmetId,
      korisnikId: korisnikId ?? this.korisnikId,
      datumVreme: datumVreme ?? this.datumVreme,
      polje: polje ?? this.polje,
      staraVrednost: staraVrednost ?? this.staraVrednost,
      novaVrednost: novaVrednost ?? this.novaVrednost,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predmetId.present) {
      map['predmet_id'] = Variable<int>(predmetId.value);
    }
    if (korisnikId.present) {
      map['korisnik_id'] = Variable<int>(korisnikId.value);
    }
    if (datumVreme.present) {
      map['datum_vreme'] = Variable<String>(datumVreme.value);
    }
    if (polje.present) {
      map['polje'] = Variable<String>(polje.value);
    }
    if (staraVrednost.present) {
      map['stara_vrednost'] = Variable<String>(staraVrednost.value);
    }
    if (novaVrednost.present) {
      map['nova_vrednost'] = Variable<String>(novaVrednost.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogIzmenaCompanion(')
          ..write('id: $id, ')
          ..write('predmetId: $predmetId, ')
          ..write('korisnikId: $korisnikId, ')
          ..write('datumVreme: $datumVreme, ')
          ..write('polje: $polje, ')
          ..write('staraVrednost: $staraVrednost, ')
          ..write('novaVrednost: $novaVrednost')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KorisniciTable korisnici = $KorisniciTable(this);
  late final $FirmaPodaciTable firmaPodaci = $FirmaPodaciTable(this);
  late final $AppPodesavanjaTable appPodesavanja = $AppPodesavanjaTable(this);
  late final $PredmetiTable predmeti = $PredmetiTable(this);
  late final $KontaktLicaTable kontaktLica = $KontaktLicaTable(this);
  late final $IriuTable iriu = $IriuTable(this);
  late final $IriuKatalogConfigTable iriuKatalogConfig =
      $IriuKatalogConfigTable(this);
  late final $KatalogArtikliTable katalogArtikli = $KatalogArtikliTable(this);
  late final $StanjeRobeStavkeTable stanjeRobeStavke = $StanjeRobeStavkeTable(
    this,
  );
  late final $StanjeRobeAppliedEffectsTable stanjeRobeAppliedEffects =
      $StanjeRobeAppliedEffectsTable(this);
  late final $StanjeRobePoslediceTable stanjeRobePosledice =
      $StanjeRobePoslediceTable(this);
  late final $PredlosciDokumenataTable predlosciDokumenata =
      $PredlosciDokumenataTable(this);
  late final $LogIzmenaTable logIzmena = $LogIzmenaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    korisnici,
    firmaPodaci,
    appPodesavanja,
    predmeti,
    kontaktLica,
    iriu,
    iriuKatalogConfig,
    katalogArtikli,
    stanjeRobeStavke,
    stanjeRobeAppliedEffects,
    stanjeRobePosledice,
    predlosciDokumenata,
    logIzmena,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'predmeti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('kontakt_lica', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'predmeti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('iriu', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'predmeti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stanje_robe_posledice', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'iriu',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stanje_robe_posledice', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'predmeti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('log_izmena', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$KorisniciTableCreateCompanionBuilder =
    KorisniciCompanion Function({
      Value<int> id,
      required String imePrezime,
      required String uloga,
      required String pinHash,
      Value<bool> aktivan,
      required String datumKreiranja,
    });
typedef $$KorisniciTableUpdateCompanionBuilder =
    KorisniciCompanion Function({
      Value<int> id,
      Value<String> imePrezime,
      Value<String> uloga,
      Value<String> pinHash,
      Value<bool> aktivan,
      Value<String> datumKreiranja,
    });

class $$KorisniciTableFilterComposer
    extends Composer<_$AppDatabase, $KorisniciTable> {
  $$KorisniciTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imePrezime => $composableBuilder(
    column: $table.imePrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uloga => $composableBuilder(
    column: $table.uloga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktivan => $composableBuilder(
    column: $table.aktivan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KorisniciTableOrderingComposer
    extends Composer<_$AppDatabase, $KorisniciTable> {
  $$KorisniciTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imePrezime => $composableBuilder(
    column: $table.imePrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uloga => $composableBuilder(
    column: $table.uloga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktivan => $composableBuilder(
    column: $table.aktivan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KorisniciTableAnnotationComposer
    extends Composer<_$AppDatabase, $KorisniciTable> {
  $$KorisniciTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imePrezime => $composableBuilder(
    column: $table.imePrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uloga =>
      $composableBuilder(column: $table.uloga, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<bool> get aktivan =>
      $composableBuilder(column: $table.aktivan, builder: (column) => column);

  GeneratedColumn<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => column,
  );
}

class $$KorisniciTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KorisniciTable,
          KorisniciData,
          $$KorisniciTableFilterComposer,
          $$KorisniciTableOrderingComposer,
          $$KorisniciTableAnnotationComposer,
          $$KorisniciTableCreateCompanionBuilder,
          $$KorisniciTableUpdateCompanionBuilder,
          (
            KorisniciData,
            BaseReferences<_$AppDatabase, $KorisniciTable, KorisniciData>,
          ),
          KorisniciData,
          PrefetchHooks Function()
        > {
  $$KorisniciTableTableManager(_$AppDatabase db, $KorisniciTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KorisniciTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KorisniciTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KorisniciTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> imePrezime = const Value.absent(),
                Value<String> uloga = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<bool> aktivan = const Value.absent(),
                Value<String> datumKreiranja = const Value.absent(),
              }) => KorisniciCompanion(
                id: id,
                imePrezime: imePrezime,
                uloga: uloga,
                pinHash: pinHash,
                aktivan: aktivan,
                datumKreiranja: datumKreiranja,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String imePrezime,
                required String uloga,
                required String pinHash,
                Value<bool> aktivan = const Value.absent(),
                required String datumKreiranja,
              }) => KorisniciCompanion.insert(
                id: id,
                imePrezime: imePrezime,
                uloga: uloga,
                pinHash: pinHash,
                aktivan: aktivan,
                datumKreiranja: datumKreiranja,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KorisniciTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KorisniciTable,
      KorisniciData,
      $$KorisniciTableFilterComposer,
      $$KorisniciTableOrderingComposer,
      $$KorisniciTableAnnotationComposer,
      $$KorisniciTableCreateCompanionBuilder,
      $$KorisniciTableUpdateCompanionBuilder,
      (
        KorisniciData,
        BaseReferences<_$AppDatabase, $KorisniciTable, KorisniciData>,
      ),
      KorisniciData,
      PrefetchHooks Function()
    >;
typedef $$FirmaPodaciTableCreateCompanionBuilder =
    FirmaPodaciCompanion Function({
      Value<int> id,
      Value<String> naziv,
      Value<String> adresa,
      Value<String> pib,
      Value<String> mb,
      Value<String> sifraDelatnosti,
      Value<String> telefon,
      Value<String> odgovornoLice,
      Value<String> email,
      Value<String> sajt,
      Value<Uint8List?> logo,
    });
typedef $$FirmaPodaciTableUpdateCompanionBuilder =
    FirmaPodaciCompanion Function({
      Value<int> id,
      Value<String> naziv,
      Value<String> adresa,
      Value<String> pib,
      Value<String> mb,
      Value<String> sifraDelatnosti,
      Value<String> telefon,
      Value<String> odgovornoLice,
      Value<String> email,
      Value<String> sajt,
      Value<Uint8List?> logo,
    });

class $$FirmaPodaciTableFilterComposer
    extends Composer<_$AppDatabase, $FirmaPodaciTable> {
  $$FirmaPodaciTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naziv => $composableBuilder(
    column: $table.naziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adresa => $composableBuilder(
    column: $table.adresa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pib => $composableBuilder(
    column: $table.pib,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mb => $composableBuilder(
    column: $table.mb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sifraDelatnosti => $composableBuilder(
    column: $table.sifraDelatnosti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefon => $composableBuilder(
    column: $table.telefon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get odgovornoLice => $composableBuilder(
    column: $table.odgovornoLice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sajt => $composableBuilder(
    column: $table.sajt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FirmaPodaciTableOrderingComposer
    extends Composer<_$AppDatabase, $FirmaPodaciTable> {
  $$FirmaPodaciTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naziv => $composableBuilder(
    column: $table.naziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adresa => $composableBuilder(
    column: $table.adresa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pib => $composableBuilder(
    column: $table.pib,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mb => $composableBuilder(
    column: $table.mb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sifraDelatnosti => $composableBuilder(
    column: $table.sifraDelatnosti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefon => $composableBuilder(
    column: $table.telefon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get odgovornoLice => $composableBuilder(
    column: $table.odgovornoLice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sajt => $composableBuilder(
    column: $table.sajt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FirmaPodaciTableAnnotationComposer
    extends Composer<_$AppDatabase, $FirmaPodaciTable> {
  $$FirmaPodaciTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get naziv =>
      $composableBuilder(column: $table.naziv, builder: (column) => column);

  GeneratedColumn<String> get adresa =>
      $composableBuilder(column: $table.adresa, builder: (column) => column);

  GeneratedColumn<String> get pib =>
      $composableBuilder(column: $table.pib, builder: (column) => column);

  GeneratedColumn<String> get mb =>
      $composableBuilder(column: $table.mb, builder: (column) => column);

  GeneratedColumn<String> get sifraDelatnosti => $composableBuilder(
    column: $table.sifraDelatnosti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telefon =>
      $composableBuilder(column: $table.telefon, builder: (column) => column);

  GeneratedColumn<String> get odgovornoLice => $composableBuilder(
    column: $table.odgovornoLice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get sajt =>
      $composableBuilder(column: $table.sajt, builder: (column) => column);

  GeneratedColumn<Uint8List> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);
}

class $$FirmaPodaciTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FirmaPodaciTable,
          FirmaPodaciData,
          $$FirmaPodaciTableFilterComposer,
          $$FirmaPodaciTableOrderingComposer,
          $$FirmaPodaciTableAnnotationComposer,
          $$FirmaPodaciTableCreateCompanionBuilder,
          $$FirmaPodaciTableUpdateCompanionBuilder,
          (
            FirmaPodaciData,
            BaseReferences<_$AppDatabase, $FirmaPodaciTable, FirmaPodaciData>,
          ),
          FirmaPodaciData,
          PrefetchHooks Function()
        > {
  $$FirmaPodaciTableTableManager(_$AppDatabase db, $FirmaPodaciTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FirmaPodaciTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FirmaPodaciTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FirmaPodaciTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> naziv = const Value.absent(),
                Value<String> adresa = const Value.absent(),
                Value<String> pib = const Value.absent(),
                Value<String> mb = const Value.absent(),
                Value<String> sifraDelatnosti = const Value.absent(),
                Value<String> telefon = const Value.absent(),
                Value<String> odgovornoLice = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> sajt = const Value.absent(),
                Value<Uint8List?> logo = const Value.absent(),
              }) => FirmaPodaciCompanion(
                id: id,
                naziv: naziv,
                adresa: adresa,
                pib: pib,
                mb: mb,
                sifraDelatnosti: sifraDelatnosti,
                telefon: telefon,
                odgovornoLice: odgovornoLice,
                email: email,
                sajt: sajt,
                logo: logo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> naziv = const Value.absent(),
                Value<String> adresa = const Value.absent(),
                Value<String> pib = const Value.absent(),
                Value<String> mb = const Value.absent(),
                Value<String> sifraDelatnosti = const Value.absent(),
                Value<String> telefon = const Value.absent(),
                Value<String> odgovornoLice = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> sajt = const Value.absent(),
                Value<Uint8List?> logo = const Value.absent(),
              }) => FirmaPodaciCompanion.insert(
                id: id,
                naziv: naziv,
                adresa: adresa,
                pib: pib,
                mb: mb,
                sifraDelatnosti: sifraDelatnosti,
                telefon: telefon,
                odgovornoLice: odgovornoLice,
                email: email,
                sajt: sajt,
                logo: logo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FirmaPodaciTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FirmaPodaciTable,
      FirmaPodaciData,
      $$FirmaPodaciTableFilterComposer,
      $$FirmaPodaciTableOrderingComposer,
      $$FirmaPodaciTableAnnotationComposer,
      $$FirmaPodaciTableCreateCompanionBuilder,
      $$FirmaPodaciTableUpdateCompanionBuilder,
      (
        FirmaPodaciData,
        BaseReferences<_$AppDatabase, $FirmaPodaciTable, FirmaPodaciData>,
      ),
      FirmaPodaciData,
      PrefetchHooks Function()
    >;
typedef $$AppPodesavanjaTableCreateCompanionBuilder =
    AppPodesavanjaCompanion Function({
      Value<int> id,
      Value<String> ziroRacun,
      Value<String> nazivBanke,
      Value<String> qrPrimalacNaziv,
      Value<String> qrSifraPlacanja,
      Value<String> qrSvrhaPlacanja,
      Value<String> pozivNaBrojTip,
      Value<double> refundacijaPioIznos,
      Value<bool> stanjeRobeOperativnoOmoguceno,
    });
typedef $$AppPodesavanjaTableUpdateCompanionBuilder =
    AppPodesavanjaCompanion Function({
      Value<int> id,
      Value<String> ziroRacun,
      Value<String> nazivBanke,
      Value<String> qrPrimalacNaziv,
      Value<String> qrSifraPlacanja,
      Value<String> qrSvrhaPlacanja,
      Value<String> pozivNaBrojTip,
      Value<double> refundacijaPioIznos,
      Value<bool> stanjeRobeOperativnoOmoguceno,
    });

class $$AppPodesavanjaTableFilterComposer
    extends Composer<_$AppDatabase, $AppPodesavanjaTable> {
  $$AppPodesavanjaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ziroRacun => $composableBuilder(
    column: $table.ziroRacun,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nazivBanke => $composableBuilder(
    column: $table.nazivBanke,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrPrimalacNaziv => $composableBuilder(
    column: $table.qrPrimalacNaziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrSifraPlacanja => $composableBuilder(
    column: $table.qrSifraPlacanja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrSvrhaPlacanja => $composableBuilder(
    column: $table.qrSvrhaPlacanja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pozivNaBrojTip => $composableBuilder(
    column: $table.pozivNaBrojTip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refundacijaPioIznos => $composableBuilder(
    column: $table.refundacijaPioIznos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stanjeRobeOperativnoOmoguceno => $composableBuilder(
    column: $table.stanjeRobeOperativnoOmoguceno,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPodesavanjaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPodesavanjaTable> {
  $$AppPodesavanjaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ziroRacun => $composableBuilder(
    column: $table.ziroRacun,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nazivBanke => $composableBuilder(
    column: $table.nazivBanke,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrPrimalacNaziv => $composableBuilder(
    column: $table.qrPrimalacNaziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrSifraPlacanja => $composableBuilder(
    column: $table.qrSifraPlacanja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrSvrhaPlacanja => $composableBuilder(
    column: $table.qrSvrhaPlacanja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pozivNaBrojTip => $composableBuilder(
    column: $table.pozivNaBrojTip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refundacijaPioIznos => $composableBuilder(
    column: $table.refundacijaPioIznos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stanjeRobeOperativnoOmoguceno => $composableBuilder(
    column: $table.stanjeRobeOperativnoOmoguceno,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPodesavanjaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPodesavanjaTable> {
  $$AppPodesavanjaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ziroRacun =>
      $composableBuilder(column: $table.ziroRacun, builder: (column) => column);

  GeneratedColumn<String> get nazivBanke => $composableBuilder(
    column: $table.nazivBanke,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qrPrimalacNaziv => $composableBuilder(
    column: $table.qrPrimalacNaziv,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qrSifraPlacanja => $composableBuilder(
    column: $table.qrSifraPlacanja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qrSvrhaPlacanja => $composableBuilder(
    column: $table.qrSvrhaPlacanja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pozivNaBrojTip => $composableBuilder(
    column: $table.pozivNaBrojTip,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refundacijaPioIznos => $composableBuilder(
    column: $table.refundacijaPioIznos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get stanjeRobeOperativnoOmoguceno => $composableBuilder(
    column: $table.stanjeRobeOperativnoOmoguceno,
    builder: (column) => column,
  );
}

class $$AppPodesavanjaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPodesavanjaTable,
          AppPodesavanjaData,
          $$AppPodesavanjaTableFilterComposer,
          $$AppPodesavanjaTableOrderingComposer,
          $$AppPodesavanjaTableAnnotationComposer,
          $$AppPodesavanjaTableCreateCompanionBuilder,
          $$AppPodesavanjaTableUpdateCompanionBuilder,
          (
            AppPodesavanjaData,
            BaseReferences<
              _$AppDatabase,
              $AppPodesavanjaTable,
              AppPodesavanjaData
            >,
          ),
          AppPodesavanjaData,
          PrefetchHooks Function()
        > {
  $$AppPodesavanjaTableTableManager(
    _$AppDatabase db,
    $AppPodesavanjaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPodesavanjaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPodesavanjaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPodesavanjaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ziroRacun = const Value.absent(),
                Value<String> nazivBanke = const Value.absent(),
                Value<String> qrPrimalacNaziv = const Value.absent(),
                Value<String> qrSifraPlacanja = const Value.absent(),
                Value<String> qrSvrhaPlacanja = const Value.absent(),
                Value<String> pozivNaBrojTip = const Value.absent(),
                Value<double> refundacijaPioIznos = const Value.absent(),
                Value<bool> stanjeRobeOperativnoOmoguceno =
                    const Value.absent(),
              }) => AppPodesavanjaCompanion(
                id: id,
                ziroRacun: ziroRacun,
                nazivBanke: nazivBanke,
                qrPrimalacNaziv: qrPrimalacNaziv,
                qrSifraPlacanja: qrSifraPlacanja,
                qrSvrhaPlacanja: qrSvrhaPlacanja,
                pozivNaBrojTip: pozivNaBrojTip,
                refundacijaPioIznos: refundacijaPioIznos,
                stanjeRobeOperativnoOmoguceno: stanjeRobeOperativnoOmoguceno,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ziroRacun = const Value.absent(),
                Value<String> nazivBanke = const Value.absent(),
                Value<String> qrPrimalacNaziv = const Value.absent(),
                Value<String> qrSifraPlacanja = const Value.absent(),
                Value<String> qrSvrhaPlacanja = const Value.absent(),
                Value<String> pozivNaBrojTip = const Value.absent(),
                Value<double> refundacijaPioIznos = const Value.absent(),
                Value<bool> stanjeRobeOperativnoOmoguceno =
                    const Value.absent(),
              }) => AppPodesavanjaCompanion.insert(
                id: id,
                ziroRacun: ziroRacun,
                nazivBanke: nazivBanke,
                qrPrimalacNaziv: qrPrimalacNaziv,
                qrSifraPlacanja: qrSifraPlacanja,
                qrSvrhaPlacanja: qrSvrhaPlacanja,
                pozivNaBrojTip: pozivNaBrojTip,
                refundacijaPioIznos: refundacijaPioIznos,
                stanjeRobeOperativnoOmoguceno: stanjeRobeOperativnoOmoguceno,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPodesavanjaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPodesavanjaTable,
      AppPodesavanjaData,
      $$AppPodesavanjaTableFilterComposer,
      $$AppPodesavanjaTableOrderingComposer,
      $$AppPodesavanjaTableAnnotationComposer,
      $$AppPodesavanjaTableCreateCompanionBuilder,
      $$AppPodesavanjaTableUpdateCompanionBuilder,
      (
        AppPodesavanjaData,
        BaseReferences<_$AppDatabase, $AppPodesavanjaTable, AppPodesavanjaData>,
      ),
      AppPodesavanjaData,
      PrefetchHooks Function()
    >;
typedef $$PredmetiTableCreateCompanionBuilder =
    PredmetiCompanion Function({
      Value<int> id,
      Value<String> brojPredmeta,
      Value<String> status,
      Value<String> datumKreiranja,
      Value<int?> savetnikId,
      Value<int> verzija,
      Value<String> businessScenarioId,
      Value<String> sourceIdentity,
      Value<int?> createdByKorisnikId,
      Value<int?> lastBusinessModifiedByKorisnikId,
      Value<String?> lastBusinessModifiedAt,
      Value<String> ime,
      Value<String> prezime,
      Value<String> srednje,
      Value<String> devojackoPrezime,
      Value<String> jmbg,
      Value<String> pol,
      Value<String> datumRodjenja,
      Value<String> mestoRodjenja,
      Value<String> datumSmrti,
      Value<String> mestoSmrti,
      Value<String> uzrokSmrti,
      Value<String> adresa,
      Value<String> imeOca,
      Value<String> imeMajke,
      Value<String> bracnoStanje,
      Value<String> bracniDrugIme,
      Value<String> bracniDrugPrezime,
      Value<String> bracniDrugPol,
      Value<String> bracniDrugJmbg,
      Value<String> bracniDrugDevojacko,
      Value<String> zanimanje,
      Value<bool> zanimanjeNaParti,
      Value<String> titula,
      Value<bool> titulaIspred,
      Value<String> cin,
      Value<bool> cinNaParti,
      Value<bool> srednjeNaParti,
      Value<String> nadimak,
      Value<bool> nadimakNaParti,
      Value<bool> nadimakCrtica,
      Value<String> radniStatus,
      Value<String> penzioner,
      Value<String> penzionerSrbije,
      Value<String> vojniPenzioner,
      Value<String> vojnePocasti,
      Value<String> posmrtnaPomoc,
      Value<double> refundacijaPio,
      Value<String> narucilacRefundira,
      Value<String> bracniDrugOstvarujePravo,
      Value<String> bracniDrugJePenzioner,
      Value<String> penzionerNapomena,
      Value<String> naruTip,
      Value<String> naruIme,
      Value<String> naruPrezime,
      Value<String> naruImePrezime,
      Value<String> naruJmbg,
      Value<String> naruAdresa,
      Value<String> naruBrojLk,
      Value<String> naruTelefon1,
      Value<String> naruTelefon2,
      Value<String> naruEmail,
      Value<String> naruPlNaziv,
      Value<String> naruPlAdresa,
      Value<String> naruPlPib,
      Value<String> naruPlMb,
      Value<String> naruPlOdgovornoLice,
      Value<String> naruPlTelefon1,
      Value<String> naruPlTelefon2,
      Value<String> naruPlEmail,
      Value<bool> naruIstiZaJkp,
      Value<String> jkpTip,
      Value<String> jkpIme,
      Value<String> jkpPrezime,
      Value<String> jkpImePrezime,
      Value<String> jkpJmbg,
      Value<String> jkpAdresa,
      Value<String> jkpBrojLk,
      Value<String> jkpTelefon1,
      Value<String> jkpTelefon2,
      Value<String> jkpEmail,
      Value<String> jkpPlNaziv,
      Value<String> jkpPlAdresa,
      Value<String> jkpPlPib,
      Value<String> jkpPlMb,
      Value<String> jkpPlOdgovornoLice,
      Value<String> jkpPlTelefon1,
      Value<String> jkpPlEmail,
      Value<String> groblje,
      Value<String> tipGroblja,
      Value<String> vrstaCeremonije,
      Value<String> datumCeremonije,
      Value<String> vremeCeremonije,
      Value<String> opelo,
      Value<String> opeloMesto,
      Value<String> vremeOpela,
      Value<String> vremeIspracaja,
      Value<String> grobnoMesto,
      Value<String> tipGrobnogMesta,
      Value<String> parcela,
      Value<String> grobBroj,
      Value<String> redGrob,
      Value<String> npk,
      Value<String> grobnica,
      Value<String> urnaSifra,
      Value<String> tipPolaganja,
      Value<String> urnaParcela,
      Value<String> urnaBroj,
      Value<String> urnaRed,
      Value<String> urnaNpk,
      Value<bool> sahranaVanSrbije,
      Value<String> svisZemlja,
      Value<String> svisGrad,
      Value<bool> docekPosmrtnihOstataka,
      Value<String> docekMesto,
      Value<String> docekVreme,
      Value<String> simbol,
      Value<String> pismo,
      Value<String> parteIme,
      Value<String> ozaloseni,
      Value<double> avans,
      Value<double> troskoviJkp,
      Value<bool> jkpPlacaSamostalno,
      Value<double> popust,
      Value<String> nacinPlacanja,
      Value<String> napomenaPlacanja,
      Value<String> napomena,
      Value<int> exportVerzija,
    });
typedef $$PredmetiTableUpdateCompanionBuilder =
    PredmetiCompanion Function({
      Value<int> id,
      Value<String> brojPredmeta,
      Value<String> status,
      Value<String> datumKreiranja,
      Value<int?> savetnikId,
      Value<int> verzija,
      Value<String> businessScenarioId,
      Value<String> sourceIdentity,
      Value<int?> createdByKorisnikId,
      Value<int?> lastBusinessModifiedByKorisnikId,
      Value<String?> lastBusinessModifiedAt,
      Value<String> ime,
      Value<String> prezime,
      Value<String> srednje,
      Value<String> devojackoPrezime,
      Value<String> jmbg,
      Value<String> pol,
      Value<String> datumRodjenja,
      Value<String> mestoRodjenja,
      Value<String> datumSmrti,
      Value<String> mestoSmrti,
      Value<String> uzrokSmrti,
      Value<String> adresa,
      Value<String> imeOca,
      Value<String> imeMajke,
      Value<String> bracnoStanje,
      Value<String> bracniDrugIme,
      Value<String> bracniDrugPrezime,
      Value<String> bracniDrugPol,
      Value<String> bracniDrugJmbg,
      Value<String> bracniDrugDevojacko,
      Value<String> zanimanje,
      Value<bool> zanimanjeNaParti,
      Value<String> titula,
      Value<bool> titulaIspred,
      Value<String> cin,
      Value<bool> cinNaParti,
      Value<bool> srednjeNaParti,
      Value<String> nadimak,
      Value<bool> nadimakNaParti,
      Value<bool> nadimakCrtica,
      Value<String> radniStatus,
      Value<String> penzioner,
      Value<String> penzionerSrbije,
      Value<String> vojniPenzioner,
      Value<String> vojnePocasti,
      Value<String> posmrtnaPomoc,
      Value<double> refundacijaPio,
      Value<String> narucilacRefundira,
      Value<String> bracniDrugOstvarujePravo,
      Value<String> bracniDrugJePenzioner,
      Value<String> penzionerNapomena,
      Value<String> naruTip,
      Value<String> naruIme,
      Value<String> naruPrezime,
      Value<String> naruImePrezime,
      Value<String> naruJmbg,
      Value<String> naruAdresa,
      Value<String> naruBrojLk,
      Value<String> naruTelefon1,
      Value<String> naruTelefon2,
      Value<String> naruEmail,
      Value<String> naruPlNaziv,
      Value<String> naruPlAdresa,
      Value<String> naruPlPib,
      Value<String> naruPlMb,
      Value<String> naruPlOdgovornoLice,
      Value<String> naruPlTelefon1,
      Value<String> naruPlTelefon2,
      Value<String> naruPlEmail,
      Value<bool> naruIstiZaJkp,
      Value<String> jkpTip,
      Value<String> jkpIme,
      Value<String> jkpPrezime,
      Value<String> jkpImePrezime,
      Value<String> jkpJmbg,
      Value<String> jkpAdresa,
      Value<String> jkpBrojLk,
      Value<String> jkpTelefon1,
      Value<String> jkpTelefon2,
      Value<String> jkpEmail,
      Value<String> jkpPlNaziv,
      Value<String> jkpPlAdresa,
      Value<String> jkpPlPib,
      Value<String> jkpPlMb,
      Value<String> jkpPlOdgovornoLice,
      Value<String> jkpPlTelefon1,
      Value<String> jkpPlEmail,
      Value<String> groblje,
      Value<String> tipGroblja,
      Value<String> vrstaCeremonije,
      Value<String> datumCeremonije,
      Value<String> vremeCeremonije,
      Value<String> opelo,
      Value<String> opeloMesto,
      Value<String> vremeOpela,
      Value<String> vremeIspracaja,
      Value<String> grobnoMesto,
      Value<String> tipGrobnogMesta,
      Value<String> parcela,
      Value<String> grobBroj,
      Value<String> redGrob,
      Value<String> npk,
      Value<String> grobnica,
      Value<String> urnaSifra,
      Value<String> tipPolaganja,
      Value<String> urnaParcela,
      Value<String> urnaBroj,
      Value<String> urnaRed,
      Value<String> urnaNpk,
      Value<bool> sahranaVanSrbije,
      Value<String> svisZemlja,
      Value<String> svisGrad,
      Value<bool> docekPosmrtnihOstataka,
      Value<String> docekMesto,
      Value<String> docekVreme,
      Value<String> simbol,
      Value<String> pismo,
      Value<String> parteIme,
      Value<String> ozaloseni,
      Value<double> avans,
      Value<double> troskoviJkp,
      Value<bool> jkpPlacaSamostalno,
      Value<double> popust,
      Value<String> nacinPlacanja,
      Value<String> napomenaPlacanja,
      Value<String> napomena,
      Value<int> exportVerzija,
    });

final class $$PredmetiTableReferences
    extends BaseReferences<_$AppDatabase, $PredmetiTable, PredmetiData> {
  $$PredmetiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$KontaktLicaTable, List<KontaktLicaData>>
  _kontaktLicaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.kontaktLica,
    aliasName: $_aliasNameGenerator(db.predmeti.id, db.kontaktLica.predmetId),
  );

  $$KontaktLicaTableProcessedTableManager get kontaktLicaRefs {
    final manager = $$KontaktLicaTableTableManager(
      $_db,
      $_db.kontaktLica,
    ).filter((f) => f.predmetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_kontaktLicaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IriuTable, List<IriuData>> _iriuRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.iriu,
    aliasName: $_aliasNameGenerator(db.predmeti.id, db.iriu.predmetId),
  );

  $$IriuTableProcessedTableManager get iriuRefs {
    final manager = $$IriuTableTableManager(
      $_db,
      $_db.iriu,
    ).filter((f) => f.predmetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_iriuRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StanjeRobePoslediceTable,
    List<StanjeRobePoslediceData>
  >
  _stanjeRobePoslediceRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stanjeRobePosledice,
        aliasName: $_aliasNameGenerator(
          db.predmeti.id,
          db.stanjeRobePosledice.predmetId,
        ),
      );

  $$StanjeRobePoslediceTableProcessedTableManager get stanjeRobePoslediceRefs {
    final manager = $$StanjeRobePoslediceTableTableManager(
      $_db,
      $_db.stanjeRobePosledice,
    ).filter((f) => f.predmetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stanjeRobePoslediceRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LogIzmenaTable, List<LogIzmenaData>>
  _logIzmenaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.logIzmena,
    aliasName: $_aliasNameGenerator(db.predmeti.id, db.logIzmena.predmetId),
  );

  $$LogIzmenaTableProcessedTableManager get logIzmenaRefs {
    final manager = $$LogIzmenaTableTableManager(
      $_db,
      $_db.logIzmena,
    ).filter((f) => f.predmetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_logIzmenaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PredmetiTableFilterComposer
    extends Composer<_$AppDatabase, $PredmetiTable> {
  $$PredmetiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brojPredmeta => $composableBuilder(
    column: $table.brojPredmeta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savetnikId => $composableBuilder(
    column: $table.savetnikId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verzija => $composableBuilder(
    column: $table.verzija,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessScenarioId => $composableBuilder(
    column: $table.businessScenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIdentity => $composableBuilder(
    column: $table.sourceIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdByKorisnikId => $composableBuilder(
    column: $table.createdByKorisnikId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastBusinessModifiedByKorisnikId => $composableBuilder(
    column: $table.lastBusinessModifiedByKorisnikId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBusinessModifiedAt => $composableBuilder(
    column: $table.lastBusinessModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ime => $composableBuilder(
    column: $table.ime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prezime => $composableBuilder(
    column: $table.prezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get srednje => $composableBuilder(
    column: $table.srednje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get devojackoPrezime => $composableBuilder(
    column: $table.devojackoPrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jmbg => $composableBuilder(
    column: $table.jmbg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pol => $composableBuilder(
    column: $table.pol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumRodjenja => $composableBuilder(
    column: $table.datumRodjenja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mestoRodjenja => $composableBuilder(
    column: $table.mestoRodjenja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumSmrti => $composableBuilder(
    column: $table.datumSmrti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mestoSmrti => $composableBuilder(
    column: $table.mestoSmrti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uzrokSmrti => $composableBuilder(
    column: $table.uzrokSmrti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adresa => $composableBuilder(
    column: $table.adresa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imeOca => $composableBuilder(
    column: $table.imeOca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imeMajke => $composableBuilder(
    column: $table.imeMajke,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracnoStanje => $composableBuilder(
    column: $table.bracnoStanje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugIme => $composableBuilder(
    column: $table.bracniDrugIme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugPrezime => $composableBuilder(
    column: $table.bracniDrugPrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugPol => $composableBuilder(
    column: $table.bracniDrugPol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugJmbg => $composableBuilder(
    column: $table.bracniDrugJmbg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugDevojacko => $composableBuilder(
    column: $table.bracniDrugDevojacko,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zanimanje => $composableBuilder(
    column: $table.zanimanje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get zanimanjeNaParti => $composableBuilder(
    column: $table.zanimanjeNaParti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titula => $composableBuilder(
    column: $table.titula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get titulaIspred => $composableBuilder(
    column: $table.titulaIspred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cin => $composableBuilder(
    column: $table.cin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cinNaParti => $composableBuilder(
    column: $table.cinNaParti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get srednjeNaParti => $composableBuilder(
    column: $table.srednjeNaParti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nadimak => $composableBuilder(
    column: $table.nadimak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nadimakNaParti => $composableBuilder(
    column: $table.nadimakNaParti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nadimakCrtica => $composableBuilder(
    column: $table.nadimakCrtica,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radniStatus => $composableBuilder(
    column: $table.radniStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get penzioner => $composableBuilder(
    column: $table.penzioner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get penzionerSrbije => $composableBuilder(
    column: $table.penzionerSrbije,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vojniPenzioner => $composableBuilder(
    column: $table.vojniPenzioner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vojnePocasti => $composableBuilder(
    column: $table.vojnePocasti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posmrtnaPomoc => $composableBuilder(
    column: $table.posmrtnaPomoc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refundacijaPio => $composableBuilder(
    column: $table.refundacijaPio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narucilacRefundira => $composableBuilder(
    column: $table.narucilacRefundira,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugOstvarujePravo => $composableBuilder(
    column: $table.bracniDrugOstvarujePravo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracniDrugJePenzioner => $composableBuilder(
    column: $table.bracniDrugJePenzioner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get penzionerNapomena => $composableBuilder(
    column: $table.penzionerNapomena,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruTip => $composableBuilder(
    column: $table.naruTip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruIme => $composableBuilder(
    column: $table.naruIme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPrezime => $composableBuilder(
    column: $table.naruPrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruImePrezime => $composableBuilder(
    column: $table.naruImePrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruJmbg => $composableBuilder(
    column: $table.naruJmbg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruAdresa => $composableBuilder(
    column: $table.naruAdresa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruBrojLk => $composableBuilder(
    column: $table.naruBrojLk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruTelefon1 => $composableBuilder(
    column: $table.naruTelefon1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruTelefon2 => $composableBuilder(
    column: $table.naruTelefon2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruEmail => $composableBuilder(
    column: $table.naruEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlNaziv => $composableBuilder(
    column: $table.naruPlNaziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlAdresa => $composableBuilder(
    column: $table.naruPlAdresa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlPib => $composableBuilder(
    column: $table.naruPlPib,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlMb => $composableBuilder(
    column: $table.naruPlMb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlOdgovornoLice => $composableBuilder(
    column: $table.naruPlOdgovornoLice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlTelefon1 => $composableBuilder(
    column: $table.naruPlTelefon1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlTelefon2 => $composableBuilder(
    column: $table.naruPlTelefon2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naruPlEmail => $composableBuilder(
    column: $table.naruPlEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get naruIstiZaJkp => $composableBuilder(
    column: $table.naruIstiZaJkp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpTip => $composableBuilder(
    column: $table.jkpTip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpIme => $composableBuilder(
    column: $table.jkpIme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPrezime => $composableBuilder(
    column: $table.jkpPrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpImePrezime => $composableBuilder(
    column: $table.jkpImePrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpJmbg => $composableBuilder(
    column: $table.jkpJmbg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpAdresa => $composableBuilder(
    column: $table.jkpAdresa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpBrojLk => $composableBuilder(
    column: $table.jkpBrojLk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpTelefon1 => $composableBuilder(
    column: $table.jkpTelefon1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpTelefon2 => $composableBuilder(
    column: $table.jkpTelefon2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpEmail => $composableBuilder(
    column: $table.jkpEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlNaziv => $composableBuilder(
    column: $table.jkpPlNaziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlAdresa => $composableBuilder(
    column: $table.jkpPlAdresa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlPib => $composableBuilder(
    column: $table.jkpPlPib,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlMb => $composableBuilder(
    column: $table.jkpPlMb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlOdgovornoLice => $composableBuilder(
    column: $table.jkpPlOdgovornoLice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlTelefon1 => $composableBuilder(
    column: $table.jkpPlTelefon1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkpPlEmail => $composableBuilder(
    column: $table.jkpPlEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groblje => $composableBuilder(
    column: $table.groblje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipGroblja => $composableBuilder(
    column: $table.tipGroblja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vrstaCeremonije => $composableBuilder(
    column: $table.vrstaCeremonije,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumCeremonije => $composableBuilder(
    column: $table.datumCeremonije,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vremeCeremonije => $composableBuilder(
    column: $table.vremeCeremonije,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opelo => $composableBuilder(
    column: $table.opelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opeloMesto => $composableBuilder(
    column: $table.opeloMesto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vremeOpela => $composableBuilder(
    column: $table.vremeOpela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vremeIspracaja => $composableBuilder(
    column: $table.vremeIspracaja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grobnoMesto => $composableBuilder(
    column: $table.grobnoMesto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipGrobnogMesta => $composableBuilder(
    column: $table.tipGrobnogMesta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcela => $composableBuilder(
    column: $table.parcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grobBroj => $composableBuilder(
    column: $table.grobBroj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redGrob => $composableBuilder(
    column: $table.redGrob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get npk => $composableBuilder(
    column: $table.npk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grobnica => $composableBuilder(
    column: $table.grobnica,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urnaSifra => $composableBuilder(
    column: $table.urnaSifra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipPolaganja => $composableBuilder(
    column: $table.tipPolaganja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urnaParcela => $composableBuilder(
    column: $table.urnaParcela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urnaBroj => $composableBuilder(
    column: $table.urnaBroj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urnaRed => $composableBuilder(
    column: $table.urnaRed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urnaNpk => $composableBuilder(
    column: $table.urnaNpk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sahranaVanSrbije => $composableBuilder(
    column: $table.sahranaVanSrbije,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get svisZemlja => $composableBuilder(
    column: $table.svisZemlja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get svisGrad => $composableBuilder(
    column: $table.svisGrad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get docekPosmrtnihOstataka => $composableBuilder(
    column: $table.docekPosmrtnihOstataka,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docekMesto => $composableBuilder(
    column: $table.docekMesto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docekVreme => $composableBuilder(
    column: $table.docekVreme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get simbol => $composableBuilder(
    column: $table.simbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pismo => $composableBuilder(
    column: $table.pismo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parteIme => $composableBuilder(
    column: $table.parteIme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ozaloseni => $composableBuilder(
    column: $table.ozaloseni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avans => $composableBuilder(
    column: $table.avans,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get troskoviJkp => $composableBuilder(
    column: $table.troskoviJkp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get jkpPlacaSamostalno => $composableBuilder(
    column: $table.jkpPlacaSamostalno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get popust => $composableBuilder(
    column: $table.popust,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nacinPlacanja => $composableBuilder(
    column: $table.nacinPlacanja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get napomenaPlacanja => $composableBuilder(
    column: $table.napomenaPlacanja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get napomena => $composableBuilder(
    column: $table.napomena,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exportVerzija => $composableBuilder(
    column: $table.exportVerzija,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> kontaktLicaRefs(
    Expression<bool> Function($$KontaktLicaTableFilterComposer f) f,
  ) {
    final $$KontaktLicaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.kontaktLica,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KontaktLicaTableFilterComposer(
            $db: $db,
            $table: $db.kontaktLica,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> iriuRefs(
    Expression<bool> Function($$IriuTableFilterComposer f) f,
  ) {
    final $$IriuTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.iriu,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IriuTableFilterComposer(
            $db: $db,
            $table: $db.iriu,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stanjeRobePoslediceRefs(
    Expression<bool> Function($$StanjeRobePoslediceTableFilterComposer f) f,
  ) {
    final $$StanjeRobePoslediceTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stanjeRobePosledice,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StanjeRobePoslediceTableFilterComposer(
            $db: $db,
            $table: $db.stanjeRobePosledice,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> logIzmenaRefs(
    Expression<bool> Function($$LogIzmenaTableFilterComposer f) f,
  ) {
    final $$LogIzmenaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logIzmena,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogIzmenaTableFilterComposer(
            $db: $db,
            $table: $db.logIzmena,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PredmetiTableOrderingComposer
    extends Composer<_$AppDatabase, $PredmetiTable> {
  $$PredmetiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brojPredmeta => $composableBuilder(
    column: $table.brojPredmeta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savetnikId => $composableBuilder(
    column: $table.savetnikId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verzija => $composableBuilder(
    column: $table.verzija,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessScenarioId => $composableBuilder(
    column: $table.businessScenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIdentity => $composableBuilder(
    column: $table.sourceIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdByKorisnikId => $composableBuilder(
    column: $table.createdByKorisnikId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastBusinessModifiedByKorisnikId =>
      $composableBuilder(
        column: $table.lastBusinessModifiedByKorisnikId,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get lastBusinessModifiedAt => $composableBuilder(
    column: $table.lastBusinessModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ime => $composableBuilder(
    column: $table.ime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prezime => $composableBuilder(
    column: $table.prezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get srednje => $composableBuilder(
    column: $table.srednje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get devojackoPrezime => $composableBuilder(
    column: $table.devojackoPrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jmbg => $composableBuilder(
    column: $table.jmbg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pol => $composableBuilder(
    column: $table.pol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumRodjenja => $composableBuilder(
    column: $table.datumRodjenja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mestoRodjenja => $composableBuilder(
    column: $table.mestoRodjenja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumSmrti => $composableBuilder(
    column: $table.datumSmrti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mestoSmrti => $composableBuilder(
    column: $table.mestoSmrti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uzrokSmrti => $composableBuilder(
    column: $table.uzrokSmrti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adresa => $composableBuilder(
    column: $table.adresa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imeOca => $composableBuilder(
    column: $table.imeOca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imeMajke => $composableBuilder(
    column: $table.imeMajke,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracnoStanje => $composableBuilder(
    column: $table.bracnoStanje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugIme => $composableBuilder(
    column: $table.bracniDrugIme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugPrezime => $composableBuilder(
    column: $table.bracniDrugPrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugPol => $composableBuilder(
    column: $table.bracniDrugPol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugJmbg => $composableBuilder(
    column: $table.bracniDrugJmbg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugDevojacko => $composableBuilder(
    column: $table.bracniDrugDevojacko,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zanimanje => $composableBuilder(
    column: $table.zanimanje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get zanimanjeNaParti => $composableBuilder(
    column: $table.zanimanjeNaParti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titula => $composableBuilder(
    column: $table.titula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get titulaIspred => $composableBuilder(
    column: $table.titulaIspred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cin => $composableBuilder(
    column: $table.cin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cinNaParti => $composableBuilder(
    column: $table.cinNaParti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get srednjeNaParti => $composableBuilder(
    column: $table.srednjeNaParti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nadimak => $composableBuilder(
    column: $table.nadimak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nadimakNaParti => $composableBuilder(
    column: $table.nadimakNaParti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nadimakCrtica => $composableBuilder(
    column: $table.nadimakCrtica,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radniStatus => $composableBuilder(
    column: $table.radniStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get penzioner => $composableBuilder(
    column: $table.penzioner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get penzionerSrbije => $composableBuilder(
    column: $table.penzionerSrbije,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vojniPenzioner => $composableBuilder(
    column: $table.vojniPenzioner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vojnePocasti => $composableBuilder(
    column: $table.vojnePocasti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posmrtnaPomoc => $composableBuilder(
    column: $table.posmrtnaPomoc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refundacijaPio => $composableBuilder(
    column: $table.refundacijaPio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narucilacRefundira => $composableBuilder(
    column: $table.narucilacRefundira,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugOstvarujePravo => $composableBuilder(
    column: $table.bracniDrugOstvarujePravo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracniDrugJePenzioner => $composableBuilder(
    column: $table.bracniDrugJePenzioner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get penzionerNapomena => $composableBuilder(
    column: $table.penzionerNapomena,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruTip => $composableBuilder(
    column: $table.naruTip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruIme => $composableBuilder(
    column: $table.naruIme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPrezime => $composableBuilder(
    column: $table.naruPrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruImePrezime => $composableBuilder(
    column: $table.naruImePrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruJmbg => $composableBuilder(
    column: $table.naruJmbg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruAdresa => $composableBuilder(
    column: $table.naruAdresa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruBrojLk => $composableBuilder(
    column: $table.naruBrojLk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruTelefon1 => $composableBuilder(
    column: $table.naruTelefon1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruTelefon2 => $composableBuilder(
    column: $table.naruTelefon2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruEmail => $composableBuilder(
    column: $table.naruEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlNaziv => $composableBuilder(
    column: $table.naruPlNaziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlAdresa => $composableBuilder(
    column: $table.naruPlAdresa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlPib => $composableBuilder(
    column: $table.naruPlPib,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlMb => $composableBuilder(
    column: $table.naruPlMb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlOdgovornoLice => $composableBuilder(
    column: $table.naruPlOdgovornoLice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlTelefon1 => $composableBuilder(
    column: $table.naruPlTelefon1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlTelefon2 => $composableBuilder(
    column: $table.naruPlTelefon2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naruPlEmail => $composableBuilder(
    column: $table.naruPlEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get naruIstiZaJkp => $composableBuilder(
    column: $table.naruIstiZaJkp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpTip => $composableBuilder(
    column: $table.jkpTip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpIme => $composableBuilder(
    column: $table.jkpIme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPrezime => $composableBuilder(
    column: $table.jkpPrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpImePrezime => $composableBuilder(
    column: $table.jkpImePrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpJmbg => $composableBuilder(
    column: $table.jkpJmbg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpAdresa => $composableBuilder(
    column: $table.jkpAdresa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpBrojLk => $composableBuilder(
    column: $table.jkpBrojLk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpTelefon1 => $composableBuilder(
    column: $table.jkpTelefon1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpTelefon2 => $composableBuilder(
    column: $table.jkpTelefon2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpEmail => $composableBuilder(
    column: $table.jkpEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlNaziv => $composableBuilder(
    column: $table.jkpPlNaziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlAdresa => $composableBuilder(
    column: $table.jkpPlAdresa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlPib => $composableBuilder(
    column: $table.jkpPlPib,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlMb => $composableBuilder(
    column: $table.jkpPlMb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlOdgovornoLice => $composableBuilder(
    column: $table.jkpPlOdgovornoLice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlTelefon1 => $composableBuilder(
    column: $table.jkpPlTelefon1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkpPlEmail => $composableBuilder(
    column: $table.jkpPlEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groblje => $composableBuilder(
    column: $table.groblje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipGroblja => $composableBuilder(
    column: $table.tipGroblja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vrstaCeremonije => $composableBuilder(
    column: $table.vrstaCeremonije,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumCeremonije => $composableBuilder(
    column: $table.datumCeremonije,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vremeCeremonije => $composableBuilder(
    column: $table.vremeCeremonije,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opelo => $composableBuilder(
    column: $table.opelo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opeloMesto => $composableBuilder(
    column: $table.opeloMesto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vremeOpela => $composableBuilder(
    column: $table.vremeOpela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vremeIspracaja => $composableBuilder(
    column: $table.vremeIspracaja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grobnoMesto => $composableBuilder(
    column: $table.grobnoMesto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipGrobnogMesta => $composableBuilder(
    column: $table.tipGrobnogMesta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcela => $composableBuilder(
    column: $table.parcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grobBroj => $composableBuilder(
    column: $table.grobBroj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redGrob => $composableBuilder(
    column: $table.redGrob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get npk => $composableBuilder(
    column: $table.npk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grobnica => $composableBuilder(
    column: $table.grobnica,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urnaSifra => $composableBuilder(
    column: $table.urnaSifra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipPolaganja => $composableBuilder(
    column: $table.tipPolaganja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urnaParcela => $composableBuilder(
    column: $table.urnaParcela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urnaBroj => $composableBuilder(
    column: $table.urnaBroj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urnaRed => $composableBuilder(
    column: $table.urnaRed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urnaNpk => $composableBuilder(
    column: $table.urnaNpk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sahranaVanSrbije => $composableBuilder(
    column: $table.sahranaVanSrbije,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get svisZemlja => $composableBuilder(
    column: $table.svisZemlja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get svisGrad => $composableBuilder(
    column: $table.svisGrad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get docekPosmrtnihOstataka => $composableBuilder(
    column: $table.docekPosmrtnihOstataka,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docekMesto => $composableBuilder(
    column: $table.docekMesto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docekVreme => $composableBuilder(
    column: $table.docekVreme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get simbol => $composableBuilder(
    column: $table.simbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pismo => $composableBuilder(
    column: $table.pismo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parteIme => $composableBuilder(
    column: $table.parteIme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ozaloseni => $composableBuilder(
    column: $table.ozaloseni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avans => $composableBuilder(
    column: $table.avans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get troskoviJkp => $composableBuilder(
    column: $table.troskoviJkp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get jkpPlacaSamostalno => $composableBuilder(
    column: $table.jkpPlacaSamostalno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get popust => $composableBuilder(
    column: $table.popust,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nacinPlacanja => $composableBuilder(
    column: $table.nacinPlacanja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get napomenaPlacanja => $composableBuilder(
    column: $table.napomenaPlacanja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get napomena => $composableBuilder(
    column: $table.napomena,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exportVerzija => $composableBuilder(
    column: $table.exportVerzija,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PredmetiTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredmetiTable> {
  $$PredmetiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brojPredmeta => $composableBuilder(
    column: $table.brojPredmeta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savetnikId => $composableBuilder(
    column: $table.savetnikId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verzija =>
      $composableBuilder(column: $table.verzija, builder: (column) => column);

  GeneratedColumn<String> get businessScenarioId => $composableBuilder(
    column: $table.businessScenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceIdentity => $composableBuilder(
    column: $table.sourceIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdByKorisnikId => $composableBuilder(
    column: $table.createdByKorisnikId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastBusinessModifiedByKorisnikId =>
      $composableBuilder(
        column: $table.lastBusinessModifiedByKorisnikId,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastBusinessModifiedAt => $composableBuilder(
    column: $table.lastBusinessModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ime =>
      $composableBuilder(column: $table.ime, builder: (column) => column);

  GeneratedColumn<String> get prezime =>
      $composableBuilder(column: $table.prezime, builder: (column) => column);

  GeneratedColumn<String> get srednje =>
      $composableBuilder(column: $table.srednje, builder: (column) => column);

  GeneratedColumn<String> get devojackoPrezime => $composableBuilder(
    column: $table.devojackoPrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jmbg =>
      $composableBuilder(column: $table.jmbg, builder: (column) => column);

  GeneratedColumn<String> get pol =>
      $composableBuilder(column: $table.pol, builder: (column) => column);

  GeneratedColumn<String> get datumRodjenja => $composableBuilder(
    column: $table.datumRodjenja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mestoRodjenja => $composableBuilder(
    column: $table.mestoRodjenja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datumSmrti => $composableBuilder(
    column: $table.datumSmrti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mestoSmrti => $composableBuilder(
    column: $table.mestoSmrti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uzrokSmrti => $composableBuilder(
    column: $table.uzrokSmrti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adresa =>
      $composableBuilder(column: $table.adresa, builder: (column) => column);

  GeneratedColumn<String> get imeOca =>
      $composableBuilder(column: $table.imeOca, builder: (column) => column);

  GeneratedColumn<String> get imeMajke =>
      $composableBuilder(column: $table.imeMajke, builder: (column) => column);

  GeneratedColumn<String> get bracnoStanje => $composableBuilder(
    column: $table.bracnoStanje,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugIme => $composableBuilder(
    column: $table.bracniDrugIme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugPrezime => $composableBuilder(
    column: $table.bracniDrugPrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugPol => $composableBuilder(
    column: $table.bracniDrugPol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugJmbg => $composableBuilder(
    column: $table.bracniDrugJmbg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugDevojacko => $composableBuilder(
    column: $table.bracniDrugDevojacko,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zanimanje =>
      $composableBuilder(column: $table.zanimanje, builder: (column) => column);

  GeneratedColumn<bool> get zanimanjeNaParti => $composableBuilder(
    column: $table.zanimanjeNaParti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titula =>
      $composableBuilder(column: $table.titula, builder: (column) => column);

  GeneratedColumn<bool> get titulaIspred => $composableBuilder(
    column: $table.titulaIspred,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cin =>
      $composableBuilder(column: $table.cin, builder: (column) => column);

  GeneratedColumn<bool> get cinNaParti => $composableBuilder(
    column: $table.cinNaParti,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get srednjeNaParti => $composableBuilder(
    column: $table.srednjeNaParti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nadimak =>
      $composableBuilder(column: $table.nadimak, builder: (column) => column);

  GeneratedColumn<bool> get nadimakNaParti => $composableBuilder(
    column: $table.nadimakNaParti,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get nadimakCrtica => $composableBuilder(
    column: $table.nadimakCrtica,
    builder: (column) => column,
  );

  GeneratedColumn<String> get radniStatus => $composableBuilder(
    column: $table.radniStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get penzioner =>
      $composableBuilder(column: $table.penzioner, builder: (column) => column);

  GeneratedColumn<String> get penzionerSrbije => $composableBuilder(
    column: $table.penzionerSrbije,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vojniPenzioner => $composableBuilder(
    column: $table.vojniPenzioner,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vojnePocasti => $composableBuilder(
    column: $table.vojnePocasti,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posmrtnaPomoc => $composableBuilder(
    column: $table.posmrtnaPomoc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refundacijaPio => $composableBuilder(
    column: $table.refundacijaPio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get narucilacRefundira => $composableBuilder(
    column: $table.narucilacRefundira,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugOstvarujePravo => $composableBuilder(
    column: $table.bracniDrugOstvarujePravo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bracniDrugJePenzioner => $composableBuilder(
    column: $table.bracniDrugJePenzioner,
    builder: (column) => column,
  );

  GeneratedColumn<String> get penzionerNapomena => $composableBuilder(
    column: $table.penzionerNapomena,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruTip =>
      $composableBuilder(column: $table.naruTip, builder: (column) => column);

  GeneratedColumn<String> get naruIme =>
      $composableBuilder(column: $table.naruIme, builder: (column) => column);

  GeneratedColumn<String> get naruPrezime => $composableBuilder(
    column: $table.naruPrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruImePrezime => $composableBuilder(
    column: $table.naruImePrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruJmbg =>
      $composableBuilder(column: $table.naruJmbg, builder: (column) => column);

  GeneratedColumn<String> get naruAdresa => $composableBuilder(
    column: $table.naruAdresa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruBrojLk => $composableBuilder(
    column: $table.naruBrojLk,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruTelefon1 => $composableBuilder(
    column: $table.naruTelefon1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruTelefon2 => $composableBuilder(
    column: $table.naruTelefon2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruEmail =>
      $composableBuilder(column: $table.naruEmail, builder: (column) => column);

  GeneratedColumn<String> get naruPlNaziv => $composableBuilder(
    column: $table.naruPlNaziv,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruPlAdresa => $composableBuilder(
    column: $table.naruPlAdresa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruPlPib =>
      $composableBuilder(column: $table.naruPlPib, builder: (column) => column);

  GeneratedColumn<String> get naruPlMb =>
      $composableBuilder(column: $table.naruPlMb, builder: (column) => column);

  GeneratedColumn<String> get naruPlOdgovornoLice => $composableBuilder(
    column: $table.naruPlOdgovornoLice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruPlTelefon1 => $composableBuilder(
    column: $table.naruPlTelefon1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruPlTelefon2 => $composableBuilder(
    column: $table.naruPlTelefon2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naruPlEmail => $composableBuilder(
    column: $table.naruPlEmail,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get naruIstiZaJkp => $composableBuilder(
    column: $table.naruIstiZaJkp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpTip =>
      $composableBuilder(column: $table.jkpTip, builder: (column) => column);

  GeneratedColumn<String> get jkpIme =>
      $composableBuilder(column: $table.jkpIme, builder: (column) => column);

  GeneratedColumn<String> get jkpPrezime => $composableBuilder(
    column: $table.jkpPrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpImePrezime => $composableBuilder(
    column: $table.jkpImePrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpJmbg =>
      $composableBuilder(column: $table.jkpJmbg, builder: (column) => column);

  GeneratedColumn<String> get jkpAdresa =>
      $composableBuilder(column: $table.jkpAdresa, builder: (column) => column);

  GeneratedColumn<String> get jkpBrojLk =>
      $composableBuilder(column: $table.jkpBrojLk, builder: (column) => column);

  GeneratedColumn<String> get jkpTelefon1 => $composableBuilder(
    column: $table.jkpTelefon1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpTelefon2 => $composableBuilder(
    column: $table.jkpTelefon2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpEmail =>
      $composableBuilder(column: $table.jkpEmail, builder: (column) => column);

  GeneratedColumn<String> get jkpPlNaziv => $composableBuilder(
    column: $table.jkpPlNaziv,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpPlAdresa => $composableBuilder(
    column: $table.jkpPlAdresa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpPlPib =>
      $composableBuilder(column: $table.jkpPlPib, builder: (column) => column);

  GeneratedColumn<String> get jkpPlMb =>
      $composableBuilder(column: $table.jkpPlMb, builder: (column) => column);

  GeneratedColumn<String> get jkpPlOdgovornoLice => $composableBuilder(
    column: $table.jkpPlOdgovornoLice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpPlTelefon1 => $composableBuilder(
    column: $table.jkpPlTelefon1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jkpPlEmail => $composableBuilder(
    column: $table.jkpPlEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groblje =>
      $composableBuilder(column: $table.groblje, builder: (column) => column);

  GeneratedColumn<String> get tipGroblja => $composableBuilder(
    column: $table.tipGroblja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vrstaCeremonije => $composableBuilder(
    column: $table.vrstaCeremonije,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datumCeremonije => $composableBuilder(
    column: $table.datumCeremonije,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vremeCeremonije => $composableBuilder(
    column: $table.vremeCeremonije,
    builder: (column) => column,
  );

  GeneratedColumn<String> get opelo =>
      $composableBuilder(column: $table.opelo, builder: (column) => column);

  GeneratedColumn<String> get opeloMesto => $composableBuilder(
    column: $table.opeloMesto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vremeOpela => $composableBuilder(
    column: $table.vremeOpela,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vremeIspracaja => $composableBuilder(
    column: $table.vremeIspracaja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grobnoMesto => $composableBuilder(
    column: $table.grobnoMesto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipGrobnogMesta => $composableBuilder(
    column: $table.tipGrobnogMesta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parcela =>
      $composableBuilder(column: $table.parcela, builder: (column) => column);

  GeneratedColumn<String> get grobBroj =>
      $composableBuilder(column: $table.grobBroj, builder: (column) => column);

  GeneratedColumn<String> get redGrob =>
      $composableBuilder(column: $table.redGrob, builder: (column) => column);

  GeneratedColumn<String> get npk =>
      $composableBuilder(column: $table.npk, builder: (column) => column);

  GeneratedColumn<String> get grobnica =>
      $composableBuilder(column: $table.grobnica, builder: (column) => column);

  GeneratedColumn<String> get urnaSifra =>
      $composableBuilder(column: $table.urnaSifra, builder: (column) => column);

  GeneratedColumn<String> get tipPolaganja => $composableBuilder(
    column: $table.tipPolaganja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urnaParcela => $composableBuilder(
    column: $table.urnaParcela,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urnaBroj =>
      $composableBuilder(column: $table.urnaBroj, builder: (column) => column);

  GeneratedColumn<String> get urnaRed =>
      $composableBuilder(column: $table.urnaRed, builder: (column) => column);

  GeneratedColumn<String> get urnaNpk =>
      $composableBuilder(column: $table.urnaNpk, builder: (column) => column);

  GeneratedColumn<bool> get sahranaVanSrbije => $composableBuilder(
    column: $table.sahranaVanSrbije,
    builder: (column) => column,
  );

  GeneratedColumn<String> get svisZemlja => $composableBuilder(
    column: $table.svisZemlja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get svisGrad =>
      $composableBuilder(column: $table.svisGrad, builder: (column) => column);

  GeneratedColumn<bool> get docekPosmrtnihOstataka => $composableBuilder(
    column: $table.docekPosmrtnihOstataka,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docekMesto => $composableBuilder(
    column: $table.docekMesto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docekVreme => $composableBuilder(
    column: $table.docekVreme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get simbol =>
      $composableBuilder(column: $table.simbol, builder: (column) => column);

  GeneratedColumn<String> get pismo =>
      $composableBuilder(column: $table.pismo, builder: (column) => column);

  GeneratedColumn<String> get parteIme =>
      $composableBuilder(column: $table.parteIme, builder: (column) => column);

  GeneratedColumn<String> get ozaloseni =>
      $composableBuilder(column: $table.ozaloseni, builder: (column) => column);

  GeneratedColumn<double> get avans =>
      $composableBuilder(column: $table.avans, builder: (column) => column);

  GeneratedColumn<double> get troskoviJkp => $composableBuilder(
    column: $table.troskoviJkp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get jkpPlacaSamostalno => $composableBuilder(
    column: $table.jkpPlacaSamostalno,
    builder: (column) => column,
  );

  GeneratedColumn<double> get popust =>
      $composableBuilder(column: $table.popust, builder: (column) => column);

  GeneratedColumn<String> get nacinPlacanja => $composableBuilder(
    column: $table.nacinPlacanja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get napomenaPlacanja => $composableBuilder(
    column: $table.napomenaPlacanja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get napomena =>
      $composableBuilder(column: $table.napomena, builder: (column) => column);

  GeneratedColumn<int> get exportVerzija => $composableBuilder(
    column: $table.exportVerzija,
    builder: (column) => column,
  );

  Expression<T> kontaktLicaRefs<T extends Object>(
    Expression<T> Function($$KontaktLicaTableAnnotationComposer a) f,
  ) {
    final $$KontaktLicaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.kontaktLica,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KontaktLicaTableAnnotationComposer(
            $db: $db,
            $table: $db.kontaktLica,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> iriuRefs<T extends Object>(
    Expression<T> Function($$IriuTableAnnotationComposer a) f,
  ) {
    final $$IriuTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.iriu,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IriuTableAnnotationComposer(
            $db: $db,
            $table: $db.iriu,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stanjeRobePoslediceRefs<T extends Object>(
    Expression<T> Function($$StanjeRobePoslediceTableAnnotationComposer a) f,
  ) {
    final $$StanjeRobePoslediceTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stanjeRobePosledice,
          getReferencedColumn: (t) => t.predmetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StanjeRobePoslediceTableAnnotationComposer(
                $db: $db,
                $table: $db.stanjeRobePosledice,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> logIzmenaRefs<T extends Object>(
    Expression<T> Function($$LogIzmenaTableAnnotationComposer a) f,
  ) {
    final $$LogIzmenaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logIzmena,
      getReferencedColumn: (t) => t.predmetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogIzmenaTableAnnotationComposer(
            $db: $db,
            $table: $db.logIzmena,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PredmetiTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredmetiTable,
          PredmetiData,
          $$PredmetiTableFilterComposer,
          $$PredmetiTableOrderingComposer,
          $$PredmetiTableAnnotationComposer,
          $$PredmetiTableCreateCompanionBuilder,
          $$PredmetiTableUpdateCompanionBuilder,
          (PredmetiData, $$PredmetiTableReferences),
          PredmetiData,
          PrefetchHooks Function({
            bool kontaktLicaRefs,
            bool iriuRefs,
            bool stanjeRobePoslediceRefs,
            bool logIzmenaRefs,
          })
        > {
  $$PredmetiTableTableManager(_$AppDatabase db, $PredmetiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredmetiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredmetiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredmetiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> brojPredmeta = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> datumKreiranja = const Value.absent(),
                Value<int?> savetnikId = const Value.absent(),
                Value<int> verzija = const Value.absent(),
                Value<String> businessScenarioId = const Value.absent(),
                Value<String> sourceIdentity = const Value.absent(),
                Value<int?> createdByKorisnikId = const Value.absent(),
                Value<int?> lastBusinessModifiedByKorisnikId =
                    const Value.absent(),
                Value<String?> lastBusinessModifiedAt = const Value.absent(),
                Value<String> ime = const Value.absent(),
                Value<String> prezime = const Value.absent(),
                Value<String> srednje = const Value.absent(),
                Value<String> devojackoPrezime = const Value.absent(),
                Value<String> jmbg = const Value.absent(),
                Value<String> pol = const Value.absent(),
                Value<String> datumRodjenja = const Value.absent(),
                Value<String> mestoRodjenja = const Value.absent(),
                Value<String> datumSmrti = const Value.absent(),
                Value<String> mestoSmrti = const Value.absent(),
                Value<String> uzrokSmrti = const Value.absent(),
                Value<String> adresa = const Value.absent(),
                Value<String> imeOca = const Value.absent(),
                Value<String> imeMajke = const Value.absent(),
                Value<String> bracnoStanje = const Value.absent(),
                Value<String> bracniDrugIme = const Value.absent(),
                Value<String> bracniDrugPrezime = const Value.absent(),
                Value<String> bracniDrugPol = const Value.absent(),
                Value<String> bracniDrugJmbg = const Value.absent(),
                Value<String> bracniDrugDevojacko = const Value.absent(),
                Value<String> zanimanje = const Value.absent(),
                Value<bool> zanimanjeNaParti = const Value.absent(),
                Value<String> titula = const Value.absent(),
                Value<bool> titulaIspred = const Value.absent(),
                Value<String> cin = const Value.absent(),
                Value<bool> cinNaParti = const Value.absent(),
                Value<bool> srednjeNaParti = const Value.absent(),
                Value<String> nadimak = const Value.absent(),
                Value<bool> nadimakNaParti = const Value.absent(),
                Value<bool> nadimakCrtica = const Value.absent(),
                Value<String> radniStatus = const Value.absent(),
                Value<String> penzioner = const Value.absent(),
                Value<String> penzionerSrbije = const Value.absent(),
                Value<String> vojniPenzioner = const Value.absent(),
                Value<String> vojnePocasti = const Value.absent(),
                Value<String> posmrtnaPomoc = const Value.absent(),
                Value<double> refundacijaPio = const Value.absent(),
                Value<String> narucilacRefundira = const Value.absent(),
                Value<String> bracniDrugOstvarujePravo = const Value.absent(),
                Value<String> bracniDrugJePenzioner = const Value.absent(),
                Value<String> penzionerNapomena = const Value.absent(),
                Value<String> naruTip = const Value.absent(),
                Value<String> naruIme = const Value.absent(),
                Value<String> naruPrezime = const Value.absent(),
                Value<String> naruImePrezime = const Value.absent(),
                Value<String> naruJmbg = const Value.absent(),
                Value<String> naruAdresa = const Value.absent(),
                Value<String> naruBrojLk = const Value.absent(),
                Value<String> naruTelefon1 = const Value.absent(),
                Value<String> naruTelefon2 = const Value.absent(),
                Value<String> naruEmail = const Value.absent(),
                Value<String> naruPlNaziv = const Value.absent(),
                Value<String> naruPlAdresa = const Value.absent(),
                Value<String> naruPlPib = const Value.absent(),
                Value<String> naruPlMb = const Value.absent(),
                Value<String> naruPlOdgovornoLice = const Value.absent(),
                Value<String> naruPlTelefon1 = const Value.absent(),
                Value<String> naruPlTelefon2 = const Value.absent(),
                Value<String> naruPlEmail = const Value.absent(),
                Value<bool> naruIstiZaJkp = const Value.absent(),
                Value<String> jkpTip = const Value.absent(),
                Value<String> jkpIme = const Value.absent(),
                Value<String> jkpPrezime = const Value.absent(),
                Value<String> jkpImePrezime = const Value.absent(),
                Value<String> jkpJmbg = const Value.absent(),
                Value<String> jkpAdresa = const Value.absent(),
                Value<String> jkpBrojLk = const Value.absent(),
                Value<String> jkpTelefon1 = const Value.absent(),
                Value<String> jkpTelefon2 = const Value.absent(),
                Value<String> jkpEmail = const Value.absent(),
                Value<String> jkpPlNaziv = const Value.absent(),
                Value<String> jkpPlAdresa = const Value.absent(),
                Value<String> jkpPlPib = const Value.absent(),
                Value<String> jkpPlMb = const Value.absent(),
                Value<String> jkpPlOdgovornoLice = const Value.absent(),
                Value<String> jkpPlTelefon1 = const Value.absent(),
                Value<String> jkpPlEmail = const Value.absent(),
                Value<String> groblje = const Value.absent(),
                Value<String> tipGroblja = const Value.absent(),
                Value<String> vrstaCeremonije = const Value.absent(),
                Value<String> datumCeremonije = const Value.absent(),
                Value<String> vremeCeremonije = const Value.absent(),
                Value<String> opelo = const Value.absent(),
                Value<String> opeloMesto = const Value.absent(),
                Value<String> vremeOpela = const Value.absent(),
                Value<String> vremeIspracaja = const Value.absent(),
                Value<String> grobnoMesto = const Value.absent(),
                Value<String> tipGrobnogMesta = const Value.absent(),
                Value<String> parcela = const Value.absent(),
                Value<String> grobBroj = const Value.absent(),
                Value<String> redGrob = const Value.absent(),
                Value<String> npk = const Value.absent(),
                Value<String> grobnica = const Value.absent(),
                Value<String> urnaSifra = const Value.absent(),
                Value<String> tipPolaganja = const Value.absent(),
                Value<String> urnaParcela = const Value.absent(),
                Value<String> urnaBroj = const Value.absent(),
                Value<String> urnaRed = const Value.absent(),
                Value<String> urnaNpk = const Value.absent(),
                Value<bool> sahranaVanSrbije = const Value.absent(),
                Value<String> svisZemlja = const Value.absent(),
                Value<String> svisGrad = const Value.absent(),
                Value<bool> docekPosmrtnihOstataka = const Value.absent(),
                Value<String> docekMesto = const Value.absent(),
                Value<String> docekVreme = const Value.absent(),
                Value<String> simbol = const Value.absent(),
                Value<String> pismo = const Value.absent(),
                Value<String> parteIme = const Value.absent(),
                Value<String> ozaloseni = const Value.absent(),
                Value<double> avans = const Value.absent(),
                Value<double> troskoviJkp = const Value.absent(),
                Value<bool> jkpPlacaSamostalno = const Value.absent(),
                Value<double> popust = const Value.absent(),
                Value<String> nacinPlacanja = const Value.absent(),
                Value<String> napomenaPlacanja = const Value.absent(),
                Value<String> napomena = const Value.absent(),
                Value<int> exportVerzija = const Value.absent(),
              }) => PredmetiCompanion(
                id: id,
                brojPredmeta: brojPredmeta,
                status: status,
                datumKreiranja: datumKreiranja,
                savetnikId: savetnikId,
                verzija: verzija,
                businessScenarioId: businessScenarioId,
                sourceIdentity: sourceIdentity,
                createdByKorisnikId: createdByKorisnikId,
                lastBusinessModifiedByKorisnikId:
                    lastBusinessModifiedByKorisnikId,
                lastBusinessModifiedAt: lastBusinessModifiedAt,
                ime: ime,
                prezime: prezime,
                srednje: srednje,
                devojackoPrezime: devojackoPrezime,
                jmbg: jmbg,
                pol: pol,
                datumRodjenja: datumRodjenja,
                mestoRodjenja: mestoRodjenja,
                datumSmrti: datumSmrti,
                mestoSmrti: mestoSmrti,
                uzrokSmrti: uzrokSmrti,
                adresa: adresa,
                imeOca: imeOca,
                imeMajke: imeMajke,
                bracnoStanje: bracnoStanje,
                bracniDrugIme: bracniDrugIme,
                bracniDrugPrezime: bracniDrugPrezime,
                bracniDrugPol: bracniDrugPol,
                bracniDrugJmbg: bracniDrugJmbg,
                bracniDrugDevojacko: bracniDrugDevojacko,
                zanimanje: zanimanje,
                zanimanjeNaParti: zanimanjeNaParti,
                titula: titula,
                titulaIspred: titulaIspred,
                cin: cin,
                cinNaParti: cinNaParti,
                srednjeNaParti: srednjeNaParti,
                nadimak: nadimak,
                nadimakNaParti: nadimakNaParti,
                nadimakCrtica: nadimakCrtica,
                radniStatus: radniStatus,
                penzioner: penzioner,
                penzionerSrbije: penzionerSrbije,
                vojniPenzioner: vojniPenzioner,
                vojnePocasti: vojnePocasti,
                posmrtnaPomoc: posmrtnaPomoc,
                refundacijaPio: refundacijaPio,
                narucilacRefundira: narucilacRefundira,
                bracniDrugOstvarujePravo: bracniDrugOstvarujePravo,
                bracniDrugJePenzioner: bracniDrugJePenzioner,
                penzionerNapomena: penzionerNapomena,
                naruTip: naruTip,
                naruIme: naruIme,
                naruPrezime: naruPrezime,
                naruImePrezime: naruImePrezime,
                naruJmbg: naruJmbg,
                naruAdresa: naruAdresa,
                naruBrojLk: naruBrojLk,
                naruTelefon1: naruTelefon1,
                naruTelefon2: naruTelefon2,
                naruEmail: naruEmail,
                naruPlNaziv: naruPlNaziv,
                naruPlAdresa: naruPlAdresa,
                naruPlPib: naruPlPib,
                naruPlMb: naruPlMb,
                naruPlOdgovornoLice: naruPlOdgovornoLice,
                naruPlTelefon1: naruPlTelefon1,
                naruPlTelefon2: naruPlTelefon2,
                naruPlEmail: naruPlEmail,
                naruIstiZaJkp: naruIstiZaJkp,
                jkpTip: jkpTip,
                jkpIme: jkpIme,
                jkpPrezime: jkpPrezime,
                jkpImePrezime: jkpImePrezime,
                jkpJmbg: jkpJmbg,
                jkpAdresa: jkpAdresa,
                jkpBrojLk: jkpBrojLk,
                jkpTelefon1: jkpTelefon1,
                jkpTelefon2: jkpTelefon2,
                jkpEmail: jkpEmail,
                jkpPlNaziv: jkpPlNaziv,
                jkpPlAdresa: jkpPlAdresa,
                jkpPlPib: jkpPlPib,
                jkpPlMb: jkpPlMb,
                jkpPlOdgovornoLice: jkpPlOdgovornoLice,
                jkpPlTelefon1: jkpPlTelefon1,
                jkpPlEmail: jkpPlEmail,
                groblje: groblje,
                tipGroblja: tipGroblja,
                vrstaCeremonije: vrstaCeremonije,
                datumCeremonije: datumCeremonije,
                vremeCeremonije: vremeCeremonije,
                opelo: opelo,
                opeloMesto: opeloMesto,
                vremeOpela: vremeOpela,
                vremeIspracaja: vremeIspracaja,
                grobnoMesto: grobnoMesto,
                tipGrobnogMesta: tipGrobnogMesta,
                parcela: parcela,
                grobBroj: grobBroj,
                redGrob: redGrob,
                npk: npk,
                grobnica: grobnica,
                urnaSifra: urnaSifra,
                tipPolaganja: tipPolaganja,
                urnaParcela: urnaParcela,
                urnaBroj: urnaBroj,
                urnaRed: urnaRed,
                urnaNpk: urnaNpk,
                sahranaVanSrbije: sahranaVanSrbije,
                svisZemlja: svisZemlja,
                svisGrad: svisGrad,
                docekPosmrtnihOstataka: docekPosmrtnihOstataka,
                docekMesto: docekMesto,
                docekVreme: docekVreme,
                simbol: simbol,
                pismo: pismo,
                parteIme: parteIme,
                ozaloseni: ozaloseni,
                avans: avans,
                troskoviJkp: troskoviJkp,
                jkpPlacaSamostalno: jkpPlacaSamostalno,
                popust: popust,
                nacinPlacanja: nacinPlacanja,
                napomenaPlacanja: napomenaPlacanja,
                napomena: napomena,
                exportVerzija: exportVerzija,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> brojPredmeta = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> datumKreiranja = const Value.absent(),
                Value<int?> savetnikId = const Value.absent(),
                Value<int> verzija = const Value.absent(),
                Value<String> businessScenarioId = const Value.absent(),
                Value<String> sourceIdentity = const Value.absent(),
                Value<int?> createdByKorisnikId = const Value.absent(),
                Value<int?> lastBusinessModifiedByKorisnikId =
                    const Value.absent(),
                Value<String?> lastBusinessModifiedAt = const Value.absent(),
                Value<String> ime = const Value.absent(),
                Value<String> prezime = const Value.absent(),
                Value<String> srednje = const Value.absent(),
                Value<String> devojackoPrezime = const Value.absent(),
                Value<String> jmbg = const Value.absent(),
                Value<String> pol = const Value.absent(),
                Value<String> datumRodjenja = const Value.absent(),
                Value<String> mestoRodjenja = const Value.absent(),
                Value<String> datumSmrti = const Value.absent(),
                Value<String> mestoSmrti = const Value.absent(),
                Value<String> uzrokSmrti = const Value.absent(),
                Value<String> adresa = const Value.absent(),
                Value<String> imeOca = const Value.absent(),
                Value<String> imeMajke = const Value.absent(),
                Value<String> bracnoStanje = const Value.absent(),
                Value<String> bracniDrugIme = const Value.absent(),
                Value<String> bracniDrugPrezime = const Value.absent(),
                Value<String> bracniDrugPol = const Value.absent(),
                Value<String> bracniDrugJmbg = const Value.absent(),
                Value<String> bracniDrugDevojacko = const Value.absent(),
                Value<String> zanimanje = const Value.absent(),
                Value<bool> zanimanjeNaParti = const Value.absent(),
                Value<String> titula = const Value.absent(),
                Value<bool> titulaIspred = const Value.absent(),
                Value<String> cin = const Value.absent(),
                Value<bool> cinNaParti = const Value.absent(),
                Value<bool> srednjeNaParti = const Value.absent(),
                Value<String> nadimak = const Value.absent(),
                Value<bool> nadimakNaParti = const Value.absent(),
                Value<bool> nadimakCrtica = const Value.absent(),
                Value<String> radniStatus = const Value.absent(),
                Value<String> penzioner = const Value.absent(),
                Value<String> penzionerSrbije = const Value.absent(),
                Value<String> vojniPenzioner = const Value.absent(),
                Value<String> vojnePocasti = const Value.absent(),
                Value<String> posmrtnaPomoc = const Value.absent(),
                Value<double> refundacijaPio = const Value.absent(),
                Value<String> narucilacRefundira = const Value.absent(),
                Value<String> bracniDrugOstvarujePravo = const Value.absent(),
                Value<String> bracniDrugJePenzioner = const Value.absent(),
                Value<String> penzionerNapomena = const Value.absent(),
                Value<String> naruTip = const Value.absent(),
                Value<String> naruIme = const Value.absent(),
                Value<String> naruPrezime = const Value.absent(),
                Value<String> naruImePrezime = const Value.absent(),
                Value<String> naruJmbg = const Value.absent(),
                Value<String> naruAdresa = const Value.absent(),
                Value<String> naruBrojLk = const Value.absent(),
                Value<String> naruTelefon1 = const Value.absent(),
                Value<String> naruTelefon2 = const Value.absent(),
                Value<String> naruEmail = const Value.absent(),
                Value<String> naruPlNaziv = const Value.absent(),
                Value<String> naruPlAdresa = const Value.absent(),
                Value<String> naruPlPib = const Value.absent(),
                Value<String> naruPlMb = const Value.absent(),
                Value<String> naruPlOdgovornoLice = const Value.absent(),
                Value<String> naruPlTelefon1 = const Value.absent(),
                Value<String> naruPlTelefon2 = const Value.absent(),
                Value<String> naruPlEmail = const Value.absent(),
                Value<bool> naruIstiZaJkp = const Value.absent(),
                Value<String> jkpTip = const Value.absent(),
                Value<String> jkpIme = const Value.absent(),
                Value<String> jkpPrezime = const Value.absent(),
                Value<String> jkpImePrezime = const Value.absent(),
                Value<String> jkpJmbg = const Value.absent(),
                Value<String> jkpAdresa = const Value.absent(),
                Value<String> jkpBrojLk = const Value.absent(),
                Value<String> jkpTelefon1 = const Value.absent(),
                Value<String> jkpTelefon2 = const Value.absent(),
                Value<String> jkpEmail = const Value.absent(),
                Value<String> jkpPlNaziv = const Value.absent(),
                Value<String> jkpPlAdresa = const Value.absent(),
                Value<String> jkpPlPib = const Value.absent(),
                Value<String> jkpPlMb = const Value.absent(),
                Value<String> jkpPlOdgovornoLice = const Value.absent(),
                Value<String> jkpPlTelefon1 = const Value.absent(),
                Value<String> jkpPlEmail = const Value.absent(),
                Value<String> groblje = const Value.absent(),
                Value<String> tipGroblja = const Value.absent(),
                Value<String> vrstaCeremonije = const Value.absent(),
                Value<String> datumCeremonije = const Value.absent(),
                Value<String> vremeCeremonije = const Value.absent(),
                Value<String> opelo = const Value.absent(),
                Value<String> opeloMesto = const Value.absent(),
                Value<String> vremeOpela = const Value.absent(),
                Value<String> vremeIspracaja = const Value.absent(),
                Value<String> grobnoMesto = const Value.absent(),
                Value<String> tipGrobnogMesta = const Value.absent(),
                Value<String> parcela = const Value.absent(),
                Value<String> grobBroj = const Value.absent(),
                Value<String> redGrob = const Value.absent(),
                Value<String> npk = const Value.absent(),
                Value<String> grobnica = const Value.absent(),
                Value<String> urnaSifra = const Value.absent(),
                Value<String> tipPolaganja = const Value.absent(),
                Value<String> urnaParcela = const Value.absent(),
                Value<String> urnaBroj = const Value.absent(),
                Value<String> urnaRed = const Value.absent(),
                Value<String> urnaNpk = const Value.absent(),
                Value<bool> sahranaVanSrbije = const Value.absent(),
                Value<String> svisZemlja = const Value.absent(),
                Value<String> svisGrad = const Value.absent(),
                Value<bool> docekPosmrtnihOstataka = const Value.absent(),
                Value<String> docekMesto = const Value.absent(),
                Value<String> docekVreme = const Value.absent(),
                Value<String> simbol = const Value.absent(),
                Value<String> pismo = const Value.absent(),
                Value<String> parteIme = const Value.absent(),
                Value<String> ozaloseni = const Value.absent(),
                Value<double> avans = const Value.absent(),
                Value<double> troskoviJkp = const Value.absent(),
                Value<bool> jkpPlacaSamostalno = const Value.absent(),
                Value<double> popust = const Value.absent(),
                Value<String> nacinPlacanja = const Value.absent(),
                Value<String> napomenaPlacanja = const Value.absent(),
                Value<String> napomena = const Value.absent(),
                Value<int> exportVerzija = const Value.absent(),
              }) => PredmetiCompanion.insert(
                id: id,
                brojPredmeta: brojPredmeta,
                status: status,
                datumKreiranja: datumKreiranja,
                savetnikId: savetnikId,
                verzija: verzija,
                businessScenarioId: businessScenarioId,
                sourceIdentity: sourceIdentity,
                createdByKorisnikId: createdByKorisnikId,
                lastBusinessModifiedByKorisnikId:
                    lastBusinessModifiedByKorisnikId,
                lastBusinessModifiedAt: lastBusinessModifiedAt,
                ime: ime,
                prezime: prezime,
                srednje: srednje,
                devojackoPrezime: devojackoPrezime,
                jmbg: jmbg,
                pol: pol,
                datumRodjenja: datumRodjenja,
                mestoRodjenja: mestoRodjenja,
                datumSmrti: datumSmrti,
                mestoSmrti: mestoSmrti,
                uzrokSmrti: uzrokSmrti,
                adresa: adresa,
                imeOca: imeOca,
                imeMajke: imeMajke,
                bracnoStanje: bracnoStanje,
                bracniDrugIme: bracniDrugIme,
                bracniDrugPrezime: bracniDrugPrezime,
                bracniDrugPol: bracniDrugPol,
                bracniDrugJmbg: bracniDrugJmbg,
                bracniDrugDevojacko: bracniDrugDevojacko,
                zanimanje: zanimanje,
                zanimanjeNaParti: zanimanjeNaParti,
                titula: titula,
                titulaIspred: titulaIspred,
                cin: cin,
                cinNaParti: cinNaParti,
                srednjeNaParti: srednjeNaParti,
                nadimak: nadimak,
                nadimakNaParti: nadimakNaParti,
                nadimakCrtica: nadimakCrtica,
                radniStatus: radniStatus,
                penzioner: penzioner,
                penzionerSrbije: penzionerSrbije,
                vojniPenzioner: vojniPenzioner,
                vojnePocasti: vojnePocasti,
                posmrtnaPomoc: posmrtnaPomoc,
                refundacijaPio: refundacijaPio,
                narucilacRefundira: narucilacRefundira,
                bracniDrugOstvarujePravo: bracniDrugOstvarujePravo,
                bracniDrugJePenzioner: bracniDrugJePenzioner,
                penzionerNapomena: penzionerNapomena,
                naruTip: naruTip,
                naruIme: naruIme,
                naruPrezime: naruPrezime,
                naruImePrezime: naruImePrezime,
                naruJmbg: naruJmbg,
                naruAdresa: naruAdresa,
                naruBrojLk: naruBrojLk,
                naruTelefon1: naruTelefon1,
                naruTelefon2: naruTelefon2,
                naruEmail: naruEmail,
                naruPlNaziv: naruPlNaziv,
                naruPlAdresa: naruPlAdresa,
                naruPlPib: naruPlPib,
                naruPlMb: naruPlMb,
                naruPlOdgovornoLice: naruPlOdgovornoLice,
                naruPlTelefon1: naruPlTelefon1,
                naruPlTelefon2: naruPlTelefon2,
                naruPlEmail: naruPlEmail,
                naruIstiZaJkp: naruIstiZaJkp,
                jkpTip: jkpTip,
                jkpIme: jkpIme,
                jkpPrezime: jkpPrezime,
                jkpImePrezime: jkpImePrezime,
                jkpJmbg: jkpJmbg,
                jkpAdresa: jkpAdresa,
                jkpBrojLk: jkpBrojLk,
                jkpTelefon1: jkpTelefon1,
                jkpTelefon2: jkpTelefon2,
                jkpEmail: jkpEmail,
                jkpPlNaziv: jkpPlNaziv,
                jkpPlAdresa: jkpPlAdresa,
                jkpPlPib: jkpPlPib,
                jkpPlMb: jkpPlMb,
                jkpPlOdgovornoLice: jkpPlOdgovornoLice,
                jkpPlTelefon1: jkpPlTelefon1,
                jkpPlEmail: jkpPlEmail,
                groblje: groblje,
                tipGroblja: tipGroblja,
                vrstaCeremonije: vrstaCeremonije,
                datumCeremonije: datumCeremonije,
                vremeCeremonije: vremeCeremonije,
                opelo: opelo,
                opeloMesto: opeloMesto,
                vremeOpela: vremeOpela,
                vremeIspracaja: vremeIspracaja,
                grobnoMesto: grobnoMesto,
                tipGrobnogMesta: tipGrobnogMesta,
                parcela: parcela,
                grobBroj: grobBroj,
                redGrob: redGrob,
                npk: npk,
                grobnica: grobnica,
                urnaSifra: urnaSifra,
                tipPolaganja: tipPolaganja,
                urnaParcela: urnaParcela,
                urnaBroj: urnaBroj,
                urnaRed: urnaRed,
                urnaNpk: urnaNpk,
                sahranaVanSrbije: sahranaVanSrbije,
                svisZemlja: svisZemlja,
                svisGrad: svisGrad,
                docekPosmrtnihOstataka: docekPosmrtnihOstataka,
                docekMesto: docekMesto,
                docekVreme: docekVreme,
                simbol: simbol,
                pismo: pismo,
                parteIme: parteIme,
                ozaloseni: ozaloseni,
                avans: avans,
                troskoviJkp: troskoviJkp,
                jkpPlacaSamostalno: jkpPlacaSamostalno,
                popust: popust,
                nacinPlacanja: nacinPlacanja,
                napomenaPlacanja: napomenaPlacanja,
                napomena: napomena,
                exportVerzija: exportVerzija,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PredmetiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                kontaktLicaRefs = false,
                iriuRefs = false,
                stanjeRobePoslediceRefs = false,
                logIzmenaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (kontaktLicaRefs) db.kontaktLica,
                    if (iriuRefs) db.iriu,
                    if (stanjeRobePoslediceRefs) db.stanjeRobePosledice,
                    if (logIzmenaRefs) db.logIzmena,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (kontaktLicaRefs)
                        await $_getPrefetchedData<
                          PredmetiData,
                          $PredmetiTable,
                          KontaktLicaData
                        >(
                          currentTable: table,
                          referencedTable: $$PredmetiTableReferences
                              ._kontaktLicaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PredmetiTableReferences(
                                db,
                                table,
                                p0,
                              ).kontaktLicaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predmetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (iriuRefs)
                        await $_getPrefetchedData<
                          PredmetiData,
                          $PredmetiTable,
                          IriuData
                        >(
                          currentTable: table,
                          referencedTable: $$PredmetiTableReferences
                              ._iriuRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PredmetiTableReferences(db, table, p0).iriuRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predmetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stanjeRobePoslediceRefs)
                        await $_getPrefetchedData<
                          PredmetiData,
                          $PredmetiTable,
                          StanjeRobePoslediceData
                        >(
                          currentTable: table,
                          referencedTable: $$PredmetiTableReferences
                              ._stanjeRobePoslediceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PredmetiTableReferences(
                                db,
                                table,
                                p0,
                              ).stanjeRobePoslediceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predmetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (logIzmenaRefs)
                        await $_getPrefetchedData<
                          PredmetiData,
                          $PredmetiTable,
                          LogIzmenaData
                        >(
                          currentTable: table,
                          referencedTable: $$PredmetiTableReferences
                              ._logIzmenaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PredmetiTableReferences(
                                db,
                                table,
                                p0,
                              ).logIzmenaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predmetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PredmetiTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredmetiTable,
      PredmetiData,
      $$PredmetiTableFilterComposer,
      $$PredmetiTableOrderingComposer,
      $$PredmetiTableAnnotationComposer,
      $$PredmetiTableCreateCompanionBuilder,
      $$PredmetiTableUpdateCompanionBuilder,
      (PredmetiData, $$PredmetiTableReferences),
      PredmetiData,
      PrefetchHooks Function({
        bool kontaktLicaRefs,
        bool iriuRefs,
        bool stanjeRobePoslediceRefs,
        bool logIzmenaRefs,
      })
    >;
typedef $$KontaktLicaTableCreateCompanionBuilder =
    KontaktLicaCompanion Function({
      Value<int> id,
      required int predmetId,
      required String blok,
      Value<String> imePrezime,
      Value<String> telefon,
      Value<String> email,
      Value<String> napomena,
      Value<int> redosled,
    });
typedef $$KontaktLicaTableUpdateCompanionBuilder =
    KontaktLicaCompanion Function({
      Value<int> id,
      Value<int> predmetId,
      Value<String> blok,
      Value<String> imePrezime,
      Value<String> telefon,
      Value<String> email,
      Value<String> napomena,
      Value<int> redosled,
    });

final class $$KontaktLicaTableReferences
    extends BaseReferences<_$AppDatabase, $KontaktLicaTable, KontaktLicaData> {
  $$KontaktLicaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PredmetiTable _predmetIdTable(_$AppDatabase db) =>
      db.predmeti.createAlias(
        $_aliasNameGenerator(db.kontaktLica.predmetId, db.predmeti.id),
      );

  $$PredmetiTableProcessedTableManager get predmetId {
    final $_column = $_itemColumn<int>('predmet_id')!;

    final manager = $$PredmetiTableTableManager(
      $_db,
      $_db.predmeti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predmetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$KontaktLicaTableFilterComposer
    extends Composer<_$AppDatabase, $KontaktLicaTable> {
  $$KontaktLicaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blok => $composableBuilder(
    column: $table.blok,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imePrezime => $composableBuilder(
    column: $table.imePrezime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefon => $composableBuilder(
    column: $table.telefon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get napomena => $composableBuilder(
    column: $table.napomena,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redosled => $composableBuilder(
    column: $table.redosled,
    builder: (column) => ColumnFilters(column),
  );

  $$PredmetiTableFilterComposer get predmetId {
    final $$PredmetiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableFilterComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KontaktLicaTableOrderingComposer
    extends Composer<_$AppDatabase, $KontaktLicaTable> {
  $$KontaktLicaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blok => $composableBuilder(
    column: $table.blok,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imePrezime => $composableBuilder(
    column: $table.imePrezime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefon => $composableBuilder(
    column: $table.telefon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get napomena => $composableBuilder(
    column: $table.napomena,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redosled => $composableBuilder(
    column: $table.redosled,
    builder: (column) => ColumnOrderings(column),
  );

  $$PredmetiTableOrderingComposer get predmetId {
    final $$PredmetiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableOrderingComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KontaktLicaTableAnnotationComposer
    extends Composer<_$AppDatabase, $KontaktLicaTable> {
  $$KontaktLicaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get blok =>
      $composableBuilder(column: $table.blok, builder: (column) => column);

  GeneratedColumn<String> get imePrezime => $composableBuilder(
    column: $table.imePrezime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telefon =>
      $composableBuilder(column: $table.telefon, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get napomena =>
      $composableBuilder(column: $table.napomena, builder: (column) => column);

  GeneratedColumn<int> get redosled =>
      $composableBuilder(column: $table.redosled, builder: (column) => column);

  $$PredmetiTableAnnotationComposer get predmetId {
    final $$PredmetiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableAnnotationComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KontaktLicaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KontaktLicaTable,
          KontaktLicaData,
          $$KontaktLicaTableFilterComposer,
          $$KontaktLicaTableOrderingComposer,
          $$KontaktLicaTableAnnotationComposer,
          $$KontaktLicaTableCreateCompanionBuilder,
          $$KontaktLicaTableUpdateCompanionBuilder,
          (KontaktLicaData, $$KontaktLicaTableReferences),
          KontaktLicaData,
          PrefetchHooks Function({bool predmetId})
        > {
  $$KontaktLicaTableTableManager(_$AppDatabase db, $KontaktLicaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KontaktLicaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KontaktLicaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KontaktLicaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predmetId = const Value.absent(),
                Value<String> blok = const Value.absent(),
                Value<String> imePrezime = const Value.absent(),
                Value<String> telefon = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> napomena = const Value.absent(),
                Value<int> redosled = const Value.absent(),
              }) => KontaktLicaCompanion(
                id: id,
                predmetId: predmetId,
                blok: blok,
                imePrezime: imePrezime,
                telefon: telefon,
                email: email,
                napomena: napomena,
                redosled: redosled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predmetId,
                required String blok,
                Value<String> imePrezime = const Value.absent(),
                Value<String> telefon = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> napomena = const Value.absent(),
                Value<int> redosled = const Value.absent(),
              }) => KontaktLicaCompanion.insert(
                id: id,
                predmetId: predmetId,
                blok: blok,
                imePrezime: imePrezime,
                telefon: telefon,
                email: email,
                napomena: napomena,
                redosled: redosled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$KontaktLicaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({predmetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (predmetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.predmetId,
                                referencedTable: $$KontaktLicaTableReferences
                                    ._predmetIdTable(db),
                                referencedColumn: $$KontaktLicaTableReferences
                                    ._predmetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$KontaktLicaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KontaktLicaTable,
      KontaktLicaData,
      $$KontaktLicaTableFilterComposer,
      $$KontaktLicaTableOrderingComposer,
      $$KontaktLicaTableAnnotationComposer,
      $$KontaktLicaTableCreateCompanionBuilder,
      $$KontaktLicaTableUpdateCompanionBuilder,
      (KontaktLicaData, $$KontaktLicaTableReferences),
      KontaktLicaData,
      PrefetchHooks Function({bool predmetId})
    >;
typedef $$IriuTableCreateCompanionBuilder =
    IriuCompanion Function({
      Value<int> id,
      required int predmetId,
      Value<String?> katalogStableArticleId,
      required String interniNaziv,
      Value<String> nazivPrikaz,
      Value<String> kom,
      Value<double> iznos,
      Value<bool> cekiran,
      Value<int> redosled,
    });
typedef $$IriuTableUpdateCompanionBuilder =
    IriuCompanion Function({
      Value<int> id,
      Value<int> predmetId,
      Value<String?> katalogStableArticleId,
      Value<String> interniNaziv,
      Value<String> nazivPrikaz,
      Value<String> kom,
      Value<double> iznos,
      Value<bool> cekiran,
      Value<int> redosled,
    });

final class $$IriuTableReferences
    extends BaseReferences<_$AppDatabase, $IriuTable, IriuData> {
  $$IriuTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PredmetiTable _predmetIdTable(_$AppDatabase db) => db.predmeti
      .createAlias($_aliasNameGenerator(db.iriu.predmetId, db.predmeti.id));

  $$PredmetiTableProcessedTableManager get predmetId {
    final $_column = $_itemColumn<int>('predmet_id')!;

    final manager = $$PredmetiTableTableManager(
      $_db,
      $_db.predmeti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predmetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StanjeRobePoslediceTable,
    List<StanjeRobePoslediceData>
  >
  _stanjeRobePoslediceRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stanjeRobePosledice,
        aliasName: $_aliasNameGenerator(
          db.iriu.id,
          db.stanjeRobePosledice.iriuId,
        ),
      );

  $$StanjeRobePoslediceTableProcessedTableManager get stanjeRobePoslediceRefs {
    final manager = $$StanjeRobePoslediceTableTableManager(
      $_db,
      $_db.stanjeRobePosledice,
    ).filter((f) => f.iriuId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stanjeRobePoslediceRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IriuTableFilterComposer extends Composer<_$AppDatabase, $IriuTable> {
  $$IriuTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get katalogStableArticleId => $composableBuilder(
    column: $table.katalogStableArticleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interniNaziv => $composableBuilder(
    column: $table.interniNaziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nazivPrikaz => $composableBuilder(
    column: $table.nazivPrikaz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kom => $composableBuilder(
    column: $table.kom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iznos => $composableBuilder(
    column: $table.iznos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cekiran => $composableBuilder(
    column: $table.cekiran,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redosled => $composableBuilder(
    column: $table.redosled,
    builder: (column) => ColumnFilters(column),
  );

  $$PredmetiTableFilterComposer get predmetId {
    final $$PredmetiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableFilterComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stanjeRobePoslediceRefs(
    Expression<bool> Function($$StanjeRobePoslediceTableFilterComposer f) f,
  ) {
    final $$StanjeRobePoslediceTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stanjeRobePosledice,
      getReferencedColumn: (t) => t.iriuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StanjeRobePoslediceTableFilterComposer(
            $db: $db,
            $table: $db.stanjeRobePosledice,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IriuTableOrderingComposer extends Composer<_$AppDatabase, $IriuTable> {
  $$IriuTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get katalogStableArticleId => $composableBuilder(
    column: $table.katalogStableArticleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interniNaziv => $composableBuilder(
    column: $table.interniNaziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nazivPrikaz => $composableBuilder(
    column: $table.nazivPrikaz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kom => $composableBuilder(
    column: $table.kom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iznos => $composableBuilder(
    column: $table.iznos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cekiran => $composableBuilder(
    column: $table.cekiran,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redosled => $composableBuilder(
    column: $table.redosled,
    builder: (column) => ColumnOrderings(column),
  );

  $$PredmetiTableOrderingComposer get predmetId {
    final $$PredmetiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableOrderingComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IriuTableAnnotationComposer
    extends Composer<_$AppDatabase, $IriuTable> {
  $$IriuTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get katalogStableArticleId => $composableBuilder(
    column: $table.katalogStableArticleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interniNaziv => $composableBuilder(
    column: $table.interniNaziv,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nazivPrikaz => $composableBuilder(
    column: $table.nazivPrikaz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kom =>
      $composableBuilder(column: $table.kom, builder: (column) => column);

  GeneratedColumn<double> get iznos =>
      $composableBuilder(column: $table.iznos, builder: (column) => column);

  GeneratedColumn<bool> get cekiran =>
      $composableBuilder(column: $table.cekiran, builder: (column) => column);

  GeneratedColumn<int> get redosled =>
      $composableBuilder(column: $table.redosled, builder: (column) => column);

  $$PredmetiTableAnnotationComposer get predmetId {
    final $$PredmetiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableAnnotationComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stanjeRobePoslediceRefs<T extends Object>(
    Expression<T> Function($$StanjeRobePoslediceTableAnnotationComposer a) f,
  ) {
    final $$StanjeRobePoslediceTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stanjeRobePosledice,
          getReferencedColumn: (t) => t.iriuId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StanjeRobePoslediceTableAnnotationComposer(
                $db: $db,
                $table: $db.stanjeRobePosledice,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IriuTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IriuTable,
          IriuData,
          $$IriuTableFilterComposer,
          $$IriuTableOrderingComposer,
          $$IriuTableAnnotationComposer,
          $$IriuTableCreateCompanionBuilder,
          $$IriuTableUpdateCompanionBuilder,
          (IriuData, $$IriuTableReferences),
          IriuData,
          PrefetchHooks Function({bool predmetId, bool stanjeRobePoslediceRefs})
        > {
  $$IriuTableTableManager(_$AppDatabase db, $IriuTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IriuTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IriuTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IriuTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predmetId = const Value.absent(),
                Value<String?> katalogStableArticleId = const Value.absent(),
                Value<String> interniNaziv = const Value.absent(),
                Value<String> nazivPrikaz = const Value.absent(),
                Value<String> kom = const Value.absent(),
                Value<double> iznos = const Value.absent(),
                Value<bool> cekiran = const Value.absent(),
                Value<int> redosled = const Value.absent(),
              }) => IriuCompanion(
                id: id,
                predmetId: predmetId,
                katalogStableArticleId: katalogStableArticleId,
                interniNaziv: interniNaziv,
                nazivPrikaz: nazivPrikaz,
                kom: kom,
                iznos: iznos,
                cekiran: cekiran,
                redosled: redosled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predmetId,
                Value<String?> katalogStableArticleId = const Value.absent(),
                required String interniNaziv,
                Value<String> nazivPrikaz = const Value.absent(),
                Value<String> kom = const Value.absent(),
                Value<double> iznos = const Value.absent(),
                Value<bool> cekiran = const Value.absent(),
                Value<int> redosled = const Value.absent(),
              }) => IriuCompanion.insert(
                id: id,
                predmetId: predmetId,
                katalogStableArticleId: katalogStableArticleId,
                interniNaziv: interniNaziv,
                nazivPrikaz: nazivPrikaz,
                kom: kom,
                iznos: iznos,
                cekiran: cekiran,
                redosled: redosled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$IriuTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({predmetId = false, stanjeRobePoslediceRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stanjeRobePoslediceRefs) db.stanjeRobePosledice,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (predmetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.predmetId,
                                    referencedTable: $$IriuTableReferences
                                        ._predmetIdTable(db),
                                    referencedColumn: $$IriuTableReferences
                                        ._predmetIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stanjeRobePoslediceRefs)
                        await $_getPrefetchedData<
                          IriuData,
                          $IriuTable,
                          StanjeRobePoslediceData
                        >(
                          currentTable: table,
                          referencedTable: $$IriuTableReferences
                              ._stanjeRobePoslediceRefsTable(db),
                          managerFromTypedResult: (p0) => $$IriuTableReferences(
                            db,
                            table,
                            p0,
                          ).stanjeRobePoslediceRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.iriuId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IriuTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IriuTable,
      IriuData,
      $$IriuTableFilterComposer,
      $$IriuTableOrderingComposer,
      $$IriuTableAnnotationComposer,
      $$IriuTableCreateCompanionBuilder,
      $$IriuTableUpdateCompanionBuilder,
      (IriuData, $$IriuTableReferences),
      IriuData,
      PrefetchHooks Function({bool predmetId, bool stanjeRobePoslediceRefs})
    >;
typedef $$IriuKatalogConfigTableCreateCompanionBuilder =
    IriuKatalogConfigCompanion Function({
      required String interniNaziv,
      required String nazivPrikaz,
      Value<bool> vidljiv,
      Value<bool> uvekPrikazati,
      Value<String> tip,
      Value<bool> jeKorisnicka,
      Value<int> redosled,
      Value<int> rowid,
    });
typedef $$IriuKatalogConfigTableUpdateCompanionBuilder =
    IriuKatalogConfigCompanion Function({
      Value<String> interniNaziv,
      Value<String> nazivPrikaz,
      Value<bool> vidljiv,
      Value<bool> uvekPrikazati,
      Value<String> tip,
      Value<bool> jeKorisnicka,
      Value<int> redosled,
      Value<int> rowid,
    });

class $$IriuKatalogConfigTableFilterComposer
    extends Composer<_$AppDatabase, $IriuKatalogConfigTable> {
  $$IriuKatalogConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get interniNaziv => $composableBuilder(
    column: $table.interniNaziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nazivPrikaz => $composableBuilder(
    column: $table.nazivPrikaz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vidljiv => $composableBuilder(
    column: $table.vidljiv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uvekPrikazati => $composableBuilder(
    column: $table.uvekPrikazati,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tip => $composableBuilder(
    column: $table.tip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get jeKorisnicka => $composableBuilder(
    column: $table.jeKorisnicka,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get redosled => $composableBuilder(
    column: $table.redosled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IriuKatalogConfigTableOrderingComposer
    extends Composer<_$AppDatabase, $IriuKatalogConfigTable> {
  $$IriuKatalogConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get interniNaziv => $composableBuilder(
    column: $table.interniNaziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nazivPrikaz => $composableBuilder(
    column: $table.nazivPrikaz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vidljiv => $composableBuilder(
    column: $table.vidljiv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uvekPrikazati => $composableBuilder(
    column: $table.uvekPrikazati,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tip => $composableBuilder(
    column: $table.tip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get jeKorisnicka => $composableBuilder(
    column: $table.jeKorisnicka,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redosled => $composableBuilder(
    column: $table.redosled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IriuKatalogConfigTableAnnotationComposer
    extends Composer<_$AppDatabase, $IriuKatalogConfigTable> {
  $$IriuKatalogConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get interniNaziv => $composableBuilder(
    column: $table.interniNaziv,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nazivPrikaz => $composableBuilder(
    column: $table.nazivPrikaz,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vidljiv =>
      $composableBuilder(column: $table.vidljiv, builder: (column) => column);

  GeneratedColumn<bool> get uvekPrikazati => $composableBuilder(
    column: $table.uvekPrikazati,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tip =>
      $composableBuilder(column: $table.tip, builder: (column) => column);

  GeneratedColumn<bool> get jeKorisnicka => $composableBuilder(
    column: $table.jeKorisnicka,
    builder: (column) => column,
  );

  GeneratedColumn<int> get redosled =>
      $composableBuilder(column: $table.redosled, builder: (column) => column);
}

class $$IriuKatalogConfigTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IriuKatalogConfigTable,
          IriuKatalogConfigData,
          $$IriuKatalogConfigTableFilterComposer,
          $$IriuKatalogConfigTableOrderingComposer,
          $$IriuKatalogConfigTableAnnotationComposer,
          $$IriuKatalogConfigTableCreateCompanionBuilder,
          $$IriuKatalogConfigTableUpdateCompanionBuilder,
          (
            IriuKatalogConfigData,
            BaseReferences<
              _$AppDatabase,
              $IriuKatalogConfigTable,
              IriuKatalogConfigData
            >,
          ),
          IriuKatalogConfigData,
          PrefetchHooks Function()
        > {
  $$IriuKatalogConfigTableTableManager(
    _$AppDatabase db,
    $IriuKatalogConfigTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IriuKatalogConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IriuKatalogConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IriuKatalogConfigTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> interniNaziv = const Value.absent(),
                Value<String> nazivPrikaz = const Value.absent(),
                Value<bool> vidljiv = const Value.absent(),
                Value<bool> uvekPrikazati = const Value.absent(),
                Value<String> tip = const Value.absent(),
                Value<bool> jeKorisnicka = const Value.absent(),
                Value<int> redosled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IriuKatalogConfigCompanion(
                interniNaziv: interniNaziv,
                nazivPrikaz: nazivPrikaz,
                vidljiv: vidljiv,
                uvekPrikazati: uvekPrikazati,
                tip: tip,
                jeKorisnicka: jeKorisnicka,
                redosled: redosled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String interniNaziv,
                required String nazivPrikaz,
                Value<bool> vidljiv = const Value.absent(),
                Value<bool> uvekPrikazati = const Value.absent(),
                Value<String> tip = const Value.absent(),
                Value<bool> jeKorisnicka = const Value.absent(),
                Value<int> redosled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IriuKatalogConfigCompanion.insert(
                interniNaziv: interniNaziv,
                nazivPrikaz: nazivPrikaz,
                vidljiv: vidljiv,
                uvekPrikazati: uvekPrikazati,
                tip: tip,
                jeKorisnicka: jeKorisnicka,
                redosled: redosled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IriuKatalogConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IriuKatalogConfigTable,
      IriuKatalogConfigData,
      $$IriuKatalogConfigTableFilterComposer,
      $$IriuKatalogConfigTableOrderingComposer,
      $$IriuKatalogConfigTableAnnotationComposer,
      $$IriuKatalogConfigTableCreateCompanionBuilder,
      $$IriuKatalogConfigTableUpdateCompanionBuilder,
      (
        IriuKatalogConfigData,
        BaseReferences<
          _$AppDatabase,
          $IriuKatalogConfigTable,
          IriuKatalogConfigData
        >,
      ),
      IriuKatalogConfigData,
      PrefetchHooks Function()
    >;
typedef $$KatalogArtikliTableCreateCompanionBuilder =
    KatalogArtikliCompanion Function({
      Value<int> id,
      Value<String?> stableArticleId,
      required String interniNazivKategorije,
      required String naziv,
      Value<double> cena,
      Value<Uint8List?> fotografija,
      Value<String?> fotografijaPath,
    });
typedef $$KatalogArtikliTableUpdateCompanionBuilder =
    KatalogArtikliCompanion Function({
      Value<int> id,
      Value<String?> stableArticleId,
      Value<String> interniNazivKategorije,
      Value<String> naziv,
      Value<double> cena,
      Value<Uint8List?> fotografija,
      Value<String?> fotografijaPath,
    });

class $$KatalogArtikliTableFilterComposer
    extends Composer<_$AppDatabase, $KatalogArtikliTable> {
  $$KatalogArtikliTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interniNazivKategorije => $composableBuilder(
    column: $table.interniNazivKategorije,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naziv => $composableBuilder(
    column: $table.naziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cena => $composableBuilder(
    column: $table.cena,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get fotografija => $composableBuilder(
    column: $table.fotografija,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotografijaPath => $composableBuilder(
    column: $table.fotografijaPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KatalogArtikliTableOrderingComposer
    extends Composer<_$AppDatabase, $KatalogArtikliTable> {
  $$KatalogArtikliTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interniNazivKategorije => $composableBuilder(
    column: $table.interniNazivKategorije,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naziv => $composableBuilder(
    column: $table.naziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cena => $composableBuilder(
    column: $table.cena,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get fotografija => $composableBuilder(
    column: $table.fotografija,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotografijaPath => $composableBuilder(
    column: $table.fotografijaPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KatalogArtikliTableAnnotationComposer
    extends Composer<_$AppDatabase, $KatalogArtikliTable> {
  $$KatalogArtikliTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interniNazivKategorije => $composableBuilder(
    column: $table.interniNazivKategorije,
    builder: (column) => column,
  );

  GeneratedColumn<String> get naziv =>
      $composableBuilder(column: $table.naziv, builder: (column) => column);

  GeneratedColumn<double> get cena =>
      $composableBuilder(column: $table.cena, builder: (column) => column);

  GeneratedColumn<Uint8List> get fotografija => $composableBuilder(
    column: $table.fotografija,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotografijaPath => $composableBuilder(
    column: $table.fotografijaPath,
    builder: (column) => column,
  );
}

class $$KatalogArtikliTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KatalogArtikliTable,
          KatalogArtikliData,
          $$KatalogArtikliTableFilterComposer,
          $$KatalogArtikliTableOrderingComposer,
          $$KatalogArtikliTableAnnotationComposer,
          $$KatalogArtikliTableCreateCompanionBuilder,
          $$KatalogArtikliTableUpdateCompanionBuilder,
          (
            KatalogArtikliData,
            BaseReferences<
              _$AppDatabase,
              $KatalogArtikliTable,
              KatalogArtikliData
            >,
          ),
          KatalogArtikliData,
          PrefetchHooks Function()
        > {
  $$KatalogArtikliTableTableManager(
    _$AppDatabase db,
    $KatalogArtikliTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KatalogArtikliTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KatalogArtikliTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KatalogArtikliTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> stableArticleId = const Value.absent(),
                Value<String> interniNazivKategorije = const Value.absent(),
                Value<String> naziv = const Value.absent(),
                Value<double> cena = const Value.absent(),
                Value<Uint8List?> fotografija = const Value.absent(),
                Value<String?> fotografijaPath = const Value.absent(),
              }) => KatalogArtikliCompanion(
                id: id,
                stableArticleId: stableArticleId,
                interniNazivKategorije: interniNazivKategorije,
                naziv: naziv,
                cena: cena,
                fotografija: fotografija,
                fotografijaPath: fotografijaPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> stableArticleId = const Value.absent(),
                required String interniNazivKategorije,
                required String naziv,
                Value<double> cena = const Value.absent(),
                Value<Uint8List?> fotografija = const Value.absent(),
                Value<String?> fotografijaPath = const Value.absent(),
              }) => KatalogArtikliCompanion.insert(
                id: id,
                stableArticleId: stableArticleId,
                interniNazivKategorije: interniNazivKategorije,
                naziv: naziv,
                cena: cena,
                fotografija: fotografija,
                fotografijaPath: fotografijaPath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KatalogArtikliTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KatalogArtikliTable,
      KatalogArtikliData,
      $$KatalogArtikliTableFilterComposer,
      $$KatalogArtikliTableOrderingComposer,
      $$KatalogArtikliTableAnnotationComposer,
      $$KatalogArtikliTableCreateCompanionBuilder,
      $$KatalogArtikliTableUpdateCompanionBuilder,
      (
        KatalogArtikliData,
        BaseReferences<_$AppDatabase, $KatalogArtikliTable, KatalogArtikliData>,
      ),
      KatalogArtikliData,
      PrefetchHooks Function()
    >;
typedef $$StanjeRobeStavkeTableCreateCompanionBuilder =
    StanjeRobeStavkeCompanion Function({
      Value<int> id,
      required String stableArticleId,
      Value<double> trenutnaKolicina,
      Value<double> minimalnaKolicina,
      Value<bool> aktivna,
      Value<String> datumKreiranja,
      Value<String> datumAzuriranja,
    });
typedef $$StanjeRobeStavkeTableUpdateCompanionBuilder =
    StanjeRobeStavkeCompanion Function({
      Value<int> id,
      Value<String> stableArticleId,
      Value<double> trenutnaKolicina,
      Value<double> minimalnaKolicina,
      Value<bool> aktivna,
      Value<String> datumKreiranja,
      Value<String> datumAzuriranja,
    });

class $$StanjeRobeStavkeTableFilterComposer
    extends Composer<_$AppDatabase, $StanjeRobeStavkeTable> {
  $$StanjeRobeStavkeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trenutnaKolicina => $composableBuilder(
    column: $table.trenutnaKolicina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimalnaKolicina => $composableBuilder(
    column: $table.minimalnaKolicina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktivna => $composableBuilder(
    column: $table.aktivna,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumAzuriranja => $composableBuilder(
    column: $table.datumAzuriranja,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StanjeRobeStavkeTableOrderingComposer
    extends Composer<_$AppDatabase, $StanjeRobeStavkeTable> {
  $$StanjeRobeStavkeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trenutnaKolicina => $composableBuilder(
    column: $table.trenutnaKolicina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimalnaKolicina => $composableBuilder(
    column: $table.minimalnaKolicina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktivna => $composableBuilder(
    column: $table.aktivna,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumAzuriranja => $composableBuilder(
    column: $table.datumAzuriranja,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StanjeRobeStavkeTableAnnotationComposer
    extends Composer<_$AppDatabase, $StanjeRobeStavkeTable> {
  $$StanjeRobeStavkeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get trenutnaKolicina => $composableBuilder(
    column: $table.trenutnaKolicina,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimalnaKolicina => $composableBuilder(
    column: $table.minimalnaKolicina,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aktivna =>
      $composableBuilder(column: $table.aktivna, builder: (column) => column);

  GeneratedColumn<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datumAzuriranja => $composableBuilder(
    column: $table.datumAzuriranja,
    builder: (column) => column,
  );
}

class $$StanjeRobeStavkeTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StanjeRobeStavkeTable,
          StanjeRobeStavkeData,
          $$StanjeRobeStavkeTableFilterComposer,
          $$StanjeRobeStavkeTableOrderingComposer,
          $$StanjeRobeStavkeTableAnnotationComposer,
          $$StanjeRobeStavkeTableCreateCompanionBuilder,
          $$StanjeRobeStavkeTableUpdateCompanionBuilder,
          (
            StanjeRobeStavkeData,
            BaseReferences<
              _$AppDatabase,
              $StanjeRobeStavkeTable,
              StanjeRobeStavkeData
            >,
          ),
          StanjeRobeStavkeData,
          PrefetchHooks Function()
        > {
  $$StanjeRobeStavkeTableTableManager(
    _$AppDatabase db,
    $StanjeRobeStavkeTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StanjeRobeStavkeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StanjeRobeStavkeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StanjeRobeStavkeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stableArticleId = const Value.absent(),
                Value<double> trenutnaKolicina = const Value.absent(),
                Value<double> minimalnaKolicina = const Value.absent(),
                Value<bool> aktivna = const Value.absent(),
                Value<String> datumKreiranja = const Value.absent(),
                Value<String> datumAzuriranja = const Value.absent(),
              }) => StanjeRobeStavkeCompanion(
                id: id,
                stableArticleId: stableArticleId,
                trenutnaKolicina: trenutnaKolicina,
                minimalnaKolicina: minimalnaKolicina,
                aktivna: aktivna,
                datumKreiranja: datumKreiranja,
                datumAzuriranja: datumAzuriranja,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stableArticleId,
                Value<double> trenutnaKolicina = const Value.absent(),
                Value<double> minimalnaKolicina = const Value.absent(),
                Value<bool> aktivna = const Value.absent(),
                Value<String> datumKreiranja = const Value.absent(),
                Value<String> datumAzuriranja = const Value.absent(),
              }) => StanjeRobeStavkeCompanion.insert(
                id: id,
                stableArticleId: stableArticleId,
                trenutnaKolicina: trenutnaKolicina,
                minimalnaKolicina: minimalnaKolicina,
                aktivna: aktivna,
                datumKreiranja: datumKreiranja,
                datumAzuriranja: datumAzuriranja,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StanjeRobeStavkeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StanjeRobeStavkeTable,
      StanjeRobeStavkeData,
      $$StanjeRobeStavkeTableFilterComposer,
      $$StanjeRobeStavkeTableOrderingComposer,
      $$StanjeRobeStavkeTableAnnotationComposer,
      $$StanjeRobeStavkeTableCreateCompanionBuilder,
      $$StanjeRobeStavkeTableUpdateCompanionBuilder,
      (
        StanjeRobeStavkeData,
        BaseReferences<
          _$AppDatabase,
          $StanjeRobeStavkeTable,
          StanjeRobeStavkeData
        >,
      ),
      StanjeRobeStavkeData,
      PrefetchHooks Function()
    >;
typedef $$StanjeRobeAppliedEffectsTableCreateCompanionBuilder =
    StanjeRobeAppliedEffectsCompanion Function({
      Value<int> id,
      required int predmetId,
      Value<int?> iriuId,
      required String kategorija,
      required String stableArticleId,
      Value<double> effectQuantity,
      required String effectStatus,
      required String effectReason,
      Value<String> datumKreiranja,
      Value<String> datumAzuriranja,
    });
typedef $$StanjeRobeAppliedEffectsTableUpdateCompanionBuilder =
    StanjeRobeAppliedEffectsCompanion Function({
      Value<int> id,
      Value<int> predmetId,
      Value<int?> iriuId,
      Value<String> kategorija,
      Value<String> stableArticleId,
      Value<double> effectQuantity,
      Value<String> effectStatus,
      Value<String> effectReason,
      Value<String> datumKreiranja,
      Value<String> datumAzuriranja,
    });

class $$StanjeRobeAppliedEffectsTableFilterComposer
    extends Composer<_$AppDatabase, $StanjeRobeAppliedEffectsTable> {
  $$StanjeRobeAppliedEffectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get predmetId => $composableBuilder(
    column: $table.predmetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iriuId => $composableBuilder(
    column: $table.iriuId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategorija => $composableBuilder(
    column: $table.kategorija,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectQuantity => $composableBuilder(
    column: $table.effectQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectStatus => $composableBuilder(
    column: $table.effectStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectReason => $composableBuilder(
    column: $table.effectReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumAzuriranja => $composableBuilder(
    column: $table.datumAzuriranja,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StanjeRobeAppliedEffectsTableOrderingComposer
    extends Composer<_$AppDatabase, $StanjeRobeAppliedEffectsTable> {
  $$StanjeRobeAppliedEffectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get predmetId => $composableBuilder(
    column: $table.predmetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iriuId => $composableBuilder(
    column: $table.iriuId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategorija => $composableBuilder(
    column: $table.kategorija,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectQuantity => $composableBuilder(
    column: $table.effectQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectStatus => $composableBuilder(
    column: $table.effectStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectReason => $composableBuilder(
    column: $table.effectReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumAzuriranja => $composableBuilder(
    column: $table.datumAzuriranja,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StanjeRobeAppliedEffectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StanjeRobeAppliedEffectsTable> {
  $$StanjeRobeAppliedEffectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get predmetId =>
      $composableBuilder(column: $table.predmetId, builder: (column) => column);

  GeneratedColumn<int> get iriuId =>
      $composableBuilder(column: $table.iriuId, builder: (column) => column);

  GeneratedColumn<String> get kategorija => $composableBuilder(
    column: $table.kategorija,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stableArticleId => $composableBuilder(
    column: $table.stableArticleId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effectQuantity => $composableBuilder(
    column: $table.effectQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectStatus => $composableBuilder(
    column: $table.effectStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectReason => $composableBuilder(
    column: $table.effectReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datumKreiranja => $composableBuilder(
    column: $table.datumKreiranja,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datumAzuriranja => $composableBuilder(
    column: $table.datumAzuriranja,
    builder: (column) => column,
  );
}

class $$StanjeRobeAppliedEffectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StanjeRobeAppliedEffectsTable,
          StanjeRobeAppliedEffect,
          $$StanjeRobeAppliedEffectsTableFilterComposer,
          $$StanjeRobeAppliedEffectsTableOrderingComposer,
          $$StanjeRobeAppliedEffectsTableAnnotationComposer,
          $$StanjeRobeAppliedEffectsTableCreateCompanionBuilder,
          $$StanjeRobeAppliedEffectsTableUpdateCompanionBuilder,
          (
            StanjeRobeAppliedEffect,
            BaseReferences<
              _$AppDatabase,
              $StanjeRobeAppliedEffectsTable,
              StanjeRobeAppliedEffect
            >,
          ),
          StanjeRobeAppliedEffect,
          PrefetchHooks Function()
        > {
  $$StanjeRobeAppliedEffectsTableTableManager(
    _$AppDatabase db,
    $StanjeRobeAppliedEffectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StanjeRobeAppliedEffectsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StanjeRobeAppliedEffectsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StanjeRobeAppliedEffectsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predmetId = const Value.absent(),
                Value<int?> iriuId = const Value.absent(),
                Value<String> kategorija = const Value.absent(),
                Value<String> stableArticleId = const Value.absent(),
                Value<double> effectQuantity = const Value.absent(),
                Value<String> effectStatus = const Value.absent(),
                Value<String> effectReason = const Value.absent(),
                Value<String> datumKreiranja = const Value.absent(),
                Value<String> datumAzuriranja = const Value.absent(),
              }) => StanjeRobeAppliedEffectsCompanion(
                id: id,
                predmetId: predmetId,
                iriuId: iriuId,
                kategorija: kategorija,
                stableArticleId: stableArticleId,
                effectQuantity: effectQuantity,
                effectStatus: effectStatus,
                effectReason: effectReason,
                datumKreiranja: datumKreiranja,
                datumAzuriranja: datumAzuriranja,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predmetId,
                Value<int?> iriuId = const Value.absent(),
                required String kategorija,
                required String stableArticleId,
                Value<double> effectQuantity = const Value.absent(),
                required String effectStatus,
                required String effectReason,
                Value<String> datumKreiranja = const Value.absent(),
                Value<String> datumAzuriranja = const Value.absent(),
              }) => StanjeRobeAppliedEffectsCompanion.insert(
                id: id,
                predmetId: predmetId,
                iriuId: iriuId,
                kategorija: kategorija,
                stableArticleId: stableArticleId,
                effectQuantity: effectQuantity,
                effectStatus: effectStatus,
                effectReason: effectReason,
                datumKreiranja: datumKreiranja,
                datumAzuriranja: datumAzuriranja,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StanjeRobeAppliedEffectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StanjeRobeAppliedEffectsTable,
      StanjeRobeAppliedEffect,
      $$StanjeRobeAppliedEffectsTableFilterComposer,
      $$StanjeRobeAppliedEffectsTableOrderingComposer,
      $$StanjeRobeAppliedEffectsTableAnnotationComposer,
      $$StanjeRobeAppliedEffectsTableCreateCompanionBuilder,
      $$StanjeRobeAppliedEffectsTableUpdateCompanionBuilder,
      (
        StanjeRobeAppliedEffect,
        BaseReferences<
          _$AppDatabase,
          $StanjeRobeAppliedEffectsTable,
          StanjeRobeAppliedEffect
        >,
      ),
      StanjeRobeAppliedEffect,
      PrefetchHooks Function()
    >;
typedef $$StanjeRobePoslediceTableCreateCompanionBuilder =
    StanjeRobePoslediceCompanion Function({
      Value<int> id,
      required int predmetId,
      required int iriuId,
      required String kategorija,
      required String katalogStableArticleId,
      required String selectedNazivSnapshot,
      Value<double> selectedIznosSnapshot,
      required String consequenceType,
      required String status,
      required String createdAt,
      required String updatedAt,
      Value<String?> resolvedAt,
      Value<String?> resolvedReason,
      required String sourceLifecycleEvent,
      Value<double> effectQuantity,
      Value<double?> availableQuantityAtCreation,
      Value<double?> shortageQuantityAtCreation,
    });
typedef $$StanjeRobePoslediceTableUpdateCompanionBuilder =
    StanjeRobePoslediceCompanion Function({
      Value<int> id,
      Value<int> predmetId,
      Value<int> iriuId,
      Value<String> kategorija,
      Value<String> katalogStableArticleId,
      Value<String> selectedNazivSnapshot,
      Value<double> selectedIznosSnapshot,
      Value<String> consequenceType,
      Value<String> status,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> resolvedAt,
      Value<String?> resolvedReason,
      Value<String> sourceLifecycleEvent,
      Value<double> effectQuantity,
      Value<double?> availableQuantityAtCreation,
      Value<double?> shortageQuantityAtCreation,
    });

final class $$StanjeRobePoslediceTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StanjeRobePoslediceTable,
          StanjeRobePoslediceData
        > {
  $$StanjeRobePoslediceTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PredmetiTable _predmetIdTable(_$AppDatabase db) =>
      db.predmeti.createAlias(
        $_aliasNameGenerator(db.stanjeRobePosledice.predmetId, db.predmeti.id),
      );

  $$PredmetiTableProcessedTableManager get predmetId {
    final $_column = $_itemColumn<int>('predmet_id')!;

    final manager = $$PredmetiTableTableManager(
      $_db,
      $_db.predmeti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predmetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IriuTable _iriuIdTable(_$AppDatabase db) => db.iriu.createAlias(
    $_aliasNameGenerator(db.stanjeRobePosledice.iriuId, db.iriu.id),
  );

  $$IriuTableProcessedTableManager get iriuId {
    final $_column = $_itemColumn<int>('iriu_id')!;

    final manager = $$IriuTableTableManager(
      $_db,
      $_db.iriu,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_iriuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StanjeRobePoslediceTableFilterComposer
    extends Composer<_$AppDatabase, $StanjeRobePoslediceTable> {
  $$StanjeRobePoslediceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategorija => $composableBuilder(
    column: $table.kategorija,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get katalogStableArticleId => $composableBuilder(
    column: $table.katalogStableArticleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedNazivSnapshot => $composableBuilder(
    column: $table.selectedNazivSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get selectedIznosSnapshot => $composableBuilder(
    column: $table.selectedIznosSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consequenceType => $composableBuilder(
    column: $table.consequenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedReason => $composableBuilder(
    column: $table.resolvedReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLifecycleEvent => $composableBuilder(
    column: $table.sourceLifecycleEvent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectQuantity => $composableBuilder(
    column: $table.effectQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get availableQuantityAtCreation => $composableBuilder(
    column: $table.availableQuantityAtCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shortageQuantityAtCreation => $composableBuilder(
    column: $table.shortageQuantityAtCreation,
    builder: (column) => ColumnFilters(column),
  );

  $$PredmetiTableFilterComposer get predmetId {
    final $$PredmetiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableFilterComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IriuTableFilterComposer get iriuId {
    final $$IriuTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iriuId,
      referencedTable: $db.iriu,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IriuTableFilterComposer(
            $db: $db,
            $table: $db.iriu,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StanjeRobePoslediceTableOrderingComposer
    extends Composer<_$AppDatabase, $StanjeRobePoslediceTable> {
  $$StanjeRobePoslediceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategorija => $composableBuilder(
    column: $table.kategorija,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get katalogStableArticleId => $composableBuilder(
    column: $table.katalogStableArticleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedNazivSnapshot => $composableBuilder(
    column: $table.selectedNazivSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get selectedIznosSnapshot => $composableBuilder(
    column: $table.selectedIznosSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consequenceType => $composableBuilder(
    column: $table.consequenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedReason => $composableBuilder(
    column: $table.resolvedReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLifecycleEvent => $composableBuilder(
    column: $table.sourceLifecycleEvent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectQuantity => $composableBuilder(
    column: $table.effectQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get availableQuantityAtCreation => $composableBuilder(
    column: $table.availableQuantityAtCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shortageQuantityAtCreation => $composableBuilder(
    column: $table.shortageQuantityAtCreation,
    builder: (column) => ColumnOrderings(column),
  );

  $$PredmetiTableOrderingComposer get predmetId {
    final $$PredmetiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableOrderingComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IriuTableOrderingComposer get iriuId {
    final $$IriuTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iriuId,
      referencedTable: $db.iriu,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IriuTableOrderingComposer(
            $db: $db,
            $table: $db.iriu,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StanjeRobePoslediceTableAnnotationComposer
    extends Composer<_$AppDatabase, $StanjeRobePoslediceTable> {
  $$StanjeRobePoslediceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kategorija => $composableBuilder(
    column: $table.kategorija,
    builder: (column) => column,
  );

  GeneratedColumn<String> get katalogStableArticleId => $composableBuilder(
    column: $table.katalogStableArticleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedNazivSnapshot => $composableBuilder(
    column: $table.selectedNazivSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get selectedIznosSnapshot => $composableBuilder(
    column: $table.selectedIznosSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consequenceType => $composableBuilder(
    column: $table.consequenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvedReason => $composableBuilder(
    column: $table.resolvedReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLifecycleEvent => $composableBuilder(
    column: $table.sourceLifecycleEvent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effectQuantity => $composableBuilder(
    column: $table.effectQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get availableQuantityAtCreation => $composableBuilder(
    column: $table.availableQuantityAtCreation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shortageQuantityAtCreation => $composableBuilder(
    column: $table.shortageQuantityAtCreation,
    builder: (column) => column,
  );

  $$PredmetiTableAnnotationComposer get predmetId {
    final $$PredmetiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableAnnotationComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IriuTableAnnotationComposer get iriuId {
    final $$IriuTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iriuId,
      referencedTable: $db.iriu,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IriuTableAnnotationComposer(
            $db: $db,
            $table: $db.iriu,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StanjeRobePoslediceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StanjeRobePoslediceTable,
          StanjeRobePoslediceData,
          $$StanjeRobePoslediceTableFilterComposer,
          $$StanjeRobePoslediceTableOrderingComposer,
          $$StanjeRobePoslediceTableAnnotationComposer,
          $$StanjeRobePoslediceTableCreateCompanionBuilder,
          $$StanjeRobePoslediceTableUpdateCompanionBuilder,
          (StanjeRobePoslediceData, $$StanjeRobePoslediceTableReferences),
          StanjeRobePoslediceData,
          PrefetchHooks Function({bool predmetId, bool iriuId})
        > {
  $$StanjeRobePoslediceTableTableManager(
    _$AppDatabase db,
    $StanjeRobePoslediceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StanjeRobePoslediceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StanjeRobePoslediceTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StanjeRobePoslediceTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predmetId = const Value.absent(),
                Value<int> iriuId = const Value.absent(),
                Value<String> kategorija = const Value.absent(),
                Value<String> katalogStableArticleId = const Value.absent(),
                Value<String> selectedNazivSnapshot = const Value.absent(),
                Value<double> selectedIznosSnapshot = const Value.absent(),
                Value<String> consequenceType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> resolvedAt = const Value.absent(),
                Value<String?> resolvedReason = const Value.absent(),
                Value<String> sourceLifecycleEvent = const Value.absent(),
                Value<double> effectQuantity = const Value.absent(),
                Value<double?> availableQuantityAtCreation =
                    const Value.absent(),
                Value<double?> shortageQuantityAtCreation =
                    const Value.absent(),
              }) => StanjeRobePoslediceCompanion(
                id: id,
                predmetId: predmetId,
                iriuId: iriuId,
                kategorija: kategorija,
                katalogStableArticleId: katalogStableArticleId,
                selectedNazivSnapshot: selectedNazivSnapshot,
                selectedIznosSnapshot: selectedIznosSnapshot,
                consequenceType: consequenceType,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                resolvedAt: resolvedAt,
                resolvedReason: resolvedReason,
                sourceLifecycleEvent: sourceLifecycleEvent,
                effectQuantity: effectQuantity,
                availableQuantityAtCreation: availableQuantityAtCreation,
                shortageQuantityAtCreation: shortageQuantityAtCreation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predmetId,
                required int iriuId,
                required String kategorija,
                required String katalogStableArticleId,
                required String selectedNazivSnapshot,
                Value<double> selectedIznosSnapshot = const Value.absent(),
                required String consequenceType,
                required String status,
                required String createdAt,
                required String updatedAt,
                Value<String?> resolvedAt = const Value.absent(),
                Value<String?> resolvedReason = const Value.absent(),
                required String sourceLifecycleEvent,
                Value<double> effectQuantity = const Value.absent(),
                Value<double?> availableQuantityAtCreation =
                    const Value.absent(),
                Value<double?> shortageQuantityAtCreation =
                    const Value.absent(),
              }) => StanjeRobePoslediceCompanion.insert(
                id: id,
                predmetId: predmetId,
                iriuId: iriuId,
                kategorija: kategorija,
                katalogStableArticleId: katalogStableArticleId,
                selectedNazivSnapshot: selectedNazivSnapshot,
                selectedIznosSnapshot: selectedIznosSnapshot,
                consequenceType: consequenceType,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                resolvedAt: resolvedAt,
                resolvedReason: resolvedReason,
                sourceLifecycleEvent: sourceLifecycleEvent,
                effectQuantity: effectQuantity,
                availableQuantityAtCreation: availableQuantityAtCreation,
                shortageQuantityAtCreation: shortageQuantityAtCreation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StanjeRobePoslediceTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({predmetId = false, iriuId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (predmetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.predmetId,
                                referencedTable:
                                    $$StanjeRobePoslediceTableReferences
                                        ._predmetIdTable(db),
                                referencedColumn:
                                    $$StanjeRobePoslediceTableReferences
                                        ._predmetIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (iriuId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.iriuId,
                                referencedTable:
                                    $$StanjeRobePoslediceTableReferences
                                        ._iriuIdTable(db),
                                referencedColumn:
                                    $$StanjeRobePoslediceTableReferences
                                        ._iriuIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StanjeRobePoslediceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StanjeRobePoslediceTable,
      StanjeRobePoslediceData,
      $$StanjeRobePoslediceTableFilterComposer,
      $$StanjeRobePoslediceTableOrderingComposer,
      $$StanjeRobePoslediceTableAnnotationComposer,
      $$StanjeRobePoslediceTableCreateCompanionBuilder,
      $$StanjeRobePoslediceTableUpdateCompanionBuilder,
      (StanjeRobePoslediceData, $$StanjeRobePoslediceTableReferences),
      StanjeRobePoslediceData,
      PrefetchHooks Function({bool predmetId, bool iriuId})
    >;
typedef $$PredlosciDokumenataTableCreateCompanionBuilder =
    PredlosciDokumenataCompanion Function({
      Value<int> id,
      required String naziv,
      Value<String> segmenti,
      Value<String> format,
      Value<bool> predefinisan,
      Value<bool> napomeneUkljucene,
      Value<bool> zakljucan,
    });
typedef $$PredlosciDokumenataTableUpdateCompanionBuilder =
    PredlosciDokumenataCompanion Function({
      Value<int> id,
      Value<String> naziv,
      Value<String> segmenti,
      Value<String> format,
      Value<bool> predefinisan,
      Value<bool> napomeneUkljucene,
      Value<bool> zakljucan,
    });

class $$PredlosciDokumenataTableFilterComposer
    extends Composer<_$AppDatabase, $PredlosciDokumenataTable> {
  $$PredlosciDokumenataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get naziv => $composableBuilder(
    column: $table.naziv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmenti => $composableBuilder(
    column: $table.segmenti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get predefinisan => $composableBuilder(
    column: $table.predefinisan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get napomeneUkljucene => $composableBuilder(
    column: $table.napomeneUkljucene,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get zakljucan => $composableBuilder(
    column: $table.zakljucan,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PredlosciDokumenataTableOrderingComposer
    extends Composer<_$AppDatabase, $PredlosciDokumenataTable> {
  $$PredlosciDokumenataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get naziv => $composableBuilder(
    column: $table.naziv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmenti => $composableBuilder(
    column: $table.segmenti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get predefinisan => $composableBuilder(
    column: $table.predefinisan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get napomeneUkljucene => $composableBuilder(
    column: $table.napomeneUkljucene,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get zakljucan => $composableBuilder(
    column: $table.zakljucan,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PredlosciDokumenataTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredlosciDokumenataTable> {
  $$PredlosciDokumenataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get naziv =>
      $composableBuilder(column: $table.naziv, builder: (column) => column);

  GeneratedColumn<String> get segmenti =>
      $composableBuilder(column: $table.segmenti, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<bool> get predefinisan => $composableBuilder(
    column: $table.predefinisan,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get napomeneUkljucene => $composableBuilder(
    column: $table.napomeneUkljucene,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get zakljucan =>
      $composableBuilder(column: $table.zakljucan, builder: (column) => column);
}

class $$PredlosciDokumenataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredlosciDokumenataTable,
          PredlosciDokumenataData,
          $$PredlosciDokumenataTableFilterComposer,
          $$PredlosciDokumenataTableOrderingComposer,
          $$PredlosciDokumenataTableAnnotationComposer,
          $$PredlosciDokumenataTableCreateCompanionBuilder,
          $$PredlosciDokumenataTableUpdateCompanionBuilder,
          (
            PredlosciDokumenataData,
            BaseReferences<
              _$AppDatabase,
              $PredlosciDokumenataTable,
              PredlosciDokumenataData
            >,
          ),
          PredlosciDokumenataData,
          PrefetchHooks Function()
        > {
  $$PredlosciDokumenataTableTableManager(
    _$AppDatabase db,
    $PredlosciDokumenataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredlosciDokumenataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredlosciDokumenataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PredlosciDokumenataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> naziv = const Value.absent(),
                Value<String> segmenti = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<bool> predefinisan = const Value.absent(),
                Value<bool> napomeneUkljucene = const Value.absent(),
                Value<bool> zakljucan = const Value.absent(),
              }) => PredlosciDokumenataCompanion(
                id: id,
                naziv: naziv,
                segmenti: segmenti,
                format: format,
                predefinisan: predefinisan,
                napomeneUkljucene: napomeneUkljucene,
                zakljucan: zakljucan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String naziv,
                Value<String> segmenti = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<bool> predefinisan = const Value.absent(),
                Value<bool> napomeneUkljucene = const Value.absent(),
                Value<bool> zakljucan = const Value.absent(),
              }) => PredlosciDokumenataCompanion.insert(
                id: id,
                naziv: naziv,
                segmenti: segmenti,
                format: format,
                predefinisan: predefinisan,
                napomeneUkljucene: napomeneUkljucene,
                zakljucan: zakljucan,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PredlosciDokumenataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredlosciDokumenataTable,
      PredlosciDokumenataData,
      $$PredlosciDokumenataTableFilterComposer,
      $$PredlosciDokumenataTableOrderingComposer,
      $$PredlosciDokumenataTableAnnotationComposer,
      $$PredlosciDokumenataTableCreateCompanionBuilder,
      $$PredlosciDokumenataTableUpdateCompanionBuilder,
      (
        PredlosciDokumenataData,
        BaseReferences<
          _$AppDatabase,
          $PredlosciDokumenataTable,
          PredlosciDokumenataData
        >,
      ),
      PredlosciDokumenataData,
      PrefetchHooks Function()
    >;
typedef $$LogIzmenaTableCreateCompanionBuilder =
    LogIzmenaCompanion Function({
      Value<int> id,
      required int predmetId,
      required int korisnikId,
      required String datumVreme,
      required String polje,
      Value<String> staraVrednost,
      Value<String> novaVrednost,
    });
typedef $$LogIzmenaTableUpdateCompanionBuilder =
    LogIzmenaCompanion Function({
      Value<int> id,
      Value<int> predmetId,
      Value<int> korisnikId,
      Value<String> datumVreme,
      Value<String> polje,
      Value<String> staraVrednost,
      Value<String> novaVrednost,
    });

final class $$LogIzmenaTableReferences
    extends BaseReferences<_$AppDatabase, $LogIzmenaTable, LogIzmenaData> {
  $$LogIzmenaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PredmetiTable _predmetIdTable(_$AppDatabase db) =>
      db.predmeti.createAlias(
        $_aliasNameGenerator(db.logIzmena.predmetId, db.predmeti.id),
      );

  $$PredmetiTableProcessedTableManager get predmetId {
    final $_column = $_itemColumn<int>('predmet_id')!;

    final manager = $$PredmetiTableTableManager(
      $_db,
      $_db.predmeti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predmetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LogIzmenaTableFilterComposer
    extends Composer<_$AppDatabase, $LogIzmenaTable> {
  $$LogIzmenaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get korisnikId => $composableBuilder(
    column: $table.korisnikId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datumVreme => $composableBuilder(
    column: $table.datumVreme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polje => $composableBuilder(
    column: $table.polje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staraVrednost => $composableBuilder(
    column: $table.staraVrednost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get novaVrednost => $composableBuilder(
    column: $table.novaVrednost,
    builder: (column) => ColumnFilters(column),
  );

  $$PredmetiTableFilterComposer get predmetId {
    final $$PredmetiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableFilterComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogIzmenaTableOrderingComposer
    extends Composer<_$AppDatabase, $LogIzmenaTable> {
  $$LogIzmenaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get korisnikId => $composableBuilder(
    column: $table.korisnikId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datumVreme => $composableBuilder(
    column: $table.datumVreme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polje => $composableBuilder(
    column: $table.polje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staraVrednost => $composableBuilder(
    column: $table.staraVrednost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get novaVrednost => $composableBuilder(
    column: $table.novaVrednost,
    builder: (column) => ColumnOrderings(column),
  );

  $$PredmetiTableOrderingComposer get predmetId {
    final $$PredmetiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableOrderingComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogIzmenaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogIzmenaTable> {
  $$LogIzmenaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get korisnikId => $composableBuilder(
    column: $table.korisnikId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datumVreme => $composableBuilder(
    column: $table.datumVreme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get polje =>
      $composableBuilder(column: $table.polje, builder: (column) => column);

  GeneratedColumn<String> get staraVrednost => $composableBuilder(
    column: $table.staraVrednost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get novaVrednost => $composableBuilder(
    column: $table.novaVrednost,
    builder: (column) => column,
  );

  $$PredmetiTableAnnotationComposer get predmetId {
    final $$PredmetiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predmetId,
      referencedTable: $db.predmeti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredmetiTableAnnotationComposer(
            $db: $db,
            $table: $db.predmeti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogIzmenaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogIzmenaTable,
          LogIzmenaData,
          $$LogIzmenaTableFilterComposer,
          $$LogIzmenaTableOrderingComposer,
          $$LogIzmenaTableAnnotationComposer,
          $$LogIzmenaTableCreateCompanionBuilder,
          $$LogIzmenaTableUpdateCompanionBuilder,
          (LogIzmenaData, $$LogIzmenaTableReferences),
          LogIzmenaData,
          PrefetchHooks Function({bool predmetId})
        > {
  $$LogIzmenaTableTableManager(_$AppDatabase db, $LogIzmenaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogIzmenaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogIzmenaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogIzmenaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predmetId = const Value.absent(),
                Value<int> korisnikId = const Value.absent(),
                Value<String> datumVreme = const Value.absent(),
                Value<String> polje = const Value.absent(),
                Value<String> staraVrednost = const Value.absent(),
                Value<String> novaVrednost = const Value.absent(),
              }) => LogIzmenaCompanion(
                id: id,
                predmetId: predmetId,
                korisnikId: korisnikId,
                datumVreme: datumVreme,
                polje: polje,
                staraVrednost: staraVrednost,
                novaVrednost: novaVrednost,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predmetId,
                required int korisnikId,
                required String datumVreme,
                required String polje,
                Value<String> staraVrednost = const Value.absent(),
                Value<String> novaVrednost = const Value.absent(),
              }) => LogIzmenaCompanion.insert(
                id: id,
                predmetId: predmetId,
                korisnikId: korisnikId,
                datumVreme: datumVreme,
                polje: polje,
                staraVrednost: staraVrednost,
                novaVrednost: novaVrednost,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LogIzmenaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({predmetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (predmetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.predmetId,
                                referencedTable: $$LogIzmenaTableReferences
                                    ._predmetIdTable(db),
                                referencedColumn: $$LogIzmenaTableReferences
                                    ._predmetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LogIzmenaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogIzmenaTable,
      LogIzmenaData,
      $$LogIzmenaTableFilterComposer,
      $$LogIzmenaTableOrderingComposer,
      $$LogIzmenaTableAnnotationComposer,
      $$LogIzmenaTableCreateCompanionBuilder,
      $$LogIzmenaTableUpdateCompanionBuilder,
      (LogIzmenaData, $$LogIzmenaTableReferences),
      LogIzmenaData,
      PrefetchHooks Function({bool predmetId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KorisniciTableTableManager get korisnici =>
      $$KorisniciTableTableManager(_db, _db.korisnici);
  $$FirmaPodaciTableTableManager get firmaPodaci =>
      $$FirmaPodaciTableTableManager(_db, _db.firmaPodaci);
  $$AppPodesavanjaTableTableManager get appPodesavanja =>
      $$AppPodesavanjaTableTableManager(_db, _db.appPodesavanja);
  $$PredmetiTableTableManager get predmeti =>
      $$PredmetiTableTableManager(_db, _db.predmeti);
  $$KontaktLicaTableTableManager get kontaktLica =>
      $$KontaktLicaTableTableManager(_db, _db.kontaktLica);
  $$IriuTableTableManager get iriu => $$IriuTableTableManager(_db, _db.iriu);
  $$IriuKatalogConfigTableTableManager get iriuKatalogConfig =>
      $$IriuKatalogConfigTableTableManager(_db, _db.iriuKatalogConfig);
  $$KatalogArtikliTableTableManager get katalogArtikli =>
      $$KatalogArtikliTableTableManager(_db, _db.katalogArtikli);
  $$StanjeRobeStavkeTableTableManager get stanjeRobeStavke =>
      $$StanjeRobeStavkeTableTableManager(_db, _db.stanjeRobeStavke);
  $$StanjeRobeAppliedEffectsTableTableManager get stanjeRobeAppliedEffects =>
      $$StanjeRobeAppliedEffectsTableTableManager(
        _db,
        _db.stanjeRobeAppliedEffects,
      );
  $$StanjeRobePoslediceTableTableManager get stanjeRobePosledice =>
      $$StanjeRobePoslediceTableTableManager(_db, _db.stanjeRobePosledice);
  $$PredlosciDokumenataTableTableManager get predlosciDokumenata =>
      $$PredlosciDokumenataTableTableManager(_db, _db.predlosciDokumenata);
  $$LogIzmenaTableTableManager get logIzmena =>
      $$LogIzmenaTableTableManager(_db, _db.logIzmena);
}
