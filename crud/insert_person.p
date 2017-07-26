
do transaction on error undo, leave:
  
  create person.
  assign 
    person.id = next-value(id)
    person.lastname = 'test_jansen'
    .
  
  create address.
  assign
    address.id = next-value(id)
    address.person_id = person.id
    address.city = 'Amsterdam'
    .

end.
message 'done' view-as alert-box.