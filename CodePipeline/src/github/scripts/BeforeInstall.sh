#!/bin/bash
if [ -d /opt/scripts ]; then
  sudo rm -rf /opt/scripts/
else
  sudo mkdir -p /opt/scripts
fi