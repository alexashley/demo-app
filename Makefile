MAKEFLAGS += --silent
.PHONY: image run

default:
	echo No default target.

image:
	docker build -t alex-ashley-demo-app .

run: image
	docker run \
		-it \
		--rm \
		-p 1234:1234 \
		alex-ashley-demo-app
