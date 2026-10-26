.PHONY: all build install run clean

all: build

build:
	@./scripts/build_app.sh

install:
	@./scripts/install.sh

run:
	@open "/Applications/Use Token Bar.app" 2>/dev/null || open "dist/Use Token Bar.app"

clean:
	@swift package clean
	@rm -rf dist .build
