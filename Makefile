PACKER_DIR=packer/base
TEMPLATE=$(PACKER_DIR)/al2023.pkr.hcl

.PHONY: init fmt validate build

init:
	packer init $(TEMPLATE)

fmt:
	packer fmt -recursive packer

validate:
	packer validate $(TEMPLATE)

build:
	packer build $(TEMPLATE)
