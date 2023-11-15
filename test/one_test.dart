import 'package:flutter_test/flutter_test.dart';
import 'package:one/one.dart';

class User {
  final String name;
  User(this.name);
}

void main() {
  test('test register and get instance', () {
    One.instance.register(User("odilon"), tag: 'one');
    One.instance.register(User("matheus"));

    var one = One.instance.get<User>(tag: 'one');
    var two = One.instance.get<User>();

    expect("odilon", one.name);
    expect("matheus", two.name);
    // expect(true, one.mounted);
    // expect(true, two.mounted);

    One.instance.unregister<User>(tag: 'one');

    expect(false, one.mounted);
    expect(true, two.mounted);
  });

  test('test lazy register new instance and get instance', () {
    One.instance.lazyRegister<User>(User("odilon"), tag: 'odilon');
    var one = One.instance.get<User>(tag: 'odilon');

    expect("odilon", one.name);
  });
}
