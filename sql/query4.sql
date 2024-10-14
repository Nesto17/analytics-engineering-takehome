SELECT
	dr.rewards_receipt_status,
	COUNT(fr."receiptItem_id") AS num_items,
	SUM(fr.quantity_purchased) AS total_qty
FROM fct_receiptitems fr 
INNER JOIN dim_receiptitems dr 
	ON fr."receiptItem_id" = dr."receiptItem_id" 
WHERE dr.rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY dr.rewards_receipt_status;