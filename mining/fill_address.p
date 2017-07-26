
{mining/ttcity.i}

define temp-table ttcitizen no-undo
  field order as integer
  field citynumber as integer
  index pk as primary unique order
  index citynumber citynumber
  .

define buffer b-ttcitizen for ttcitizen.
define variable i as integer no-undo.
define variable maxno as integer no-undo.
define variable currentPos as integer no-undo.

output to value("./../log/addressload.log") unbuffered.
put unformatted substitute("[&1] start~n", iso-date(now)).
put unformatted substitute("[&1] read temp-table~n", iso-date(now)).

temp-table ttcity:read-json("file", "./data/inwoners.json").

put unformatted substitute("[&1] read array~n", iso-date(now)).
temp-table ttcitizen:read-json("file", "./data/ttcitizen.json").

put unformatted substitute("[&1] generate addresses, to go:~n", iso-date(now)).

maxno = 14412054.
for each person no-lock:
  
  currentPos = random(1, maxno).  // we pick random from the array
  find ttcitizen where ttcitizen.order = currentPos.
  find ttcity where ttcity.order = ttcitizen.citynumber.
  
  do transaction on error undo, leave:
    
    find address where address.person_id = person.id exclusive-lock no-error.
    if (not available(address)) then do:
      create address.
      assign 
        address.id = next-value(id)
        address.person_id = person.id
        .
    end.
      
    address.city = ttcity.city.
    
    find current address no-lock.
    
  end.
    
  // fill the gap at currentPos  
  find last b-ttcitizen use-index pk.
  ttcitizen.citynumber = b-ttcitizen.citynumber.
  delete b-ttcitizen.
  
  maxno = maxno - 1.
  
  if (maxno mod 100000 = 0) then
    put unformatted substitute("[&1] &2~n", iso-date(now), string(maxno)).
    
end.

output close.

message "done" view-as alert-box.



/*maxno = 14412054.                             */
/*do i = 1 to maxno:                            */
/*                                              */
/*  find first ttcity where ttcity.citizens > 0.*/
/*  create ttcitizen.                           */
/*  assign                                      */
/*    ttcitizen.order = i                       */
/*    ttcitizen.citynumber = ttcity.order       */
/*    ttcity.citizens = ttcity.citizens - 1     */
/*    .                                         */
/*                                              */
/*end.                                          */

/*put unformatted substitute("[&1] write array~n", iso-date(now)). */
/*temp-table ttcitizen:write-json("file", "./data/ttcitizen.json").*/

/*i = 0.*/
/*for each ttcitizen where citynumber = 76:*/
/*  i = i + 1.                           */
/*end.                                   */
/*message i.                             */
/*                                       */
/*return.                                */
