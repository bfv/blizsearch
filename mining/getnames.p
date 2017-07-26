
using mining.PagesFetcher from propath.

define variable fetcher as PagesFetcher no-undo.


fetcher = new PagesFetcher().
fetcher:Execute().

message "done" view-as alert-box.