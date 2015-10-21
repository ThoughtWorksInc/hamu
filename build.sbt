enablePlugins(AllHaxePlugins)

organization := "com.thoughtworks.microbuilder"

name := "hamu"

libraryDependencies += "com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test

haxeOptions in Test ++= Seq("--macro", "exclude('haxe.unit')")

for (c <- Seq(Test, Compile)) yield {
  haxeOptions in c ++= Seq("-dce", "no")
}

developers := List(
  Developer(
    "Atry",
    "杨博 (Yang Bo)",
    "pop.atry@gmail.com",
    url("https://github.com/Atry")
  ),
  Developer(
    "wzhao0928",
    "赵文博 (Zhao Wenbo)",
    "wbzhao@thoughtworks.com",
    url("https://github.com/wzhao0928")
  )
)

haxelibContributors := Seq("Atry")

licenses += "MIT" -> url("https://opensource.org/licenses/MIT")

haxelibReleaseNote := "Initial release"

haxelibTags ++= Seq(
  "cross", "cpp", "cs", "flash", "java", "javascript", "js", "neko", "php", "python", "nme",
  "macro", "utility"
)