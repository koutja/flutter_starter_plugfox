FVM = fvm

ifeq (, $(shell which ${FVM}))
	FLUTTER = flutter
	DART = dart
else
	FLUTTER = $(FVM) flutter
	DART = $(FVM) dart
endif

precache:
	$(FLUTTER) precache --ios
	$(FLUTTER) precache --android

.PHONY: test
test:
	$(FLUTTER) test

fix:
	$(DART) fix --apply .

fmt:
	$(DART) format -l 80 lib/ test/

ff: fix fmt

.PHONY: get
gca:
	git add .
	git commit --amend --no-edit

.PHONY: get
get:
	$(FLUTTER) pub get

.PHONY: upgrade
upgrade: get ## Upgrade dependencies
	$(FLUTTER) pub upgrade

.PHONY: upgrade-major
upgrade-major: get ## Upgrade to major versions 
	$(FLUTTER) pub upgrade --major-versions

.PHONY: outdated
outdated: get ## Check for outdated dependencies
	$(FLUTTER) pub outdated --show-all --dev-dependencies --dependency-overrides --transitive --no-prereleases

.PHONY: dependencies
dependencies: get ## Check outdated dependencies 
	$(FLUTTER) pub outdated --dependency-overrides \
		--dev-dependencies --prereleases -- show-all --transitive

.PHONY: b
b:
	$(DART) run build_runner build --delete-conflicting-outputs