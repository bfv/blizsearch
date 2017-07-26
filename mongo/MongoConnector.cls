 
 /*------------------------------------------------------------------------
    File        : MongoConnector
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jul 19 06:56:37 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using mongo.INoSqlConnector.
using OpenEdge.Net.HTTP.IHttpRequest.
using OpenEdge.Net.HTTP.IHttpResponse.
using OpenEdge.Net.HTTP.RequestBuilder.
using OpenEdge.Net.HTTP.ClientBuilder.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.JsonConstruct from propath.

block-level on error undo, throw.

class mongo.MongoConnector implements INoSqlConnector: 
  
  {mongo/ttchangeseq.i}
  
  method public void GetLastChangeSeqId(output table ttchangeseq):
    
    define variable request as IHttpRequest no-undo.
    define variable response as IHttpResponse no-undo.
    define variable changeseqs as JsonArray no-undo.
    define variable currentChangeseq as JsonObject no-undo.
    
    define variable lastSequenceId as integer no-undo.
    define variable i as integer no-undo.
    

    // first get the last change sequence id which is stored in Mongo
    request = RequestBuilder:Get('http://localhost:4220/changeseqid'):AcceptJson():Request.
    response = ClientBuilder:Build():Client:Execute(request).
    
    empty temp-table ttchangeseq.
    
    define variable lc1 as longchar no-undo.
    changeseqs = cast(response:Entity, 'Progress.Json.ObjectModel.JsonObject'):GetJsonArray("changeseqid").
    
    do i = 1 to changeseqs:Length:
      currentChangeseq = changeseqs:GetJsonObject(i).
      create ttchangeseq.
      assign 
        ttchangeseq.tablename = currentChangeseq:GetCharacter('table')
        ttchangeseq.changeseqid = currentChangeseq:GetInt64('changeseqid')
        .
    end.    
    
  end method.
  

  method public void SendBatch(personArray as JsonArray):
    
    SendUpdate(personArray).
    
    finally:
      delete object personArray no-error.
    end.
    
  end method.
  
  
  method public void SendUpdate(updateJson as JsonObject):
    SendJsonUpdate(updateJson).
  end method.
  
  
  method public void SendUpdate(updateJson as JsonArray):
    SendJsonUpdate(updateJson).
  end method.
  
  method private void SendJsonUpdate(updateJson as JsonConstruct):
    
    define variable request as IHttpRequest no-undo.
    define variable response as IHttpResponse no-undo.
    define variable tmpObject as JsonObject no-undo.
    
    if (updateJson:GetClass():TypeName = 'Progress.Json.ObjectModel.JsonObject') then
      request = RequestBuilder:Post('http://localhost:4220/update', updateJson):ContentType('application/json'):Request.  
    else do:
      // wrap the JsonArray into a JsonObject
      tmpObject = new JsonObject().
      tmpObject:Add('array', cast(updateJson, Progress.Json.ObjectModel.JsonArray)).      
      request = RequestBuilder:Post('http://localhost:4220/bulkcreate', tmpObject):ContentType('application/json'):Request.
    end.
    
    response = ClientBuilder:Build():Client:Execute(request).
        
    finally:
      delete object tmpObject no-error. 
      delete object request no-error.
      delete object response no-error.
    end.
    
  end method.
  
  method public void UpdateChangeSeqid(table ttchangeseq):
    
    define variable request as IHttpRequest no-undo.
    define variable response as IHttpResponse no-undo.
    define variable json as JsonObject no-undo.
    define variable lc1 as longchar no-undo.
    
    for each ttchangeseq where ttchangeseq.updated:
      
      json = createUpdateJson(ttchangeseq.tablename, ttchangeseq.changeseqid).
      //JsonHelper:ShowContent(json).
      request = RequestBuilder:Post('http://localhost:4220/changeseq', json):ContentType('application/json'):Request.
      response = ClientBuilder:Build():Client:Execute(request).
    end.
    
  end method.
  
  
  method private JsonObject createUpdateJson(tablename as character, changeseqid as int64):
    
    define variable json as JsonObject no-undo.
    
    json = new JsonObject().
    json:Add('table', tablename).
    json:Add('changeseqid', changeseqid).
    
    return json.
    
  end method.
  
end class.