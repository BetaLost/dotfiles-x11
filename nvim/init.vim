" Vim Plug
call plug#begin()

" Icons
Plug 'nvim-tree/nvim-web-devicons'

" File Tabs
Plug 'romgrk/barbar.nvim'

" Statusline
Plug 'SmiteshP/nvim-navic'
Plug 'nvim-lualine/lualine.nvim'

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
Plug 'AlphaTechnolog/pywal.nvim', { 'as': 'pywal' }
Plug 'lilydjwg/colorizer'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Autocomplete
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind.nvim'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
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
set pumheight=10

" Color Scheme
colorscheme pywal

" NeoTree
nnoremap <C-t> :Neotree toggle<CR>

" Switch Tabs
map <A-,> <Cmd>BufferPrevious<CR>
map <A-.> <Cmd>BufferNext<CR>
map <A-1> <Cmd>BufferGoto 1<CR>
map <A-2> <Cmd>BufferGoto 2<CR>
map <A-3> <Cmd>BufferGoto 3<CR>
map <A-4> <Cmd>BufferGoto 4<CR>
map <A-5> <Cmd>BufferGoto 5<CR>
map <A-6> <Cmd>BufferGoto 6<CR>
map <A-7> <Cmd>BufferGoto 7<CR>
map <A-8> <Cmd>BufferGoto 8<CR>
map <A-9> <Cmd>BufferGoto 9<CR>
map <A-c> <Cmd>BufferClose<CR>

" Build System
autocmd FileType python map <C-b> :w<CR>:!clear && python3 % && clear<CR>
autocmd FileType rust map <C-b> :w<CR>:!clear && cargo run<CR>

" Visualize Indent
set list listchars=tab:\│\ 
hi NonText ctermfg=239
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

lua <<EOF
	-- Tabs
	require("bufferline").setup()
	
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
		},
		filesystem = {
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_gitignored = false,
			}
		}
	})

	-- Statusline
	local navic = require('nvim-navic')
	navic.setup({
		separator = "  "
	})
	
	local winbar = {
		lualine_a = {},
		lualine_b = {
			{
				'filename',
				icon = '',
				padding = { left = 4 }
			},
		},
		lualine_c = {
			{
				navic.get_location,
				icon = "",
				cond = navic.is_available,
			},
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {}
	}
	
	require('lualine').setup({
		options = {
			theme = 'pywal-nvim',
			icons_enabled = true,
			disabled_filetypes = { -- Recommended filetypes to disable winbar
				winbar = { 'gitcommit', 'neo-tree', 'toggleterm', 'fugitive' },
			},
		},
		winbar = winbar,
		inactive_winbar = winbar,
	})

	local on_attach = function(client, bufnr)
		if client.server_capabilities.documentSymbolProvider then
			navic.attach(client, bufnr)
		end
	end

	-- Setup Autocomplete
	local lspkind = require('lspkind')
	local cmp = require("cmp")
	cmp.setup({
		--window = {
		--	completion = cmp.config.window.bordered(),
		--	documentation = cmp.config.window.bordered(),
		--},

		formatting = {
			format = lspkind.cmp_format({
				mode = 'symbol_text',
				maxwidth = 50,
				ellipsis_char = '...',
			})
		},

		snippet = {
			expand = function(args)
				vim.fn["vsnip#anonymous"](args.body)
			end
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
				{ name = "vsnip" },
				{ name = 'nvim_lsp_signature_help' }
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
		capabilities = capabilities,
		on_attach = on_attach
	}

	require("lspconfig")["tsserver"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}

	require("lspconfig")["rust_analyzer"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}

	require("lspconfig")["clangd"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}

	require("lspconfig")["lua_ls"].setup {
		capabilities = capabilities,
		on_attach = on_attach,
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
	cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

	-- Syntax Highlighting
	require('nvim-treesitter.configs').setup {
		ensure_installed = { "c", "lua", "rust", "python" },
		sync_install = false,
		auto_install = true,
		ignore_install = {},

		highlight = {
			enable = true,
			disable = {},
			additional_vim_regex_highlighting = false
		},
	}
EOF
