/*
hamu
Copyright 2015 杨博 (Yang Bo)

Author: 杨博 (Yang Bo) <pop.atry@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package hamu;

import haxe.unit.TestCase;
class SingletonTest extends TestCase {
  function test() {
    assertEquals("123 42", MySingleton.toString(123));
    assertEquals(42, MySingleton.y);
    assertEquals(42, MySingleton.x);
    MySingleton.z = 33;
    assertEquals(33, MySingleton.y);
    assertEquals(33, MySingleton.x);
    MySingleton.x = 57;
    assertEquals(57, MySingleton.y);
    assertEquals(57, MySingleton.x);
    assertEquals(73, MySingleton2.foo());
    assertEquals(87, MySingleton3.foo());
    assertEquals(45, MySingleton4.y);
    assertEquals("789 45", MySingleton4.formatString(789));
    assertEquals(new MyAbstract(45), MySingleton4._new());
  }
}

@:build(hamu.Singleton.build(new MyClass(42)))
class MySingleton {}


@:build(hamu.Singleton.build({
  foo: function():Int return 73
}))
class MySingleton2 {}

@:build(hamu.Singleton.build(MyTypeFactory.newInstance(87)))
class MySingleton3 {}

@:build(hamu.Singleton.build(new MyAbstract(45)))
class MySingleton4 {}

class MyClass<T> {
  public var x:T;
  public var y(get, never):T;
  public var z(never, set):T;
  function get_y():T return x;
  function set_z(value:T):T return x = value;
  public function toString(prefix:T) return '$prefix $x';
  public function new(x:T) {
    this.x = x;
  }
}


abstract MyAbstract<T>(T) {
  public var y(get, never):T;
  function get_y():T return this;
  public function formatString(prefix:T) return '$prefix $this';
  public function new(x:T) {
    this = x;
  }
}