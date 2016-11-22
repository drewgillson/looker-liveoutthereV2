view: plan_weekly_sales {
  derived_table: {
    sql: SELECT
        products.parent_id AS parent_id,
        CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),DATEADD(day,(0 - (((DATEPART(dw,sales.order_created ) - 1) - 1 + 7) % (7))), sales.order_created  ),120), 120) AS order_created,
        (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.qty ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_qty ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))  AS net_sold_quantity,
        100.00 * CASE
              WHEN FLOOR((CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2)))) = 0 AND (CAST((CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))) - (CASE WHEN (CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))) > 0 THEN (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.extended_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.extended_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) END) AS money)) = 0 THEN NULL
              WHEN FLOOR((CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2)))) > 0 THEN (CAST((CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))) - (CASE WHEN (CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))) > 0 THEN (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.extended_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.extended_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) END) AS money)) / (CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2)))
            END AS gross_margin,
        CAST((CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))) - (CASE WHEN (CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))) > 0 THEN (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.extended_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.extended_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) END) AS money)  AS gross_profit,
        CAST((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.row_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - ((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_total ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(credits.refunded_tax ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), credits.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))) AS decimal(38,2))  AS net_sold
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
      LEFT JOIN ${sales_credits_items.SQL_TABLE_NAME} AS credits ON sales.order_entity_id = credits.order_entity_id
            AND sales.product_id = credits.product_id
      WHERE
        (((sales.order_created ) >= (CONVERT(DATETIME,'2015-01-01', 120))))
      GROUP BY products.parent_id ,CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),DATEADD(day,(0 - (((DATEPART(dw,sales.order_created ) - 1) - 1 + 7) % (7))), sales.order_created  ),120), 120),products.product;;
    indexes: ["parent_id", "order_created"]
    sql_trigger_value: SELECT CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),DATEADD(day,(0 - (((DATEPART(dw,GETDATE() ) - 1) - 1 + 7) % (7))), GETDATE()  ),120), 120)
      ;;
  }

  dimension: parent_id {
    primary_key: yes
    hidden: yes
  }

  measure: net_sold_quantity {
    type: sum
    sql: ${TABLE}.net_sold_quantity ;;
  }

  measure: net_sold {
    label: "Net Sold $"
    type: sum
    sql: ${TABLE}.gross_profit ;;
    value_format: "$#,##0"
  }

  measure: gross_profit {
    label: "Profit $"
    type: sum
    sql: ${TABLE}.gross_profit ;;
    value_format: "$#,##0"
  }

  measure: gross_margin {
    label: "Gross Margin %"
    type: average
    sql: ${TABLE}.gross_margin ;;
    value_format: "0\%"
    html:
      {% if value >= 38 %}
      <font color="darkgreen">{{ rendered_value }}</font>
      {% elsif value >= 28 %}
      <font color="goldenrod">{{ rendered_value }}</font>
      {% else %}
      <font color="darkred">{{ rendered_value }}</font>
      {% endif %} ;;
  }

}
