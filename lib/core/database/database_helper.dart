import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance to avoid multiple DB connections
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  // Database initialization
  Future<Database> get database async {
    if (_db != null) {
      print("Database already initialized.");
      return _db!;
    }
    print("Database is null, initializing...");
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    print("Database path: $dbPath");

    bool resetDatabase =
        true; // Set this to true if you want to delete the database

    if (resetDatabase) {
      await deleteDatabase(dbPath); // This will delete the existing database
      print("Existing database deleted.");
    }
    try {
      print("Initializing database...");
      final db = await openDatabase(
        'formula_manager.db',
        version: 7,
        readOnly: false,
        onCreate: (db, version) async {
          print("Creating tables...");
          await db.execute('PRAGMA foreign_keys = ON'); 
          await db.execute('''
          CREATE TABLE IF NOT EXISTS formulas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            notes TEXT,
            creation_date TEXT, -- Store the date as an ISO 8601 string
            modified_date TEXT
          )
        ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS formula_ingredients (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              formula_id INTEGER,
              ingredient_id INTEGER,
              amount REAL,
              dilution REAL,
              FOREIGN KEY (formula_id) REFERENCES formulas(id) ON DELETE CASCADE,
              FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS ingredients (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              category TEXT,
              inventory_amount REAL,
              cost_per_gram REAL,
              supplier TEXT,
              acquisition_date TEXT,
              description TEXT,
              personal_notes TEXT,
              supplier_notes TEXT,
              pyramid_place TEXT,
              substantivity REAL
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS cas_numbers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              ingredient_id INTEGER,
              cas_number TEXT,
              FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
            )
          ''');
          await db.execute('''
            CREATE TABLE tags (
              id INTEGER PRIMARY KEY,
              tag_name TEXT
            );
          ''');
          await db.execute('''
            CREATE TABLE ingredient_tags (
              ingredient_id INTEGER,
              tag_id INTEGER,
              FOREIGN KEY (ingredient_id) REFERENCES ingredients(id),
              FOREIGN KEY (tag_id) REFERENCES tags(id)
            );
          ''');

          await db.execute('''
                CREATE TABLE ifra_standards (
                            key TEXT PRIMARY KEY,
                            amendment_number INTEGER,
                            year_previous_publication TEXT,
                            year_last_publication INTEGER,
                            implementation_deadline_existing TEXT,
                            implementation_deadline_new TEXT,
                            name_of_ifra_standard TEXT,
                            cas_numbers TEXT,
                            cas_numbers_comment TEXT,
                            synonyms TEXT,
                            ifra_standard_type TEXT,
                            intrinsic_property TEXT,
                            flavor_use_consideration TEXT,
                            prohibited_fragrance_notes TEXT,
                            phototoxicity_notes TEXT,
                            restricted_ingredients_notes TEXT,
                            specified_ingredients_notes TEXT,
                            contributions_other_sources TEXT,
                            contributions_other_sources_notes TEXT,
                            category_1 TEXT,
                            category_2 TEXT,
                            category_3 TEXT,
                            category_4 TEXT,
                            category_5a TEXT,
                            category_5b TEXT,
                            category_5c TEXT,
                            category_5d TEXT,
                            category_6 TEXT,
                            category_7a TEXT,
                            category_7b TEXT,
                            category_8 TEXT,
                            category_9 TEXT,
                            category_10a TEXT,
                            category_10b TEXT,
                            category_11a TEXT,
                            category_11b TEXT,
                            category_12 TEXT
                        );
              ''');

          await db.execute('''
                        CREATE TABLE ifra_categories (
                          category_id TEXT PRIMARY KEY,
                          description TEXT NOT NULL
                        )
                      ''');

          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_1', 'Lip Products/Toys');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_2', 'Deodorant/Antiperspirant/Body Spray/Body Mist');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_3', 'Eye Products/Make-up/Facial Treatment Masks');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_4', 'Perfume');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5a', 'Body Creams/Leave-on Body Products');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5b', 'Face Creams/Beard Oil/Leave-on Face Products');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5c', 'Hand Sanitizers/Leave on Hand Products');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5d', 'Baby Creams/Baby Oils/Baby Products');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_6', 'Mouthwash/Toothpaste/Breath Spray');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_7a', 'Rinse off Hair Treatments');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_7b', 'Leave on Hair Treatments');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_8', 'Intimate Wipes/Baby Wipes');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_9', 'Bathwater Products/Soap/Shampoo');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_10a', 'Household Cleaning Products/Reed Diffusers');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_10b', 'Air Freshener Sprays');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_11a', 'Diapers');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_11b', 'Scented Clothing');
                            ''');
          await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_12', 'Candles/Incense/Air Fresheners');
                            ''');

           await db.execute('''
                CREATE TABLE olfactive_categories (
                  id INTEGER PRIMARY KEY,
                  name TEXT NOT NULL,
                  color TEXT
                );
              ''');
          final categories = [
            'Aldehydic',
            'Ambery',
            'Citrus',
            'Floral',
            'Fruity',
            'Gourmand',
            'Green',
            'Herbal',
            'Agrestic',
            'Leather',
            'Moss',
            'Marine',
            'Musky',
            'Spicy',
            'Terpenic',
            'Woody',
          ];

          // Insert each category with color as NULL
          for (var category in categories) {
            await db.insert('olfactive_categories', {'name': category, 'color': null});
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          //   print("Upgrading database from version $oldVersion to $newVersion");
          print("upgrading...");
          print(oldVersion);
          print(newVersion);
          if (oldVersion < 1) {
            //     // If the database version is less than 5, add the `amount` column to the `ingredients` table

            await db.execute('''
                        CREATE TABLE ifra_categories (
                          category_id TEXT PRIMARY KEY,
                          description TEXT NOT NULL
                        )
                      ''');

            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_1', 'Lip Products/Toys');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_2', 'Deodorant/Antiperspirant/Body Spray/Body Mist');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_3', 'Eye Products/Make-up/Facial Treatment Masks');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_4', 'Perfume');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5a', 'Body Creams/Leave-on Body Products');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5b', 'Face Creams/Beard Oil/Leave-on Face Products');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5c', 'Hand Sanitizers/Leave on Hand Products');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_5d', 'Baby Creams/Baby Oils/Baby Products');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_6', 'Mouthwash/Toothpaste/Breath Spray');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_7a', 'Rinse off Hair Treatments');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_7b', 'Leave on Hair Treatments');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_8', 'Intimate Wipes/Baby Wipes');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_9', 'Bathwater Products/Soap/Shampoo');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_10a', 'Household Cleaning Products/Reed Diffusers');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_10b', 'Air Freshener Sprays');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_11a', 'Diapers');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_11b', 'Scented Clothing');
                            ''');
            await db.execute('''
                              INSERT INTO ifra_categories (category_id, description) VALUES ('category_12', 'Candles/Incense/Air Fresheners');
                            ''');
            //     //   await db.execute('''
            //     //   INSERT INTO formula_ingredients_new (formula_id, ingredient_id, amount)
            //     //   SELECT formula_id, ingredient_id, amount
            //     //   FROM formula_ingredients
            //     // ''');
            //     //     await db.execute('DROP TABLE formula_ingredients');
          }
          if (oldVersion < 2) {
            await db.execute('''
                ALTER TABLE formulas ADD COLUMN modified_date TEXT
              ''');
          }
          if (oldVersion < 5) {
            print("...to version 5");
            await db.execute('''DROP TABLE olfactive_categories;''');
            await db.execute('''
                CREATE TABLE olfactive_categories (
                  id INTEGER PRIMARY KEY,
                  name TEXT NOT NULL,
                  color TEXT
                );
              ''');
          final categories = [
            'Aldehydic',
            'Ambery',
            'Citrus',
            'Floral',
            'Fruity',
            'Gourmand',
            'Green',
            'Herbal',
            'Agrestic',
            'Leather',
            'Moss',
            'Marine',
            'Musky',
            'Spicy',
            'Terpenic',
            'Woody',
          ];

          // Insert each category with color as NULL
          for (var category in categories) {
            await db.insert('olfactive_categories', {'name': category, 'color': null});
          }

          }
          if(oldVersion <6 ){
            // remove old formula ingredients
           db.execute('ALTER TABLE formula_ingredients RENAME TO old_formula_ingredients;');
          //  remake with on cascade
           db.execute('''
              CREATE TABLE formula_ingredients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                formula_id INTEGER,
                ingredient_id INTEGER,
                amount REAL,
                dilution REAL,
                FOREIGN KEY (formula_id) REFERENCES formulas(id) ON DELETE CASCADE,
                FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
              ); ''');
            db.execute('DROP TABLE old_formula_ingredients;');
          }
        },
      );
      // print(await db.rawQuery('select * from olfactive_categories'));
      return db;
    } catch (e) {
      print("Error initializing database: $e");
      rethrow;
    }
  }
}
