#!/usr/bin/env bash
../../mvnw -DskipTests clean package

export JAR="vanilla-tx-0.0.1.BUILD-SNAPSHOT.jar"
rm tx
printf "Unpacking $JAR"
rm -rf unpack
mkdir unpack
cd unpack
jar -xvf ../target/$JAR >/dev/null 2>&1
cp -R META-INF BOOT-INF/classes

cd BOOT-INF/classes
export LIBPATH=`find ../../BOOT-INF/lib | tr '\n' ':'`
export CP=.:$LIBPATH

# This would run it here... (as an exploded jar)
#java -classpath $CP hello.Application

# Our feature being on the classpath is what triggers it
export CP=$CP:../../../../../spring-graal-native-feature/target/spring-graal-native-feature-0.6.0.BUILD-SNAPSHOT.jar

printf "\n\nCompile\n"
native-image \
  -Dio.netty.noUnsafe=true \
  --no-server \
  -H:Name=tx \
  -H:+ReportExceptionStackTraces \
  -H:+TraceClassInitialization \
  --no-fallback \
  --allow-incomplete-classpath \
  -H:EnableURLProtocols=https \
  --report-unsupported-elements-at-runtime \
  -DremoveUnusedAutoconfig=true \
  -cp $CP app.main.SampleApplication

  #--debug-attach \
mv tx ../../..

printf "\n\nCompiled app \n"
cd ../../..
./tx 

