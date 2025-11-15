* Always double-check before you consider something is done. For example when you say a command
works, try and see if it works.
  * use validate commands or the like to prevent syntactic issues
  * use dry-run commands to see the effects your change would have

## Style

### Markdown

* add one newline before and after headings
* format paragraphs using max width of 100
* use `*` instead of `-` for lists

## Tools

* use `uv` in python projects

### DOT (Graphviz)

* use `dot -Tplain` for testing DOT syntax (faster than `-Tsvg`, no graphical output needed)
* use `echo 'input' | go run cmd/tokens/main.go` to test the scanner tokenization

## TODO Management

**IMPORTANT: When completing TODO items in files, remove them entirely from the file. Do not add
checkboxes, strikethrough text, or mark them as done. Simply delete the completed items.**
