package hamu;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.PositionTools;
import haxe.ds.StringMap;

typedef FieldsGenerator<Argument> = {
  function fields(argument:Argument, buildingModule:String, buildingClassName:String):Array<Field>;
}

class Builder<Argument> {

  var fieldsGenerator: FieldsGenerator<Argument>;

  public function new(fieldsGenerator: FieldsGenerator<Argument>) {
    this.fieldsGenerator = fieldsGenerator;
  }

  #if macro


  /**
   * Define a class `buildingModule`.`buildingClassName` with metadata `meta`.
   *
   * If calling this method to generate same class more than once,
   * the second call will be ignored.
   */
  public function lazyDefineClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    var parserPackage = buildingModule.split(".");
    var moduleName = parserPackage.pop();
    var parserDefinition = {
      pack: parserPackage,
      name: buildingClassName == null ? moduleName : buildingClassName,
      pos: PositionTools.here(),
      params: null,
      meta: meta,
      kind: TDClass(null, [], false),
      isExtern: false,
      fields: fieldsGenerator.fields(argument, buildingModule, buildingClassName == null ? moduleName : buildingClassName)
    };
    Context.onTypeNotFound(function(name) return {
      if (name == buildingModule) {
        parserDefinition;
      } else {
        null;
      }
    });
  }

  /**
   * Define a class `buildingModule`.`buildingClassName` with metadata `meta`.
   *
   * If calling this method to generate same class more than once,
   * a compilation error will be raised.
   */
  public function defineClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    var parserPackage = buildingModule.split(".");
    var moduleName = parserPackage.pop();
    var parserDefinition = {
      pack: parserPackage,
      name: buildingClassName == null ? moduleName : buildingClassName,
      pos: PositionTools.here(),
      params: null,
      meta: meta,
      kind: TDClass(null, [], false),
      isExtern: false,
      fields: fieldsGenerator.fields(argument, buildingModule, buildingClassName == null ? moduleName : buildingClassName)
    };
    Context.defineModule(buildingModule, [ parserDefinition ]);
  }

  public function lazyDefineMacroClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    hamu.ExprEvaluator.runInMacroContext(function () {
      lazyDefineClass(argument, buildingModule, buildingClassName, meta);
    });
  }

  /**
   * Define a class `buildingModule`.`buildingClassName` with metadata `meta` in macro scope.
   *
   * If calling this method to generate same class more than once,
   * a compilation error will be raised.
   */
  public function defineMacroClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    hamu.ExprEvaluator.runInMacroContext(function () {
      defineClass(argument, buildingModule, buildingClassName, meta);
    });
  }

  public function build(argument:Argument):Array<Field> return {
    var localClass = Context.getLocalClass().get();
    Context.getBuildFields().concat(fieldsGenerator.fields(argument, localClass.module, localClass.name));
  }

  #end

}
