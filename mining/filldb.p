

define variable i as integer no-undo.
define variable j as integer no-undo.

define variable count as integer no-undo.
define variable currentLetter as character no-undo.
define variable personCount as integer no-undo.

{mining/ttname.i}

function logthis returns logical(logMessage as character):
  output to ./creating.log append.
  put unformatted "[" + iso-date(now) + "]  " + logMessage + "~n".
  output close.
end function.

do i = 0 to 25:
  
  currentLetter = chr(asc('a') + i).
  temp-table ttname:read-json("file", "./data/ttname-" + currentLetter + ".json").
  
  for each ttname:
    
    // lastname show's up at multiple letters (at the first letter of each component of the name)     
    if (substring(ttname.lastname, 1, 1) = currentLetter) then do:
      do j = 1 to ttname.namecount:
        
        do transaction on error undo, leave:
          create person.
          assign 
            person.id = next-value(id)
            person.lastname = ttname.lastname
            personCount = personCount + 1
            .
          release person.  
        end.  // transaction
      
      end.
      
      logthis(ttname.lastname + ": " + string(ttname.namecount)).
      
    end.
    
  end.
    
  empty temp-table ttname.
  
end.

message substitute("done: &1 person created", personCount) view-as alert-box.
