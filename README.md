# ArchLabs Awesome
A customized AwesomeWM config meant to be used on a clean **ArchLabs** installation.
It is in a usable state but still a **work in progress**!
Please do not hesitate to open an issue if you encounter bugs or if you have any suggestion for this theme.

## Installation
After installing ArchLabs:
```shell
sudo pacman -S awesome pamac inotify-tools git # Install needed software
git clone https://github.com/elenapan/archlabs-awesome.git
cp -rT archlabs-awesome ~ # Copy files to home directory
fc-cache # Refresh font cache
rm ~/.git ~/screenshots # Delete the repo's non needed folders
```

## Extra packages and why they are needed
1. `pamac`: GUI frontend for pacman

   Launched by clicking the update widget.
2. `inotify-tools`: Monitors file modifications

   Monitors power supply status (plugged/unplugged) in order to update the battery widget icon.

## TODOs in order of priority
- Calendar widget
- Layout indicator widget
- `hjkl` equivalent keybinds for all arrow keybinds
- Update button: add text or tooltip (e.g. '34 packages need to be updated')
- Update button: icon and color should change depending on whether or not there are any updates
- Generate window buttons dynamically instead of using images (will allows buttons to change color according to the xrdb colors)
- Network widget should change icon depending on type of connection (wired/wireless)
- Add night mode widget (will require `redshift` or `clight` to be installed)
- Test sidebar with multiple monitors
- Prettier right click menu
- Check if garbage collection can be done with a Lua timer instead of awful.widget.watch
- Remove (if titlebar buttons provide that info) or prettify tasklist client modifiers (floating, ontop, etc)
- Alt tab widget (in order to justify removing bottom bar and increase available vertical space)
- Clean up code (remove TODOs and random notes)

## Screenshot previews
![Screenshot](./screenshots/ss1.png?raw=true)
![Screenshot](./screenshots/ss2.png?raw=true)
![Screenshot](./screenshots/ss3.png?raw=true)
