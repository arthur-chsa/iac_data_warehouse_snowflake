locals {
  databases = {
    "LOADING_DB" = {
      comment = "Landing zone for raw ingested data"
      grants = [
        { privileges = ["USAGE", "CREATE SCHEMA"], roles = ["LOADING_RL"] },
        { privileges = ["USAGE"],                  roles = ["TRANSFORMATION_RL"] },
      ]
    }
    "TRANSFORMATION_DB" = {
      comment = "Intermediate and modelled data — dbt workspace"
      grants = [
        { privileges = ["USAGE", "CREATE SCHEMA"], roles = ["TRANSFORMATION_RL"] },
        { privileges = ["USAGE"],                  roles = ["LOADING_RL"] },
      ]
    }
    "DATAMARTS_DB" = {
      comment = "Business-facing datamarts consumed by BI tools"
      grants = [
        { privileges = ["USAGE", "CREATE SCHEMA"], roles = ["TRANSFORMATION_RL"] },
        { privileges = ["USAGE"],                  roles = ["READING_PRODUCT_RL", "READING_MARKETING_RL"] },
      ]
    }
  }
}
