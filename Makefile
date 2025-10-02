# stolen from https://github.com/khcrysalis/Feather/blob/5a7456447205fb1bea4e783ec066ee3dedd6a893/Makefile
NAME := PsychonautWiki Journal
APPNAME := Journal
PLATFORM := iphoneos

TMP := $(TMPDIR)/$(APPNAME)
ARCHIVE := $(TMP)/archive.xcarchive
IPA := packages/$(APPNAME)-unsigned.ipa

.PHONY: all clean archive ipa

all: ipa

clean:
	rm -rf "$(TMP)" "packages"

archive:
	rm -rf "$(ARCHIVE)"
	xcodebuild archive \
	    -project "$(NAME).xcodeproj" \
	    -scheme "$(NAME)" \
	    -configuration Release \
	    -sdk $(PLATFORM) \
	    -archivePath "$(ARCHIVE)" \
	    -skipPackagePluginValidation \
	    CODE_SIGN_IDENTITY="" \
	    CODE_SIGNING_REQUIRED=NO \
	    CODE_SIGNING_ALLOWED=NO \
	    ARCHS=arm64 VALID_ARCHS=arm64 \
	    DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
	    STRIP_INSTALLED_PRODUCT=YES \
	    ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO

ipa: archive
	rm -rf "$(TMP)/Payload"
	mkdir -p "$(TMP)/Payload"
	cp -R "$(ARCHIVE)/Products/Applications/$(APPNAME).app" "$(TMP)/Payload/"

	mkdir -p "$(dir $(IPA))"

	/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$(TMP)/Payload/$(APPNAME).app/Info.plist" > "$(dir $(IPA))/version.txt"

	cd "$(TMP)" && zip -r9 -y -q "$(abspath $(IPA))" Payload
