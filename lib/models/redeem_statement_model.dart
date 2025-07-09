class RedeemStatement {
  final String orderId;
  final int personNo;
  final int redeemedCoverCharges;
  final int redeemedFreeDrinks;
  final String uniqueCode;
  final DateTime createdAt;

  RedeemStatement({
    required this.orderId,
    required this.personNo,
    required this.redeemedCoverCharges,
    required this.redeemedFreeDrinks,
    required this.uniqueCode,
    required this.createdAt,
  });

  factory RedeemStatement.fromJson(Map<String, dynamic> json) {
    return RedeemStatement(
      orderId: json['order_id'],
      personNo: json['person_no'],
      redeemedCoverCharges: json['redeemed_cover_charges'],
      redeemedFreeDrinks: json['redeemed_free_drinks'],
      uniqueCode: json['unique_code'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
