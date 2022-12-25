" Vim Plug
call plug#begin()

" Icons
Plug 'nvim-tree/nvim-web-devicons'

" File Tabs
Plug 'romgrk/barbar.nvim'

" HTML Emmet
Plug 'mattn/emmet-vim'

" Close tags
Plug 'windwp/nvim-autopairs'
Plug 'alvan/vim-closetag'

" File Explorer
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'

" Colors
Plug 'dracula/vim', { 'name': 'dracula' }
Plug 'lilydjwg/colorizer'
Plug 'sheerun/vim-polyglot'

" Autocomplete
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

call plug#end()

" General configuration
filetype indent on
syntax on
set number
set ts=4 sw=4
set signcolumn=no
set pastetoggle=<F2>
set ttimeoutlen=0
set completeopt=menu,menuone,noselect

" Color Scheme
colorscheme dracula
hi Normal ctermbg=none
hi NonText ctermbg=none
hi LineNr ctermbg=none

" Nvim Tree
nnoremap <C-t> :Neotree toggle<CR>

" Switch Tabs
nnoremap <C-,> :BufferPrevious<CR>
nnoremap <C-.> :BufferNext<CR>

" Build System
autocmd FileType python map <C-b> :w<CR>:!clear && python3 % && clear<CR>
autocmd FileType rust map <C-b> :w<CR>:!clear && cargo run<CR>

" Visualize Indent
set list listchars=tab:\│\ 
hi NonText ctermfg=239

" Status Bar
let g:currentmode={
       \ 'n': 'NORMAL ',
       \ 'v': 'VISUAL ',
       \ 'V': 'V·LINE ',
       \ "\<C-V>": 'V·BLOCK ',
       \ 'i': 'INSERT ',
       \ 'R': 'REPLACE ',
       \ 'Rv': 'V·REPLACE ',
       \ 'c': 'COMMAND ',
       \}

let g:R_ARROW="\uE0B0"
let g:L_ARROW="\uE0B2"

"Green BG
hi User1 ctermfg=0 ctermbg=49

" Green FG
hi User2 ctermfg=49 ctermbg=0

" Blue BG
hi User3 ctermfg=0 ctermbg=39

" Yellow BG
hi User4 ctermfg=0 ctermbg=220

" Arrow 1
hi User5 ctermfg=49 ctermbg=39

" Arrow 2
hi User6 ctermfg=39 ctermbg=220

" Arrow 3
hi User7 ctermfg=220 ctermbg=0

set laststatus=2
set noshowmode
set statusline=

set statusline+=%1*
set statusline+=\ %{g:currentmode[mode()]}

set statusline+=%5*
set statusline+=%{g:R_ARROW}

set statusline+=%3*\ 
set statusline+=%{&modified?'MODIFIED\ ':'UNMODIFIED\ '}

set statusline+=%6*
set statusline+=%{g:R_ARROW}

set statusline+=%4*\ 
set statusline+=%{&readonly?'LOCKED\ ':'UNLOCKED\ '}

set statusline+=%7*
set statusline+=%{g:R_ARROW}

set statusline+=%2*
set statusline+=\ %F
set statusline+=\%=

set statusline+=%7*
set statusline+=%{g:L_ARROW}

set statusline+=%4*
set statusline+=\ %l/%L\ 

set statusline+=%6*
set statusline+=%{g:L_ARROW}

set statusline+=%3*
set statusline+=\ %{&filetype}\ 

set statusline+=%5*
set statusline+=%{g:L_ARROW}

set statusline+=%1*
set statusline+=\ %{&fenc}\ 

set statusline=%!v:lua.require('statusline').get()

lua <<EOF
	-- Setup File Explorer
	require("neo-tree").setup({
		close_if_last_window = true,
		popup_border_style = "rounded",
		symbols = false,
		default_component_configs = {
			symbols = false
		},
		git_status = {
			symbols = false
		},
		window = {
			width = 25
		}
	})

	-- Setup Autocomplete
	local cmp = require("cmp")
	cmp.setup({
		snippet = {
			expand = function(args)
				vim.fn["vsnip#anonymous"](args.body)
			end
		},

		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},

		mapping = cmp.mapping.preset.insert({
			['<C-b>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete(),
			['<C-e>'] = cmp.mapping.abort(),
			['<Tab>'] = cmp.mapping.confirm({ select = true })
		}),

		sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "vsnip" }
			}, {
				{ name = "buffer" }
		})
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" }
		}
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" }
		}, {
			{ name = "cmdline" }
		})
	})

	local capabilities = require('cmp_nvim_lsp').default_capabilities()
	
	require("lspconfig")["pyright"].setup {
		capabilities = capabilities
	}

	require("lspconfig")["tsserver"].setup {
		capabilities = capabilities
	}

	require("lspconfig")["rust_analyzer"].setup {
		capabilities = capabilities
	}

	require("lspconfig")["clangd"].setup {
		capabilities = capabilities
	}

	require("lspconfig")["sumneko_lua"].setup {
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" }
				}
			}
		}
	}

	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.diagnostic.on_publish_diagnostics, {
			signs = {
				severity_limit = "Hint",
			},
			virtual_text = {
				severity_limit = "Warning",
			},
		}
	)

	-- Close Pairs
	require("nvim-autopairs").setup({})
	local cmp_autopairs = require('nvim-autopairs.completion.cmp')
	cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
	)
EOF
