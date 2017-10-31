define variable t1 as int64 no-undo.
define variable t2 as int64 no-undo.
define variable i as integer no-undo.

t1 = etime(false).
for each address where address.city = "Amsterdam" no-lock,
   first person where person.id = address.person_id
                  and person.lastname = "Jansen" no-lock:
  i = i + 1.
end.

/*for each person where person.lastname = "Jansen" no-lock,*/
/*   first address where address.person_id = person.id     */
/*                  and address.city = "Amsterdam" no-lock:*/
/*  i = i + 1.                                             */
/*end.                                                     */

t2 = etime(false).

message string(t2 - t1, ">>,>>9") + "ms , #=" + string(i) view-as alert-box.
