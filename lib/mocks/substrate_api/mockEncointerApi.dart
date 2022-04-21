import 'package:encointer_wallet/mocks/data/mockEncointerData.dart';
import 'package:encointer_wallet/service/substrate_api/encointer/encointerApi.dart';
import 'package:encointer_wallet/store/encointer/types/bazaar.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';

import '../../models/index.dart';
import 'core/mockDartApi.dart';
import 'mockJSApi.dart';

/// The key rationale behind this mock is that all the getters do not alter the app state.
///
/// This allows to configure the app storage for specific tests via the `PrepareStorage` class.
/// The getters then return the preconfigured value, which in turn leads to consistent
/// responses in the test.
class MockApiEncointer extends EncointerApi {
  MockApiEncointer(MockJSApi js, MockSubstrateDartApi dartApi) : super(js, dartApi);

  void _log(String msg) {
    print("[mockApiAssets] $msg");
  }

  @override
  Future<void> startSubscriptions() async {
    _log("empty startSubscriptions stub");
  }

  @override
  Future<void> stopSubscriptions() async {
    _log("empty stopSubscriptions stub");
  }

  @override
  Future<void> subscribeBusinessRegistry() async {
    _log("empty subscribeBusinessRegistry stub");
  }

  @override
  Future<CeremonyPhase> getCurrentPhase() async {
    if (store.encointer.currentPhase == null) {
      store.encointer.setCurrentPhase(initialPhase);
    }

    return store.encointer.currentPhase;
  }

  @override
  Future<int> getCurrentCeremonyIndex() async {
    if (store.encointer.currentCeremonyIndex == null) {
      store.encointer.setCurrentCeremonyIndex(1);
    }
    return store.encointer.currentCeremonyIndex;
  }

  @override
  Future<AggregatedAccountData> getAggregatedAccountData(CommunityIdentifier cid, String account) {
    return Future.value(null);
  }

  @override
  Future<void> getReputations() async {}

  @override
  Future<void> getEncointerBalance() async {}

  @override
  Future<void> getAllMeetupLocations() async {}

  @override
  Future<List<CommunityIdentifier>> getCommunityIdentifiers() async {
    return testCommunityIdentifiers;
  }

  @override
  Future<List<CidName>> communitiesGetAll() async {
    return store.encointer.communities;
  }

  @override
  Future<bool> hasPendingIssuance() async {
    return true;
  }

  @override
  Future<void> getDemurrage() async {}

  @override
  Future<List<AccountBusinessTuple>> getBusinesses() async {
    _log("warn: getBusinessRegistry mock is unimplemented");

    return Future.value([]);
  }

  @override
  Future<void> getCommunityMetadata() {
    return Future.value(null);
  }

  @override
  Future<void> getCommunityData() {
    return Future.value(null);
  }

  @override
  Future<void> getMeetupTime() async {
    return DateTime.fromMillisecondsSinceEpoch(claim['timestamp']);
  }

  @override
  Future<void> getBootstrappers() {
    return Future.value(null);
  }
}