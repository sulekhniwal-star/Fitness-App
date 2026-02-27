import 'package:flutter_test/flutter_test.dart';
import 'package:fitkarma/core/sync/sync_service.dart';

void main() {
  group('SyncAction', () {
    test('should create SyncAction from constructor', () {
      final action = SyncAction(
        id: 'action_1',
        collection: 'food_logs',
        operation: 'create',
        data: {'name': 'test'},
        recordId: 'record_123',
      );

      expect(action.id, 'action_1');
      expect(action.collection, 'food_logs');
      expect(action.operation, 'create');
      expect(action.data, {'name': 'test'});
      expect(action.recordId, 'record_123');
      expect(action.retryCount, 0);
    });

    test('should create SyncAction with custom retry count', () {
      final action = SyncAction(
        id: 'action_1',
        collection: 'food_logs',
        operation: 'create',
        data: {'name': 'test'},
        recordId: 'record_123',
        retryCount: 3,
      );

      expect(action.retryCount, 3);
    });

    test('should convert to JSON correctly', () {
      final action = SyncAction(
        id: 'action_1',
        collection: 'food_logs',
        operation: 'create',
        data: {'name': 'test', 'value': 42},
        recordId: 'record_123',
      );

      final json = action.toJson();

      expect(json['id'], 'action_1');
      expect(json['collection'], 'food_logs');
      expect(json['operation'], 'create');
      expect(json['data'], {'name': 'test', 'value': 42});
      expect(json['recordId'], 'record_123');
      expect(json['retryCount'], 0);
      expect(json['createdAt'], isNotNull);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'action_1',
        'collection': 'food_logs',
        'operation': 'create',
        'data': {'name': 'test'},
        'recordId': 'record_123',
        'retryCount': 2,
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final action = SyncAction.fromJson(json);

      expect(action.id, 'action_1');
      expect(action.collection, 'food_logs');
      expect(action.operation, 'create');
      expect(action.data, {'name': 'test'});
      expect(action.recordId, 'record_123');
      expect(action.retryCount, 2);
      expect(action.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should copyWith update retry count', () {
      final action = SyncAction(
        id: 'action_1',
        collection: 'food_logs',
        operation: 'create',
        data: {'name': 'test'},
        recordId: 'record_123',
        retryCount: 0,
      );

      final updated = action.copyWith(retryCount: 5);

      expect(updated.retryCount, 5);
      expect(updated.id, action.id); // unchanged
      expect(updated.collection, action.collection); // unchanged
    });

    test('should handle all operation types', () {
      final createAction = SyncAction(
        id: '1',
        collection: 'test',
        operation: 'create',
        data: {},
        recordId: '',
      );
      expect(createAction.operation, 'create');

      final updateAction = SyncAction(
        id: '2',
        collection: 'test',
        operation: 'update',
        data: {},
        recordId: 'r1',
      );
      expect(updateAction.operation, 'update');

      final deleteAction = SyncAction(
        id: '3',
        collection: 'test',
        operation: 'delete',
        data: {},
        recordId: 'r1',
      );
      expect(deleteAction.operation, 'delete');
    });
  });
}
