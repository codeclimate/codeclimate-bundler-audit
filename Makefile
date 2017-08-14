.PHONY: image test citest update_version

IMAGE_NAME ?= codeclimate/codeclimate-bundler-audit

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run -e PAGER=more --tty --interactive --rm $(IMAGE_NAME) bundle exec rake

citest:
	docker run --rm $(IMAGE_NAME) bundle exec rake

update_database:
	date > DATABASE_VERSION
	make image
