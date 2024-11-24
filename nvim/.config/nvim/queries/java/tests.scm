; Find JUnit5 tests.
; TODO also get @ParameterizedTest
; TODO also get class name so I can construct "-Dtest=classname#testname"
(method_declaration ; [271, 2] - [282, 3]
  (modifiers ; [271, 2] - [271, 7]
    (marker_annotation ; [271, 2] - [271, 7]
      name: (identifier) @annotation (#match? @annotation "^Test$"))) ; [271, 3] - [271, 7]
  type: (void_type) ; [272, 2] - [272, 6]
  name: (identifier) @name) @test ; [272, 7] - [272, 77]
