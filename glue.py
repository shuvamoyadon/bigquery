def _build_full_grid(src_df):
    """Build a complete grid of all months for each inventory source"""
    # Get all unique inventory sources
    inv_sources = src_df.select("inv_src").distinct()
    
    # Get date range
    date_range = src_df.agg(
        _min(trunc(col("evnt_ts"), "month")).alias("min_month"),
        _max(trunc(col("evnt_ts"), "month")).alias("max_month")
    ).collect()[0]
    
    min_month = date_range["min_month"]
    max_month = date_range["max_month"]
    
    # Calculate months difference using Python datetime
    from datetime import datetime
    import calendar
    
    # Convert to datetime for calculation
    min_dt = min_month
    max_dt = max_month
    
    # Calculate number of months
    months_diff = (max_dt.year - min_dt.year) * 12 + (max_dt.month - min_dt.month) + 1
    
    # Create months DataFrame
    months_df = spark.range(months_diff).select(
        add_months(lit(min_month), col("id")).alias("month")
    )
    
    # Cross join to get all combinations
    full_grid = inv_sources.crossJoin(months_df)
    
    return full_grid

def compute_monthly_by_invsrc_corrected(src_df):
    """
    Corrected version that ensures proper 12-month comparison logic
    """
    # Normalize to day & month
    src = (
        src_df
        .withColumn("day", to_date(col("evnt_ts")))
        .withColumn("month", trunc(col("evnt_ts"), "month"))
    )

    latest_month = src.agg(_max("month").alias("latest")).collect()[0]["latest"]

    # Daily rollup (per inv_src, per day)
    daily = (
        src.groupBy("inv_src", "day")
           .agg(_sum("historical_imps").alias("imp_day"))
           .withColumn("month", trunc(col("day"), "month"))
    )

    # Monthly rollup from daily
    monthly_core = (
        daily.groupBy("inv_src", "month")
             .agg(
                 _sum("imp_day").alias("monthly_imps"),
                 _max("imp_day").alias("max_imp_day"),
                 _min("imp_day").alias("min_imp_day"),
                 countDistinct("day").alias("days_with_data")
             )
    )

    # Distinct networks seen in the month
    month_counts = (
        src.groupBy("inv_src", "month")
           .agg(countDistinct("network").alias("networks_distinct"))
    )

    # Continuous month grid per inv_src
    full_grid = _build_full_grid(src)

    # Left join to ensure months with no data exist as rows
    monthly = (
        full_grid
        .join(monthly_core, on=["inv_src", "month"], how="left")
        .join(month_counts, on=["inv_src", "month"], how="left")
    )

    # Fill nulls for metrics where missing month means 0
    monthly = (
        monthly
        .withColumn("monthly_imps",       F.coalesce(col("monthly_imps"), F.lit(0)))
        .withColumn("max_imp_day",        F.coalesce(col("max_imp_day"),  F.lit(0)))
        .withColumn("min_imp_day",        F.coalesce(col("min_imp_day"),  F.lit(0)))
        .withColumn("networks_distinct",  F.coalesce(col("networks_distinct"), F.lit(0)))
        .withColumn("days_with_data",     F.coalesce(col("days_with_data"), F.lit(0)))
    )

    # CORRECTED: Proper 12-month comparison using exact date matching
    # Instead of shifting months, we'll join on the exact same month from different years
    prior_12_months = (
        monthly
        .select(
            col("inv_src").alias("p_inv_src"),
            col("month").alias("p_month"),
            col("monthly_imps").alias("monthly_imps_t12"),
            col("max_imp_day").alias("max_imp_day_t12"),
            col("min_imp_day").alias("min_imp_day_t12"),
            col("networks_distinct").alias("networks_distinct_t12"),
            col("days_with_data").alias("days_with_data_t12")
        )
    )

    # Join current with prior using proper 12-month offset
    monthly = (
        monthly.alias("cur")
        .join(
            prior_12_months,
            (col("cur.inv_src") == col("p_inv_src")) & 
            (col("cur.month") == add_months(col("p_month"), 12)),  # Current month = Prior month + 12
            how="inner"  # CHANGED: Use inner join to only keep records with valid prior data
        )
        .drop("p_inv_src", "p_month")
    )

    # FIXED: Additional filter to ensure both periods have meaningful data
    monthly = monthly.filter(
        (col("monthly_imps") > 0) & 
        (col("monthly_imps_t12") > 0) &
        (col("days_with_data") > 0) & 
        (col("days_with_data_t12") > 0)
    )

    # Fill prior with zeros where missing (now only for records that passed the filter)
    monthly = (
        monthly
        .withColumn("monthly_imps_t12",      F.coalesce(col("monthly_imps_t12"), F.lit(0)))
        .withColumn("max_imp_day_t12",       F.coalesce(col("max_imp_day_t12"),  F.lit(0)))
        .withColumn("min_imp_day_t12",       F.coalesce(col("min_imp_day_t12"),  F.lit(0)))
        .withColumn("networks_distinct_t12", F.coalesce(col("networks_distinct_t12"), F.lit(0)))
        .withColumn("days_with_data_t12",    F.coalesce(col("days_with_data_t12"), F.lit(0)))
    )

    # Calculate averages using actual days with data
    monthly = (
        monthly
        .withColumn("ave_imp_per_day_raw",
                    (col("monthly_imps") / F.greatest(col("days_with_data"), F.lit(1))).cast(DoubleType()))
        .withColumn("ave_imp_per_day_prior_raw",
                    (col("monthly_imps_t12") / F.greatest(col("days_with_data_t12"), F.lit(1))).cast(DoubleType()))
    )

    # Mark source type
    monthly = monthly.withColumn(
        "SOURCE_TYPE",
        when(col("month") < lit(latest_month), lit("Existing_data")).otherwise(lit("New_data"))
    )

    # Apply the logic directly without conditional enforcement
    monthly = (
        monthly
        .withColumn("AVE_IMP_PER_DAY", 
                    F.greatest(col("ave_imp_per_day_raw"), col("ave_imp_per_day_prior_raw")))
        .withColumn("AVE_IMP_PER_DAY_PRIOR_12_MO", col("ave_imp_per_day_prior_raw"))
        .withColumn("MIN_IMP_PER_DAY",
                    F.greatest(col("min_imp_day").cast(DoubleType()),
                               col("min_imp_day_t12").cast(DoubleType())))
        .withColumn("MIN_IMP_PER_DAY_PRIOR_12_MO", col("min_imp_day_t12").cast(DoubleType()))
    )

    # Final select
    out = (
        monthly.select(
            col("month").cast(DateType()).alias("start_date"),
            last_day(col("month")).cast(DateType()).alias("end_date"),
            col("SOURCE_TYPE"),
            col("monthly_imps").cast(LongType()).alias("TOTAL_IMPRESSIONS"),
            col("AVE_IMP_PER_DAY"),
            col("AVE_IMP_PER_DAY_PRIOR_12_MO"),
            col("max_imp_day").cast(DoubleType()).alias("MAX_IMP_PER_DAY"),
            col("max_imp_day_t12").cast(DoubleType()).alias("MAX_IMP_PER_DAY_PRIOR_12_MO"),
            col("MIN_IMP_PER_DAY"),
            col("MIN_IMP_PER_DAY_PRIOR_12_MO"),
            col("networks_distinct").cast(LongType()).alias("NETWORK_COUNT"),
            col("networks_distinct_t12").cast(LongType()).alias("NETWORK_COUNT_PRIOR_12_MO"),
            col("inv_src").alias("INVENTORY_SOURCE")
        )
        .orderBy("start_date", "SOURCE_TYPE", "INVENTORY_SOURCE")
    )
    return out
