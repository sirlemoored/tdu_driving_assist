# TDU Driving Assist
___
### What it is
Driving Assist is a tiny utility tool made for Test Drive Unlimited game. It serves two purposes:
  - Records your current position on the island and saves it to a file
  - Shows basic roadtrip statstics (time, avg. speed, distance)

### How it works
Every fraction of a second Driving Assist reads just four float values from TDU memory: three position coordinates and total mileage of the car. Based on this data it outputs basic roadtrip statistics and saves it to file.

### Controls
Driving Assist is a microscopic window with just few buttons and no help whatsoever. Here's an overview of all its ugly controls:
  - **Logger** button       -- toggles saving position to the file.
  - **Timer** button        -- toggles recording time/distance.
  - **Reset timer**         -- self-explanatory.
  - **Logs folder**         -- opens folder selection dialog. This folder will be used as a storage for all your files with saved position. Location will be saved in your _Documents/Test Drive Unlimited/DA/settings.tdu_ file.
  - **"___ m"** combo box   -- sets position logging interval (every x travelled meters the program will append your current position to the position file).
  - **Auto** checkbox       -- if toggled ON, the timer and logger will stop automatically if your car is standing still.
### Key bindings
  - **Ctrl+E** -- toggles logger.
  - **Ctrl+T** -- toggles timer.
___
### Why?
Because I am a very odd being and I needed a tool with both features for self-set goal of 1000 miles of free-ride.

Based on the data output you can generate pretty nifty heatmaps in your favourite plotters!
![Tdu](https://i.imgur.com/7W1peCb.png) |![Tdu](https://i.imgur.com/MIskXSg.png)
-|-
Position heatmap after playing the game for ~3 months. | The same heatmap but with enhanced values.
___
### Build
You can build it yourself using CheatEngine and .CETRAINER file or download the .EXE from releases.
Windows only.

### Other stuff

  - _CheatEngine_ - cheatengine.org

I don't care about licenses, I think this is MIT or something.


