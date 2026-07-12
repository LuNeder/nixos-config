
My new daily driver phone, in a dual boot with postmarketOS and degoogled android: Fairphone 6

## nix setup (postmarketOS)

```sh
sudo apk add curl git
sudo apk add sudo !doas-sudo-shim
sudo su
# manually delete /etc/environment (should be empty/just comments by default, check) (ensure file is then created by sm, otherwise touch (not having the file there enables dnssec for some reason???))
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
systemctl enable nix-daemon --now
exit
reboot
nix profile add 'github:numtide/system-manager'
git clone https://github.com/LuNeder/nixos-config
cd nixos-config
system-manager switch --flake .#Luana-Fairphone6 --sudo
```

## android setup

List of things that need to be set up in android if a backup doesn't bring them back (tho hopefully I'm fully migrating to pmOS soon anyway)

- Add Yoke's rootCA to trust store
- Configure SeedVault and EasySync
- `adb shell settings put secure back_gesture_inset_scale_right 0` (Disable right side back gesture, it makes no sense to even exist as right side should be un-back)
  - Why is this not an option in settings this is dumb
  - I still hate that the back gesture is some OS thing that breaks hamburguer menus gestures instead of working like iOS...
