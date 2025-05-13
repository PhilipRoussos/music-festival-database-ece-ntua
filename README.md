# Music Festival Management System
Project for the "Databases" course in ECE NTUA.

In this project we were asked to implement a database for a fictonal music festival, more details about the exercise in docs/exercise.pdf. The process involved us designing the ER and Relational Diagrams, implementing the sql schema and procedures, in MySQL, generating the fake data through a Python script with the assistance of AI and lastly implementing the queries.

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
  source /path/to/your/DataBase/festival_database.sql
  source /path/to/your/DataBase/procedures.sql
  source /path/to/your/DataBase/indices.sql
  source /path/to/your/DataBase/fake_data.sql
```
## License
This project uses the [MIT License](https://github.com/PhilipRoussos/music-festival-database-ece-ntua/edit/main/LICENSE)
