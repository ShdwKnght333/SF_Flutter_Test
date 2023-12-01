import 'package:sf_auth_test/Classes/auth_token.dart';

class User{
  String id;
  String accountId;
  String name;
  AuthToken token;

  User({
    required this.id,
    required this.accountId,
    required this.name,
    required this.token,
  });

  @override
  String toString() {
    String data = '''
$name infomration
ID         : $id
AccountId  : $accountId
''';
    return data;
  }
}