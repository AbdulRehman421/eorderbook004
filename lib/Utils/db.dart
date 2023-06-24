import 'dart:convert';

import 'package:Mini_Bill/Area%20&%20Sector/Sector.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../Area & Sector/Area.dart';
import '../Customer/Customer.dart';
import '../Products/Product.dart';

mainDB() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database6.db');

  Database database = await openDatabase(
    path,
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "User" ("userName" VARCHAR(255),"cmpcd" VARCHAR(255),"password" VARCHAR(255),"actype" VARCHAR(255),"code" VARCHAR(102),      "description" VARCHAR(255),      "userId" VARCHAR(102),"email" VARCHAR(255),"enabled" VARCHAR(1));');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Area" ("SubSecCd"	NUMERIC,"_id"	INTEGER PRIMARY KEY AUTOINCREMENT,"AreaCd"	integer,"AreaNm"	varchar(50),"SecCd"	integer);');

      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Sector" ("_id"	INTEGER PRIMARY KEY AUTOINCREMENT,"SecCd"	integer,"SecNm"	varchar(50));');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Parties" ("_id"	INTEGER PRIMARY KEY AUTOINCREMENT,"acno"	integer,"dsc"	varchar(50),"Type"	varchar(1), "Mobile"	varchar(15),     "AreaCd"	integer, "Balance"	float,      "EnabDisab"	varchar(1));');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Product" ("_id"	INTEGER PRIMARY KEY AUTOINCREMENT, "pcode"	varchar(6),"CmpCd"	varchar(2),"grcd"	varchar(1), "name1"	varchar(40),"tp"	NUMERIC,"rp"	NUMERIC,"balance"	integer)');
      await db.execute(
        'CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT, tax REAL, vat REAL, paidAmount REAL, shippingCost REAL, customerId INTEGER, areaId INTEGER, sectorId INTEGER, date TEXT, invoiceNumber TEXT)',
      );
      await db.execute(
        'CREATE TABLE IF NOT EXISTS OrderedProducts (id INTEGER PRIMARY KEY AUTOINCREMENT, productId INTEGER, orderId INTEGER,quantity INTEGER,bonus INTEGER,discount INTEGER,price INTEGER)',
      );
    },
  );

  // Query the SQLite master table to retrieve table names
  List<Map<String, dynamic>> tables = await database.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'",
  );

  // Extract the table names from the query result
  List tableNames = tables.map((table) => table['name']).toList();

  // Print the table names
  print('Available tables: $tableNames');

  database.close();
}

createOrderDB() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database6.db');
  Database database = await openDatabase(path);

  await database.execute(
    'CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT, tax REAL, vat REAL, paidAmount REAL, shippingCost REAL, customerId INTEGER, areaId INTEGER, sectorId INTEGER, date TEXT, invoiceNumber TEXT)',
  );
  await database.execute(
    'CREATE TABLE IF NOT EXISTS OrderedProducts (id INTEGER PRIMARY KEY AUTOINCREMENT, productId INTEGER, orderId INTEGER,quantity INTEGER,bonus INTEGER,discount INTEGER,price INTEGER)',
  );
  database.close();
}

