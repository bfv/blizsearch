
define variable inputline as character no-undo.
define variable totaal as integer no-undo.
define variable order as integer no-undo.

input from ./data/inwoners.txt.

{mining/ttcity.i}

define variable factor as decimal no-undo.

factor = 14412054 / 17081507.  // factor for number of names in db

repeat: 
  import unformatted inputline.
  
  order = order + 1.
  
  create ttcity.
  assign 
    ttcity.order = order
    ttcity.city = entry(1, inputline, "~t")
    ttcity.citizens = integer(factor * integer(entry(2, inputline, "~t")))
    .
    
  totaal = totaal + ttcity.citizens.
  
end.

temp-table ttcity:write-json("file", "./data/inwoners.json", true).

message "done: " totaal view-as alert-box.