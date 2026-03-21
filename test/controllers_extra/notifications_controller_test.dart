import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/notifications/data/notifications_repository_impl.dart';
import 'package:ojaewa/features/notifications/domain/app_notification.dart';
import 'package:ojaewa/features/notifications/domain/notification_preferences.dart';
import 'package:ojaewa/features/notifications/domain/notifications_repository.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';

void main() {
  group('OptimisticNotificationsNotifier', () {
    test('returns an empty list when unauthenticated', () async {
      final repository = _MockNotificationsRepository();
      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => null),
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationsListProvider.future);

      expect(result, isEmpty);
      verifyNever(() => repository.getNotifications());
    });

    test('marks a single notification as read optimistically', () async {
      final repository = _MockNotificationsRepository();
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => [_notification(id: 1), _notification(id: 2)]);

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsListProvider.future);

      container
          .read(notificationsListProvider.notifier)
          .markAsReadOptimistically(2);

      final state = container.read(notificationsListProvider).requireValue;
      expect(state.first.isRead, isFalse);
      expect(state.last.isRead, isTrue);
    });
  });

  group('OptimisticUnreadCountNotifier', () {
    test('decrements count optimistically without dropping below zero', () async {
      final repository = _MockNotificationsRepository();
      when(() => repository.getUnreadCount()).thenAnswer((_) async => 1);

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(unreadCountProvider.future);

      final notifier = container.read(unreadCountProvider.notifier);
      notifier.decrementOptimistically();
      notifier.decrementOptimistically();

      expect(container.read(unreadCountProvider).requireValue, 0);
    });
  });

  group('NotificationsActionsController', () {
    test('markAsRead updates list and unread count before syncing', () async {
      final repository = _MockNotificationsRepository();
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => [_notification(id: 1), _notification(id: 2)]);
      when(() => repository.getUnreadCount()).thenAnswer((_) async => 2);
      when(() => repository.markAsRead(2)).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsListProvider.future);
      await container.read(unreadCountProvider.future);

      await container.read(notificationsActionsProvider.notifier).markAsRead(2);

      final notifications = container
          .read(notificationsListProvider)
          .requireValue;
      final unreadCount = container.read(unreadCountProvider).requireValue;

      expect(notifications.last.isRead, isTrue);
      expect(unreadCount, 1);
      expect(
        container.read(notificationsActionsProvider),
        const AsyncData<void>(null),
      );
      verify(() => repository.markAsRead(2)).called(1);
    });

    test('updatePreferences rolls back optimistic changes on failure', () async {
      final repository = _MockNotificationsRepository();
      final initialPrefs = _preferences();
      final newPrefs = initialPrefs.copyWith(newOrders: true);

      when(
        () => repository.getPreferences(),
      ).thenAnswer((_) async => initialPrefs);
      when(
        () => repository.updatePreferences(newPrefs),
      ).thenThrow(StateError('save failed'));

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationPreferencesProvider.future);
      container.read(optimisticPreferencesProvider);

      expect(
        () => container
            .read(notificationsActionsProvider.notifier)
            .updatePreferences(newPrefs),
        throwsA(isA<StateError>()),
      );

      final rolledBack = container.read(optimisticPreferencesProvider);
      expect(rolledBack, isNotNull);
      expect(rolledBack!.newOrders, isFalse);
      expect(
        container.read(notificationsActionsProvider),
        isA<AsyncError<void>>(),
      );
    });
  });
}

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

AppNotification _notification({required int id, bool isRead = false}) {
  return AppNotification(
    id: id,
    title: 'Notification $id',
    body: 'Body $id',
    isRead: isRead,
    createdAt: DateTime(2026, 3, 13),
    event: 'order_status',
    payload: const {'deep_link': '/orders'},
  );
}

NotificationPreferences _preferences() {
  return const NotificationPreferences(
    allowPushNotifications: true,
    newProducts: true,
    discountAndSales: true,
    newBlogPosts: true,
    newOrders: false,
  );
}
