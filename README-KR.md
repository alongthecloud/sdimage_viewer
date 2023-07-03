# Stable Diffusion Image Viewer

플러터로 만들어진 스테이블디퓨전 이미지 뷰어이며, 포함된 정보를 같이 보여줍니다

## 소개

이 프로그램은 이미지와 프롬프트를 포함한 정보를 보여줍니다.
정보를 보기 위해 [exiftool](https://exiftool.org)이 필요합니다

## 실행, 빌드

데스크탑용으로 실행 및 빌드를 하기 위해서 플러터와 Visual Studio 또는 XCode 가 필요합니다.

1. Repository 를 clone
2. `flutter pub get` 으로 관련 라이브러리를 가져옵니다
3. `flutter run` 으로 실행합니다
4. `flutter build` 명령으로 빌드할 수 있습니다

## exiftool 설치 방법
### Windows
1. https://exiftool.org 에서 프로그램을 다운로드 합니다
2. 실행 파일의 이름을 exiftool.exe 로 바꾸고, 이 프로그램과 같은 디렉토리 또는 실행 경로에 둡니다

### Mac
당신이 만일 brew 를 쓰고 있다면 다음 명령으로 exiftool 을 설치할 수 있습니다

```brew install exiftool```

## 사용
![screenshot0](images/screenshot1.jpg)

이미지를 윈도우로 드래그 앤 드랍

1. exiftool 이 설치되어 있다면 오른쪽의 정보가 보입니다
2. 밑줄이 그어진 parameters 와 negative prompt 를 클릭하여 해당 내용을 클립보드로 복사할 수 있습니다
3. model hash를 클릭하면 civitai 로 이동합니다

맥에서는 디렉토리를 드래그 앤 드랍 했을 때만 이전 파일, 다음 파일로 이동할 수 있으며 화살표 키로 이동 가능합니다.

Windows에서는 이미지 파일을 끌어다 놓아도 이전/다음 이미지로 이동할 수 있습니다.

## 라이선스

[![License](https://img.shields.io/badge/License-BSD%202--Clause--"Simplified"-blue.svg)](LICENSE)

## 그 외

* 영어 번역을 위해 [DeepL](https://www.deepl.com/translator) 과 [ChatGPT](https://chat.openai.com) 를 사용하였습니다
