# modules/glue_athena/main.tf

resource "aws_glue_catalog_database" "cur_db" {
  name = "coldtracker_cur_db"
}

resource "aws_glue_catalog_table" "cur_table" {
  name          = "cur_reports"
  database_name = aws_glue_catalog_database.cur_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"     = "csv"
    "compressionType"    = "gzip"
    "typeOfData"         = "file"
    "projection.enabled" = "true"
  }

  storage_descriptor {
    location      = "s3://${var.cur_bucket_name}/cur/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = true

    # Correct syntax: use column blocks instead of columns argument
    columns {
      name = "line_item_usage_account_id"
      type = "string"
    }

    columns {
      name = "line_item_product_code"
      type = "string"
    }

    columns {
      name = "line_item_usage_start_date"
      type = "string"
    }

    columns {
      name = "line_item_usage_end_date"
      type = "string"
    }

    columns {
      name = "line_item_usage_amount"
      type = "double"
    }

    ser_de_info {
      name                  = "cur_serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }
  }
}

resource "aws_athena_named_query" "top_services_cost" {
  name        = "TopServicesCost"
  database    = aws_glue_catalog_database.cur_db.name
  description = "Top 20 AWS services by cost"
  query       = <<EOF
SELECT
  line_item_product_code AS service,
  SUM(line_item_usage_amount) AS total_cost
FROM
  cur_reports
GROUP BY
  line_item_product_code
ORDER BY
  total_cost DESC
LIMIT 20;
EOF

  workgroup = aws_athena_workgroup.cur_workgroup.name
}


resource "aws_athena_workgroup" "cur_workgroup" {
  name = "coldtracker_cur_workgroup"

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${var.cur_bucket_name}/athena-results/"
    }
  }
}