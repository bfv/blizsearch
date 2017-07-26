 
 /*------------------------------------------------------------------------
    File        : UpdateUploader
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Tue Jul 18 10:53:01 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.JsonObject from propath.
using OpenEdge.Net.HTTP.IHttpRequest from propath.
using OpenEdge.Net.HTTP.RequestBuilder from propath.
using OpenEdge.Net.HTTP.HttpClient from propath.
using OpenEdge.Net.HTTP.ClientBuilder from propath.
using OpenEdge.Net.HTTP.IHttpResponse from propath.
using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.JsonConstruct from propath.

block-level on error undo, throw.

class mongo.UpdateCreator: 
    
  method public JsonObject CreateUpdate(personId as int64, changeseqid as int64):
    
    define variable result as JsonObject no-undo.
    define variable personJson as JsonObject no-undo.
    define variable addressJson as JsonObject no-undo.
    
    
    result = new JsonObject().
    result:Add("changeseqid", changeseqid).
    
    personJson = createPersonJson(personId).
    result:Add("info", personJson).
    
    return result.
    
  end method.
  
  
  method public JsonObject CreatePersonJson(personId as int64):
    
    define buffer b-person for person.
    define buffer b-address for address.

    define variable personJson as JsonObject no-undo.
    define variable addressJson as JsonObject no-undo.
    
    find b-person where b-person.id = personId no-lock.
    
    personJson = new JsonObject().
    personJson:Add("id", b-person.id).
    personJson:Add("lastname", b-person.lastname).
    
    for first b-address where b-address.person_id = b-person.id no-lock:
      addressJson = new JsonObject().
      addressJson:Add("city", b-address.city).    
      personJson:Add("address", addressJson).
    end.
    
    return personJson.
        
  end method.
  
  
  method public void InitialLoad(): 
    
    
  end method.
  
  
  
end class.