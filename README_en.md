# chrome-profmgr

Profile Manager for Google Chrome

# DESCRIPTION

A profile manager for Google Chrome.

![chrome-profmgr](https://i.imgur.com/d8dKo9Q.png "Execution example")

<img width="972" height="746" alt="Image" src="https://github.com/user-attachments/assets/9d5289d5-8ec8-4809-9977-fdc76302abad" />

In short, I created it because I wanted something similar to `firefox -P` for Firefox.

It does support multiple languages, but it is a proprietary specification.

# INSTRATION
To start the program, simply run the included `.ps1` file, but by default, `.ps1` files do not start when double-clicked, which can be a hassle, so I created a script to create a shortcut for starting the program.

There are versions available for a windowed version (`xxx_MakeShotcut.vbs`), a windowless version (`xxx_MakeShotcut-Hidden.vbs`), and a windowless version running with PowerShell 7 (`xx_MakeShotcut-Hidden-v7.vbs`). Running any of these will create a shortcut on your desktop.

This script is general-purpose, and if you drag and drop any `.ps1` file(s) onto a `.vbs` file, a corresponding shortcut will be created.


# BUG

## It appears to freeze when downloaded.
The profile download (zip file creation) process takes a long time, but no progress bar appears and the mouse pointer does not change to an hourglass, so it appears frozen.

## Icons are displayed in 16 colors
If you are logged in to Google with a profile, you can obtain the icon image (PNG format), but you cannot convert it to an ICO image.

If you set the hidden parameter `config.link_with_icon=true`, an icon will be set when you create a shortcut, but the number of colors will be reduced to 16.


## Translation is appropriate
Let's just say that Google Translate is bad.




