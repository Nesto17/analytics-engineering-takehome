WITH latest_receipt_scanned_date AS (
	SELECT MAX(date_scanned) AS date
	FROM fct_receiptitems
),
recent_month_receipts AS (
    SELECT 
    	barcode, 
    	COUNT("receiptItem_id") AS num_transactions,
    	DENSE_RANK() OVER(ORDER BY COUNT("receiptItem_id") DESC) AS rnk
    FROM fct_receiptitems
    WHERE date_scanned >= (SELECT date FROM latest_receipt_scanned_date) - INTERVAL '1 month' AND 
    	date_scanned < (SELECT date FROM latest_receipt_scanned_date) AND
    	barcode IS NOT NULL
    GROUP BY 1
),
previous_month_receipts AS (
    SELECT 
    	barcode, 
    	COUNT("receiptItem_id") AS num_transactions,
    	DENSE_RANK() OVER(ORDER BY COUNT("receiptItem_id") DESC) AS rnk
    FROM fct_receiptitems
    WHERE date_scanned >= (SELECT date FROM latest_receipt_scanned_date) - INTERVAL '2 month' AND
    	date_scanned < (SELECT date FROM latest_receipt_scanned_date) - INTERVAL '1 month' AND 
    	barcode IS NOT NULL
    GROUP BY 1
)

SELECT 
    rm.barcode,
    rm.num_transactions AS recent_month_count,
    rm.rnk AS recent_month_rank,
    pm.num_transactions AS previous_month_count,
    pm.rnk AS previous_month_rank
FROM recent_month_receipts rm
LEFT JOIN previous_month_receipts pm 
	ON rm.barcode = pm.barcode
WHERE rm.rnk <= 5
ORDER BY recent_month_count DESC;