# Stable Diffusion Image Viewer

[한국어](README-KR.md)

A Flutter-based stable diffusion image viewer for displaying images and information

## Introduction

This program show image and information(include prompts, negative prompts, etc)
To look meta information need to [exiftool](https://exiftool.org)

This program creates "sdviewer-alongthecloud" directory under the Documents directory for storing settings and etc.

## Features

* Shows images (png,jpg,jpeg,webp) created with stable diffusion
* Shows prompts, negative prompts, etc. if exiftool is available
* Prompts and negative prompts can be copied to clipboard with one click
* Navigate to previous/next image in the same directory (on Mac, only when dragging and dropping directories)
* You can attach a watermark image to the image and save it to a specific folder
* Adds an start up page
* Current file can be opened in Explorer or Finder

 - [x] A1111
 - [x] InvokeAI

for more information, see in-program help

## Run and Build

You need Flutter and Visual Studio or XCode to run and build for desktop app.

1. clone the repository
2. `flutter pub get` fetch to dependencies
3. `flutter run` to execute
4. build with `flutter build` command

* There is a problem that exiftool does not work and can't display metadata when this program is run from the Applications directory. This is a part that was confirmed to work properly in a previous version.
* since I am not using a Mac very much and am considering replacing exiftool, there are no plans to resolve this issue for the time being.
* There seems to be no problem when running with `flutter run`.

## Install exiftool
### Windows
Using the 'App Installer' makes installation easy

1. If you don't have the App Installer, install it from [here](https://www.microsoft.com/p/app-installer/9nblggh4nns1).
2. After installation, open up command prompt window.
3. ```winget install ExifTool``` in command prompt window. You will see the installation screen and the installation will proceed.

### Mac
If you are using [brew](https://brew.sh), you can install exiftool with the following command

```brew install exiftool```

## ScreenShot

![screenshot1](images/screenshot1.jpg)
![screenshot2](images/screenshot2.jpg)

## Usage

Drag and drop images to the window

1. if you have exiftool installed, you will see the information on the right panel
2. click on the prompt and negative prompt to copy contents to the clipboard
3. click on model hash to go to civitai site

If you drag and drop a directory containing images, the first image in that directory will appear and you can move to the previous/next image by arrow keys.

On Windows, you can move to the previous/next image even when you drop image file.

## License

[![License](https://img.shields.io/badge/License-BSD%202--Clause--"Simplified"-blue.svg)](LICENSE)

## Additional Notes

* Use [DeepL](https://www.deepl.com/translator) and [ChatGPT](https://chat.openai.com) for translation
