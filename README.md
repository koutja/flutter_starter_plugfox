## Description

Flutter starter project inspired by PlugFox

## Source

https://www.youtube.com/watch?v=8Mv-poV0KIE
https://www.youtube.com/watch?v=rkSNfS6FTcc

## Init project Platforms

```shell
flutter create --project-name="" --org="com." --template=app --empty
```

## Adding Required Platforms

Commands to add each platform individually:

```shell
flutter create --platforms=ios .
```

```shell
flutter create --platforms=android .
```

```shell
flutter create --platforms=windows .
```

```shell
flutter create --platforms=linux .
```

```shell
flutter create --platforms=macos .
```

```shell
flutter create --platforms=web .
```

Or multiple platforms simultaneously:

```shell
flutter create --platforms=ios,android,web .
```

## Github actions

Docker-containers: https://github.com/plugfox/docker_flutter/pkgs/container/flutter

```yaml
build-web:
    container:
        image: ghrc.io/plugfox/flutter:3.29.3-web
```

В packages/** имеет смысл выносить переводы, ui-kit, базу данных, обращение в api, forks open source packages

### TIPS

Чтобы не публиковать в магазин приложений stage-андроид сборку, можно загрузить в internal-app-sharing, откуда по ссылке можно получить сборку


Структура feature
https://www.youtube.com/live/rkSNfS6FTcc?t=4815
feature/
├── controller/
│   ├── controller.dart
├── logic(or data)/
│   ├── repository.dart
│   └── sse.dart
├── model/
│   ├── entity_codec.dart
│   ├── entity_json_converter.dart
│   ├── entity.dart
└── widget/
    ├── list_widget.dart
    ├── layout.dart
    ├── scope.dart
    ├── screen.dart
