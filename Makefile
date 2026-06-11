.PHONY: help get clean build gen run test format

# ─── Help ──────────────────────────────────────────────────────────
help:
	@echo "Flutter Riverpod Template - Available Commands"
	@echo ""
	@echo "  make get        Install dependencies"
	@echo "  make gen        Run code generation (build_runner)"
	@echo "  make clean      Clean build artifacts"
	@echo "  make run        Run in debug mode"
	@echo "  make run-prod   Run in release mode"
	@echo "  make test       Run all tests"
	@echo "  make format     Format code"
	@echo "  make analyze    Run analyzer"
	@echo "  make fix        Apply analyzer fixes"
	@echo "  make build-apk  Build Android APK"
	@echo "  make build-ipa  Build iOS IPA"
	@echo ""

# ─── Setup ─────────────────────────────────────────────────────────
get:
	flutter pub get

gen:
	dart run build_runner build --delete-conflicting-outputs

gen-watch:
	dart run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean && flutter pub get

# ─── Run ───────────────────────────────────────────────────────────
run:
	flutter run --dart-define-from-file=.env.json

run-prod:
	flutter run --release --dart-define-from-file=.env.prod.json

# ─── Test ──────────────────────────────────────────────────────────
test:
	flutter test --coverage

test-watch:
	flutter test --watch

coverage:
	flutter test --coverage && genhtml coverage/lcov.info -o coverage/html

# ─── Code Quality ──────────────────────────────────────────────────
format:
	dart format lib test --line-length 90

analyze:
	flutter analyze

fix:
	dart fix --apply

lint:
	dart run custom_lint

# ─── Build ─────────────────────────────────────────────────────────
build-apk:
	flutter build apk --release --dart-define-from-file=.env.prod.json

build-appbundle:
	flutter build appbundle --release --dart-define-from-file=.env.prod.json

build-ipa:
	flutter build ipa --release --dart-define-from-file=.env.prod.json

# ─── Firebase ──────────────────────────────────────────────────────
firebase-config:
	flutterfire configure

# ─── All-in-one ────────────────────────────────────────────────────
setup: get gen
	@echo "✓ Project ready!"
