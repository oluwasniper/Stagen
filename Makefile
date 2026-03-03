# ─────────────────────────────────────────────────────────────────────────────
# Scagen Makefile
#
# Reads dart-define build-time configuration values from .env (gitignored).
# Copy .env.example → .env and fill in your values before running.
#
# Usage:
#   make run              # flutter run with dart-defines
#   make build-android    # flutter build apk (release)
#   make build-ios        # flutter build ios (release)
#   make clean            # flutter clean
# ─────────────────────────────────────────────────────────────────────────────

-include .env
export

DART_DEFINES := \
	--dart-define=APPWRITE_ENDPOINT=$(APPWRITE_ENDPOINT) \
	--dart-define=APPWRITE_PROJECT_ID=$(APPWRITE_PROJECT_ID) \
	--dart-define=POSTHOG_API_KEY=$(POSTHOG_API_KEY)

ifneq ($(strip $(POSTHOG_HOST)),)
DART_DEFINES += --dart-define=POSTHOG_HOST=$(POSTHOG_HOST)
endif

.PHONY: run build-android build-ios clean check-appwrite-defines

check-appwrite-defines:
	@endpoint="$$APPWRITE_ENDPOINT"; \
	if [ -z "$$endpoint" ]; then endpoint="$$APPWRITE_URL"; fi; \
	missing=""; \
	if [ -z "$$endpoint" ]; then missing="$$missing APPWRITE_ENDPOINT/APPWRITE_URL"; fi; \
	if [ -z "$$APPWRITE_PROJECT_ID" ]; then missing="$$missing APPWRITE_PROJECT_ID"; fi; \
	if [ -n "$$missing" ]; then \
		echo "ERROR: The following required Appwrite variables are unset or empty:$$missing"; \
		exit 1; \
	fi

run: check-appwrite-defines
	flutter run $(DART_DEFINES)

build-android: check-appwrite-defines
	flutter build apk $(DART_DEFINES) --release

build-ios: check-appwrite-defines
	flutter build ios $(DART_DEFINES) --release

clean:
	flutter clean
