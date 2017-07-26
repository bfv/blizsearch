 
 /*------------------------------------------------------------------------
    File        : PageFetcher
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jul 12 11:05:37 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.Net.HTTP.RequestBuilder from propath.
using OpenEdge.Net.HTTP.IHttpRequest from propath.
using OpenEdge.Net.HTTP.ClientBuilder from propath.
using OpenEdge.Net.HTTP.IHttpResponse from propath.
using OpenEdge.Core.Collections.ObjectStack from propath.
using Progress.Lang.Object from propath.
using OpenEdge.Core.String from propath.
using mining.PageParser from propath.
using mining.PagesFetcher from propath.

block-level on error undo, throw.

class mining.PagesFetcher: 
  
  {mining/tturl.i &accessor=private}
  {mining/ttname.i &accessor=private}
  
  define private variable baseUrl as character no-undo.
  define variable nameCount as integer no-undo.
  
    
  constructor public PagesFetcher():
    baseUrl = "http://www.cbgfamilienamen.nl".
  end.
  
  method public void Execute():
    fetchAll().
  end method.
  
  method private void fetchAll():
    
    define variable i as integer no-undo.
    
    logthis('start').
    do i = 0 to 25:
      
      fetchBeginningWith(chr(asc('a') + i)).
      
      logthis(caps(chr(asc('a') + i)) + " count=" + string(nameCount)).
      
      temp-table ttname:write-json("file", "./data/ttname-" + chr(asc('a') + i) + ".json", true).
      empty temp-table ttname.
      
      nameCount = 0.
    end.
    logthis('end').
    
  end method.
  
  
  method private void fetchBeginningWith(letter as character):
    
    define variable resultString as longchar no-undo.
    define variable parser as PageParser no-undo.
    
    resultString = fetchPage(baseUrl + '/nfb/lijst_namen.php?operator=bw&naam=' + letter).
    parser = new PageParser(this-object, resultString).
    parser:GetUrlsOnPage(output table tturl).
    parser:GetNamesOnPage(output table ttname append).
    
    //temp-table tturl:write-json("file", "c:/tmp/tturl.json", true).
    
    for each tturl:
      resultString = fetchPage(baseUrl + tturl.pageurl).
      parser = new PageParser(this-object, resultString).
      parser:GetNamesOnPage(output table ttname append).
      delete tturl.
    end.
    
  end method.
  
  
  method private longchar fetchPage(url as character):
    
    define variable request as IHttpRequest no-undo.
    define variable response as IHttpResponse no-undo.
    define variable responseEntity as Object no-undo.
    
    request = RequestBuilder:Get(url):Request.
    response = ClientBuilder:Build():Client:Execute(request).
    responseEntity = response:Entity.
        
    return cast(responseEntity, String):Value.
    
  end method.

  method private character normalizeLastName(lastname as character):
    
    define variable firstChar as character no-undo.
    define variable moveToEnd as character no-undo.
    
    moveToEnd = "'-".
    firstChar = substring(lastname, 1, 1).
    if (index(moveToEnd, firstChar) > 0) then
      lastname = substring(lastname, 2) + firstChar.
    
    return lastname.
    
  end method.
  
  
  method public void AddName(lastname as character, amount as character):

    define buffer b-ttname for ttname.
    
    do on error undo, leave:
      
      if (lastname > "" and not can-find(first b-ttname where b-ttname.lastname = lastname)) then do:
        lastname = normalizeLastName(lastname).
        create ttname.
        assign 
         ttname.lastname = lastname
         ttname.namecount = (if (amount begins "&") then 1 else integer(amount)).
         .
         
        nameCount = nameCount + 1.
        
      end.
      
      catch err1 as Progress.Lang.Error :
        // do nothing  
      end catch.    
    
    end.
    
  end method.  
  
  method private void logthis(logMessage as character):
    output to ./timing.log append.
    put unformatted "[" + iso-date(now) + "]  " + logMessage + "~n".
    output close.
  end method.
  
end class.