import 'package:evancode_task/core/errors/app_exceptions.dart';
import 'package:evancode_task/data/repositories/order_repository.dart';
import 'package:evancode_task/data/sources/order_local_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeConnectivity connectivity;
  late MemoryStorage storage;
  late FakeRemote remote;
  late OrderRepository repository;

  setUp(() {
    connectivity = FakeConnectivity();
    storage = MemoryStorage();
    remote = FakeRemote([sampleOrder()]);
    repository = OrderRepository(
      remote: remote,
      local: OrderLocalSource(storage),
      connectivity: connectivity,
    );
  });

  test(
    'online with no cache: fetches, caches and reports fresh data',
    () async {
      final result = await repository.getOrders();
      expect(result.isFromCache, isFalse);
      expect(result.orders.single.id, 'WSL-2026-0001');
      expect((await repository.readCache())?.orders.length, 1);
    },
  );

  test('cache present and no force: returns cache without network', () async {
    await repository.getOrders();
    final result = await repository.getOrders();
    expect(result.isFromCache, isTrue);
    expect(remote.calls, 1);
  });

  test('offline with cache: keeps cached list and flags the error', () async {
    await repository.getOrders();
    connectivity.online = false;
    final result = await repository.getOrders(forceRefresh: true);
    expect(result.isFromCache, isTrue);
    expect(result.orders, isNotEmpty);
    expect(result.refreshError, isA<OfflineException>());
  });

  test('server failure with cache: never wipes saved data', () async {
    await repository.getOrders();
    remote.failWith = const ServerException('boom');
    final result = await repository.getOrders(forceRefresh: true);
    expect(result.orders, isNotEmpty);
    expect(result.refreshError, isA<ServerException>());
    expect((await repository.readCache())?.orders, isNotEmpty);
  });

  test('offline with no cache: throws OfflineException', () async {
    connectivity.online = false;
    expect(repository.getOrders(), throwsA(isA<OfflineException>()));
  });

  test('corrupt cache is discarded instead of crashing', () async {
    storage.data['orders_cache_v1'] = '{not json';
    expect(await repository.readCache(), isNull);
    expect(storage.data, isEmpty);
  });
}
