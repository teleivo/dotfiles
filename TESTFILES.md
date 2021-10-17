# Testfiles

## Objective

I would like to get a list of all test files that reference the currently open
file in telescope. This allows me to get them in the quickfixlist. If there is
only one such file directly open it.

## Plan

* make a request for lsp_document_symbols filter for class or package
* make a request for lsp_references
* filter result to get only tests. start simple by just filtering for test in
  the filenames. This might be different by language.
* put result into telescope. Should I create a plugin for this?
* map it to `gt`? go to test. or is that taken?

## Research

If I am on a symbol lsp_references gives me the list
I would need to find the outermost class for java. I could use treesitter for
this. So I do not have to go to the lsp. I could use the lsp to get the symbols
and then filter for class.
