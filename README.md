Entity-Relationship Diagram for ImportExportTransactions database
The project used the drawio software to establish the relationship between the the dimensions and fact tables.
Below is the ERD for ImportExportTransactions database for the project.

![ERD](Relationship_diagram.drawio.png)




   






   



    


ADD  CONSTRAINT FK_Import_Export_Transaction_Type FOREIGN KEY(Transaction_id)
REFERENCES dim.Transaction_Type(Transaction_id)
Creating Foreign Key on the fact table for the Calendar table
ALTER TABLE f.Import_Export
ADD CONSTRAINT FK_Import_Export_Calendar FOREIGN KEY (pkCalendar)
    REFERENCES dim.Calendar(pkCalendar)
