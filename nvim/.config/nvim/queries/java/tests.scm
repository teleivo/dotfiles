; Find JUnit5 tests.
; TODO also get class name so I can construct "-Dtest=classname#testname"
; (class_declaration
;     name: (identifier) @class
;   )
(method_declaration
  (modifiers
    (marker_annotation
      name: (identifier) @annotation (#any-of? @annotation "Test" "ParameterizedTest")))
  type: (void_type)
  name: (identifier) @name) @test
