.PHONY: image test citest update_version

IMAGE_NAME ?= codeclimate/codeclimate-bundler-audit
TEST_IMAGE_NAME ?= $(IMAGE_NAME)-test

image:
	docker build --rm -t $(IMAGE_NAME) .

test-image: image
	docker build --rm -t $(TEST_IMAGE_NAME) -f Dockerfile.test .

test:
	@$(MAKE) test-image > /dev/null
	docker run \
        -e PAGER=more \
        --tty --interactive --rm \
        $(TEST_IMAGE_NAME)

update_database:
	date > DATABASE_VERSION
	make image
