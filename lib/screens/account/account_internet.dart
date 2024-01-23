import 'package:game_template/screens/account/account_model.dart';
import 'package:game_template/services/firebase/firebase_rtdb.dart';
import 'package:game_template/services/get_it_helper.dart';

class AccountInternet{
  static AccountInternet _accountInternet = AccountInternet._();
  factory AccountInternet(){
    return _accountInternet;
  }
  AccountInternet._();

  Future<AccountModel> getUser(String userId){

    return global.db.gatherFutureData(
      ref: "users",
      child: userId
    ).then((value) => AccountModel.fromRtdb(value));
  }

  Future postUser(AccountModel accountModel){
    return global.db.modifyData(
      dataChange: DataChange.Insert,
      updateIfAlreadyInserted: true,
      ref: "users",
      data: {
        "user_id"       : accountModel.userId,
        "username"      : accountModel.username,
        "stats"         : accountModel.stats,
        "personal_info" : accountModel.personalInfo,
        "preferences"   : accountModel.preferences,
      }
    );
  }


}