# Arch Linux notes 

As I first learned Arch and attempted to integrate it as a working environment here, some kit I found useful.



List all installed packages (local & foreign).
This is useful for analyzing what I've installed and how I should associate it to profiles in package installer kit.

```
pacman -Q > arch/packages.txt
pacman -Qm > arch/packages.foreign.txt
yay -Q > arch/packages.yay.txt
```
