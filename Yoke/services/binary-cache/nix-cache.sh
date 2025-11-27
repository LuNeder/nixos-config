#!@shebang@
set -e

FORCEBUILD=false
REPO='https://github.com/LuNeder/nixos-config'
COMMITMAIL='auto-updater@luana.dev.br'
MAIN='strawberry'
EXTRABUILDOPTS='--impure'
CORES=2
JOBS=2
FNUM=0
SNUM=0

while getopts ":f" option "$@"; do
   case $option in
      f) # Enter a name
         FORCEBUILD=true;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit 1;;
   esac
done



echo Starting Nix Binary Cache Autoupdate
rm -rf /tmp/nix-cache-compiler
mkdir -p /tmp/nix-cache-compiler
cd /tmp/nix-cache-compiler
@git@ clone "$REPO" repo > /dev/null
cd repo

@git@ config user.name "Auto Updater"
@git@ config user.email "$COMMITMAIL"

{
    @git@ switch auto-updater 
} || {
    @git@ switch -c auto-updater --guess && EXTRAPUSH='--set-upstream origin auto-updater'
}

echo Updating branch from $MAIN
@git@ merge -Xtheirs --ff $MAIN

@nix@ flake update --refresh --tarball-ttl 0 > /dev/null
{ 
    if [ "$FORCEBUILD" = true ] ; then
        echo 'Using -f, building anyway!'
    else
        @git@ diff --exit-code && echo "no updates to lockfile, nothing to do, exiting" && cd ../.. && rm -rf /tmp/nix-cache-compiler && exit 0
    fi
} || {
    echo "Lockfile updated, let's build"
}

rm -rf ./auto-updater
mkdir ./auto-updater
echo "bot: Auto Update (%XYZREPLACEMENUMS%)" > ./auto-updater/results.txt
echo "" >> ./auto-updater/results.txt

mkdir -p /nix/var/nix/gcroots/binary-cache-builder
rm -f ./result


for i in $(@nix@ eval --raw --apply 'x: builtins.concatStringsSep " " (builtins.attrNames x)' .#nixosConfigurations); 
do
    { 
        {
            echo Building $i && @nixosrebuild@ build --flake .#$i $EXTRABUILDOPTS --option eval-cache false --show-trace --cores $CORES -j $JOBS > ./auto-updater/$i.log 2>&1
        } && { 
            SNUM=$((SNUM+1)) && echo "$i: SUCCESS" && echo "$i: SUCCESS" >> ./auto-updater/results.txt && rm "./auto-updater/$i.log" && rm -f "/nix/var/nix/gcroots/binary-cache-builder/$i" && ln -s "$(readlink -f ./result)" "/nix/var/nix/gcroots/binary-cache-builder/$i" && rm ./result
        }
    } || { 
        FNUM=$((FNUM+1)) && echo "$i: FAIL" && echo "$i: FAIL" >> ./auto-updater/results.txt && rm -f ./result
    }
done

sed -i "s/%XYZREPLACEMENUMS%/$FNUM Failures, $SNUM Succeeded/" ./auto-updater/results.txt

@git@ add -A > /dev/null
@git@ commit -a -F ./auto-updater/results.txt > /dev/null
@git@ push --force $EXTRAPUSH > /dev/null
cd ../..
rm -rf /tmp/nix-cache-compiler
echo Finished

exit 0