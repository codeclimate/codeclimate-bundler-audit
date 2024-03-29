.PHONY: image test citest update_database release

IMAGE_NAME ?= codeclimate/codeclimate-bundler-audit
RELEASE_REGISTRY ?= codeclimate
TEST_IMAGE_NAME ?= $(IMAGE_NAME)-test

ifndef RELEASE_TAG
override RELEASE_TAG = latest
endif

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

release:
	docker tag $(IMAGE_NAME) $(RELEASE_REGISTRY)/codeclimate-bundler-audit:$(RELEASE_TAG)
	docker push $(RELEASE_REGISTRY)/codeclimate-bundler-audit:$(RELEASE_TAG)
