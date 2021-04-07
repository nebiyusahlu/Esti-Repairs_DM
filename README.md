# Esti-Repairs_DM

This project was for a car repair company. They have repair shops all over the United States and I was tasked to create a data warehouse from a transaction database. 

The Transaction database contained thireen tables with multiple columns in each table and thousands of rows as well.

![Transaction data base diagram](https://user-images.githubusercontent.com/82042663/113946462-1e291c80-97ce-11eb-8b16-c4e88c58b6e7.PNG)


After a discussion with the stakeholders and analyzing the whole data, I decided to create a data mart in a star schema model and with five dimension tables and one fact table.


![Star Schema DM](https://user-images.githubusercontent.com/82042663/113946435-12d5f100-97ce-11eb-9fa5-4b4120981e66.PNG)

I created a stored procedure to:-

-   create schemas 'Dim' and 'Fact'
-   transform some of the data using a 'Case' Statment
-   convert data types of some of the data into decimal using 'Convert' 
-   'Unpivot' some of the columns into rows to make the fact table tall rather than wide       
-   Dump the transformed data into a 'Temporary Table' after 'Left Joining' all 12 tables with the largest table ( transaction table) in the database
-   create Fact and Dimension tables
-   load data into some of the 'Dimension' tables using 'Type 2' SCD (Slowly Changing Dimension)
-   load data into 'Fact' table.


Note- The Store Procedure can be found on the first page named ' SP_Esti_DM '

