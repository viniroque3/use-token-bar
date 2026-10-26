.PHONY: all build install run package clean

all: build

build:
	@./scripts/build_app.sh

install:
	@./scripts/install.sh

run:
	@open "/Applications/Use Token Bar.app" 2>/dev/null || open "dist/Use Token Bar.app"

package: build
	@echo "Creating distributable release archive..."
	@cd dist && zip -rq "UseTokenBar-v1.0.0.zip" "Use Token Bar.app"
	@echo "Release archive created: dist/UseTokenBar-v1.0.0.zip"

clean:
	@swift package clean
	@rm -rf dist .build
