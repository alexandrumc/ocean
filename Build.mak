# Makd auto-detects if Ocean's test runner should be used based on submodules,
# but we -of course- don't have Ocean as a submodule, so we set it explicitly.
TEST_RUNNER_MODULE := ocean.core.UnitTestRunner

# This will make D2 unittests fail if stomping prevention is triggered
# (only with dmd-transitional, no effect on other compilers)
export ASSERT_ON_STOMPING_PREVENTION=1

# Common D compiler flags
override DFLAGS += -w -version=GLIBC

# Treat deprecations as errors to ensure ocean doesn't use own deprecated
# symbols internally. Disable it on explicit flag to make possible regression
# testing in D upstream.
ifneq ($(ALLOW_DEPRECATIONS),1)
	ifeq ($(DVER),2)
	override DFLAGS += -de
	else
	override DFLAGS := $(filter-out -di,$(DFLAGS))
	endif
endif

# Remove coverage files
clean += .*.lst

# Remove deprecated modules from testing:
TEST_FILTER_OUT += \
	$C/src/ocean/io/Stdout_tango.d \
	$C/src/ocean/io/FilePath_tango.d \
	$C/src/ocean/core/Runtime.d \
	$C/src/ocean/core/Thread.d \
	$C/src/ocean/core/Traits_tango.d \
	$C/src/ocean/core/Vararg.d \
	$C/src/ocean/core/VersionIdentifiers.d \
	$C/src/ocean/core/Exception_tango.d \
	$C/src/ocean/io/device/SerialPort.d \
	$C/src/ocean/io/device/ProgressFile.d \
	$C/src/ocean/io/stream/Digester.d \
	$C/src/ocean/io/stream/Endian.d \
	$C/src/ocean/io/stream/Greedy.d \
	$C/src/ocean/io/stream/Map.d \
	$C/src/ocean/io/stream/Typed.d \
	$C/src/ocean/io/stream/Utf.d \
	$C/src/ocean/io/UnicodeFile.d \
	$C/src/ocean/io/vfs/ZipFolder.d \
	$C/src/ocean/math/BigInt.d \
	$C/src/ocean/net/http/ChunkStream.d \
	$C/src/ocean/util/compress/Zip.d \
	$C/src/ocean/util/log/LayoutChainsaw.d \
	$C/src/ocean/util/log/Log.d \
	$C/src/ocean/text/convert/Memory.d \
	$C/src/ocean/text/Text.d \
	$C/src/ocean/stdc/stringz.d \
	$C/src/ocean/io/stream/Snoop.d \
	$C/src/ocean/core/_util/console.d \
	$C/src/ocean/core/_util/string.d \
	$C/src/ocean/meta/traits/Function.d \
	$(shell find $C/src/ocean/text/locale -type f)

$O/test-%: override LDFLAGS += -lebtree

$O/test-filesystemevent: override LDFLAGS += -lrt

$O/test-httpserver: override LDFLAGS += -lglib-2.0

# Link unittests to all used libraries
$O/%unittests: override LDFLAGS += -lglib-2.0 -lpcre -lxml2 -lxslt -lebtree \
		-lreadline -lhistory -llzo2 -lbz2 -lz -ldl -lgcrypt -lgpg-error -lrt

# Enable coverage report in CI
ifdef CI
$O/%unittests: override DFLAGS += -cov
endif
