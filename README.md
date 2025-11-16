## Description

Flutter starter project inspired by PlugFox

## Source

https://www.youtube.com/live/8Mv-poV0KIE?t=335
https://www.youtube.com/watch?v=rkSNfS6FTcc

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

В packages/** имеет смысл выносить переводы, ui-kit, базу данных, образение в api, форки opensource

### TIPS

Чтобы не публиковать в стор stage-андроид сборку, можно загрузить в internal-app-sharing, откуда по ссылке можно получить сборку

Продожение
https://www.youtube.com/watch?v=8Mv-poV0KIE&t=1515s