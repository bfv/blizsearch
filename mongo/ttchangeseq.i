
define {&accessor} temp-table ttchangeseq no-undo
  field tablename as character
  field changeseqid as int64
  field updated as logical
  index pk as primary unique tablename changeseqid
  index tablename as unique tablename
  .
  

  