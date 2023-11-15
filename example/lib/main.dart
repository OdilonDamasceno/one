import 'package:flutter/material.dart';
import 'package:one/core/router/one_router.dart';
import 'package:one/core/services/one_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp.router(
    routerConfig: OneRouterConfig(
      routes: {
        '/': OneRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('One'),
            ),
            body: const Center(
              child: Text('One'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                One.instance.pushNamed('/blue');
              },
              child: const Icon(Icons.add),
            ),
          ),
          bindingBuilder: (instance) async {
            instance.register(1, tag: 'One', onGet: () {
              print('One registered');
            });
            instance.register(3, tag: 'a', onGet: () {
              print('a registered');
            });
            instance.register(5, tag: 'h', onGet: () {
              print('h registered');
            });
          },
        ),
        '/blue': OneRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Blue'),
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back),
              //   onPressed: () {
              //     One.instance.pop();
              //   },
              // ),
            ),
            body: const Center(
              child: Text('Blue'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                var _ = One.instance.get<BasicClass>(tag: 'two');
              },
              child: const Icon(Icons.add),
            ),
          ),
          bindingBuilder: (instance) async {
            instance.lazyRegister(
              BasicClass(),
              tag: 'two',
              onDispose: () {
                print("One disposed");
              },
              onGet: () {
                print('One registered');
              },
            );
          },
        ),
      },
    ),
  ));
}

class BasicClass {}
