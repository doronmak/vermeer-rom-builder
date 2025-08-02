#!/bin/bash

ROM_NAME="lineage"
ROM_VERSION="22.0"
DEVICE="vermeer"
LUNCH_COMBO="${ROM_NAME}_${DEVICE}-userdebug"
BUILD_ROOT="$HOME/android/lineage"
LOG_DIR="$BUILD_ROOT/logs"
JOBS=$(nproc)
DATE=$(date +%Y%m%d_%H%M)
LOG_FILE="$LOG_DIR/build_${ROM_NAME}_${DEVICE}_${DATE}.log"

MANIFEST_URL="https://github.com/LineageOS/android.git"

mkdir -p "$LOG_DIR"
cd "$BUILD_ROOT" || exit 1

log() {
    echo -e "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"
}

abort() {
    log "❌ ERROR: $1"
    exit 1
}

log "🚀 Starting LineageOS $ROM_VERSION build for $DEVICE"
log "📁 Working dir: $BUILD_ROOT"

if [ ! -d ".repo" ]; then
    log "📦 Initializing repo..."
    repo init -u "$MANIFEST_URL" -b "lineage-$ROM_VERSION" || abort "Repo init failed"
fi

log "🧩 Injecting local manifest..."
mkdir -p .repo/local_manifests
cat > .repo/local_manifests/vermeer.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="xiaomi-sm8550-devs/android_device_xiaomi_vermeer" path="device/xiaomi/vermeer" remote="github" revision="lineage-22.0" />
  <project name="xiaomi-sm8550-devs/android_device_xiaomi_sm8550-common" path="device/xiaomi/sm8550-common" remote="github" revision="lineage-22.0" />
  <project name="xiaomi-sm8550-devs/android_vendor_xiaomi_vermeer" path="vendor/xiaomi/vermeer" remote="github" revision="lineage-22.0" />
  <project name="xiaomi-sm8550-devs/android_kernel_xiaomi_sm8550" path="kernel/xiaomi/sm8550" remote="github" revision="lineage-22.0" />
</manifest>
EOF

log "🔃 Syncing sources..."
repo sync -c -j$JOBS --force-sync --no-tags --no-clone-bundle || abort "Repo sync failed"

log "🧪 Setting up build environment..."
source build/envsetup.sh || abort "envsetup failed"

log "🍽️ Running lunch: $LUNCH_COMBO"
lunch "$LUNCH_COMBO" || abort "Lunch failed"

log "🛠️ Building ROM..."
mka bacon -j$JOBS 2>&1 | tee -a "$LOG_FILE"

BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    ZIP_PATH=$(ls "$BUILD_ROOT/out/target/product/$DEVICE/${ROM_NAME}-"*.zip 2>/dev/null | head -n 1)
    log "✅ Build completed successfully! ROM at: $ZIP_PATH"
else
    log "❌ Build failed. Check the log: $LOG_FILE"
    exit 1
fi
