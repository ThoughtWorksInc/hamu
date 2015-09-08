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
import haxe.macro.PositionTools;
import haxe.macro.Expr;
using Reflect;

class ExprEvaluator {

  @:noUsing
  macro public static function toLiteral<T>(expr:ExprOf<T>):ExprOf<T> return {
    var className = 'ExprEvaluator_${seed++}';
    var positionExpr = Context.makeExpr(Context.getPosInfos(Context.currentPos()), Context.currentPos());
    var definition = macro class $className {
      macro public static function getLiteral():haxe.macro.Expr return {
        haxe.macro.Context.makeExpr($expr, haxe.macro.PositionTools.make($positionExpr));
      }
    }
    definition.isExtern = true;
    definition.pack = ["hamu"];
    Context.defineType(definition);
    macro hamu.$className.getLiteral();
  }

  static var temporaryValues = new Map<Int, Dynamic>();

#if macro

  static var seed:Int = 0;

  @:noUsing
  public static function evaluate<T>(expr:ExprOf<T>):T return {
    var id = seed++;
    var className = 'ExprEvaluator_$id';
    var positionExpr = Context.makeExpr(Context.getPosInfos(Context.currentPos()), Context.currentPos());
    var definition = macro class $className {
      macro public static function onCreated():haxe.macro.Expr return {
        hamu.ExprEvaluator.temporaryValues.set($v{id}, $expr);
        macro null;
      }
      @:extern public static inline function raiseOnCreated():Dynamic return onCreated();
    }
    definition.meta = [
      {
        name : ":access",
        params : [macro hamu.ExprEvaluator],
        pos : PositionTools.here()
      }
    ];
    definition.isExtern = true;
    definition.pack = ["hamu"];
    Context.defineType(definition);
    Context.typeof(macro hamu.$className.raiseOnCreated());
    var result = temporaryValues[id];
    temporaryValues.remove(id);
    result;
  }

  @:noUsing
  public static function evaluateInMacroContext<T>(expr:ExprOf<T>):T return {
    var id = seed++;
    var className = 'ExprEvaluator_$id';
    var positionExpr = Context.makeExpr(Context.getPosInfos(Context.currentPos()), Context.currentPos());
    var definition = macro class $className {
      macro public static function onCreated():haxe.macro.Expr return {
        hamu.ExprEvaluator.temporaryValues.set($v{id}, $expr);
        macro null;
      }
      macro public static function raiseOnCreated():haxe.macro.Expr return {
        onCreated();
        macro null;
      }
      @:extern public static inline function raiseRaiseOnCreated():Dynamic return raiseOnCreated();
    }
    definition.meta = [
      {
        name : ":access",
        params : [macro hamu.ExprEvaluator],
        pos : PositionTools.here()
      }
    ];
    definition.isExtern = true;
    definition.pack = ["hamu"];
    Context.defineType(definition);
    Context.typeof(macro hamu.$className.raiseOnCreated());
    var result = temporaryValues[id];
    temporaryValues.remove(id);
    result;
  }
#end
}
