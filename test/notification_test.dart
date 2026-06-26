import 'package:flutter_test/flutter_test.dart';
import 'package:flarelane_flutter/notification.dart';

/// Spec for [FlareLaneNotification.fromJson] parsing. The class is a thin read-only data
/// holder; native (Android/iOS) computes derived fields (`clickedButton`, `clickedUrl`) and
/// hands them over via the bridge — these tests pin the parsing contract so future bridge
/// schema changes can't silently drop fields.
void main() {
  group('FlareLaneNotification', () {
    test('parses a body click payload (no buttons)', () {
      final notification = FlareLaneNotification({
        'id': 'n1',
        'body': 'hello',
        'url': 'https://example.com/body',
        'clickedButtonIndex': null,
        'clickedButton': null,
        'clickedUrl': 'https://example.com/body',
      });

      expect(notification.id, 'n1');
      expect(notification.body, 'hello');
      expect(notification.url, 'https://example.com/body');
      expect(notification.buttons, isNull);
      expect(notification.clickedButtonIndex, isNull);
      expect(notification.clickedButton, isNull);
      // Body click branch: clickedUrl = body url.
      expect(notification.clickedUrl, 'https://example.com/body');
    });

    test('parses a button click payload (button has link)', () {
      final notification = FlareLaneNotification({
        'id': 'n2',
        'body': 'hello',
        'url': 'https://example.com/body',
        'buttons': [
          {'label': 'Open', 'link': 'https://example.com/a'},
          {'label': 'Share'},
        ],
        'clickedButtonIndex': 0,
        'clickedButton': {'label': 'Open', 'link': 'https://example.com/a'},
        'clickedUrl': 'https://example.com/a',
      });

      expect(notification.buttons?.length, 2);
      expect(notification.buttons?[0].label, 'Open');
      expect(notification.buttons?[0].link, 'https://example.com/a');
      expect(notification.buttons?[1].label, 'Share');
      expect(notification.buttons?[1].link, isNull);
      expect(notification.clickedButtonIndex, 0);
      expect(notification.clickedButton?.label, 'Open');
      expect(notification.clickedButton?.link, 'https://example.com/a');
      expect(notification.clickedUrl, 'https://example.com/a');
    });

    test(
      'parses a button click without link — clickedUrl is null, NOT the body url',
      () {
        // This is the critical "no cross-fallback" guard: when the user taps a button that
        // has no link, the bridge sends clickedUrl=null. The data class must surface that
        // null and not silently substitute the body's url, which would be a different
        // destination than what the click carried.
        final notification = FlareLaneNotification({
          'id': 'n3',
          'body': 'hello',
          'url': 'https://example.com/body',
          'buttons': [
            {'label': 'NoLink'},
          ],
          'clickedButtonIndex': 0,
          'clickedButton': {'label': 'NoLink'},
          'clickedUrl': null,
        });

        expect(notification.clickedButtonIndex, 0);
        expect(notification.clickedButton?.label, 'NoLink');
        expect(notification.clickedButton?.link, isNull);
        expect(notification.clickedUrl, isNull);
        expect(notification.url, 'https://example.com/body');
      },
    );

    test('parses out-of-range button click (clickedButton=null, clickedUrl=null)', () {
      final notification = FlareLaneNotification({
        'id': 'n4',
        'body': 'hello',
        'url': 'https://example.com/body',
        'buttons': [
          {'label': 'Only', 'link': 'https://example.com/only'},
        ],
        // OS reported a button slot tap but native couldn't resolve the button (stale
        // category cache, etc.). Index stays set so callers can still tell "it was a
        // button click", but the button object and clickedUrl are null.
        'clickedButtonIndex': 5,
        'clickedButton': null,
        'clickedUrl': null,
      });

      expect(notification.clickedButtonIndex, 5);
      expect(notification.clickedButton, isNull);
      expect(notification.clickedUrl, isNull);
    });

    test('parses data as Map (both iOS and Android bridges send Map now)', () {
      final notification = FlareLaneNotification({
        'id': 'n5',
        'body': 'hello',
        'data': {'key': 'value'},
      });
      expect(notification.data, {'key': 'value'});
    });

    test('skips malformed button entries instead of throwing', () {
      final notification = FlareLaneNotification({
        'id': 'n7',
        'body': 'hello',
        // Mixed list — native should only forward Map-shaped entries with valid labels,
        // but guard anyway so a wire-format hiccup can't crash the callback. Any of:
        //   - non-Map (string/int) entries
        //   - Map entries with missing / non-string / empty `label`
        // are dropped silently.
        'buttons': [
          {'label': 'Good', 'link': 'https://example.com/a'},
          'not-a-map',
          42,
          {'link': 'https://example.com/no-label'}, // missing label
          {'label': null, 'link': 'https://example.com/null-label'}, // null label
          {'label': '', 'link': 'https://example.com/empty-label'}, // empty label
          {'label': 99, 'link': 'https://example.com/int-label'}, // wrong-type label
          {'label': 'AlsoGood'},
        ],
      });

      expect(notification.buttons?.length, 2);
      expect(notification.buttons?[0].label, 'Good');
      expect(notification.buttons?[1].label, 'AlsoGood');
    });
  });
}
