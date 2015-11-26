. ./config.sh

PROJECT_DIR=$1
SCHEME_NAME=$2
CODE_SIGNING_IDENTITY=$3
MOBILE_PROVISION=$4
OUTPUT_IPA=$5
WORKSPACE=$6
CONFIGURATION=$7

UUID=`grep -aA1 UUID ${MOBILE_PROVISION} | grep -o "[-A-Z0-9]\{36\}"`

MOBILE_PROVISION_OUTPUT="$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"

rm -Rf ~/Library/MobileDevice/Provisioning\ Profiles/*
mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"

cp -f "$MOBILE_PROVISION" "$MOBILE_PROVISION_OUTPUT"

rm -rf $HOME/Library/Developer/Xcode/DerivedData/*

pushd . > /dev/null
cd $PROJECT_DIR

if [ "$CODE_SIGNING_IDENTITY" == "none" ]; then

if [ "$WORKSPACE" == "none" ]; then
xcodebuild -scheme "$SCHEME_NAME" > "./.xcode_build_output"
else
xcodebuild -workspace "$WORKSPACE"".xcworkspace" -scheme "$SCHEME_NAME" > "./.xcode_build_output"
fi

else

if [ "$WORKSPACE" == "none" ]; then
xcodebuild -scheme "$SCHEME_NAME" CODE_SIGN_IDENTITY="${CODE_SIGNING_IDENTITY}" > "./.xcode_build_output"
else
xcodebuild -workspace "$WORKSPACE"".xcworkspace" -scheme "$SCHEME_NAME" CODE_SIGN_IDENTITY="${CODE_SIGNING_IDENTITY}" > "./.xcode_build_output"
fi

fi


if [ $? -ne 0 ]; then
cat "./.xcode_build_output"
exit 5
fi

PROJECT_DERIVED_DATA_DIRECTORY=$(grep -oE "$WORKSPACE-([a-zA-Z0-9]+)[/]" "./.xcode_build_output" | sed -n "s/\($WORKSPACE-[a-z]\{1,\}\)\//\1/p" | head -n1)

rm -rf "./.xcode_build_output"

PROJECT_DERIVED_DATA_PATH="$DERIVED_DATA_PATH/$PROJECT_DERIVED_DATA_DIRECTORY"
PROJECT_APP=$(ls -1 "$PROJECT_DERIVED_DATA_PATH/Build/Products/""$CONFIGURATION""-iphoneos/" | grep ".*\.app$" | head -n1)

if [ "$CODE_SIGNING_IDENTITY" == "none" ]; then
xcrun -sdk iphoneos PackageApplication "$PROJECT_DERIVED_DATA_PATH/Build/Products/""$CONFIGURATION""-iphoneos/$PROJECT_APP" -o "$OUTPUT_IPA" --embed "$MOBILE_PROVISION"
else
xcrun -sdk iphoneos PackageApplication "$PROJECT_DERIVED_DATA_PATH/Build/Products/""$CONFIGURATION""-iphoneos/$PROJECT_APP" -o "$OUTPUT_IPA" --embed "$MOBILE_PROVISION" --sign "$CODE_SIGNING_IDENTITY"
fi

if [ $? -ne 0 ]; then
exit 6
fi

popd > /dev/null
