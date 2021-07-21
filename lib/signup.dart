import 'package:agent_dart/agent_dart.dart';

import 'init.dart';

class SignupMethod {
  static const signup = "signup";
}

CType SignupRequest = IDL.Record({
  'company' : IDL.Text,
  'education' : IDL.Text,
  'display_name' : IDL.Text,
  'title' : IDL.Text,
  'username' : IDL.Text,
  'description' : IDL.Text,
  'link' : IDL.Text,
  'location' : IDL.Text,
  'pubkey' : IDL.Vec(IDL.Nat8)
});

CType Profile = IDL.Record({
  'id' : IDL.Nat64,
  'company' : IDL.Text,
  'education' : IDL.Text,
  'display_name' : IDL.Text,
  'title' : IDL.Text,
  'image' : Image,
  'cover' : Image,
  'description' : IDL.Text,
  'link' : IDL.Text,
  'location' : IDL.Text,
  'username' : IDL.Text,
});

CType Image = IDL.Record({
  'canister_id' : IDL.Principal,
  'image_id' : IDL.Text,
  'timestamp' : IDL.Nat64,
  'format' : IDL.Text
});

final idl = IDL.Service({
  SignupMethod.signup : IDL.Func([SignupRequest], [Profile], []),
});

class Signup extends ActorHook {
  Signup();
  factory Signup.create(CanisterActor _actor) {
    return Signup()..setActor(_actor);
  }
  setActor(CanisterActor _actor) {
    actor = _actor;
  }

  Future<dynamic> signup(List<dynamic> argumnets) async {
    try {
      var res = await actor.getFunc(SignupMethod.signup)!(argumnets);
      if (res != null) {
        // return (res as BigInt).toInt();
        return res;
      }
      throw "Cannot get count but $res";
    } catch (e) {
      rethrow;
    }
  }
}
