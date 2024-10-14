SELECT
	db.barcode,
	db."name",
	COUNT(fr."receiptItem_id") AS num_transactions
FROM fct_receiptitems fr 
RIGHT JOIN dim_brands db 
	ON fr.barcode = db.barcode 
LEFT JOIN dim_users du 
	ON fr.user_id = du.user_id 
WHERE du.created_date > (
	SELECT MAX(du.created_date)
	FROM dim_users du 
) - INTERVAL '6 months'
GROUP BY 1, 2
ORDER BY num_transactions DESC;