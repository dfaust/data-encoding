#!/bin/sh
set -e

LF='
'

run() {
  local cmd="$1" in="$2" tout="$3" terr="$4" cmd sout serr code=0
  sout="$(echo -n "$in" | eval "$cmd" 2>/dev/null)" || true
  serr="$(echo -n "$in" | eval "$cmd" 2>&1 >/dev/null)" || code=$?
  [ "$tout" = "$sout" ] || { echo out; return 1; }
  [ "$terr" = "$serr" ] || { echo err; return 1; }
  if [ "$code" -eq 0 ]; then
    [ -z "$terr" ] || { echo code; return 1; }
  else
    [ "$code" -eq 1 ] || { echo code; return 1; }
  fi
}

count=0
error=0

unit() {
  local opts="$1" in="$2" out="$3" err="$4" cmd res
  [ -z "$err" ] || err="data-encoding: $err"
  cmd="../target/debug/data-encoding $opts"
  count=$(expr $count + 1)
  if res=$(run "$cmd" "$in" "$out" "$err"); then
    echo -n " [32m$count[m"
  else
    echo " [1;31m$count[m($res)"
    /bin/echo -E "echo '$in' | $cmd"
    echo -n "$in" | eval "$cmd" || true
    echo
    error=$(expr $error + 1)
  fi
}

cargo build

echo -n 'encode:'
unit '-mencode -b64 -p='
unit '-mencode -b64 -p=' f Zg==
unit '-mencode -b64 -p=' fo Zm8=
unit '-mencode -b64 -p=' foo Zm9v
unit '-mencode -b64 -p=' foob Zm9vYg==
unit '-mencode -b64 -p=' fooba Zm9vYmE=
unit '-mencode -b64 -p=' foobar Zm9vYmFy
echo
echo -n 'decode:'
unit '-mdecode -b64 -p='
unit '-mdecode -b64 -p=' Zg== f
unit '-mdecode -b64 -p=' Zm8= fo
unit '-mdecode -b64 -p=' Zm9v foo
unit '-mdecode -b64 -p=' Zm9vYg== foob
unit '-mdecode -b64 -p=' Zm9vYmE= fooba
unit '-mdecode -b64 -p=' Zm9vYmFy foobar
unit '-mdecode -b64 -p=' Zg==Zm8=Zg== ffof
echo
echo -n 'wrap:'
unit "-mencode -b64 -p= -w0 -s'$LF'" fo Zm8=
unit "-mencode -b64 -p= -w1 -s'$LF'" fo '' 'wrap width not a multiple of 4'
unit "-mencode -b64 -p= -w4 -s'$LF'" fo Zm8=
unit "-mencode -b64 -p= -w4 -s'$LF'" foobar "Zm9v${LF}YmFy"
echo
echo -n 'skip:'
unit "-mdecode -b64 -p= -g'$LF'" "Z${LF}m$LF$LF$LF${LF}8=" fo
unit "-mdecode -b64 -p= -g'$LF'" "Zg$LF$LF=$LF$LF=Z$LF${LF}m$LF${LF}8=${LF}Zg-=" 'ffo' 'invalid symbol at 19'
unit "-mdecode -b64 -p= -g'$LF' --block=8" "Zg$LF$LF=$LF$LF=Z$LF${LF}m$LF${LF}8=${LF}Zg-=" ffo 'invalid symbol at 19'
echo
echo -n 'symbol:'
unit '-mdecode -b64 -p=' Zg==Zm8=Zg-= '' 'invalid symbol at 10'
unit '-mdecode -b64 -p= --block=8' Zg==Zm8=Zg-= ffo 'invalid symbol at 10'
unit '-mdecode -b64 -p=' "Z${LF}g=" '' 'invalid symbol at 1'
unit '-mdecode -b64 -p=' 'Z g=' '' 'invalid symbol at 1'
unit '-mdecode -b64 -p=' Z=g= '' 'invalid symbol at 1'
unit '-mdecode -b64 -p=' Zm9vZm9v---- '' 'invalid symbol at 8'
unit '-mdecode -b64 -p= --block=8' Zm9vZm9v---- foofoo 'invalid symbol at 8'
echo
echo -n 'padding:'
unit "-mdecode -b64 -p=" Z=== '' 'invalid padding length at 1'
echo
echo -n 'length:'
unit "-mdecode -b64 -p=" Zg= '' 'invalid length at 0'
unit "-mdecode -b64 -p=" Zg==Z f 'invalid length at 4'
unit "-mdecode -b64 -p=" Zg==Zg f 'invalid length at 4'
unit "-mdecode -b64 -p=" Zg==ZgZ f 'invalid length at 4'
echo
echo -n 'trailing:'
unit "-mdecode -b64 -p=" Zh== '' 'non-zero trailing bits at 1'
echo
echo -n 'custom:'
unit "--mode=info --symbols=0" '' '' 'invalid number of symbols'
unit "--mode=info --symbols=$(printf '\303\251')" '' '' 'non-ascii character'
unit "--mode=info --symbols=01 --translate=$(printf '\303\251')" '' '' 'Invalid translate'
echo

[ "$error" -eq 0 ]
