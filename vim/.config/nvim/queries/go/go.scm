;; Write queries here (see $VIMRUNTIME/queries/ for examples).
;; Move cursor to a capture ("@foo") to highlight matches in the source buffer.
;; Completion for grammar nodes is available (:help compl-omni)

; https://pkg.go.dev/testing#pkg-overview
(function_declaration
  name: (identifier) @name (#match? @name "^Test[A-Z].*")) @test

(function_declaration
  name: (identifier) @name (#match? @name "^Test[A-Z].*")
  parameters: (parameter_list
                (parameter_declaration
      type: (pointer_type
              (
               (qualified_type
                  package: (package_identifier) @package
                  type: (type_identifier) @identifier)
           (#eq? @package "testing")
           (#eq? @identifier "T"))
             )))) @testB
