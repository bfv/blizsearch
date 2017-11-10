# PUG Challenge CDC to the Max!
These are the sources accompanying my presentation on the EMEA PUG Challenge 2017 in Prague.

High over the archtecture is:

```
MongoDB ◄===== NodeJS ◄===== Dispatcher =====► OE db ◄===== (any client, 4GL, SQL)
                  ▲
                  ║
                  ║

         search client (angular)	
```

## directories

### cdc
In the cdc is the dispatcher. The dispatcher send every update in the cdc table to the node.js backend.

### crud
Some test programs for reading and updating the data in the OE database

### mining
This directory contains the source which I used to create the OE database with 14 million names and addresses. 
With these sources names are extracted from a website which list all (well almost all) last names of people living in the Netherland.

### mongo
These are the OE sources to communicate with Mongo from OE. Uses an implementation of the OE HTTP client.

### search 
This is the node.js project which implements both the search API and the connection to the MongoDB.

### webui
An Angular based website to display the search results.

