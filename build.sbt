enablePlugins(AllHaxePlugins)

organization := "com.thoughtworks.microbuilder"

name := "hamu"

autoScalaLibrary := false

crossPaths := false

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

homepage := Some(url(s"https://github.com/ThoughtWorksInc/${name.value}"))

startYear := Some(2015)

releasePublishArtifactsAction := PgpKeys.publishSigned.value

import ReleaseTransformations._

releaseProcess := Seq[ReleaseStep](
  checkSnapshotDependencies,
  inquireVersions,
  runClean,
  runTest,
  setReleaseVersion,
  commitReleaseVersion,
  tagRelease,
  releaseStepTask(publish in Haxe),
  publishArtifacts,
  setNextVersion,
  commitNextVersion,
  releaseStepCommand("sonatypeRelease"),
  pushChanges
)

scmInfo := Some(ScmInfo(
  url(s"https://github.com/ThoughtWorksInc/${name.value}"),
  s"scm:git:git://github.com/ThoughtWorksInc/${name.value}.git",
  Some(s"scm:git:git@github.com:ThoughtWorksInc/${name.value}.git")))

licenses += "MIT" -> url("https://opensource.org/licenses/MIT")

haxelibReleaseNote := "Initial release"

haxelibTags ++= Seq(
  "cross", "cpp", "cs", "flash", "java", "javascript", "js", "neko", "php", "python", "nme",
  "macro", "utility"
)