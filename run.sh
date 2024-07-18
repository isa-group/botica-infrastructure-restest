#!/bin/bash

VERSION_FILE=".botica-director-version"
DIRECTOR_JAR="botica-director.jar"
LATEST_RELEASE_URL="https://api.github.com/repos/isa-group/botica/releases/latest"
DOWNLOAD_URL="https://github.com/isa-group/botica/releases/latest/download/botica-director.jar"
JAVA_CMD=""

check_java_version() {
  if type -p java >/dev/null; then
    JAVA_CMD=java
  elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
    JAVA_CMD="$JAVA_HOME/bin/java"
  else
    echo "Error: Java is not installed on this machine. Please install Java 11 or higher and try again."
    return 1
  fi

  version=$("$JAVA_CMD" -version 2>&1 | awk -F[\"\._] '/version/ {print $2}')
  if [[ "$version" -ge 11 ]]; then
    return 0
  else
    echo "Error: you need at least Java 11 to run Botica. Found version: $version. Please install \
Java 11 or higher and try again."
    return 1
  fi
}

if ! check_java_version; then
  exit 1
fi

get_latest_release() {
  latest_version=$(curl -s $LATEST_RELEASE_URL | grep -oP '"tag_name": "\K(.*)(?=")')
  if [[ $? -ne 0 || -z "$latest_version" ]]; then
    return 1
  fi
  return 0
}

download_botica_director() {
  echo "Downloading the latest version ($latest_version)..."
  if ! curl -L -o $DIRECTOR_JAR $DOWNLOAD_URL; then
    echo "Error: Failed to download Botica Director. Please check your internet connection and try again."
    exit 1
  fi
  echo "$latest_version" > $VERSION_FILE
}

if ! get_latest_release; then
  if [[ -f $DIRECTOR_JAR ]]; then
    echo "Warning: Failed to fetch the latest release version. Please check your internet connection."
  else
    echo "Error: Failed to download Botica Director. Please check your internet connection and try again."
    exit 1
  fi
else
  if [[ -f $DIRECTOR_JAR && -f $VERSION_FILE ]]; then
    local_version=$(cat $VERSION_FILE)
    if [[ "$latest_version" != "$local_version" ]]; then
      echo "A new version ($latest_version) is available."
      download_botica_director
    fi
  else
    download_botica_director
  fi
fi

"$JAVA_CMD" -jar $DIRECTOR_JAR "$@"
