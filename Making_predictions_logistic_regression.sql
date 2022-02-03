WITH number_of_copies AS (
SELECT f.film_id, COUNT(i.inventory_id) copies_amount
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
GROUP BY film_id),
rental_amount AS (
SELECT f.film_id, COUNT(r.rental_id) rental_amount,
CASE WHEN r.rental_date BETWEEN '2005-05-01' AND '2005-05-30' THEN 1
    ELSE 0 END AS rented_or_not
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY film_id,3),
cte AS (
SELECT DISTINCT i.film_id, i.copies_amount, r.rental_amount, c.name category, f.rating, f.length, f.title
                movie, f.release_year, f.rental_rate, r.rented_or_not
FROM number_of_copies i
LEFT JOIN rental_amount r
ON i.film_id = r.film_id
JOIN film_category fc
ON i.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON i.film_id = f.film_id
JOIN inventory inv
ON i.film_id = inv.film_id
JOIN rental r
ON r.inventory_id = inv.inventory_id),
dataset AS (SELECT RANK() OVER (PARTITION BY film_id ORDER BY rented_or_not desc) AS rnk, film_id, copies_amount,
      rental_amount, category, rating, length, movie, release_year, rental_rate, rented_or_not
FROM cte)
SELECT film_id, copies_amount, rental_amount, category, rating, length, movie, release_year, rental_rate, 
       rented_or_not
FROM dataset
WHERE rnk = 1;
