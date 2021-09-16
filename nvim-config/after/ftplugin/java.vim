lua require('my.java').start_jdt()
" lua require('jdtls').start_or_attach({cmd = {'java-lsp'}})
" lua require('jdtls').start_or_attach({cmd = {'java-lsp', '/home/user/workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')}, root_dir = require('jdtls.setup').find_root({'gradle.build', 'pom.xml'})})
