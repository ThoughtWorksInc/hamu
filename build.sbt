libraryDependencies += "com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test

haxeOptions in Test ++= Seq("--macro", "exclude('haxe.unit')")

for (c <- Seq(Test, Compile)) yield {
  haxeOptions in c ++= Seq("-dce", "no")
}