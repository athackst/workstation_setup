#!/bin/bash
set -e

mkdir -p src
$(cd src && git clone https://github.com/bazelbuild/examples/)
