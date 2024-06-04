#!/bin/bash

REPO_URL="http://your-nexus-repo/nexus/content/repositories/your-repo"
GROUP_ID="com.yourcompany"
ARTIFACT_ID="your-artifact"
VERSION="1.0.0"
PACKAGING="jar"
FILE_PATH="/path/to/your/artifact.jar"
POM_PATH="/path/to/your/pom.xml"
USERNAME="your-username"
PASSWORD="your-password"

GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')

# Upload JAR
curl -u $USERNAME:$PASSWORD --upload-file $FILE_PATH \
"$REPO_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.$PACKAGING"

# Upload POM
curl -u $USERNAME:$PASSWORD --upload-file $POM_PATH \
"$REPO_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.pom"

# Generate checksums
md5sum $FILE_PATH | awk '{print $1}' > $FILE_PATH.md5
sha1sum $FILE_PATH | awk '{print $1}' > $FILE_PATH.sha1
md5sum $POM_PATH | awk '{print $1}' > $POM_PATH.md5
sha1sum $POM_PATH | awk '{print $1}' > $POM_PATH.sha1

# Upload checksums
curl -u $USERNAME:$PASSWORD --upload-file "$FILE_PATH.md5" \
"$REPO_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.$PACKAGING.md5"

curl -u $USERNAME:$PASSWORD --upload-file "$FILE_PATH.sha1" \
"$REPO_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.$PACKAGING.sha1"

curl -u $USERNAME:$PASSWORD --upload-file "$POM_PATH.md5" \
"$REPO_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.pom.md5"

curl -u $USERNAME:$PASSWORD --upload-file "$POM_PATH.sha1" \
"$REPO_URL/$GROUP_PATH/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.pom.sha1"
