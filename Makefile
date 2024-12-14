SHELL := /bin/bash
BUILD_FLAGS?=-s -w
TRIM_FLAGS=
MAIN_TARGETS?=linux/amd64,linux/arm64,darwin/amd64,darwin/arm64
PLUGIN_TARGETS?=linux/amd64,linux/arm64,darwin/amd64,darwin/arm64
GO_RELEASE_V=$(shell go version | { read _ _ v _; echo $${v#go}; })

#include plugins/Makefile

test:
	@go test

linuxamd64:
	@GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build ${TRIM_FLAGS} -ldflags "${BUILD_VARS}" -o dist/rdap-$@ cmd/rdap/main.go

linuxarm64:
	@GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build ${TRIM_FLAGS} -ldflags "${BUILD_VARS}" -o dist/rdap-$@ cmd/rdap/main.go

darwinamd64:
	@GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build ${TRIM_FLAGS} -ldflags "${BUILD_VARS}" -o dist/rdap-$@ cmd/rdap/main.go

darwinarm64:
	@GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 go build ${TRIM_FLAGS} -ldflags "${BUILD_VARS}" -o dist/rdap-$@ cmd/rdap/main.go

winamd64:
	@GOOS=windows GOARCH=amd64 go build ${TRIM_FLAGS} -ldflags "${BUILD_VARS}" -o dist/rdap-$@ cmd/rdap/main.go


release: linuxamd64 linuxarm64 winamd64 darwinamd64 darwinarm64

github:
	@if [ -z "$(TAG)" ]; then \
		echo "Error: TAG is not set"; \
		exit 1; \
	fi
	repo=$$(git remote -v | tail -1 | sed 's|.*:||; s|\.git||' | awk '{print $$1}'); \
	gh release create "v$$TAG" --draft=1 --repo $$repo --title "v$$TAG" --notes "Generated from parent openrdap/rdap"
	gh repo set-default $$repo; \
	for f in dist/*; do \
		gh release upload "v$$TAG" $$f; \
	done;
	gh release edit "v$$TAG" --draft=0

.PHONY: test release linuxamd64 linuxarm64 darwinamd64 darwinarm64 winamd64 github
