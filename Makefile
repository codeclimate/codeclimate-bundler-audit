.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-bundler-audit

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run --rm $(IMAGE_NAME) bundle exec rake
