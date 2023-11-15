import 'package:flutter/material.dart';
import 'package:one/core/services/one_manager.dart';

typedef OneRouteMap = Map<String, OneRoute>;

class OneRouterConfig extends RouterConfig<RouteSettings> {
  OneRouterConfig({
    required OneRouteMap routes,
    String initialRoute = "/",
  })  : assert(routes.isNotEmpty && initialRoute.isNotEmpty),
        super(
          routerDelegate: OneRouteDelegate(routes: routes, initialRoute: initialRoute),
          routeInformationParser: OneRouteInformationParser(),
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(uri: Uri.parse(initialRoute)),
          ),
        );
}

class OneRoute<T> {
  final Widget Function(BuildContext context) builder;
  final Future<void> Function(One instance) bindingBuilder;

  OneRoute({required this.builder, required this.bindingBuilder});
}

class OneRouteInformationParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(RouteInformation routeInformation) async {
    return RouteSettings(name: routeInformation.uri.path);
  }

  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) {
    return RouteInformation(uri: Uri.parse(configuration.name!));
  }
}

class OneRouteDelegate extends RouterDelegate<RouteSettings> with PopNavigatorRouterDelegateMixin<RouteSettings>, WidgetsBindingObserver {
  final One _one = One.instance;

  final OneRouteMap _routes;
  final String _initialRoute;

  bool _hasListeners = false;

  OneRouteDelegate({
    required OneRouteMap routes,
    required String initialRoute,
  })  : _routes = routes,
        _initialRoute = initialRoute;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _one.navigatorKey;

  @override
  void addListener(VoidCallback listener) {
    if (!_hasListeners) {
      WidgetsBinding.instance.addObserver(this);
      _hasListeners = true;
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_hasListeners) {
      WidgetsBinding.instance.removeObserver(this);
      _hasListeners = false;
    }
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    print("One: Going to route ${configuration.name}");
    _one.currentRoute = configuration.name;
    var route = _routes[configuration.name!]!;
    await route.bindingBuilder(_one);
  }

  @override
  Widget build(BuildContext context) {
    return _buildNavigator();
  }

  Widget _buildNavigator() {
    return Navigator(
      key: navigatorKey,
      initialRoute: _initialRoute,
      onGenerateInitialRoutes: (navigator, initialRoute) => [
        _OnePageRoute(
          settings: RouteSettings(name: initialRoute),
          builder: (context) {
            return _routes[initialRoute]!.builder(context);
          },
        ),
      ],
      onGenerateRoute: generateRoute,
    );
  }

  Route<dynamic>? generateRoute(RouteSettings settings) {
    setNewRoutePath(settings);
    return _OnePageRoute(
      settings: settings,
      builder: (context) {
        return _routes[settings.name!]!.builder(context);
      },
    );
  }
}

class _OnePageRoute<T> extends MaterialPageRoute<T> {
  _OnePageRoute({
    required super.settings,
    required super.builder,
    super.allowSnapshotting,
    super.fullscreenDialog,
    super.maintainState,
  });

  @override
  Future<RoutePopDisposition> willPop() {
    One.instance.unregisterFromCurrentRoute();
    return super.willPop();
  }
}
