# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

mock "tfplan/v2" {
  module {
    source = "./mocks/policy-success-sg-port/mock-tfplan-v2.sentinel"
  }
}

mock "tfresources" {
  module {
    source = "../../../../modules/tfresources/tfresources.sentinel"
  }
}

mock "report" {
  module {
    source = "../../../../modules/mocks/report/report.sentinel"
  }
}

param "ensure_no_ingress_to_port_3389_from_unknown_sources" {
  value = true
}

param "prevent_unknown_ipv4_ingress" {
  value = true
}


test {
  rules = {
    main = true
  }
}
