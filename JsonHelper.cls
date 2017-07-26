 
 /*------------------------------------------------------------------------
    File        : JsonHelper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jul 19 12:00:29 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.JsonObject from propath.

block-level on error undo, throw.

class JsonHelper: 
  
  method public static void ShowContent(json as JsonObject):
    define variable lc1 as longchar no-undo.
    json:write(input-output lc1).
    message string(lc1) view-as alert-box.
  end method. 
  
end class.