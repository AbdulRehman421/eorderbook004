import 'package:hive/hive.dart';
part 'Customer.g.dart';
@HiveType(typeId: 2)
class Customer {
  @HiveField(0)
  String name="";
  @HiveField(1)
  String address="";
  @HiveField(2)
  String phone;
  @HiveField(3)
  String email;
  @HiveField(4)
  String id;
  String areaCode;

  Customer(this.name, this.address, this.phone, this.email, this.id,this.areaCode);


  @override
  String toString() {
    return 'Customer{name: $name, address: $address, phone: $phone, email: $email}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'id': id,
    };
  }

  Map<String, Object?> toSqlMap() {
   return {
     'acno': id,
     'dsc':name ?? "",
     'Type': 'M',
     'Address': address,
     'Phone': '',
     'Mobile': '',
     'AreaCd': areaCode,
   };
  }

}
