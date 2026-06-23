class PriceHelper {

  static const Map<String, String> _encodeMap = {
    '0': 'B',
    '1': 'E',
    '2': 'K',
    '3': 'T',
    '4': 'M',
    '5': 'P',
    '6': 'R',
    '7': 'S',
    '8': 'X',
    '9': 'Z',
  };

  static String _encodeDigits(String input) {
    return input.split('').map((c) => _encodeMap[c] ?? c).join();
  }

  // ================= STORE ORIGINAL =================
  static double normalize(dynamic value) {
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ================= UI ONLY ENCODE =================
  static String toEncodedDisplay(dynamic value) {
    double price = normalize(value);
    String text = price.toStringAsFixed(2);
    return _encodeDigits(text);
  }
}