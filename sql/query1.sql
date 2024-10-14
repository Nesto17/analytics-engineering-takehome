SELECT 
	fr.barcode,
	COUNT(fr."receiptItem_id") AS receipt_count
FROM fct_receiptitems fr 
LEFT JOIN dim_brands db
	ON fr.barcode = db.barcode 
WHERE 
	fr.date_scanned >= (SELECT MAX(date_scanned) FROM fct_receiptitems) - INTERVAL '1 month' AND 
	fr.date_scanned < (SELECT MAX(date_scanned) FROM fct_receiptitems) AND 
	fr.barcode IS NOT NULL
GROUP BY 1
ORDER BY receipt_count DESC
LIMIT 5;
