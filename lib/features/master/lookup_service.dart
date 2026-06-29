import '../../db/db_helper.dart';

class LookupService {

  static Future<List<Map<String,dynamic>>> getCategories() async{
    final db=await DBHelper.db;

    return await db.query(
      "categories",
      orderBy: "category_name",
    );
  }

  static Future<List<Map<String,dynamic>>> getBrands() async{
    final db=await DBHelper.db;

    return await db.query(
      "brands",
      orderBy: "brand_name",
    );
  }

  static Future<List<Map<String,dynamic>>> getColors() async{
    final db=await DBHelper.db;

    return await db.query(
      "colors",
      orderBy: "color_name",
    );
  }

  static Future<List<Map<String,dynamic>>> getSizes() async{
    final db=await DBHelper.db;

    return await db.query(
      "sizes",
      orderBy: "size_name",
    );
  }

}