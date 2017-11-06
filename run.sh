#!/bin/bash
# Copyright 2017, Oracle and/or its affiliates. All rights reserved.

echo "$(date +%H:%M:%S): Running the OWASP dependency-check Wercker Step"

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
# Download OWASP dependency-check when not already available
#

if [ ! -d "$WERCKER_CACHE_DIR/owasp" ]; then
  mkdir $WERCKER_CACHE_DIR/owasp
  echo "$(date +%H:%M:%S): Downloading OWASP dependency-check"
  curl -O -L https://dl.bintray.com/jeremy-long/owasp/dependency-check-3.0.1-release.zip

  echo "$(date +%H:%M:%S): Extracting OWASP dependency-check"
  unzip -q dependency-check-3.0.1-release.zip -d $WERCKER_CACHE_DIR/owasp
  rm dependency-check-3.0.1-release.zip

else
  if [ ! -x "$WERCKER_CACHE_DIR/owasp/dependency-check/bin/dependency-check.sh" ] ; then
      echo "$(date +%H:%M:%S): ERROR: dependency-check was not installed properly"
      exit 1
  fi
  echo "$(date +%H:%M:%S): OWASP dependency-check already present"
fi

#
# Run OWASP dependency-check
#
CHECK_CMD="$WERCKER_CACHE_DIR/owasp/dependency-check/bin/dependency-check.sh --project $WERCKER_OWASP_DEPENDENCY_CHECK_PROJECT --scan $WERCKER_OWASP_DEPENDENCY_CHECK_SCAN --out $WERCKER_OWASP_DEPENDENCY_CHECK_OUT --format $WERCKER_OWASP_DEPENDENCY_CHECK_FORMAT --failOnCVSS $WERCKER_OWASP_DEPENDENCY_CHECK_FAIL_ON_CVSS --data $WERCKER_OWASP_DEPENDENCY_CHECK_DATA"
echo "$(date +%H:%M:%S): Running OWASP dependency-check with command:"
echo "% $CHECK_CMD"
$CHECK_CMD

#
# Save OWASP dependency-check reports
#
echo "$(date +%H:%M:%S): Save OWASP dependency-check reports to $WERCKER_CACHE_DIR"
echo "% cp -fv $WERCKER_OWASP_DEPENDENCY_CHECK_OUT/dependency-check-*.* $WERCKER_CACHE_DIR"
cp -fv $WERCKER_OWASP_DEPENDENCY_CHECK_OUT/dependency-check-*.* $WERCKER_CACHE_DIR

#
# Exit without error so pipeline completes
#
exit 0
