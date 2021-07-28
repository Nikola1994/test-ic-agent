import 'package:agent_dart/agent_dart.dart';

class AgentFactory {
  late final Principal _canisterId;
  late Identity _identity;
  late HttpAgent _agent;
  HttpAgent getAgent() => _agent;
  late final bool _debug;
  CanisterActor? _actor;
  late Service _idl;
  late String _url;
  Identity get identity => _identity;
  Principal get canisterId => _canisterId;
  Service get idl => _idl;
  String get agentUrl => _url;

  CanisterActor? get actor => _actor;

  AgentFactory(
      {required String canisterId,
      required String url,
      required Service idl,
      Identity? identity,
      bool? debug = true}) {
    _setCanisterId(canisterId);
    _identity = identity ?? Ed25519KeyIdentity.generate(null);
    _idl = idl;
    _debug = debug ?? true;
    _url = url;
  }

  static CanisterActor createActor(ServiceClass idl, HttpAgent agent, Principal canisterId) {
    return Actor.createActor(idl, ActorConfig.fromMap({"canisterId": canisterId, "agent": agent}));
  }

  factory AgentFactory.create(
      {required String canisterId,
      required String url,
      required Service idl,
      Identity? identity,
      bool? debug = true}) {
    return AgentFactory(
        canisterId: canisterId,
        url: url,
        idl: idl,
        identity: identity ?? Ed25519KeyIdentity.generate(null),
        debug: debug);
  }

  T hook<T extends ActorHook>(T target) {
    target.actor = actor!;
    return target;
  }

  void _setCanisterId(String canisterId) {
    _canisterId = Principal.fromText(canisterId);
  }

  Future<void> initAgent(String url) async {
    var uri = Uri.parse(url);
    var port = ":${uri.port}";
    var protocol = uri.scheme;
    var host = uri.host;

    _agent = HttpAgent(
        defaultProtocol: protocol,
        defaultHost: host,
        defaultPort: port,
        options: HttpAgentOptions()..identity = _identity);
    if (_debug) {
      await _agent.fetchRootKey();
    }
    _agent.addTransform(HttpAgentRequestTransformFn()..call = makeNonceTransform());
  }

  void setActor() {
    _actor =
        Actor.createActor(_idl, ActorConfig.fromMap({"canisterId": _canisterId, "agent": _agent}));
  }
}

abstract class ActorHook {
  late final CanisterActor actor;
}
