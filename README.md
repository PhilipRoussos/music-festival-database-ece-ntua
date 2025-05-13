# Music Festival Management System
Project for the "Databases" course in ECE NTUA.

In this project we were asked to implement a database for a fictional music festival, more details about the exercise in [docs/exercise.pdf](https://github.com/PhilipRoussos/music-festival-database-ece-ntua/blob/main/docs/exercise.pdf). The process involved designing the [ER](https://github.com/PhilipRoussos/music-festival-database-ece-ntua/blob/main/diagrams/er.pdf) and Relational Diagrams, implementing the SQL schema and procedures, in MySQL, generating fake data using a Python script with the assistance of AI and lastly implementing and executing the queries.

## Contributors
- [Palaiokostas Marios](https://github.com/Mariosplk)
- [Panagiotarakos Alexios](https://github.com/alexp9904)
- [Roussos Philippos](https://github.com/PhilipRoussos)

## Installation
- Ensure that you have MySQL Server installed on you system.
- Run the following:
```
  mysql -h "server-name" -u "your_username" -p "your_password"
```
Inside the MySQL command-line interface, run the following in order:
```
  source /path/to/your/database/festival_database.sql
  source /path/to/your/database/procedures.sql
  source /path/to/your/database/indices.sql
  source /path/to/your/database/fake_data.sql
```
## License
This project uses the [MIT License](https://github.com/PhilipRoussos/music-festival-database-ece-ntua/edit/main/LICENSE)
