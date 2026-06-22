# Smart Shop

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# planning
1.	dukan dibo. 
2.	Product kinbo. 
3.	Ki ki product kinechi oi gulo sob koytay level lagabo. 
4.	Levele e thakbe (product name, barcode or QRcode, purchase price Unicode or method code, selling price, owner name, address). Level create korar jonno product information dite hobe. (Name, purchase price, selling price, size, color, stock, photo)
5.	Product Dukane sajabo. 
6.	Customer asbe kono product choice korche ta hoile oi product ta scan kore add to cart kore sell kore dibo. Selling flow -> scan/product list theke scarch -> product details -> add to cart -> again product scan -> details -> add to cart -> all cart checkout (count up down kora jabe) if discount dite chai ta hoile discount dite parbo all amount er maje. Every product theke equle vabe discount hobe. 
7.	Report dekhbo. 
i.	Ajke koto takar product sell korlam kon kon item tar list and total amount
ii.	Ajker expenses koto taka tar list dekhte chai.
iii.	Everyday/ Coustom day (calendar From date – To date) koto taka profit hoyeche ta dekhte chai.
iv.	Admin kon kon product sell hoy geche every item er purchase price and selling price profit/loss profit black hobe loss rad color show korbe. Jate kore admin easy vabe scroll kore dekhte pare kon kon item loss e sell kore felchi. 
v.	Je product gulo stock 0 se product gulo alada table e show korbe. 
8.	Eki product age ekbar entry diyechi oi product ta sob sell hoyegeche then same product ta abar purchase kore niye aschi or alert diyechilo stock pry ses then purchase kore anchi oita same stocki noton kore add korte chai. Jate kore search korle stock thik moto dekhay. 
9.	Full database ta jar jar mobile er google drive e store hobe. 



# My work
1. ami je backup nitachi ar backup list dekhtachi oita kaj ki? jokhon uninstall korbo ofcourse jante chabe or auto ekta backup hobe then uninstall hobe. abar jokhon install korbo tokhon je gmail diye ekbar login korchi oi gmail diye again install kori ta hoile ofcourse database backup theke nibe then full data thakbe. 
2. apk link korte chai. 

# ja korechi 
User Login (Gmail)

        ↓

SQLite Database (Offline)
- Product
- Sell
- Customer
- Stock
- Expense
সব data এখানে save হবে।

        ↓

Internet আছে?
 ├─ না → শুধু SQLite এ save হবে।
 │
 └─ হ্যাঁ →
      Pending data check করবে।
      Server/Firebase এ Auto Sync হবে।
      unsynced_data = 0

        ↓

Settings Page
- Backup Now
- Backup List
- Last Backup Time
- Unsynced Data Count

যেমন:
Last Backup : 21 Jun 2026 10:30 PM
Unsynced Data : 15
