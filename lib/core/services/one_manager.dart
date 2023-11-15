import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:one/core/router/bottom_sheet_route.dart';

typedef OneBindingList<T> = List<_OneBinding<T>>;

class _OneBinding<T> {
  final String tag;
  final T Function<T>() binding;
  final String? routeContext;

  _OneBinding({required this.tag, required this.binding, this.routeContext});
}

class One with _OneNavigator {
  /// At this point we have a singleton, that follows the singleton pattern
  /// [Wiki](https://en.wikipedia.org/wiki/Singleton_pattern)
  static final One _internal = One._();
  factory One() => _internal;
  One._() {
    _registredInstances = [];
  }

  static Iterable<One> get _instanceYield sync* {
    yield _internal;
  }

  static One get instance => _instanceYield.first;

  // Registred instances of application
  late OneBindingList _registredInstances;

  T get<T>({String? tag}) {
    final String instanceTag = tag ?? T.toString();

    _OneBinding<T> tBinding = instance._registredInstances.firstWhere((element) {
      bool isTag = element.tag == instanceTag;
      if (isTag) {
        element.mounted = true;
        element.onGet?.call();
      }
      return element.tag == instanceTag;
    }, orElse: () {
      throw Exception('Instance $T not found');
    }) as _OneBinding<T>;

    T tInstance = tBinding.binding<T>();

    tInstance.mounted = true;
    tInstance.onGet?.call();

    return tInstance;
  }

  void lazyRegister<T>(T tInstance, {String? tag, void Function()? onGet, void Function()? onDispose}) {
    final String instanceTag = tag ?? T.toString();
    final String? route = currentRoute;

    if (kDebugMode) {
      print('Registering instance $tInstance with tag $instanceTag');
    }

    if (instance._registredInstances.where((element) => element.tag == instanceTag).isNotEmpty) {
      throw Exception('Instance $T already registered');
    }

    instance._registredInstances.add(
      _OneBinding<T>(
        tag: instanceTag,
        binding: <T>() {
          tInstance.onGet = onGet;
          tInstance.onDispose = onDispose;
          return tInstance as T;
        },
        routeContext: route,
      ),
    );
  }

  T register<T>(T tInstance, {String? tag, void Function()? onGet, void Function()? onDispose}) {
    lazyRegister(tInstance, tag: tag, onGet: onGet, onDispose: onDispose);
    return get<T>(tag: tag);
  }

  void unregister<T>({String? tag}) {
    final String instanceTag = tag ?? T.toString();

    if (kDebugMode) {
      print('Unregistering instance $T with tag $instanceTag');
    }

    instance._registredInstances.removeWhere((element) {
      bool isTag = (element as _OneBinding<T>).tag == instanceTag;
      if (isTag) {
        element.mounted = false;
        element.onDispose?.call();
      }
      return isTag;
    });
  }

  void unregisterFromRoute<T>({required String route}) {
    if (kDebugMode) {
      print('Unregistering instance $T from route $route');
    }

    instance._registredInstances.removeWhere(
      (element) {
        bool isRoute = element.routeContext == route;
        if (isRoute) {
          element.mounted = false;
          element.onDispose?.call();
        }
        return isRoute;
      },
    );
  }

  void unregisterFromCurrentRoute<T>() {
    if (kDebugMode) {
      print('Unregistering instances from current route');
    }
    unregisterFromRoute(route: currentRoute!);
  }

  @override
  void pop<T>([T? result]) {
    return _navigator.pop(result);
  }

  @override
  Future<T?> popAndPushNamed<T, TO>(String routeName, {TO? result, Object? arguments}) {
    return _navigator.popAndPushNamed(routeName, result: result, arguments: arguments);
  }

  @override
  void popUntil(RoutePredicate predicate) {
    return _navigator.popUntil(predicate);
  }

  @override
  Future<T?> push<T>(Route<T> route) {
    return _navigator.push(route);
  }

  @override
  Future<T?> pushAndRemoveUntil<T>(Route<T> newRoute, RoutePredicate predicate) {
    return _navigator.pushAndRemoveUntil(newRoute, predicate);
  }

  @override
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return _navigator.pushNamed(routeName, arguments: arguments);
  }

  @override
  Future<T?> pushNamedAndRemoveUntil<T>(String newRouteName, RoutePredicate predicate, {Object? arguments}) {
    return _navigator.pushNamedAndRemoveUntil(newRouteName, predicate, arguments: arguments);
  }

  @override
  Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result}) {
    return _navigator.pushReplacement(route, result: result);
  }

  @override
  Future<T?> pushReplacementNamed<T, TO>(String routeName, {TO? result, Object? arguments}) {
    return _navigator.pushReplacementNamed(routeName, result: result, arguments: arguments);
  }

  @override
  void replace<T>(Route<T> oldRoute, Route<T> newRoute) {
    return _navigator.replace(oldRoute: oldRoute, newRoute: newRoute);
  }

  @override
  Future<T?> showBottomSheet<T>(Widget child) {
    return _navigator.push<T>(AlertPopup(child));
  }

  @override
  void replaceRouteBelow<T>(Route<dynamic> anchorRoute, Route<T> newRoute) {
    return _navigator.replaceRouteBelow(anchorRoute: anchorRoute, newRoute: newRoute);
  }
}

abstract mixin class _OneNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => navigatorKey.currentState!;

  String? currentRoute;

  Future<T?> push<T>(Route<T> route);

  Future<T?> showBottomSheet<T>(Widget child);

  Future<T?> pushNamed<T>(String routeName, {Object? arguments});

  Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result});

  Future<T?> pushReplacementNamed<T, TO>(String routeName, {TO? result, Object? arguments});

  Future<T?> pushNamedAndRemoveUntil<T>(String newRouteName, RoutePredicate predicate, {Object? arguments});

  Future<T?> pushAndRemoveUntil<T>(Route<T> newRoute, RoutePredicate predicate);

  void pop<T>([T? result]);
  void popUntil(RoutePredicate predicate);

  Future<T?> popAndPushNamed<T, TO>(String routeName, {TO? result, Object? arguments});

  void replace<T>(Route<T> oldRoute, Route<T> newRoute);

  void replaceRouteBelow<T>(Route<dynamic> anchorRoute, Route<T> newRoute);
}

extension Any<T> on T {
  static void Function()? _onGet;

  static void Function()? _onDispose;

  static bool _mounted = false;

  bool get mounted {
    return _mounted;
  }

  set mounted(bool value) {
    _mounted = value;
  }

  void Function()? get onGet => _onGet;

  Function()? get onDispose => _onDispose;

  set onGet(Function()? value) {
    _onGet = value;
  }

  set onDispose(Function()? value) {
    _onDispose = value;
  }
}
