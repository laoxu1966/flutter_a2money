class Token {
  Token({
    this.id,
    required this.abilityid,
    required this.respondid,
    required this.payable,
    this.freeze,
    this.unfreeze,
    this.pay,
    this.income,
    this.fee,
    this.cash,
    this.msg,
    required this.uid,
    this.created,
    this.updated,
  });

  int? id;
  int abilityid;
  int respondid;
  num payable;
  num? freeze;
  num? unfreeze;
  num? pay;
  num? income;
  num? fee;
  num? cash;
  String? msg;
  int uid;
  DateTime? created;
  DateTime? updated;

  factory Token.fromJson(Map<String, dynamic> parsedJson) {
    return Token(
      id: parsedJson['id'],
      abilityid: parsedJson['abilityid'],
      respondid: parsedJson['respondid'],
      payable: parsedJson['payable'],
      freeze: parsedJson['freeze'],
      unfreeze: parsedJson['unfreeze'],
      pay: parsedJson['pay'],
      income: parsedJson['income'],
      fee: parsedJson['fee'],
      cash: parsedJson['cash'],
      msg: parsedJson['msg'],
      uid: parsedJson['uid'],
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now())
          .toLocal(),
      updated: (DateTime.tryParse(parsedJson['updated']) ?? DateTime.now())
          .toLocal(),
    );
  }
}
