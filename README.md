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
        project: demo
        scan: $WERCKER_CACHE_DIR
        out: $WERCKER_CACHE_DIR
        format: ALL
        fail_on_cvss: "5.0"
        data: $WERCKER_CACHE_DIR/owasp/
```

### Parameters

_TBD_

## Example

See the sample wercker application at [https://github.com/thefrogpad/getting-started-java](https://github.com/TheFrogPad/getting-started-java).
