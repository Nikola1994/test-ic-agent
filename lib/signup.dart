import 'package:agent_dart/agent_dart.dart';

import 'init.dart';

class SignupMethod {
  static const signup = "signup";
}

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

  Future<dynamic> signup(List<dynamic> argumnets) async {
    try {
      DelegationIdentity? delegationIdentity;
      if (signIdentity != null) {
        try {
          delegationIdentity = await requestFEDelegation(signIdentity!);
        } catch (error) {
          rethrow;
        }
      }

      final newAgent = AgentFactory.create(
          identity: delegationIdentity,
          canisterId: agent.canisterId.toText(),
          idl: agent.idl,
          url: agent.agentUrl,
          debug: false);

      var newActor = newAgent.hook(Signup()..agent = newAgent).actor;

      var res = await newActor.getFunc(SignupMethod.signup)!(argumnets);

      if (res != null) {
        // return (res as BigInt).toInt();
        return res;
      }
      throw "Cannot get count but $res";
    } catch (e) {
      rethrow;
    }
  }

  Future<DelegationIdentity> requestFEDelegation(
    SignIdentity identity,
  ) async {
    final sessionKey = Ed25519KeyIdentity.generate(null);
    const tenMinutesInMsec = 10 * 1000 * 60;

    final chain = await DelegationChain.create(
      identity,
      sessionKey.getPublicKey(),
      DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + tenMinutesInMsec),
      targets: [agent.canisterId],
    );

    return DelegationIdentity.fromDelegation(sessionKey, chain);
  }
}
