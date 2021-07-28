import 'package:agent_dart/agent_dart.dart';

import 'init.dart';

class SignupMethod {
  static const signup = "signup";
  static const getLatestAnnouncements = "getLatestAnnouncements";
}

CType Announcement = IDL.Record({
  'title' : IDL.Text,
  'updated_at' : IDL.Nat64,
  'action' : IDL.Text,
  'announcement_type' : IDL.Text,
  'content' : IDL.Text,
  'created_at' : IDL.Nat64,
  'user_id' : IDL.Nat64,
  'button_name' : IDL.Text,
  'announcement_id' : IDL.Nat64,
});

CType SignupRequest = IDL.Record({
  'company': IDL.Text,
  'education': IDL.Text,
  'display_name': IDL.Text,
  'title': IDL.Text,
  'username': IDL.Text,
  'description': IDL.Text,
  'link': IDL.Text,
  'location': IDL.Text,
  'pubkey': IDL.Vec(IDL.Nat8)
});

CType Profile = IDL.Record({
  'id': IDL.Nat64,
  'company': IDL.Text,
  'education': IDL.Text,
  'display_name': IDL.Text,
  'title': IDL.Text,
  'image': Image,
  'cover': Image,
  'description': IDL.Text,
  'link': IDL.Text,
  'location': IDL.Text,
  'username': IDL.Text,
});

CType Image = IDL.Record({
  'canister_id': IDL.Principal,
  'image_id': IDL.Text,
  'timestamp': IDL.Nat64,
  'format': IDL.Text
});

final idl = IDL.Service({
  SignupMethod.signup: IDL.Func([SignupRequest], [Profile], []),
  SignupMethod.getLatestAnnouncements : IDL.Func([], [IDL.Vec(Announcement)], ['query']),
});

class Signup extends ActorHook {
  late AgentFactory agent;
  SignIdentity? signIdentity;
  Signup();
  factory Signup.create(CanisterActor _actor) {
    return Signup()..setActor(_actor);
  }
  setActor(CanisterActor _actor) {
    actor = _actor;
  }

  Future<dynamic> signup(
    SignIdentity identity,
    List<dynamic> argumnets,
  ) async {
    try {
      agent.getAgent().setIdentity(Future.value(identity));

      var res = await agent.actor!.getFunc(SignupMethod.signup)!(argumnets);

      if (res != null) {
        // return (res as BigInt).toInt();
        return res;
      }
      throw "Cannot get count but $res";
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLatestAnnouncements(
      SignIdentity identity,
      List<dynamic> argumnets,
      ) async {
    try {
      agent.getAgent().setIdentity(Future.value(identity));

      var res = await agent.actor!.getFunc(SignupMethod.getLatestAnnouncements)!(argumnets);

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
