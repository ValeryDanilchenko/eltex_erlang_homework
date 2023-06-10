-record(keylist_element,{
    key     :: atom(),
    value   :: atom() | string(),
    comment :: atom() | string(), 
    owner   :: pid()
}).