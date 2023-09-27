import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _database = DatabaseService();

Future main() async {
  // Inicjalizacja sqflite_common_ffi.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await _database.initDb();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Brak _brak = Brak();
  final _formKey = GlobalKey<FormState>();
  final _searchFormKey = GlobalKey<FormState>();
  Future<List<Brak>>? _searchResults = _database.queryFilteredRows('', '');

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
    int iloscWystawionaNaProdukcje = int.tryParse(iloscWystawionaNaProdukcjeController.text) ?? 0;
    int brakiNaprawialne1Strona = int.tryParse(brakiNaprawialne1StronaController.text) ?? 0;
    int brakiNaprawialne2Strona = int.tryParse(brakiNaprawialne2StronaController.text) ?? 0;
    int brakiNienaprawialneBraki = int.tryParse(brakiNienaprawialneBrakiController.text) ?? 0;
    int brakiNienaprawialneZgubione = int.tryParse(brakiNienaprawialneZgubioneController.text) ?? 0;
    int magazyn = int.tryParse(magazynController.text) ?? 0;

    int iloscWyslana = iloscWystawionaNaProdukcje - brakiNaprawialne1Strona - brakiNaprawialne2Strona -
        brakiNienaprawialneBraki - brakiNienaprawialneZgubione - magazyn;

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontrola - braki'),
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
                            InputDecoration(labelText: 'Symbol soczewki'),
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.symbolSoczewki = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: numerZamowieniaController,
                        decoration: InputDecoration(labelText: 'Nr zamówienia'),
                        validator: validateEmpty,
                        onSaved: (value) {
                          _brak.numerZamowienia = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: szkloController,
                        decoration: InputDecoration(labelText: 'Szkło'),
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
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: iloscWystawionaNaProdukcjeController,
                  decoration: InputDecoration(
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
                        decoration: InputDecoration(
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
                        decoration: InputDecoration(
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
                        decoration: InputDecoration(
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
                        decoration: InputDecoration(
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
                  decoration: InputDecoration(labelText: 'Magazyn'),
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
                  decoration: InputDecoration(labelText: 'Ilość wysłana'),
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
                    }
                  },
                  child: Text('Dodaj Braki'),
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
                    decoration: InputDecoration(labelText: 'Symbol soczewki'),

                  ),
                ),
                Expanded(
                  child: TextFormField(
                      controller: searchSzkloController,
                    decoration: InputDecoration(labelText: 'Szkło'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Aktualizuje _searchResults za każdym razem, gdy przycisk jest naciśnięty
                    setState(() {
                      _searchResults = _database.queryFilteredRows(
                          searchSymbolSoczewkiController.text, searchSzkloController.text);
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: Text('Szukaj'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Brak>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      final brak = snapshot.data?[index];
                      return ListTile(
                        title: Text(brak?.symbolSoczewki ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Numer zamówienia: ${brak?.numerZamowienia ?? ''}'),
                            Text(
                                'szkło: ${brak?.szklo ?? ''}'),
                            Text(
                                'Ilość wystawiona na produkcje: ${brak?.iloscWystawionaNaProdukcje ?? ''}'),
                            Text(
                                'Braki naprawialne 1 strona: ${brak?.brakiNaprawialne1Strona ?? ''}'),
                            Text(
                                'Braki naprawialne 2 strona: ${brak?.brakiNaprawialne2Strona ?? ''}'),
                            Text(
                                'Braki nienaprawialne - braki: ${brak?.brakiNienaprawialneBraki ?? ''}'),
                            Text(
                                'Braki nienaprawialne - zgubione: ${brak?.brakiNienaprawialneZgubione ?? ''}'),
                            Text('Magazyn: ${brak?.magazyn ?? ''}'),
                            Text('Ilość wysłana: ${brak?.iloscWyslana ?? ''}'),
                          ],
                        ),
                        trailing: Text('Data: ${brak?.data ?? ''}'),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Brak {
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
}

class DatabaseService {
  Database? _db;

  Future<void> initDb() async {
    if (_db == null) {
      _db = await openDatabase(
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
  }

  Future<void> insertBrak(Map<String, dynamic> braki) async {
    await _db?.insert(
      'braki',
      braki,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Brak>> queryAllRows() async {
    final brakiList = await _db!.query('braki');
    return brakiList.map((e) => Brak.fromMap(e)).toList().reversed.toList();
  }

  Future<List<Brak>> queryFilteredRows(String symbolSoczewki, String szklo) async {
    final brakiList = await _db!.query('braki', where: 'symbolSoczewki LIKE ? AND szklo LIKE ?',
        whereArgs: ['%$symbolSoczewki%', '%$szklo%']);
    return brakiList.map((e) => Brak.fromMap(e)).toList().reversed.toList();
  }

}

class DateField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String?)? onSaved;

  DateField({required this.controller, this.onSaved});

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    widget.controller.text = "${selectedDate.toLocal()}".split(' ')[0]; // Ustawienie domyślnej daty.
  }
  // Metoda do wyświetlenia date picker.
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        widget.controller.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(labelText: 'Data'),
      onTap: () {
        // Zamknięcie klawiatury ekranowej, jeśli jest otwarta
        FocusScope.of(context).requestFocus(new FocusNode());
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