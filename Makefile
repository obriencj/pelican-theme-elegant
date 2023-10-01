

BOOTSTRAP_CSS:=source/css/bootstrap.css source/css/responsive.css


##@ Basic Targets

default:	help


help:	## Display this help  (default)
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Setup Environment

dependencies:	## Install dependencies using yarn and pipx
	@yarn
	@pipx install pip-tools
	@pipx install lesscpy --system-site-packages


##@ Container dependencies

requirements.txt: requirements.in
	@pip-compile


upgrade-requirements:	## Upgrade requirements.txt
	@pip-compile --upgrade


##@ Build


source/css/%.css: source/bootstrap/%.less
	@lesscpy "$<" "$@"


bootstrap: $(BOOTSTRAP_CSS)


clean-bootstrap:
	@rm -f $(BOOTSTRAP_CSS)


css-js: bootstrap	## Build static CSS and JS
	@npx gulp


container: requirements.txt css-js	## Build the pelican-inelegant:latest container
	@podman build . -f Containerfile \
	  --tag 'pelican-inelegant:latest'


.PHONY: bootstrap container dependencies gulp help upgrade


# The end.
