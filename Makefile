# ─────────────────────────────────────────────────────────────────────────────
# Scagen Makefile
#
# Reads dart-define secrets from .env (gitignored).
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
	--dart-define=POSTHOG_API_KEY=$(POSTHOG_API_KEY) \
	--dart-define=POSTHOG_HOST=$(POSTHOG_HOST)

.PHONY: run build-android build-ios clean

run:
	flutter run $(DART_DEFINES)

build-android:
	flutter build apk $(DART_DEFINES) --release

build-ios:
	flutter build ios $(DART_DEFINES) --release

clean:
	flutter clean
