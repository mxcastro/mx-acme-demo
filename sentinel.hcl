# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

import "module" "report" {
  source = "./modules/report/report.sentinel"
}

import "module" "tfresources" {
  source = "./modules/tfresources/tfresources.sentinel"
}

import "module" "tfplan-functions" {
  source = "./modules/tfplan-functions/tfplan-functions.sentinel"
}

import "module" "tfconfig-functions" {
  source = "./modules/tfconfig-functions/tfconfig-functions.sentinel"
}

policy "s3-block-public-access-bucket-level" {
  source = "./policies/s3/s3-block-public-access-bucket-level.sentinel"
  enforcement_level = "hard-mandatory"
}