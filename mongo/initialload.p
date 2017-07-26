using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using mongo.UpdateCreator from propath.
using mongo.MongoConnector from propath.

define variable personArray as JsonArray no-undo.

define variable updateJson as JsonObject no-undo.
define variable i as integer no-undo.
define variable count as integer no-undo.
define variable batchsize as integer no-undo.
define variable creator as UpdateCreator no-undo.
define variable connector as MongoConnector no-undo.

creator = new UpdateCreator().
connector = new MongoConnector().

output to value("./../log/upload.log") unbuffered.

batchsize = 256.
personArray = new JsonArray().
for each person no-lock:
  
  if (i mod 10000 = 0) then
    put unformatted substitute("[&1] &2~n", iso-date(now), i).     
  
  updateJson = creator:CreatePersonJson(person.id).
  personArray:Add(updateJson).

  // create batches because one HTTP call for each person is way to slow
  i = i + 1.
  if (i mod batchsize = 0) then do:      
    connector:SendBatch(personArray).
    personArray = new JsonArray().
  end.
     
end.  // for each person

// send last batch    
if (i mod batchsize <> 0) then
  connector:SendBatch(personArray).

output close.
