# OWASP dependency-check Step for wercker

A wercker step to run the OWASP dependency-check tool standalone from the source build.

## OWASP dependency-check Information

For more information on OWASP dependency-check tool please see the [OWASP website](https://www.owasp.org/index.php/OWASP_Dependency_Check) or [documentation on GitHub](https://jeremylong.github.io/DependencyCheck/)

## Requirements

The wercker `box` that you run your pipeline should use or extend the `openjdk` container [from Docker Hub](https://hub.docker.com/_/openjdk/).

The `curl` and `unzip` utilties are also expected in order to download the binary distriubtion to the wercker cache directory.

## Usage

To use the step, add the step to your pipeline (`wercker.yml`) with the appropriate properties, as in the example below:

```
  steps:
    - thefrogpad/owasp-dependency-check:
        project: application
        scan: $WERCKER_CACHE_DIR
        out: $WERCKER_CACHE_DIR
        format: JSON
        fail_on_cvss: "11"
        data: $WERCKER_CACHE_DIR/owasp/
```

_NOTE:_ The `fail_on_cvss` parameter should be an integer value between 0 and 10, the use of 11 means that no error status will be returned from running dependency-check and the step will complete successfully even when a vulnerability is detected.

### Parameters

Parameters are currently limited to the following and match the [OWASP dependency-check arguments](https://jeremylong.github.io/DependencyCheck/dependency-check-cli/arguments.html):

* `project`
<br>The name of the project being scanned

* `scan`
<br>The path to scan

* `out`
<br>The folder to write reports to

* `format`
<br>The output format to write to (XML, HTML, CSV, JSON, VULN, ALL)

* `fail_on_cvss`
<br>If the score is set between 0 and 10 the exit code from dependency-check will indicate if a vulnerability with a CVSS score equal to or higher was identified

* `data`
<br>The location of the data directory used to store persistent data

## Example

See the sample wercker application at [https://github.com/thefrogpad/getting-started-java](https://github.com/TheFrogPad/getting-started-java).
