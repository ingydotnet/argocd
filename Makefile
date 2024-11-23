SHELL := bash

CHART ?= home-assistant

COMMON-TAR := $(CHART)/charts/common-3.5.1.tgz

TEMPLATE-DEPS := \
  $(COMMON-TAR) \
  $(shell find $(CHART) -type f) \

NEW-OUT := $(CHART)-template-new.yaml
OLD-OUT := $(CHART)-template-old.yaml


test: $(OLD-OUT) $(NEW-OUT)
	diff -u $^
	@echo NO Differences

$(NEW-OUT): $(CHART) $(TEMPLATE-DEPS)
	helm template $< > $@

$(OLD-OUT): $(CHART) $(TEMPLATE-DEPS)
	helm template $< > $@

clean:
	$(RM) $(NEW-OUT)

realclean: clean
	$(RM) -r */charts */Chart.lock

distclean: realclean
	$(RM) $(OLD-OUT)

$(COMMON-TAR):
	helm dependency build $(CHART)
