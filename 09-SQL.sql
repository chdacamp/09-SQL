
#1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name FROM sakila.actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

ALTER TABLE sakila.actor ADD COLUMN actor_name VARCHAR(50);
UPDATE sakila.actor SET actor_name = CONCAT(first_name,', ',last_name);
SELECT actor_name FROM sakila.actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM sakila.actor
	WHERE first_name = 'Joe';
#2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id, first_name, last_name FROM sakila.actor
	WHERE last_name LIKE '%GEN%';
    
#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT actor_id, first_name, last_name FROM sakila.actor
	WHERE last_name LIKE '%LI%'
    ORDER BY last_name ASC, first_name ASC;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM sakila.country
	WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


#3a. You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB 
#(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).


ALTER TABLE sakila.actor ADD COLUMN description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE sakila.actor DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) FROM sakila.actor
    GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) FROM sakila.actor
	GROUP BY last_name
	HAVING COUNT(last_name) > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE sakila.actor
	SET first_name = 'HARPO', actor_name = 'HARPO, WILLIAMS'
	WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'; 

SELECT * FROM sakila.actor
	WHERE last_name = 'WILLIAMS';
    
#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
#It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE sakila.actor
	SET first_name = 'GROUCHO', actor_name = 'GROUCHO, WILLIAMS'
	WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS'; 

SELECT * FROM sakila.actor
	WHERE last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE SCHEMA sakila;
CREATE TABLE sakila.address 
    (address_id smallint auto_increment,
    address varchar(50),
    address2 varchar(50),
    district varchar(20),
    city_id smallint(5),
    postal_code varchar(10),
    phone varchar(20),
    location geometry,
    last_update timestamp on update CURRENT_TIMESTAMP);

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
#Use the tables staff and address:

USE sakila;
SELECT staff.address_id, staff.first_name, staff.last_name, address.address
	FROM sakila.staff
    JOIN address ON staff.address_id=address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.

SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount), payment.payment_date
	FROM sakila.staff
    INNER JOIN payment ON staff.staff_id=payment.staff_id 
		AND payment.payment_date BETWEEN '2005-08-01' AND '2005-08-31'
    GROUP BY staff.staff_id, staff.first_name;

#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.

SELECT film.film_id, film.title, COUNT(film_actor.actor_id)
	FROM sakila.film
    INNER JOIN film_actor ON film.film_id=film_actor.film_id 
    GROUP BY film.film_id;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.film_id, film.title, COUNT(inventory.inventory_id)
	FROM sakila.film
    INNER JOIN sakila.inventory ON film.film_id=inventory.film_id 
    GROUP BY film.film_id
        HAVING title = 'Hunchback Impossible';

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
#List the customers alphabetically by last name:

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount)
	FROM customer
    INNER JOIN payment ON customer.customer_id = payment.customer_id
    GROUP BY customer.customer_id
    ORDER BY last_name ASC, first_name ASC;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT film.film_id, film.title FROM sakila.film
	WHERE title LIKE 'K%' OR title LIKE 'Q%';

#7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT actor.actor_name FROM sakila.actor
	WHERE actor_id IN (SELECT actor_id FROM film_actor
							WHERE film_id IN (SELECT film_id FROM film
												WHERE title = 'Alone Trip'));
						

#7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email, country.country
	FROM customer
    JOIN address ON address.address_id = customer.address_id
    JOIN city ON city.city_id = address.city_id
    JOIN country ON country.country_id = city.country_id
        WHERE country = 'Canada';
	
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT film.title, category.name FROM film
	JOIN film_category ON film_category.film_id = film.film_id
    JOIN category ON category.category_id = film_category.category_id
		WHERE category.name = 'family';

#7e. Display the most frequently rented movies in descending order.

SELECT film.title, COUNT(rental.rental_id) FROM film
	JOIN inventory ON inventory.film_id = film.film_id
    JOIN rental ON rental.inventory_id = inventory.inventory_id
    GROUP BY film.title
    ORDER BY COUNT(rental.rental_id) DESC;
    

#7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, sum(payment.amount) FROM sakila.store
	JOIN inventory ON inventory.store_id = store.store_id
    JOIN rental ON rental.inventory_id = inventory.inventory_id
    JOIN payment ON payment.rental_id = rental.rental_id
		GROUP BY store.store_id;

#7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country FROM store
	JOIN address ON address.address_id = store.address_id
    JOIN city ON city.city_id = address.city_id
    JOIN country ON country.country_id = city.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, SUM(payment.amount) FROM film
	JOIN film_category ON film_category.film_id = film.film_id
    JOIN category ON category.category_id = film_category.category_id
    JOIN inventory ON inventory.film_id = film.film_id
    JOIN rental ON rental.inventory_id = inventory.inventory_id
    JOIN payment ON payment.rental_id = rental.rental_id
		GROUP BY category.name
        ORDER BY SUM(payment.amount) DESC
        LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
#by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top5_by_genre AS

SELECT category.name, SUM(payment.amount) FROM film
	JOIN film_category ON film_category.film_id = film.film_id
    JOIN category ON category.category_id = film_category.category_id
    JOIN inventory ON inventory.film_id = film.film_id
    JOIN rental ON rental.inventory_id = inventory.inventory_id
    JOIN payment ON payment.rental_id = rental.rental_id
		GROUP BY category.name
        ORDER BY SUM(payment.amount) DESC
        LIMIT 5;

#8b. How would you display the view that you created in 8a?

SELECT * FROM top5_by_genre;


#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top5_by_genre;
