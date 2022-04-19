// ignore_for_file: constant_identifier_names

//String endPoint = 'https://192.168.255.162:3000';
String endPoint = 'https://www.a2money.com:3000';
//String endPoint = 'https://1618.tpddns.cn:3000';

enum ConfirmDialogAction {
  CANCEL,
  OK,
}

enum AbilityAction {
  FAVORITE,
  CANCEL_FAVORITE,
  UPDATE,
  DELETE,
  SHARE,
  SHARE_QR,
}

enum UserAction {
  FOLLOW,
  MEMO,
}

enum RespondAction {
  UPDATE,
  DELETE,
  VIEW,
  MEMO,
}

enum AuthAction {
  USERNAME,
  PASSWORD,
  PROFILE,
  EMAIL,
  TEL,
  SIGNOUT,
  LOGOUT,
  SIGNINWITHGOOGLE,
  SIGNINWITHFACEBOOK,
  SIGNINWITHTWITTER,
  SIGNINWITHGITGUB,
  SIGNINWITHWECHAT,
  SIGNINWITHEMAILANDLINK,
}

enum ImageAction {
  GALLERY_IMAGE,
  CAMERA_IMAGE,
}

enum QuestionAction {
  UPDATE,
  DELETE,
}

enum AnswerAction {
  UPDATE,
  DELETE,
}

List<String> payingArr = [
  '响应方向发起方支付',
  '发起方向响应方支付',
];

List<String> tokenArr = [
  '预授权',
  '解除预授权',
  '预授权转支付',
  '收入',
  '手续费',
  '提现',
];

List<String> classificationArr = [
  '经验(技能)变现',
  '方案(专利)变现',
  '写作(报告)变现',
  '数据(资料)变现',
  '社交(人脉)变现',
  '资质(证书)变现',
  '流量(平台)变现',
  '组织(身份)变现',
  '策划(创意)变现',
  '颜值(天赋)变现',
  '社群(会员)变现',
  '商机(项目)变现',
  '品牌(渠道)变现',
  '智商(情商)变现',
  '资产(债务)变现',
];
