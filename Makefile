SHELL := bash

CHART ?= home-assistant

COMMON-CHART := bjw-s/helm-charts
COMMON-REPO := https://github.com/$(COMMON-CHART)
COMMON-TEMPLATES := $(COMMON-CHART)/library/common/

STARTING-COMMIT := 82a6195

TEMPLATE-DEPS := \
  $(COMMON-TEMPLATES) \
  $(shell find $(CHART) -type f) \

NEW-OUT := $(CHART)-template-new.yaml
OLD-OUT := $(CHART)-template-old.yaml


test: $(OLD-OUT) $(NEW-OUT)
	diff -u $^
	@echo NO Differences

$(NEW-OUT): $(CHART) $(TEMPLATE-DEPS)
	helm template $< > $@

$(OLD-OUT): $(STARTING-COMMIT)
	$(MAKE) -C $< $(OLD-OUT)
	mv $</$@ $@
	sleep 1
	touch $@

clean:
	$(RM) $(NEW-OUT)

realclean: clean
	$(RM) -r $(COMMON-CHART) */charts */Chart.lock

distclean: realclean
	$(RM) $(OLD-OUT)
	$(RM) -r $(STARTING-COMMIT)

$(COMMON-TEMPLATES): $(COMMON-CHART)

$(COMMON-CHART):
	git clone $(COMMON-REPO) $(COMMON-CHART)
	helm dependency build $(CHART)

$(STARTING-COMMIT):
	git worktree add $@ $@
