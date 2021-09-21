.DEFAULT_GOAL := print-instructions

ifndef TARGET_USER
$(error Please set TARGET_USER variable)
endif

ifndef TARGET_HOST
$(error Please set TARGET_HOST variable)
endif

OUT := out
HOSTS_FILE := $(OUT)/hosts.ini
ANSIBLE_TAGS ?= all

.PHONY: setup
setup: $(HOSTS_FILE)

.PHONY: print-instructions
print-instructions:
	@echo 'Instructions:'
	@echo ''
	@echo '1. Set up ssh key-based auth on the remote host.'
	@echo '2. If you want the host to have your private key, transfer it.'
	@echo '3. Link the desired playbook here as "playbook.yml" (e.g. `ln -s playbooks/dev-machine.yml playbook.yml`).'
	@echo '   Edit the contents (vars, rolls, etc.) as desired.'
	@echo '4. Run `make run`.'

$(HOSTS_FILE): Makefile
	@mkdir -p $(@D)
	@echo -n 'Writing $(HOSTS_FILE)...'
	@echo '[nodes]' > $@
	@echo 'node1  ansible_user=$(TARGET_USER)  ansible_host=$(TARGET_HOST)' >> $@
	@echo ' done.'

.PHONY: run
run: setup
	@ansible-playbook -i $(HOSTS_FILE) --ask-become-pass playbook.yml --tags $(ANSIBLE_TAGS)

.PHONY: clean
clean:
	@rm -rf $(OUT)
