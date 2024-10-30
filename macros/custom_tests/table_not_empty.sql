{#
    Test that checks if a table or view has at least one row.
    
    Args:
        model: The table or view to test
        
    Returns:
        A table with 0 rows if the test passes (table has records)
        A table with 1 row if the test fails (table is empty)
        
#}

{% test table_not_empty(model) %}

WITH row_count AS (
    SELECT COUNT(*) AS rc
    FROM {{ model }}
)

SELECT *
FROM row_count
WHERE rc = 0

{% endtest %}