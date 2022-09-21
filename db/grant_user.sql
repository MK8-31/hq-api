GRANT ALL PRIVILEGES ON *.* TO 'user_name'@'%';
FLUSH PRIVILEGES

/* docker-compose exec db mysql -u root -p -e"$(cat db/grant_user.sql)" */
/* docker-compose exec db mysql -u user_name -p -e"show grants;" */
