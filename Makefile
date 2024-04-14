build:
	hugo

server:
	hugo server

dev:
	hugo server --buildDrafts

update:
	cd themes/poison && git pull && cd -

yaml:
	hugo convert toYAML --unsafe --verbose

update-themes:
	git submodule update --remote
