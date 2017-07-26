
using mongo.INoSqlConnector from propath.
using mongo.MongoConnector from propath.
using mongo.UpdateCreator.
using Progress.Json.ObjectModel.JsonObject.

define variable connector as INoSqlConnector no-undo.
define variable creator as UpdateCreator no-undo.
define variable json as JsonObject no-undo.

define variable lastseqid as int64 no-undo.
define variable tmpSeqId as int64 no-undo.
define variable jsonString as character no-undo.
define variable lockfile as character no-undo.
define variable jsonContent as longchar no-undo.

define stream logfile.

{mongo/ttchangeseq.i}


define temp-table ttupdate no-undo
  field changeseqid as int64
  field person_id as int64
  index person_id as primary unique person_id
  index changeseqid changeseqid
  .

function logthis returns logical (logmessage as character):
  put stream logfile unformatted substitute('[&1] &2~n', iso-date(now), logmessage).
  return true.
end.

output stream logfile to value('./../log/dispatcher.log') unbuffered append.
  
lockfile = './../dispatcher.lock'.

logthis('starting...').
if (search(lockfile) <> ?) then do:
  logthis('dispatcher.lock found, shutting down').
  return.
end.

output to value(lockfile).
put unformatted iso-date(now).
output close.  

connector = new MongoConnector().
creator = new UpdateCreator().

connector:GetLastChangeSeqId(output table ttchangeseq).
for each ttchangeseq:
  logthis(substitute('last processed changeseqid &1: &2', ttchangeseq.tablename, ttchangeseq.changeseqid)).
end.

if (not session:batch-mode) then do:
  
  message 'Proceed?'
    view-as alert-box question
    buttons yes-no
    update proceed as logical
    .
  
  if (not proceed) then
    return.

end.

logthis('started').
  
repeat:
  
  // send changes to person
  find ttchangeseq where ttchangeseq.tablename = "cdc_person" no-error.
  lastseqid = (if (available(ttchangeseq)) then ttchangeseq.changeseqid else 0).
  for each cdc_person where cdc_person._Change-Sequence > lastseqid no-lock by cdc_person._Change-Sequence:
    run createUpdate("cdc_person", cdc_person.id, cdc_person._Change-Sequence).
  end.
  
  // send changes to address
  find ttchangeseq where ttchangeseq.tablename = "cdc_address" no-error.
  lastseqid = (if (available(ttchangeseq)) then ttchangeseq.changeseqid else 0).
  for each cdc_address where cdc_address._Change-Sequence > lastseqid no-lock by cdc_address._Change-Sequence:
    run createUpdate("cdc_address", cdc_address.person_id, cdc_address._Change-Sequence).
  end.
  
  lastseqid = tmpSeqId.
  
  for each ttupdate by ttupdate.changeseqid:
    logthis('ttupdate found').
    json = creator:CreateUpdate(ttupdate.person_id, ttupdate.changeseqid).
    connector:SendUpdate(json).
    json:Write(input-output jsonContent, false).
    logthis('update: ' + string(jsonContent)). 
  end.
  
  empty temp-table ttupdate.
  
  if (can-find(first ttchangeseq where ttchangeseq.updated = true)) then do:
    logthis('updating changeseq~'s').
    connector:UpdateChangeSeqid(table ttchangeseq).
    logthis('finished updating changeseq~'s').
    for each ttchangeseq:
      ttchangeseq.updated = false.  
    end.
  end.
  
  // leave after 1 iteration when ran interactive
  if (not session:batch-mode) then
    leave.
  else do:
    process events.
    if (search(lockfile) = ?) then do:
      logthis('dispatcher.lock not found').
      logthis('shutting down').
      leave.
    end.      
  end.
  
  pause 1.
  
end.  // repeat

catch err1 as Progress.Lang.Error :
  logthis(substitute('ERROR: &1', err1:GetMessage(1))).  
  logthis(replace(err1:CallStack, ",", "~n")).
  os-delete value(search(lockfile)). 
end catch.

finally:
  logthis('dispatcher closed').
  if (not session:batch-mode) then do:
    os-delete value(search(lockfile)).
  end. 
  output stream logfile close.   
end.

procedure createUpdate:
  
  define input parameter tablename as character no-undo.
  define input parameter personId as int64 no-undo.
  define input parameter changeseqid as int64 no-undo.
  
  
  run recordUpdateseqid(tablename, changeseqid).
  
  find first ttupdate where ttupdate.person_id = personId no-error.
  if (not available(ttupdate)) then do:
    create ttupdate.
    ttupdate.person_id = personId.
  end.
  
  if (ttupdate.changeseqid < changeseqid) then
    ttupdate.changeseqid = changeseqid.
  
  if (tmpSeqId < changeseqid) then
    tmpSeqId = changeseqid.
  
end procedure.

procedure recordUpdateseqid:
  
  define input parameter tablename as character no-undo.
  define input parameter changeseqid as int64 no-undo.
  
  find ttchangeseq where ttchangeseq.tablename = tablename.
  if (ttchangeseq.changeseqid < changeseqid) then 
    assign
      ttchangeseq.changeseqid = changeseqid
      ttchangeseq.updated = true
      .
    
end procedure.