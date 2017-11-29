#!/bin/bash
# Copyright 2017, Oracle and/or its affiliates. All rights reserved.

echo "$(date +%H:%M:%S): Running the OWASP dependency-check wercker Step"

#
# Check for required dependencies
#

if [ -n "$JAVA_HOME" ] ; then
  if [ ! -x "$JAVA_HOME/bin/java" ] ; then
      echo "$(date +%H:%M:%S): ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
      exit 1
  fi
else
  echo "$(date +%H:%M:%S): Please ensure Java is installed and JAVA_HOME set correctly"
  exit 1
fi

hash curl 2>/dev/null || { echo "$(date +%H:%M:%S): curl is required, install curl before this step."; exit 1; }

hash unzip 2>/dev/null || { echo "$(date +%H:%M:%S): unzip is required, install unzip before this step"; exit 1; }

echo "$(date +%H:%M:%S): OWASP dependency-check requirements complete"

#
# Proxy information when available [IFF proxy server then include proxy port]
#
if [[ -z "$HTTPS_PROXY_SERVER" ]]; then
  CURL_PROXY=""
  CHECK_PROXY=""
  echo "$(date +%H:%M:%S): A proxy will not be used for dependency-check"
else
  CURL_PROXY="--proxy $HTTPS_PROXY_SERVER:$HTTPS_PROXY_PORT"
  CHECK_PROXY="--proxyserver $HTTPS_PROXY_SERVER --proxyport $HTTPS_PROXY_PORT"
fi

#
# Download OWASP dependency-check when not already available, find latest version
#

if [ ! -d "$WERCKER_CACHE_DIR/owasp" ]; then
  mkdir $WERCKER_CACHE_DIR/owasp
  echo "$(date +%H:%M:%S): Downloading OWASP dependency-check"
  curl $CURL_PROXY -o $WERCKER_CACHE_DIR/owasp/dependency-check_version.txt -L https://jeremylong.github.io/DependencyCheck/current.txt
  version=$(cat $WERCKER_CACHE_DIR/owasp/dependency-check_version.txt)
  file="dependency-check-$version-release.zip"
  echo "$(date +%H:%M:%S): Downloading $file"
  curl $CURL_PROXY -O -L https://dl.bintray.com/jeremy-long/owasp/$file

  echo "$(date +%H:%M:%S): Extracting OWASP dependency-check"
  unzip -q $file -d $WERCKER_CACHE_DIR/owasp
  rm $file

else
  if [ ! -x "$WERCKER_CACHE_DIR/owasp/dependency-check/bin/dependency-check.sh" ] ; then
      echo "$(date +%H:%M:%S): ERROR: dependency-check was not installed properly"
      rm -rf $WERCKER_CACHE_DIR/owasp
      exit 1
  fi
  echo "$(date +%H:%M:%S): OWASP dependency-check already present"
fi

#
# Run OWASP dependency-check
#
CHECK_CMD="$WERCKER_CACHE_DIR/owasp/dependency-check/bin/dependency-check.sh $CHECK_PROXY --project $WERCKER_OWASP_DEPENDENCY_CHECK_PROJECT --scan $WERCKER_OWASP_DEPENDENCY_CHECK_SCAN --out $WERCKER_OWASP_DEPENDENCY_CHECK_OUT --format $WERCKER_OWASP_DEPENDENCY_CHECK_FORMAT --failOnCVSS $WERCKER_OWASP_DEPENDENCY_CHECK_FAIL_ON_CVSS --data $WERCKER_OWASP_DEPENDENCY_CHECK_DATA"
echo "$(date +%H:%M:%S): Running OWASP dependency-check with command:"
echo "% $CHECK_CMD"
$CHECK_CMD

#
# Check for error result from OWASP dependency-check
#
rc=$?
if [[ $rc != 0 ]]; then
  echo "$(date +%H:%M:%S): OWASP dependency-check reported status: $rc"
  echo "$(date +%H:%M:%S): Check OWASP dependency-check reports in $WERCKER_OWASP_DEPENDENCY_CHECK_OUT"
  exit $rc
fi

#
# Done OWASP dependency-check reports
#
echo "$(date +%H:%M:%S): Saved OWASP dependency-check reports to $WERCKER_OWASP_DEPENDENCY_CHECK_OUT"
