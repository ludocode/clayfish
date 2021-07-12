ifeq ($(wildcard lib/pottery/include/pottery/pottery_dependencies.h),)
$(error "Run ./configure to fetch dependencies and set up the project.")
endif
ifeq ($(wildcard config.mk),)
$(error "Run ./configure to fetch dependencies and set up the project.")
endif

NAME = clayfish
BUILD = .build
EXECUTABLE = $(BUILD)/$(NAME)

.PHONY: run
run: $(EXECUTABLE)
	@echo
	@echo "Running $<"
	@echo
	@./$<

.PHONY: build
build: $(EXECUTABLE)

.PHONY: clean
clean:
	rm -rf .build

CPPFLAGS += -Ilib/pottery/include -Ilib/pottery/util -DPOTTERY_AVAILABLE=1
CPPFLAGS += -Wall -Wextra -Wpedantic -Werror -Wno-unused-parameter
ifneq ($(CC),tcc)
CPPFLAGS += -MD -MP
endif

CFLAGS = -g
LDFLAGS =

ifeq ($(CC),tcc)
LDFLAGS += -lpthread
else
LDFLAGS += -pthread
endif

include config.mk

SRCS := $(shell find src -type f -name '*.c')
OBJS := $(patsubst %, $(BUILD)/%.o, $(SRCS))

$(EXECUTABLE): $(OBJS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $^

$(OBJS): $(BUILD)/%.o: % $(MAKEFILE_LIST)
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $<

# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/#depdelete
DEPS := $(OBJS:%.o=%.d)
$(DEPS):
-include $(DEPS)
