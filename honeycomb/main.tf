resource "honeycombio_dataset" "datasets" {
  for_each = local.datasets

  name             = each.value.name
  description      = each.value.description
  delete_protected = each.value.delete_protected
}

# 1. Derived Column for Build Status (used in visualizations)
resource "honeycombio_derived_column" "build_status_integer" {
  alias       = "derived_column.status_integer"
  expression  = "IF(OR(EQUALS($status, \"failure\"), EQUALS($status, \"failed\")), 1, 0)"
  description = "An integer representation of the status field allowing use of more visualizations."
  dataset     = local.datasets["gha-builds"].name

  # Ensure the dataset exists first
  depends_on = [honeycombio_dataset.datasets]
}

# 2. Query & Annotation: Slow Builds (> 2 minutes)
data "honeycombio_query_specification" "build_times_over_ideal" {
  calculation {
    op     = "HEATMAP"
    column = "duration_ms"
  }

  filter {
    column = "job.status"
    op     = "="
    value  = "success"
  }

  filter {
    column = "trace.parent_id"
    op     = "does-not-exist"
  }

  filter {
    column = "duration_ms"
    op     = ">"
    value  = 120000 # 2 minutes in milliseconds
  }

  time_range = 604800 # 7 days in seconds
}

resource "honeycombio_query" "build_times_over_ideal" {
  dataset    = local.datasets["gha-builds"].name
  query_json = data.honeycombio_query_specification.build_times_over_ideal.json

  depends_on = [honeycombio_dataset.datasets]
}

resource "honeycombio_query_annotation" "build_times_over_ideal_annotation" {
  dataset     = local.datasets["gha-builds"].name
  query_id    = honeycombio_query.build_times_over_ideal.id
  name        = "Which builds are slow?"
  description = "Explore builds that are taking longer than 2 minutes"
}

# 3. Query & Annotation: Build Failures Breakdown
data "honeycombio_query_specification" "success_failure_breakdown" {
  calculation {
    op     = "HEATMAP"
    column = "derived_column.status_integer"
  }

  filter {
    column = "trace.parent_id"
    op     = "does-not-exist"
  }

  filter {
    column = "derived_column.status_integer"
    op     = "!="
    value  = "0"
  }

  breakdowns = ["status", "branch"]
  time_range = 604800 # 7 days in seconds
}

resource "honeycombio_query" "success_failure_breakdown" {
  dataset    = local.datasets["gha-builds"].name
  query_json = data.honeycombio_query_specification.success_failure_breakdown.json

  # Ensure the derived column is created first
  depends_on = [honeycombio_derived_column.build_status_integer]
}

resource "honeycombio_query_annotation" "success_failure_breakdown_annotation" {
  dataset     = local.datasets["gha-builds"].name
  query_id    = honeycombio_query.success_failure_breakdown.id
  name        = "Which builds are failing?"
  description = "Explore patterns in build failures"
}

# 4. Flexible Board for Buildevents
resource "honeycombio_flexible_board" "buildevents_board" {
  name        = "Explore Buildevents"
  description = "Board created to explore CI/CD build telemetry and performance patterns"

  panel {
    type = "query"
    query_panel {
      query_id            = honeycombio_query.success_failure_breakdown.id
      query_annotation_id = honeycombio_query_annotation.success_failure_breakdown_annotation.id
    }
  }

  panel {
    type = "query"
    query_panel {
      query_id            = honeycombio_query.build_times_over_ideal.id
      query_annotation_id = honeycombio_query_annotation.build_times_over_ideal_annotation.id
    }
  }
}
