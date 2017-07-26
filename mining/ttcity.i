define temp-table ttcity no-undo
  field order as integer
  field city as character
  field citizens as integer
  index pk as primary unique order
  index citizens citizens
  .
