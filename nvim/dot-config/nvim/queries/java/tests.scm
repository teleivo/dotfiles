; Find JUnit5 tests.
(class_declaration
     name: (identifier) @class
     body: (class_body
      (method_declaration
        (modifiers
          (marker_annotation
            name: (identifier) @annotation (#any-of? @annotation "Test" "ParameterizedTest")))
        name: (identifier) @name) @test
))
