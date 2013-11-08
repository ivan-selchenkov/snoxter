$.support.uploadProgress = ( -> 
    r = window.XMLHttpRequest && new window.XMLHttpRequest() || ''
    'onprogress' of r
)()