SaveInvoice(orderMap, List<Product> products) async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database6.db');
  Database database = await openDatabase(path);

  int orderId = await database.insert(
    'orders',
    orderMap,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  Map<String, dynamic> newMap = {};
  for (var element in products) {
    int orderProductId = await database.insert(
      'orderedProducts',
      {
        'productId': element.id,
        'orderId': orderId,
        'quantity': element.quantity,
        'bonus': element.bonus,
        'discount': element.discount,
        'price': element.price
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String query = '''
  SELECT orders.id, orders.time, orders.tax, orders.vat, orders.paidAmount,
         orders.shippingCost, orders.customerId, orders.areaId, orders.sectorId,
         orders.date, orders.invoiceNumber,
         Parties.acno, Parties.dsc, Parties.Type, Parties.Mobile, Parties.Balance,
         Sector.SecCd, Sector.SecNm,
         Area.SubSecCd, Area.AreaCd, Area.AreaNm
  FROM orders
  JOIN Parties ON orders.customerId = Parties.acno
  JOIN Sector ON orders.sectorId = Sector.SecCd
  JOIN Area ON orders.areaId = Area.AreaCd''';

  List<Map<String, dynamic>> result = await database.rawQuery(query);

  if (result.isNotEmpty) {
    for (Map<String, dynamic> row in result) {
      // Access the order, customer, sector, and area information
      int orderId = row['id'];
      String orderTime = row['time'];
      int sectorCode = row['SecCd'];
      String sectorName = row['SecNm'];
      int areaSubSecCode = row['SubSecCd'] ?? 0;
      int areaCode = row['AreaCd'];
      String areaName = row['AreaNm'];
      print('Order ID: $orderId');
      print('Order Time: $orderTime');
      print('Sector Code: $sectorCode');
      print('Sector Name: $sectorName');
      print('Area SubSec Code: $areaSubSecCode');
      print('Area Code: $areaCode');
      print('Area Name: $areaName');
      // ...
    }
  } else {
    print("nothing");
  }
  database.close();
}

UpdateInvoice(orderId, List<Product> products) async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database6.db');
  Database database = await openDatabase(path);
  await database.delete(
    'orderedProducts',
    where: 'orderId = ?',
    whereArgs: [orderId],
  );

  for (Product item in products) {
    await database.insert('orderedProducts', {
      'productId': item.id,
      'orderId': orderId,
      'quantity': item.quantity,
      'bonus': item.bonus,
      'discount': item.discount,
      'price': item.price
    });
  }

  database.close();
}

getPath(databasesPath) {
  return join(databasesPath, 'my_database6.db');
}

sync() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database6.db');

  Database database = await openDatabase(
    path,
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "User" ("userName" VARCHAR(255),"cmpcd" VARCHAR(255),"password" VARCHAR(255),"actype" VARCHAR(255),"code" VARCHAR(102),      "description" VARCHAR(255),      "userId" VARCHAR(102),"email" VARCHAR(255),"enabled" VARCHAR(1));');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Area" ("SubSecCd"	NUMERIC,"_id"	INTEGER PRIMARY KEY AUTOINCREMENT,"AreaCd"	integer,"AreaNm"	varchar(50),"SecCd"	integer);');

      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Sector" ("_id"	INTEGER PRIMARY KEY AUTOINCREMENT,"SecCd"	integer,"SecNm"	varchar(50));');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Parties" ("_id"	INTEGER PRIMARY KEY AUTOINCREMENT,"acno"	integer,"dsc"	varchar(50),"Type"	varchar(1), "Mobile"	varchar(15),     "AreaCd"	integer, "Balance"	float,      "EnabDisab"	varchar(1));');
      await db.execute(
          'CREATE TABLE IF NOT EXISTS "Product" ("_id"	INTEGER PRIMARY KEY AUTOINCREMENT, "pcode"	varchar(6),"CmpCd"	varchar(2),"grcd"	varchar(1), "name1"	varchar(40),"tp"	NUMERIC,"rp"	NUMERIC,"balance"	integer)');
      await db.execute(
        'CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT, tax REAL, vat REAL, paidAmount REAL, shippingCost REAL, customerId INTEGER, areaId INTEGER, sectorId INTEGER, date TEXT, invoiceNumber TEXT)',
      );
      await db.execute(
        'CREATE TABLE IF NOT EXISTS OrderedProducts (id INTEGER PRIMARY KEY AUTOINCREMENT, productId INTEGER, orderId INTEGER,quantity INTEGER,bonus INTEGER,discount INTEGER,price INTEGER)',
      );
    },
  );
  await clearTable('Product', database);

  return true;
}

fetchSector() async {
  List<Sector> fetched = [];

  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('sector').get();

  if (snapshot.value != null) {
    Map<Object?, dynamic> data = snapshot.value as Map<Object?, dynamic>;
    print(data.length);
    data.forEach((key, value) {
      fetched.add(Sector(
          value['sectorcode'], value['sectorcode'], value['sectorname']));
    });
  }
  return fetched;
}

