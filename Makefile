WS=./canboat_workspace
PLATFORM=$(shell uname | tr '[A-Z]' '[a-z]')-$(shell uname -m)

bin/viamboatmodule: go.mod *.go cmd/module/*.go
	go build -o bin/viamboatmodule cmd/module/cmd.go

bin/viamboat: go.mod *.go cmd/remote/*.go
	go build -o bin/viamboat cmd/remote/cmd.go

lint:
	gofmt -s -w .

sample: bin/viamboat
	./bin/viamboat data/sample.json

updaterdk:
	go get go.viam.com/rdk@latest
	go mod tidy

test:
	go test

canboat:
	mkdir -p $(WS)
	@cd $(WS); git clone https://github.com/canboat/canboat.git
	@cd $(WS)/canboat; make

canboatbinaries: canboat
	cp $(WS)/canboat/rel/$(PLATFORM)/* bin/

bin/candump:
	apt install can-utils
	cp /usr/bin/candump bin/

module.tar.gz: bin/viamboatmodule bin/candump canboatbinaries start.sh
	tar czf $@ $^

module: module.tar.gz

all: test bin/viamboat module 


