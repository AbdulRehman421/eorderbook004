class Order {
  int? id;
  String? time;
  double? tax;
  double? vat;
  double? paidAmount;
  double? shippingCost;
  int? customerId;
  int? areaId;
  int? sectorId;
  String? date;
  String? invoiceNumber;

  Order({
    this.id,
    this.time,
    this.tax,
    this.vat,
    this.paidAmount,
    this.shippingCost,
    this.customerId,
    this.areaId,
    this.sectorId,
    this.date,
    this.invoiceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'tax': tax,
      'vat': vat,
      'paidAmount': paidAmount,
      'shippingCost': shippingCost,
      'customerId': customerId,
      'areaId': areaId,
      'sectorId': sectorId,
      'date': date,
      'invoiceNumber': invoiceNumber,
    };
  }
}

class OrderedProduct {
  int? id;
  int? productId;
  int? orderId;

  OrderedProduct({
    this.id,
    this.productId,
    this.orderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'orderId': orderId,
    };
  }
}
