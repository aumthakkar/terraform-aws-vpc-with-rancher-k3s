terraform {
  cloud {

    organization = "MTC-Jan25"

    workspaces {
      name = "pht-dev"
    }
  }
}