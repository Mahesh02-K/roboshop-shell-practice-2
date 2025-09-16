#!/bin/bash

source ./common.sh
app_name=cart

verify_root
app_setup
nodejs_install
systemd_setup
print_time