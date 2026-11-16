; extends

; Force ERB-style comments (<%# %>) everywhere in eruby buffers instead of
; letting the built-in treesitter-aware `gc` fall back to the injected
; html (<!-- -->) or ruby (#) commentstring based on cursor context.
((template) @_erb.root (#set! bo.commentstring "<%# %s %>"))
