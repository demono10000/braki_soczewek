import 'dart:io';

import 'package:excel/excel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _database = DatabaseService();

Future main() async {
  // Inicjalizacja sqflite_common_ffi.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await _database.initDb();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _database.initDb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: CircularProgressIndicator()); // ekran ładowania
        } else if (snapshot.hasError) {
          return MaterialApp(home: Text('Błąd: ${snapshot.error}')); // ekran z błędem
        } else {
          return const MaterialApp(home: HomePage()); // główna strona aplikacji
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Brak _brak = Brak();
  final _formKey = GlobalKey<FormState>();
  final _searchFormKey = GlobalKey<FormState>();
  Future<List<Brak>>? _searchResults = _database.queryFilteredRows();
  bool isExcelButtonEnabled = true;

  final symbolSoczewkiController = TextEditingController();
  final numerZamowieniaController = TextEditingController();
  final szkloController = TextEditingController();
  final iloscWystawionaNaProdukcjeController = TextEditingController();
  final brakiNaprawialne1StronaController = TextEditingController();
  final brakiNaprawialne2StronaController = TextEditingController();
  final brakiNienaprawialneBrakiController = TextEditingController();
  final brakiNienaprawialneZgubioneController = TextEditingController();
  final magazynController = TextEditingController();
  final iloscWyslanaController = TextEditingController();
  final _dateController = TextEditingController();

  final searchSymbolSoczewkiController = TextEditingController();
  final searchSzkloController = TextEditingController();
  final searchDataStartController = TextEditingController();
  final searchDataKoniecController = TextEditingController();

  final _scrollController = ScrollController();
  final _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();

    // Dodawanie nasłuchiwaczy do kontrolerów.
    iloscWystawionaNaProdukcjeController.addListener(updateIloscWyslana);
    brakiNaprawialne1StronaController.addListener(updateIloscWyslana);
    brakiNaprawialne2StronaController.addListener(updateIloscWyslana);
    brakiNienaprawialneBrakiController.addListener(updateIloscWyslana);
    brakiNienaprawialneZgubioneController.addListener(updateIloscWyslana);
    magazynController.addListener(updateIloscWyslana);
  }

  void updateIloscWyslana() {
    int iloscWystawionaNaProdukcje =
        int.tryParse(iloscWystawionaNaProdukcjeController.text) ?? 0;
    int brakiNaprawialne1Strona =
        int.tryParse(brakiNaprawialne1StronaController.text) ?? 0;
    int brakiNaprawialne2Strona =
        int.tryParse(brakiNaprawialne2StronaController.text) ?? 0;
    int brakiNienaprawialneBraki =
        int.tryParse(brakiNienaprawialneBrakiController.text) ?? 0;
    int brakiNienaprawialneZgubione =
        int.tryParse(brakiNienaprawialneZgubioneController.text) ?? 0;
    int magazyn = int.tryParse(magazynController.text) ?? 0;

    int iloscWyslana = iloscWystawionaNaProdukcje -
        brakiNaprawialne1Strona -
        brakiNaprawialne2Strona -
        brakiNienaprawialneBraki -
        brakiNienaprawialneZgubione -
        magazyn;

    iloscWyslanaController.text = iloscWyslana.toString();
  }

  @override
  void dispose() {
    iloscWystawionaNaProdukcjeController.removeListener(updateIloscWyslana);
    brakiNaprawialne1StronaController.removeListener(updateIloscWyslana);
    brakiNaprawialne2StronaController.removeListener(updateIloscWyslana);
    brakiNienaprawialneBrakiController.removeListener(updateIloscWyslana);
    brakiNienaprawialneZgubioneController.removeListener(updateIloscWyslana);
    magazynController.removeListener(updateIloscWyslana);

    symbolSoczewkiController.dispose();
    numerZamowieniaController.dispose();
    szkloController.dispose();
    iloscWystawionaNaProdukcjeController.dispose();
    brakiNaprawialne1StronaController.dispose();
    brakiNaprawialne2StronaController.dispose();
    brakiNienaprawialneBrakiController.dispose();
    brakiNienaprawialneZgubioneController.dispose();
    magazynController.dispose();
    iloscWyslanaController.dispose();
    _dateController.dispose();

    searchSymbolSoczewkiController.dispose();
    searchSzkloController.dispose();
    searchDataStartController.dispose();
    searchDataKoniecController.dispose();

    _scrollController.dispose();
    _scrollController2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrola - braki'),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: symbolSoczewkiController,
                        decoration:
                            const InputDecoration(labelText: 'Symbol soczewki'),
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.symbolSoczewki = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: numerZamowieniaController,
                        decoration:
                            const InputDecoration(labelText: 'Nr zamówienia'),
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.numerZamowienia = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: szkloController,
                        decoration: const InputDecoration(labelText: 'Szkło'),
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.szklo = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: DateField(
                        controller: _dateController,
                        onSaved: (value) {
                          _brak.data = _dateController.text;
                        },
                        dateText: "Data",
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: iloscWystawionaNaProdukcjeController,
                  decoration: const InputDecoration(
                      labelText: 'Ilość wystawiona na produkcję'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: validateEmpty,
                  onSaved: (value) {
                    _brak.iloscWystawionaNaProdukcje =
                        int.tryParse(value ?? '0');
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: brakiNaprawialne1StronaController,
                        decoration: const InputDecoration(
                            labelText: 'Braki naprawialne 1 strona'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.brakiNaprawialne1Strona =
                              int.tryParse(value ?? '0');
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: brakiNaprawialne2StronaController,
                        decoration: const InputDecoration(
                            labelText: 'Braki naprawialne 2 strona'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.brakiNaprawialne2Strona =
                              int.tryParse(value ?? '0');
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: brakiNienaprawialneBrakiController,
                        decoration: const InputDecoration(
                            labelText: 'Braki nienaprawialne - braki'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.brakiNienaprawialneBraki =
                              int.tryParse(value ?? '0');
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: brakiNienaprawialneZgubioneController,
                        decoration: const InputDecoration(
                            labelText: 'Braki nienaprawialne - zgubione'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.brakiNienaprawialneZgubione =
                              int.tryParse(value ?? '0');
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: magazynController,
                  decoration: const InputDecoration(labelText: 'Magazyn'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: validateEmpty,
                  onSaved: (value) {
                    _brak.magazyn = int.tryParse(value ?? '0');
                  },
                ),
                TextFormField(
                  controller: iloscWyslanaController,
                  decoration: const InputDecoration(labelText: 'Ilość wysłana'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: validateEmpty,
                  onSaved: (value) {
                    _brak.iloscWyslana = int.tryParse(value ?? '0');
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      await _database.insertBrak(_brak.toMap());
                      symbolSoczewkiController.clear();
                      numerZamowieniaController.clear();
                      szkloController.clear();
                      iloscWystawionaNaProdukcjeController.clear();
                      brakiNaprawialne1StronaController.clear();
                      brakiNaprawialne2StronaController.clear();
                      brakiNienaprawialneBrakiController.clear();
                      brakiNienaprawialneZgubioneController.clear();
                      magazynController.clear();
                      iloscWyslanaController.clear();
                      setState(() {});
                      _searchResults = _database.queryFilteredRows(
                          symbolSoczewki: searchSymbolSoczewkiController.text,
                          szklo: searchSzkloController.text,
                          dataStart: searchDataStartController.text,
                          dataKoniec: searchDataKoniecController.text);
                      isExcelButtonEnabled = true;
                    }
                  },
                  child: const Text('Dodaj'),
                ),
              ],
            ),
          ),
          Form(
            key: _searchFormKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchSymbolSoczewkiController,
                    decoration:
                        const InputDecoration(labelText: 'Symbol soczewki'),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: searchSzkloController,
                    decoration: const InputDecoration(labelText: 'Szkło'),
                  ),
                ),
                Expanded(
                  child: DateField(
                    controller: searchDataStartController,
                    dateText: "Data start",
                    defaultDate: 'past',
                  ),
                ),
                Expanded(
                  child: DateField(
                    controller: searchDataKoniecController,
                    dateText: "Data koniec",
                    defaultDate: 'future',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Aktualizuje _searchResults za każdym razem, gdy przycisk jest naciśnięty
                    setState(() {
                      _searchResults = _database.queryFilteredRows(
                          symbolSoczewki: searchSymbolSoczewkiController.text,
                          szklo: searchSzkloController.text,
                          dataStart: searchDataStartController.text,
                          dataKoniec: searchDataKoniecController.text);
                    });
                    isExcelButtonEnabled = true;
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: const Text('Szukaj'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Brak>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 28, 108, 28))),
                        onPressed: !isExcelButtonEnabled
                            ? null
                            : () {
                          setState(() {
                            isExcelButtonEnabled = false;
                          });
                          _database.queryAllRowsToExcel(
                            symbolSoczewki: searchSymbolSoczewkiController.text,
                            szklo: searchSzkloController.text,
                            dataStart: searchDataStartController.text,
                            dataKoniec: searchDataKoniecController.text,
                          );
                        },
                        child: const Text('Eksportuj do Excela'),
                      ),
                      Expanded(
                        child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 15,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  controller: _scrollController2,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                          label: Flexible(
                                              child: Text('Symbol\nSoczewki',
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                      DataColumn(
                                          label: Flexible(
                                              child: Text('Numer\nzamówienia',
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                      DataColumn(
                                          label: Flexible(
                                              child: Text('Szkło',
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                      DataColumn(label: Text('Data')),
                                      DataColumn(
                                          label: Flexible(
                                              child: Text(
                                                  'Ilość\nwystawiona\nna produkcje',
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                      DataColumn(
                                          label: Text(
                                              'Braki\nnaprawialne\n1 strona')),
                                      DataColumn(
                                          label: Text(
                                              'Braki\nnaprawialne\n2 strona')),
                                      DataColumn(
                                          label: Text(
                                              'Braki\nnienaprawialne\n- braki')),
                                      DataColumn(
                                          label: Text(
                                              'Braki\nnienaprawialne\n- zgubione')),
                                      DataColumn(label: Text('Magazyn')),
                                      DataColumn(label: Text('Ilość\nwysłana')),
                                      DataColumn(label: Text('Akcja')),
                                    ],
                                    rows: snapshot.data!
                                        .map((brak) => DataRow(
                                              cells: [
                                                DataCell(Text(brak.symbolSoczewki
                                                    as String)),
                                                DataCell(Text(brak.numerZamowienia
                                                    as String)),
                                                DataCell(
                                                    Text(brak.szklo as String)),
                                                DataCell(
                                                    Text(brak.data as String)),
                                                DataCell(Text(brak
                                                    .iloscWystawionaNaProdukcje
                                                    .toString())),
                                                DataCell(Text(brak
                                                    .brakiNaprawialne1Strona
                                                    .toString())),
                                                DataCell(Text(brak
                                                    .brakiNaprawialne2Strona
                                                    .toString())),
                                                DataCell(Text(brak
                                                    .brakiNienaprawialneBraki
                                                    .toString())),
                                                DataCell(Text(brak
                                                    .brakiNienaprawialneZgubione
                                                    .toString())),
                                                DataCell(Text(
                                                    brak.magazyn.toString())),
                                                DataCell(Text(brak.iloscWyslana
                                                    .toString())),
                                                DataCell(
                                                  brak.id != null
                                                      ? ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        Colors
                                                                            .red),
                                                          ),
                                                          onPressed: () async {
                                                            await _database
                                                                .deleteBraki(brak
                                                                    .id as int);
                                                            setState(() {});
                                                            _searchResults = _database.queryFilteredRows(
                                                                symbolSoczewki:
                                                                    searchSymbolSoczewkiController
                                                                        .text,
                                                                szklo:
                                                                    searchSzkloController
                                                                        .text,
                                                                dataStart:
                                                                    searchDataStartController
                                                                        .text,
                                                                dataKoniec:
                                                                    searchDataKoniecController
                                                                        .text);
                                                          },
                                                          child:
                                                              const Text('Usuń'),
                                                        )
                                                      : const SizedBox
                                                          .shrink(), // lub inny widget do wyświetlenia, gdy id jest null
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ))),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class Brak {
  int? id;
  String? symbolSoczewki;
  String? numerZamowienia;
  String? szklo;
  String? data;
  int? iloscWystawionaNaProdukcje;
  int? brakiNaprawialne1Strona;
  int? brakiNaprawialne2Strona;
  int? brakiNienaprawialneBraki;
  int? brakiNienaprawialneZgubione;
  int? magazyn;
  int? iloscWyslana;

  Brak({
    this.id,
    this.symbolSoczewki,
    this.numerZamowienia,
    this.szklo,
    this.data,
    this.iloscWystawionaNaProdukcje,
    this.brakiNaprawialne1Strona,
    this.brakiNaprawialne2Strona,
    this.brakiNienaprawialneBraki,
    this.brakiNienaprawialneZgubione,
    this.magazyn,
    this.iloscWyslana,
  });

  // Metoda służąca do konwersji obiektu klasy Brak na mapę.
  Map<String, dynamic> toMap() {
    return {
      'symbolSoczewki': symbolSoczewki,
      'numerZamowienia': numerZamowienia,
      'szklo': szklo,
      'data': data,
      'iloscWystawionaNaProdukcje': iloscWystawionaNaProdukcje,
      'brakiNaprawialne1': brakiNaprawialne1Strona,
      'brakiNaprawialne2': brakiNaprawialne2Strona,
      'brakiNienaprawialneBraki': brakiNienaprawialneBraki,
      'brakiNienaprawialneZgubione': brakiNienaprawialneZgubione,
      'magazyn': magazyn,
      'iloscWyslana': iloscWyslana,
    };
  }

  // Metoda służąca do konwersji mapy na obiekt klasy Brak.
  static Brak fromMap(Map<String, dynamic> map) {
    Brak b = Brak(
      id: map['id'] as int?,
      symbolSoczewki: map['symbolSoczewki'] as String?,
      numerZamowienia: map['numerZamowienia'] as String?,
      szklo: map['szklo'] as String?,
      data: map['data'].toString(),
      iloscWystawionaNaProdukcje: map['iloscWystawionaNaProdukcje'] as int?,
      brakiNaprawialne1Strona: map['brakiNaprawialne1'] as int?,
      brakiNaprawialne2Strona: map['brakiNaprawialne2'] as int?,
      brakiNienaprawialneBraki: map['brakiNienaprawialneBraki'] as int?,
      brakiNienaprawialneZgubione: map['brakiNienaprawialneZgubione'] as int?,
      magazyn: map['magazyn'] as int?,
      iloscWyslana: map['iloscWyslana'] as int?,
    );
    return b;
  }

  List<dynamic> toExcelRow() => [
        symbolSoczewki,
        numerZamowienia,
        szklo,
        data,
        iloscWystawionaNaProdukcje,
        brakiNaprawialne1Strona,
        brakiNaprawialne2Strona,
        brakiNienaprawialneBraki,
        brakiNienaprawialneZgubione,
        magazyn,
        iloscWyslana,
      ];
}

class DatabaseService {
  Database? _db;

  Future<void> initDb() async {
    _db ??= await openDatabase(
      'database.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
            CREATE TABLE IF NOT EXISTS braki (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                symbolSoczewki TEXT,
                numerZamowienia TEXT,
                szklo TEXT,
                data DATE,
                iloscWystawionaNaProdukcje INTEGER,
                brakiNaprawialne1 INTEGER,
                brakiNaprawialne2 INTEGER,
                brakiNienaprawialneBraki INTEGER,
                brakiNienaprawialneZgubione INTEGER,
                magazyn INTEGER,
                iloscWyslana INTEGER
            )
            ''',
        );
      },
    );
  }

  Future<void> insertBrak(Map<String, dynamic> braki) async {
    await _db?.insert(
      'braki',
      braki,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void queryAllRowsToExcel(
      {String symbolSoczewki = '',
      String szklo = '',
      String dataStart = '2000-01-01',
      String dataKoniec = '2100-01-01'}) async {
    final List<Map<String, Object?>> brakiList;
    brakiList = await _db!.query('braki',
        where:
            'symbolSoczewki LIKE ? AND szklo LIKE ? AND data BETWEEN ? AND ?',
        whereArgs: ['%$symbolSoczewki%', '%$szklo%', dataStart, dataKoniec]);
    // final brakiList = await _db!.query('braki');
    List<Brak> braki =
        brakiList.map((e) => Brak.fromMap(e)).toList().reversed.toList();
    var excel = Excel.createExcel();
    Sheet sheet = excel['soczewki'];
    excel.delete('Sheet1');

    sheet.appendRow([
      'Symbol soczewki',
      'Numer zamówienia',
      'Szkło',
      'Data',
      'Ilość wystawiona na produkcję',
      'Braki naprawialne 1 strona',
      'Braki naprawialne 2 strona',
      'Braki nienaprawialne - braki',
      'Braki nienaprawialne - zgubione',
      'Magazyn',
      'Ilość wysłana'
    ]);

    for (var brak in braki) {
      sheet.appendRow(brak.toExcelRow());
    }

    var onValue = excel.encode();
    // set filename to current date and time without space and miliseconds
    var filename = DateTime.now()
        .toString()
        .replaceAll(' ', '_')
        .replaceAll(':', '_')
        .split('.')[0];
    File("excel/$filename.xlsx")
      ..createSync(recursive: true)
      ..writeAsBytesSync(onValue!);
  }

  Future<List<Brak>> queryFilteredRows(
      {String symbolSoczewki = '',
      String szklo = '',
      String dataStart = '2000-01-01',
      String dataKoniec = '2100-01-01'}) async {
    final List<Map<String, Object?>> brakiList;
    brakiList = await _db!.query('braki',
        where:
            'symbolSoczewki LIKE ? AND szklo LIKE ? AND data BETWEEN ? AND ?',
        whereArgs: ['%$symbolSoczewki%', '%$szklo%', dataStart, dataKoniec]);
    List<Brak> braki =
        brakiList.map((e) => Brak.fromMap(e)).toList().reversed.toList();
    if (braki.isNotEmpty) {
      Map<String, Object?> sumy = {};
      for (var brak in braki) {
        brak.toMap().forEach((key, value) {
          if (brak.toMap().keys.toList().indexOf(key) < 4) {
            sumy[key] = '-';
            return;
          }

          if (value is int) {
            if (sumy[key] == null) {
              sumy[key] = 0;
            }
            sumy[key] = (sumy[key] as int) + value;
          }
        });
      }

      // Dodanie wiersza sum do listy braki.
      braki.add(Brak.fromMap(Map<String, Object?>.fromEntries(
        sumy.entries.map((e) => MapEntry(e.key, e.value)),
      )));
    }
    return braki.toList();
  }

  Future<void> deleteBraki(int id) async {
    await _db!.delete('braki', where: 'id = ?', whereArgs: [id]);
  }
}

class DateField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String?)? onSaved;
  final String dateText;
  final String defaultDate;

  const DateField(
      {super.key,
      required this.controller,
      this.onSaved,
      required this.dateText,
      this.defaultDate = 'now'});

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.defaultDate == 'past') {
      selectedDate = DateTime(2000);
    } else if (widget.defaultDate == 'future') {
      selectedDate = DateTime(2100);
    }
    widget.controller.text = "${selectedDate.toLocal()}".split(' ')[0];
  }

  // Metoda do wyświetlenia date picker.
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(labelText: widget.dateText),
      onTap: () {
        // Zamknięcie klawiatury ekranowej, jeśli jest otwarta
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context);
      },
      validator: validateEmpty,
      readOnly: true,
      onSaved: widget.onSaved,
    );
  }
}

String? validateEmpty(String? value) {
  return (value == null || value.isEmpty) ? 'Pole nie może być puste' : null;
}
