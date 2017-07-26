
/*------------------------------------------------------------------------
    File        : INoSqlConnector
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jul 19 06:55:53 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Json.ObjectModel.JsonObject from propath.

interface mongo.INoSqlConnector:    
  
  {mongo/ttchangeseq.i}
  
  method public void GetLastChangeSeqId(output table ttchangeseq).
  method public void UpdateChangeSeqid(table ttchangeseq).
  method public void SendUpdate(updateJson as JsonObject).
end interface.