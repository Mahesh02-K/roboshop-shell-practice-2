#!/bin/bash

source ./common.sh
app_name=cart

verify_root
nodejs_install
app_setup
systemd_setup
print_time