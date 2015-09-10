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
import haxe.macro.ComplexTypeTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.PositionTools;

class Singleton {

#if macro

  private static function proxyFields(fields:Array<ClassField>, typeResolver:Type -> Type, pos:Position):Array<Field> return {
    var buildingFields = [];
    for (field in fields) {
      var fieldName = field.name;
      switch (field.kind) {
        case FMethod(_):
          if (field.isPublic) {
            if (field.meta.has(":impl")) {
              buildingFields.push({
                name: fieldName,
                access: [ AStatic, APublic ],
                pos: pos,
                kind: switch (Context.follow(typeResolver(field.type))) {
                  case TFun(args, ret):
                    var argIdents = [
                      for (i in 1...args.length) {
                        macro $i{args[i].name}
                      }
                    ];
                    FFun({
                      args : [
                        for (i in 1...args.length) {
                          var arg = args[i];
                          {
                            name : arg.name,
                            opt : arg.opt,
                            type : TypeTools.toComplexType(arg.t)
                          }
                        }
                      ],
                      ret : TypeTools.toComplexType(ret),
                      params: [
                        for (param in field.params) {
                          {
                            name: param.name // TODO: constraints
                          }
                        }
                      ],
                      expr : macro return INSTANCE.$fieldName($a{argIdents})
                    });
                  default:
                    throw "Expect TFun";
                }
              });
            } else {
              buildingFields.push({
                name: fieldName,
                access: [ AStatic, APublic],
                pos: pos,
                kind: switch (Context.follow(typeResolver(field.type))) {
                  case TFun(args, ret):
                    var argIdents = [
                      for (arg in args) {
                        macro $i{arg.name}
                      }
                    ];
                    FFun({
                      args : [
                        for (arg in args) {
                          name : arg.name,
                          opt : arg.opt,
                          type : TypeTools.toComplexType(arg.t)
                        }
                      ],
                      ret : TypeTools.toComplexType(ret),
                      params: [
                        for (param in field.params) {
                          {
                            name: param.name // TODO: constraints
                          }
                        }
                      ],
                      expr : macro return INSTANCE.$fieldName($a{argIdents})
                    });
                  default:
                    throw "Expect TFun";
                }
              });
            }
          }
        case FVar(read, write):
          if (field.isPublic) {
            var fieldType = typeResolver(field.type);
            var fieldComplexType = TypeTools.toComplexType(fieldType);
            var getAccess = switch (read) {
              case AccCall, AccInline, AccNormal:
                buildingFields.push({
                  name: 'get_$fieldName',
                  access: [ AStatic ],
                  pos: pos,
                  kind: FFun({
                    args: [],
                    ret: fieldComplexType,
                    params: [],
                    expr: macro return INSTANCE.$fieldName
                  })
                });
                "get";
              default:
                "never";
            }
            var setAccess = switch (write) {
              case AccCall, AccInline, AccNormal:
                buildingFields.push({
                  name: 'set_$fieldName',
                  access: [ AStatic ],
                  pos: pos,
                  kind: FFun({
                    args: [
                      {
                        name: "value",
                        type: fieldComplexType,
                      }
                    ],
                    ret: fieldComplexType,
                    params: [],
                    expr: macro return INSTANCE.$fieldName = value
                  })
                });
                "set";
              default:
                "never";
            }
            buildingFields.push({
              name: fieldName,
              access: [ APublic, AStatic ],
              pos: pos,
              kind: FProp(getAccess, setAccess, fieldComplexType)
            });
          }
      }
    }
    buildingFields;
  }

  public static function build<T>(instance:ExprOf<T>):Array<Field> return {
    var type = Context.typeof(instance);
    var buildingFields:Array<Field> = switch (Context.follow(type)) {
      case TInst(_.get() => classType, typeArguments):
        proxyFields(
          classType.fields.get(),
          TypeTools.applyTypeParameters.bind(_, classType.params, typeArguments),
          instance.pos);
      case TAnonymous(_.get() => anonymousType):
        proxyFields(anonymousType.fields, function(t)return t, instance.pos);
      case TAbstract(_.get() => abstractType, typeArguments):
        if (abstractType.impl != null) {
          proxyFields(
            abstractType.impl.get().statics.get(),
            TypeTools.applyTypeParameters.bind(_, abstractType.params, typeArguments),
            instance.pos);
        } else {
          throw 'Unsupported type: $type';
        }
      default:
        throw 'Unsupported type: $type';
    }
    buildingFields.push(
      {
        name: "INSTANCE",
        access: [ AStatic ],
        pos: PositionTools.here(),
        kind: FProp("default", "never", null, instance)
      }
    );
    buildingFields;
  }

  static var seed = 0;

  public static function macroType<T>(instance:ExprOf<T>, ?singletonName:String):Type return {
    var type = Context.typeof(instance);
    switch TypeTools.toComplexType(type) {
      case TPath(path):
        var localName = path.sub == null ? path.name : path.sub;
        if (singletonName == null) {
          var id = seed++;
          singletonName = '${localName}_Singleton_$id';
        }
        var definition = macro class $singletonName {};
        definition.pack = path.pack;
        definition.fields = hamu.Singleton.build(instance);
        Context.defineType(definition);
        ComplexTypeTools.toType(TPath({
          pack: definition.pack,
          name: definition.name
        }));
      default:
        throw "Expect TPath";
    }
  }

#end

}
