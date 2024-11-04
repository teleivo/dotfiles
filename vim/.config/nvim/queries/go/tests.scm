; Find tests as defined in https://pkg.go.dev/testing#pkg-overview
(function_declaration
  name: (identifier) @name (#match? @name "^Test[A-Z].*")
  parameters: (parameter_list
    (parameter_declaration
      name: (identifier)
      type: (pointer_type
        (qualified_type
          package: (package_identifier) @package.name
          name: (type_identifier) @package.identifier)
           (#eq? @package.name "testing")
           (#eq? @package.identifier "T"))))) @test
