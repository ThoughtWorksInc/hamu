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

import haxe.macro.Context;
import haxe.macro.Expr;
import hamu.ExprEvaluator;
import haxe.unit.TestCase;

class ExprEvaluatorTest extends TestCase {

  macro static function postMacro():Expr return {
    var result = ExprEvaluator.runInMacroContext(function()return Context.defined("macro"));
    macro $v{result};
  }

  function testPost():Void {
    assertEquals(true, postMacro());
  }

  macro static function evaluate():Expr return {
    var expr = macro ["a", "b"].length;
    var result = ExprEvaluator.evaluate(expr);
    macro $v{result};
  }

  function testEvaluate():Void {
    assertEquals(2, evaluate());
  }

  function testToLiteral():Void {
    assertEquals(101, ExprEvaluator.toLiteral(100 + 1));
    assertEquals(101, ExprEvaluator.toLiteral(100 + 1));
    assertEquals(2, ExprEvaluator.toLiteral(["a", "b"].length));
  }

}