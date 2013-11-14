#bin/sh

DOCSETNAME="starling.docset"

rm -rf starling.docset
rm docSet.dsidx

echo "Generating Docset Index Database"
ruby populateIndex.rb starlingdocs/all-classes.html

echo "Create Docset"
mkdir -p ${DOCSETNAME}/Contents/Resources/Documents/
cp -r starlingdocs/ ${DOCSETNAME}/Contents/Resources/Documents/
cp info.plist ${DOCSETNAME}/Contents/
cp docSet.dsidx ${DOCSETNAME}/Contents/Resources/
cp icon.png ${DOCSETNAME}/

tar --exclude='.DS_Store' -cvzf starling.tgz ${DOCSETNAME}