package hamu;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.PositionTools;

typedef FieldsGenerator<Argument> = {
  function fields(argument:Argument, buildingModule:String, buildingClassName:String):Array<Field>;
}

class Builder<Argument> {

  var fieldsGenerator: FieldsGenerator<Argument>;

  public function new(fieldsGenerator: FieldsGenerator<Argument>) {
    this.fieldsGenerator = fieldsGenerator;
  }

  #if macro

  public function defineClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta: Metadata):Void {
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


  public function defineMacroClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta: Metadata):Void {
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
