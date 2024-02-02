### DB design:
This design approach uses entity-relationship modelling to model the entities in the data. We have 4 categories:
* Symbol data which uniquely identifies stocks
* Reporting month, which reports the numerical data for a stock inside the Nifty50 index
* Numerical data for each (stock, reporting_month)
* String data (company name, industry). The relationship between industry to name is one-to-many

### Transactions:

The table is normalised to 3NF and meets the conditions: atomic values, no partial dependencies, no transitive dependencies. The string table and the duration table have symbol as the key, the numeric data as symbol and report_date as the key. 

I created this table design while keeping in mind the loading process of the data. Stock_values table is updated every month and unless changes to ticker are made, there should be no scenario where data needs to be changed. Company table contains the string data, this table is updated only when a new stock which is not in the database is added.

Company table is seperated from stock_values table to reduce data redundancy because they have a one to many relationship.

Index_duration table is a seperate table to company table even though both have (symbol) as the primary key. The reason for this is because the addition of the duration_months value requires calculation at every update ```end_date - start_date```, there are additional risks of wrong data being added and needing to be cleaned, so it is seperated from company table. In the event the data in index_duration must be cleaned to improve data_integrity, we do not need to touch the company table.

![My Image](/images/image1.png "Schema")

### Constraints and optimisations:

There are primary and foreign key constraints on the tables as per the diagrams.

Indexes and paritiions are added to the tables to facilitate better performance of the queries, while keeping in mind the overhead incurred whenever the tables are updated. Index added on (industry) to speed up grouping operations on indusstry. I considered added an index on (symbol, date) to speed up all time based queries (SMA, high, low, correlation), but the overhead is too high. I added a ranged partition by year on the reporting_date column, to improve performance when querying by year.

### Database loading:
The dataset contains missing rows in name and industry columns. It also contans rows where the industry value is in the name column. 

![My Image](/images/image2.png "Database")

When populating the company table, we must take care to ensure clean data is loaded. The initial scan will drop rows with missing data, lowercase the name and industry, extract the unique values. And if there are still multiple strings to choose from to fill Name and Industry, the value that matches the first two characters of the Ticker will be used for the name column.

![My Image](/images/image3.png "Database")