fetchArea() async {
  List<Area> areas = [];
  final Database database = await openDatabase('my_database6.db');

  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('area').get();

  if (snapshot.value != null) {
    Map<Object?, dynamic> data = snapshot.value as Map<Object?, dynamic>;
    data.forEach((key, value) {
      areas.add(Area(value['areacode'], value['areacode'], value['areaname'],
          value['sectorcode']));
    });
  }
  return areas;
}

getAll() async {
  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('product').get();
  List<Product> allData = [];
  if (snapshot.value != null) {
    Map<Object?, dynamic> data = snapshot.value as Map<Object?, dynamic>;
    data.forEach((key, value) {
      Product p = Product(
          value['code'],
          value['name'],
          double.parse(value['rate']),
          1,
          0,
          "$key",
          int.parse(value['balance']));
      allData.add(p);
    });
  }
  return allData;
}

syncLogin() async {
  getAllUsers();
}

getAllUsers() async {
  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('users').get();
  Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;

  if (data != null) {
    final json_data = json.encode(data);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('users', json_data);
    print(preferences.getString('users') ?? '');
  }
}

getAllCustomer() async {
  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('parties').get();
  List<Customer> allData = [];
  if (snapshot.value != null) {
    for (var element in snapshot.children) {
      allData.add(Customer(
          "${element.child("name").value}",
          "${element.child("address").value}",
          '',
          '',
          '${element.child('code').value}',
          "${element.child("areacode").value}"));
    }
  }
  return allData;
}

Future<void> clearTable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insert(await getAll(), database);
  print("Product Cleared");
}

Future<void> clearCTable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insertCustomer(await getAllCustomer(), database);
  print("Customer Cleared");
}

Future<void> clearSTable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insertSector(await fetchSector(), database);
  print("Sector Cleared");
}

Future<void> clearATable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insertArea(await fetchArea(), database);
  print("Area Cleared");
}

Future<void> insert(List<Product> users, database) async {
  final Database db = await database;
  for (final user in users) {
    try {
      await db.insert(
        'Product',
        user.toSqlMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print(e);
    }
  }
  print("Area Added");
  await clearCTable('Parties', database);
}

Future<void> insertCustomer(List<Customer> users, database) async {
  final Database db = await database;
  for (final user in users) {
    await db.insert(
      'Parties',
      user.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  print("Customer Added");
  await clearSTable('Sector', database);
}

Future<void> insertSector(List<Sector> users, database) async {
  final Database db = await database;
  for (final user in users) {
    await db.insert(
      'Sector',
      user.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  print("Sector Added");

  await clearATable('Area', database);
}

Future<void> insertArea(List<Area> users, database) async {
  final Database db = await database;
  for (final user in users) {
    await db.insert(
      'Area',
      user.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  print("Area Added");

  db.close();
}

void saveCustomer(String boxName, List<Map<String, dynamic>> customers) async {
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CustomerAdapter());
  }
  var box = await Hive.openBox<Customer>(boxName);
  for (var customer in customers) {
    if (box.containsKey(customer['_id'])) {
      box.delete(customer['_id']);
    }
    box.put(
        customer['_id'],
        Customer(
            customer['dsc'],
            "${customer['Address']}",
            "${customer['Phone']}",
            "",
            "${customer['_id']}",
            "${customer['AreaCd']}"));
  }
}

void openHiveBox(String boxName, List<Map<String, dynamic>> products) async {
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProductAdapter());
  }
  var box = await Hive.openBox<Product>(boxName);
  for (var product in products) {
    if (kDebugMode) {
      print(product['balance']);
    }
    if (box.containsKey(product['_id'])) {
      box.delete(product['_id']);
    }
    box.put(
        product['_id'],
        Product(
            product['pcode'] ?? "",
            product['name1'],
            double.parse("${product['rate']}"),
            1,
            0,
            "${product['_id']}",
            int.parse("${product['balance']}")));
  }
  /*SharedPreferences prefs = await SharedPreferences.getInstance();
  final dbAdded = prefs.setBool("DB_ADDED",true);
  prefs.commit();*/
}
