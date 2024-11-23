SHELL := bash

CHART ?= home-assistant

COMMON-CHART := bjw-s/helm-charts
COMMON-REPO := https://github.com/$(COMMON-CHART)
COMMON-TEMPLATES := $(COMMON-CHART)/library/common/

STARTING-COMMIT := 8715a11

TEMPLATE-DEPS := \
  $(COMMON-TEMPLATES) \
  $(shell find $(CHART) -type f) \

NEW-TEMPLATE-OUT := $(CHART)-template-new.yaml
OLD-TEMPLATE-OUT := $(CHART)-template-old.yaml


test: test-template

test-template: $(OLD-TEMPLATE-OUT) $(NEW-TEMPLATE-OUT)
	diff -u $^
	@echo NO Differences

$(NEW-TEMPLATE-OUT): $(CHART) $(TEMPLATE-DEPS)
	helm dependency build $(CHART)
	helm template $< > $@

$(OLD-TEMPLATE-OUT): $(STARTING-COMMIT)
	$(MAKE) -C $< $(OLD-TEMPLATE-OUT)
	mv $</$@ $@
	touch $@

clean:
	$(RM) $(NEW-TEMPLATE-OUT)

realclean: clean
	$(RM) -r $(COMMON-CHART) */charts */Chart.lock

distclean: realclean
	$(RM) $(OLD-TEMPLATE-OUT)
	$(RM) -r $(STARTING-COMMIT)

$(COMMON-TEMPLATES): $(COMMON-CHART)

$(COMMON-CHART):
	git clone $(COMMON-REPO) $(COMMON-CHART)

$(STARTING-COMMIT):
	git worktree add -f $@ $@
