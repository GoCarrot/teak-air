#! /bin/bash

INPATH=$1

LIBPREFIX="lib"
LIBS="Teak TeakAir"
LIBEXT=".a"

OUT="TeakAirMerged"

ARCHS="armv7 arm64"

for arch in $ARCHS
do
  for lib in $LIBS
  do
    lipo -extract $arch $INPATH/$LIBPREFIX$lib$LIBEXT -o $INPATH/$LIBPREFIX$lib-$arch$LIBEXT
  done
  INLIBS=`eval echo $INPATH/$LIBPREFIX\{${LIBS// /,}\}-$arch$LIBEXT`
  libtool -static -o $INPATH/$LIBPREFIX$OUT-$arch$LIBEXT $INLIBS
  rm $INLIBS
done

OUTLIBS=`eval echo $INPATH/$LIBPREFIX$OUT-\{${ARCHS// /,}\}$LIBEXT`
lipo -create $OUTLIBS -o $INPATH/$LIBPREFIX$OUT$LIBEXT
rm $OUTLIBS
