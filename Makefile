# cix-recipes -- the gates that assert things about recipe CONTENT.
#
# These moved here with the corpus (cix#504, cix ADR-0308) because
# they test the recipes, not the daemon. A gate that lives away from
# what it gates is a gate nobody runs, which is the failure mode cix's
# own SELFTESTS list has already produced twice -- so this Makefile
# exists from the first commit rather than being left for later.
#
# TCC, like everything else this project builds (cix ADR-0224). These
# link no daemon code, deliberately: that is what lets them run here
# with nothing but a compiler.
CC ?= tcc
CFLAGS ?= -Wall -Werror -D_GNU_SOURCE -D_FORTIFY_SOURCE=0
BUILD := build

TESTS := $(BUILD)/test_recipe_hygiene $(BUILD)/test_toolchain_policy

.PHONY: all test clean
all: $(TESTS)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%: test/%.c | $(BUILD)
	$(CC) $(CFLAGS) $< -o $@

# Run from the repository root: both tests open recipes/package
# relative to the working directory.
test: $(TESTS)
	@fail=0; for t in $(TESTS); do \
		printf '%-34s' "$$(basename $$t)"; \
		if ./$$t >/tmp/cixrec-$$(basename $$t).log 2>&1; then \
			echo PASS; \
		else \
			echo FAIL; sed 's/^/      /' /tmp/cixrec-$$(basename $$t).log; fail=1; \
		fi; \
	done; \
	if [ $$fail -ne 0 ]; then echo "RECIPE GATES: FAIL"; exit 1; fi; \
	echo "RECIPE GATES: PASS"

clean:
	rm -rf $(BUILD)
