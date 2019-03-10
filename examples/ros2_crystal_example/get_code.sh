#!/bin/bash
set -e

mkdir -p src
cp .rosinstall src/.rosinstall
wstool up -t src
