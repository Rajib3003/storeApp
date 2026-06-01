class PriceEncoder {
  static String encode(double price) {
    int base = (price * 2).toInt();

    return "657${base}075";
  }

  static double decode(String code) {
    String clean = code
        .replaceAll("657", "")
        .replaceAll("075", "");
    int base = int.parse(clean);

    return base / 2;
  }
}