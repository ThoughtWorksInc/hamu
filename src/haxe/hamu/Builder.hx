package hamu;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.PositionTools;
import haxe.ds.StringMap;

typedef FieldsGenerator<Argument> = {
  function fields(argument:Argument, buildingModule:String, buildingClassName:String):Array<Field>;
}

#if macro

private class LazyTypeFactory {

  var lazyClasses:Null<StringMap<TypeDefinition>>;

  public function new() {}

  public function defineType(moduleName:String, typeBuilder:TypeDefinition):Void {
    if (lazyClasses == null) {
      lazyClasses = new StringMap<TypeDefinition>();
      Context.onAfterGenerate(function() {
        lazyClasses = null;
      });
      Context.onTypeNotFound(function(moduleName) return {
        switch lazyClasses.get(moduleName) {
          case null: null;
          case builder:
            builder;
        }
      });
    }
    if (lazyClasses.exists(moduleName)) {
      trace('Duplicated lazy module: $moduleName');
    } else {
      lazyClasses.set(moduleName, typeBuilder);
    }
  }

  public static var TARGET_FACTORY(default, never) = new LazyTypeFactory();

  public static var MACRO_FACTORY(default, never) = new LazyTypeFactory();

}

#end

class Builder<Argument> {

  var fieldsGenerator: FieldsGenerator<Argument>;

  public function new(fieldsGenerator: FieldsGenerator<Argument>) {
    this.fieldsGenerator = fieldsGenerator;
  }

  #if macro

  function internalLazyDefineClass(typeFactory:LazyTypeFactory, argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    var parserPackage = buildingModule.split(".");
    var moduleName = parserPackage.pop();
    typeFactory.defineType(buildingModule, {
      pack: parserPackage,
      name: buildingClassName == null ? moduleName : buildingClassName,
      pos: PositionTools.here(),
      params: null,
      meta: meta,
      kind: TDClass(null, [], false),
      isExtern: false,
      fields: fieldsGenerator.fields(argument, buildingModule, buildingClassName == null ? moduleName : buildingClassName)
    });
  }

  /**
   * Define a class `buildingModule`.`buildingClassName` with metadata `meta`.
   *
   * If calling this method to generate same module more than once,
   * the second call will be ignored.
   */
  public function lazyDefineClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    internalLazyDefineClass(LazyTypeFactory.TARGET_FACTORY, argument, buildingModule, buildingClassName, meta);
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

  /**
   * Define a class `buildingModule`.`buildingClassName` with metadata `meta` in macro context.
   *
   * If calling this method to generate same module more than once,
   * the second call will be ignored.
   */
  public function lazyDefineMacroClass(argument:Argument, buildingModule:String, ?buildingClassName:String, ?meta:Metadata):Void {
    hamu.ExprEvaluator.runInMacroContext(function () {
      internalLazyDefineClass(LazyTypeFactory.MACRO_FACTORY, argument, buildingModule, buildingClassName, meta);
    });
  }

  /**
   * Define a class `buildingModule`.`buildingClassName` with metadata `meta` in macro context.
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
