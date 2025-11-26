#!@shebang@
set -e

export REPO='https://github.com/LuNeder/nixos-config'
export COMMITMAIL='auto-updater@luana.dev.br'
export MAIN='strawberry'
export EXTRABUILDOPTS='--impure'
export CORES=2
export JOBS=2
export FNUM=0
export SNUM=0


rm -rf /tmp/nix-cache-compiler
mkdir -p /tmp/nix-cache-compiler
cd /tmp/nix-cache-compiler
@git@ clone "$REPO" repo
cd repo

@git@ config user.name "Auto Updater"
@git@ config user.email "$COMMITMAIL"

{
    @git@ switch auto-updater 
} || {
    @git@ switch -c auto-updater --guess && export EXTRAPUSH='--set-upstream origin auto-updater'
}

@git@ merge -Xtheirs --ff $MAIN

@nix@ flake update --refresh --tarball-ttl 0
{ 
    @git@ diff --exit-code && echo "no updates, nothing to do, exiting" && cd ../.. && rm -rf /tmp/nix-cache-compiler && exit 0
} || {
    echo "Lockfile updated, let's build"
}

rm -rf ./auto-updater
mkdir ./auto-updater
echo "bot: Auto Update (%XYZREPLACEMENUMS%)" > ./auto-updater/results.txt
echo "" >> ./auto-updater/results.txt

for i in $(@nix@ eval --raw --apply 'x: builtins.concatStringsSep " " (builtins.attrNames x)' .#nixosConfigurations); 
do
    { 
        {
            @nixosrebuild@ build --flake .#$i $EXTRABUILDOPTS --option eval-cache false --show-trace --cores $CORES -j $JOBS > ./auto-updater/$i.log 2>&1
        } && { 
            SNUM=$((SNUM+1)) && echo "$i: SUCCESS" >> ./auto-updater/results.txt && rm "./auto-updater/$i.log" 
        }
    } || { 
        FNUM=$((FNUM+1)) && echo "$i: FAIL" >> ./auto-updater/results.txt 
    }
done

sed -i "s/%XYZREPLACEMENUMS%/$FNUM Failures, $SNUM Succeeded/" ./auto-updater/results.txt

@git@ add -A
@git@ commit -a -F ./auto-updater/results.txt
@git@ push --force $EXTRAPUSH
cd ../..
rm -rf /tmp/nix-cache-compiler

exit 0