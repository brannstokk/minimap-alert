.PHONY: zip checktag checkdir clean

ADDON=Minimap_Alert
TAG=$(shell git describe --tags)
FILES=\
	${ADDON}/${ADDON}.lua \
	${ADDON}/${ADDON}.toc \
	${ADDON}/DefaultSettings.lua \
	${ADDON}/Fullscreen_Flash.blp \
	${ADDON}/Helpers.lua \
	${ADDON}/Options.lua \
	${ADDON}/TrackableList.lua \
	${ADDON}/Trackables.lua \
	${ADDON}/TrackingList.lua \
	${ADDON}/README.md

# Make release zip
zip: clean checkdir checktag
	(cd ..; zip -r ${ADDON}/${ADDON}-${TAG}.zip ${FILES})

# Make sure all releases have clean tags
checktag:
	echo ${TAG} | grep -q '^v[0-9]\+[.][0-9]\+[.][0-9]\+-classic$$' || (echo "ERROR: Invalid tag: "${TAG}; exit 1)

# Make sure the top-level directory is named correctly (used in the zip)
checkdir:
	basename "$(shell pwd)" | grep -q "^${ADDON}$$"

# Clean up previous release attempts
clean:
	rm -vf ${ADDON}-v*.zip

