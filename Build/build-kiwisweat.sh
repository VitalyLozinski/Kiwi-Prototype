. ./config.sh



###########################################################################
echo "$(tput setaf 14)Updating Libraries...$(tput sgr0)"
###########################################################################

pod update



###########################################################################
echo "$(tput setaf 14)Applying Configs...$(tput sgr0)"
###########################################################################

cp -rf "$MOBILE_PROVISION_DIR""VenmoTouchSettings.h" "../Pods/Braintree/venmo-touch/VenmoTouch.framework/Headers/VenmoTouchSettings.h"


###########################################################################
echo "$(tput setaf 14)Building Production for AppStore...$(tput sgr0)"
###########################################################################

. ./build-ipa.sh \
".." \
"Production" \
"iPhone Distribution: KiwiSweat LLC" \
"$MOBILE_PROVISION_DIR""KiwiSweat_Prod.mobileprovision" \
"$BUILD_DIR/KiwiSweat_Production_AppStore.ipa" \
"Kiwi" \
"Release"


###########################################################################
echo "$(tput setaf 14)Building Production for TestFlight...$(tput sgr0)"
###########################################################################

. ./build-ipa.sh \
".." \
"Production" \
"iPhone Developer: Alicia Thomas" \
"$MOBILE_PROVISION_DIR""KiwiSweat_Dev.mobileprovision" \
"$BUILD_DIR/KiwiSweat_Production_TestFlight.ipa" \
"Kiwi" \
"Release"


###########################################################################
echo "$(tput setaf 14)Building Beta...$(tput sgr0)"
###########################################################################

. ./build-ipa.sh \
".." \
"Beta" \
"none" \
"$MOBILE_PROVISION_DIR""KiwiSweat_Beta.mobileprovision" \
"$BUILD_DIR/KiwiSweat_Beta_TestFlight.ipa" \
"Kiwi" \
"Debug"


###########################################################################
echo "$(tput setaf 14)Building QA...$(tput sgr0)"
###########################################################################

. ./build-ipa.sh \
".." \
"QA" \
"none" \
"$MOBILE_PROVISION_DIR""KiwiSweat.mobileprovision" \
"$BUILD_DIR/KiwiSweat_QA_TestFlight.ipa" \
"Kiwi" \
"Debug"




###########################################################################
echo "$(tput setaf 14)Uploading to Test Flight...$(tput sgr0)"
###########################################################################

. ./upload-ipa.sh "$BUILD_DIR/KiwiSweat_Beta_TestFlight.ipa" "KiwisweatBeta"
. ./upload-ipa.sh "$BUILD_DIR/KiwiSweat_QA_TestFlight.ipa" "KiwisweatQA"
. ./upload-ipa.sh "$BUILD_DIR/KiwiSweat_Production_TestFlight.ipa" "KiwisweatProd"
