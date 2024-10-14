SELECT
	db.barcode,
	db."name",
	SUM(CAST(fr.final_price AS FLOAT)) AS total_spend
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
ORDER BY total_spend DESC;