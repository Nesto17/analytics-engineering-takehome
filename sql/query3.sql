SELECT 
	dr.rewards_receipt_status,
	AVG(CAST(final_price AS FLOAT)) AS average_spend
FROM fct_receiptitems fr 
INNER JOIN dim_receiptitems dr 
	ON fr."receiptItem_id" = dr."receiptItem_id" 
WHERE dr.rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY dr.rewards_receipt_status;