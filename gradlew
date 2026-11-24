#!/bin/bash
APP_HOME=$(cd "$(dirname "$0")" && pwd)
exec /home/userlinux/.jdks/gradle-8.2/bin/gradle "$@"
