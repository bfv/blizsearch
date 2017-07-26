
define buffer b-person for person.

function removeGenaamd returns character (lastname as character) forward.

for each person exclusive-lock:
  
  person.lastname = replace(person.lastname, "(y)", "").
  person.lastname = trim(person.lastname).
  if (person.lastname matches "*genaamd*" or person.lastname matches "*bijgenaamd*") then
    person.lastname = removeGenaamd(person.lastname).
  
end.

function removeGenaamd returns character (lastname as character):
  
end function.
