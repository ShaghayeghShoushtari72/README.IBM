sql


Workshop.q1
1/ 
SELECT
    f.title AS "Film Title",
    c.name AS "Category Name",
    COUNT(r.rental_id) AS "Count of Rentals"
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
LEFT JOIN
    inventory i ON f.film_id = i.film_id
LEFT JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY
    f.title, c.name
ORDER BY
    c.name, f.title;
    
    
    
 2/   
 WITH MovieAvgDuration AS (
    SELECT
        fc.category_id,
        f.title AS film_title,
        AVG(f.rental_duration) AS avg_rental_duration
    FROM
        film f
    JOIN
        film_category fc ON f.film_id = fc.film_id
    GROUP BY
        fc.category_id, f.title
),
QuartileValues AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_rental_duration) AS first_quarter,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_rental_duration) AS second_quarter,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_rental_duration) AS third_quarter
    FROM
        MovieAvgDuration
)
SELECT
    m.film_title,
    c.name AS category_name,
    CASE
        WHEN avg_rental_duration <= q.first_quarter THEN 'first_quarter'
        WHEN avg_rental_duration <= q.second_quarter THEN 'second_quarter'
        WHEN avg_rental_duration <= q.third_quarter THEN 'third_quarter'
        ELSE 'final_quarter'
    END AS quartile
FROM
    MovieAvgDuration m
JOIN
    category c ON m.category_id = c.category_id
CROSS JOIN
    QuartileValues q
ORDER BY
    category_name, film_title;   
    
    
3/
WITH MovieRentalDuration AS (
    SELECT  f.fil fc.category_id, c.name AS category_name,  f.rental_duration,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.rental_duration) OVER (PARTITION BY fc.category_id) AS quartile_25,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY f.rental_duration) OVER (PARTITION BY fc.category_id) AS quartile_50,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.rental_duration) OVER (PARTITION BY fc.category_id) AS quartile_75
    FROM film f
    JOIN
        film_category fc ON f.film_id = fc.film_id
    JOIN
        category c ON fc.category_id = c.category_id),
RentalLengthCategory AS ( SELECT
        film_id, category_id,  category_name,  rental_duration, quartile_25, quartile_50,  quartile_75,
        CASE
            WHEN rental_duration <= quartile_25 THEN 1
            WHEN rental_duration <= quartile_50 THEN 2
            WHEN rental_duration <= quartile_75 THEN 3
            ELSE 4
        END AS standard_quartile
    FROM
        MovieRentalDuration)
SELECT category_name AS "Category",
    standard_quartile AS "Standard Quartile",
    COUNT(*) AS "Count"
FROM  RentalLengthCategory
GROUP BY category_name, standard_quartile
ORDER BY category_name, standard_quartile;






4
WITH MovieAvgDuration AS (
    SELECT
        fc.category_id,
        f.title AS film_title,
        AVG(f.rental_duration) AS avg_rental_duration
    FROM
        film f
    JOIN
        film_category fc ON f.film_id = fc.film_id
    GROUP BY
        fc.category_id, f.title
),
QuartileValues AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_rental_duration) AS first_quarter,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_rental_duration) AS second_quarter,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_rental_duration) AS third_quarter
    FROM
        MovieAvgDuration
)
SELECT
    m.film_title,
    c.name AS category_name,
    CASE
        WHEN avg_rental_duration <= q.first_quarter THEN 'first_quarter'
        WHEN avg_rental_duration <= q.second_quarter THEN 'second_quarter'
        WHEN avg_rental_duration <= q.third_quarter THEN 'third_quarter'
        ELSE 'final_quarter'
    END AS quartile
FROM
    MovieAvgDuration m
JOIN
    category c ON m.category_id = c.category_id
CROSS JOIN
    QuartileValues q
ORDER BY
    category_name, film_title;


