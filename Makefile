# Entry points; the real work is in scripts/. IPA defaults to the first file in ipa/.
IPA ?= $(firstword $(wildcard ipa/*.ipa))

# What goes on the phone is the mod alone. FLEX is the inspector `make trees` reads the screens
# through, so it rides along only when it is asked for: make install FLEX=1. (A make target cannot
# take --flex; make would read that as an option of its own.)
FLEX ?= 0
FLEX_ARG := $(if $(filter 0,$(FLEX)),--no-flex,)

# A local install is renamed and re-iconed so it is told apart from the released app on the home
# screen.
DEV_NAME ?= spoti.dev
DEV_ICON ?= docs/icon.png

# Other tweaks (.deb) injected along with this one: make release EXTRA="a.deb b.deb" (paths without
# spaces). NO_BUILD=1 skips building the tweak from source and injects only those files.
EXTRA ?=
NO_BUILD ?= 0
EXTRA_ARGS := $(foreach d,$(EXTRA),--extra $(d)) $(if $(filter 1,$(NO_BUILD)),--no-build,)

.PHONY: build release install trees session log flags
build:    ## FLEX + glass IPA into out/ (EXTRA="a.deb b.deb" adds tweaks, NO_BUILD=1 injects only those)
	./scripts/pipeline.sh $(IPA) $(EXTRA_ARGS)
release:  ## glass only, no FLEX
	./scripts/pipeline.sh $(IPA) --no-flex $(EXTRA_ARGS)
install:  ## build, sign with your certificate, push to the phone on USB (FLEX=1 to take FLEX too)
	./scripts/pipeline.sh $(IPA) --install $(FLEX_ARG) $(EXTRA_ARGS) --name "$(DEV_NAME)" --icon "$(DEV_ICON)" -o out/spoti.dev.ipa
trees:    ## record per-screen view trees into trees/ (needs a FLEX build on the phone)
	./scripts/record-trees.py
session:  ## record clean trees screen by screen into trees/clean/, Enter per snapshot, n for the next screen (SCREENS="playlist artist" for some)
	./scripts/record-session.py $(SCREENS)
log:     ## stream the tweak's log lines from the phone
	./scripts/dump-log.sh
flags:    ## regenerate tweak/Sources/Shared/Flags/SGFlagList.m, Spotify's remote-config flags, from the IPA
	./scripts/extract-flags.py $(IPA)
