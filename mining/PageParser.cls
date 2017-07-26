 
 /*------------------------------------------------------------------------
    File        : PageParser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jul 12 11:39:46 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using mining.PagesFetcher from propath.

block-level on error undo, throw.

class mining.PageParser: 
  
  {mining/tturl.i &accessor=private}
  {mining/ttname.i &accessor=private}
  
  define private variable pageContent as longchar no-undo.
  define variable fetcher as PagesFetcher no-undo.
  
  
  constructor public PageParser(fetcher as PagesFetcher, pageString as longchar):
    this-object:pageContent = pageString.
    this-object:fetcher = fetcher.
  end.
  
  method public void GetUrlsOnPage(output table tturl):
    
    define variable offset as integer no-undo init 1.
    define variable lineEndPosition as integer no-undo.
    
    define variable pageline as character no-undo.
    
    offset = index(pageContent, "[<a href=", offset).
    do while (offset > 1):
      
      lineEndPosition = index(pageContent, "&nbsp", offset).
      
      if ((lineEndPosition - offset) <= 0) then
        return.
        
      pageline = string(substring(pageContent, offset, lineEndPosition - offset)).
      pageline = substring(pageline, index(pageline, "~"") + 1).
      pageline = substring(pageline, 1, index(pageline, "~"") - 1).
      
      create tturl.
      tturl.pageurl = pageline.
      
      offset = index(pageContent, "[<a href=", lineEndPosition).
      
    end.
    
  end method.
  
  method public void GetNamesOnPage(output table ttname):
    
    define variable offset as integer no-undo.
    define variable pageline as character no-undo.
    define variable completeTr as character no-undo.
    define variable lineEnd as integer no-undo.
    define variable i as integer no-undo.
    
    offset = index(pageContent, "<table id=~"hitlist~">").
    offset = index(pageContent, "<th>", offset).
    offset = index(pageContent, "<tr>", offset).    
    
    do while (offset > 0):
      
      lineEnd = index(pageContent, "~n", offset).
      pageline = trim(substring(pageContent, offset, lineEnd - offset)).
      pageline = replace(pageline, "~t", "").
      
      completeTr = completeTr + pageline.
      
      if (pageline = "</tr>") then do:
        parseNameInfo(completeTr).
        completeTr = "".
      end.     
      else if (pageline = "</table>") then do:
        return. 
      end.
      
      offset = lineEnd + 1.
      
    end.
    
  end method.
  
  
  method private void parseNameInfo(nameInfo as character): 
    
    define variable offset as integer no-undo init 1.
    define variable lastname as character no-undo.
    define variable amount as character no-undo.
    define variable tdEnd as integer no-undo.
    define variable currentTd as character no-undo.
    define variable content as character no-undo.
    define variable closePos as integer no-undo.
    define variable tdHasClass as logical no-undo.
    
    
    
    nameInfo = replace(nameInfo, "<tr>", "").
    nameInfo = replace(nameInfo, "</tr>", "").
    
    offset = index(nameInfo, "<td>").
    do while (offset > 0):
      
      tdEnd = index(nameInfo, "</td>", offset).
      currentTd = substring(nameInfo, offset, tdEnd - offset + 5).
      
      closePos = index(nameInfo, ">", offset).
      content = substring(nameInfo, closePos + 1, tdEnd - closePos - 1).
      
      if (index(currentTd, "class=") > 0) then
        amount = content.
      else if (content > "" and not content matches "*href=*" and not content begins "<!--") then
        lastname = content. 
      
      if (lastname > "" and amount > "") then
        leave.
        
      offset = index(nameInfo, "<td", tdEnd).
      if (index(nameInfo, "<!--") < offset) then 
        leave.
       
    end.
    
    fetcher:AddName(lastname, amount).
      
  end method.
  
end class.