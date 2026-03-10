locals {
  warehouses = {
    "LOADING_WH" = {
      warehouse_size      = "XSMALL"
      auto_suspend        = 60
      auto_resume         = true
      initially_suspended = true
      comment             = "Warehouse for data ingestion"
      grants = [
        { privileges = ["USAGE"], roles = ["LOADING_RL"] },
      ]
    }
    "TRANSFORMATION_WH" = {
      warehouse_size      = "XSMALL"
      auto_suspend        = 60
      auto_resume         = true
      initially_suspended = true
      comment             = "Warehouse for dbt runs"
      grants = [
        { privileges = ["USAGE"], roles = ["TRANSFORMATION_RL"] },
      ]
    }
    "READING_WH" = {
      warehouse_size      = "XSMALL"
      auto_suspend        = 60
      auto_resume         = true
      initially_suspended = true
      comment             = "Warehouse for BI queries"
      grants = [
        { privileges = ["USAGE"], roles = ["READING_PRODUCT_RL", "READING_MARKETING_RL"] },
      ]
    }
  }
}
