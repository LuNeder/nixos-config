
Test phone on postmarketOS: Xiaomi Redmi Note 9S (Tianma)

```sh
sudo apk add curl git
sudo apk add sudo !doas-sudo-shim
sudo su
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
systemctl enable nix-daemon --now
exit
reboot
nix profile add 'github:numtide/system-manager'
git clone https://github.com/LuNeder/nixos-config
cd nixos-config
system-manager switch --flake .#luana-note9s --sudo
```