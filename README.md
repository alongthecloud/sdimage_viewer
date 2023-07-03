# Stable Diffusion Image Viewer

A Flutter-based stable diffusion image viewer for displaying images and information

## Introduction

This program show image and information(include prompts, negative prompts, etc)
To look meta information need to [exiftool](https://exiftool.org)

## Features

* Shows images (png,jpg,jpeg,webp) created with stable diffusion 
* Shows prompts, negative prompts, etc. if exiftool is available
* Prompts and negative prompts can be copied to clipboard with one click
* Allows you to flip to the previous/next(filename order) image in the same directory (on Windows)

## Run and Build

You need Flutter and Visual Studio or XCode to run and build for desktop app.

1. clone the repository
2. `flutter pub get` fetch to dependencies
3. `flutter run` to execute
4. build with `flutter build` command

## Install exiftool
### Windows
1. download the program from https://exiftool.org
2. rename the executable file to 'exiftool.exe' and place it in the same directory of this program or execution path

### Mac
If you are using brew, you can install exiftool with the following command

```brew install exiftool```

## Usage

![screenshot0](images/screenshot1.jpg)

Drag and drop images to the window

1. if you have exiftool installed, you will see the information on the right panel
2. click on the parameters and negative prompt to copy contents to the clipboard
3. click on model hash to go to civitai site

If you drag and drop a directory containing images, the first image in that directory will appear and you can move to the previous/next image by arrow keys.

On Windows, you can move to the previous/next image even when you drop image file.

## License

[![License](https://img.shields.io/badge/License-BSD%202--Clause--"Simplified"-blue.svg)](LICENSE)

## Additional Notes

* Use [DeepL](https://www.deepl.com/translator) and [ChatGPT](https://chat.openai.com) for translation
