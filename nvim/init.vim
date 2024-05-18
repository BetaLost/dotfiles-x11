" PLUGINS - Vim Plug
call plug#begin()

Plug 'nvim-tree/nvim-web-devicons' " Colored icons
Plug 'akinsho/bufferline.nvim', { 'tag': '*' } " File tabs

Plug 'nvim-lualine/lualine.nvim' " Statusline

Plug 'windwp/nvim-autopairs' " Autopair
Plug 'alvan/vim-closetag' " Auto close HTML tags

Plug 'MunifTanjim/nui.nvim' " UI Library, Neotree dependency
Plug 'nvim-lua/plenary.nvim' " Neotree dependency
Plug 'nvim-neo-tree/neo-tree.nvim' " Neotree file explorer

Plug 'lilydjwg/colorizer' " Visualize hex colors
Plug 'loctvl842/monokai-pro.nvim' " Colorscheme
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " Syntax highlighting

" Autocomplete
Plug 'neovim/nvim-lspconfig' " Quickstart configs for Nvim LSP
Plug 'onsails/lspkind.nvim' " Vscode-like pictograms
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

call plug#end()

" GENERAL CONFIGURATION
filetype indent on
syntax on
set number
set ts=4 sw=4
set signcolumn=no
set pastetoggle=<F2>
set ttimeoutlen=0
set completeopt=menu,menuone,noselect
set pumheight=10

" KEYBINDS

" NeoTree
nnoremap <C-t> :Neotree toggle<CR>

" Copy to system clipboard 
nmap <C-A-c> "+y$

" Manage Tabs
map <A-,> <Cmd>bnext<CR>
map <A-.> <Cmd>bprev<CR>
map <A-c> <Cmd>bdelete<CR>

" Indent visualization
let g:rust_recommended_style = 0
set list listchars=tab:\│\ 
hi NonText ctermfg=239
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

" Restore terminal cursor on exit
autocmd VimLeave * set guicursor=a:ver25-blinkon1

lua <<EOF
	-- Colorscheme
	require("monokai-pro").setup({
		filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
	})
	vim.cmd([[colorscheme monokai-pro]])
	
	-- File tabs
	require("bufferline").setup({options = {
		separator_style = "slant",
		indicator = {
			style = "none",
		},
		buffer_close_icon = '',
		close_icon = '',
		modified_icon = '●',
		left_trunc_marker = '',
		right_trunc_marker = '',
		numbers = "ordinal",
		diagnostics = "nvim_lsp",
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_close_icon = true,
		persist_buffer_sort = true,
		enforce_regular_tabs = true,
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and "" or ""
			return icon .. " " .. count
		end
	}})
	
	-- Statusline
	require('lualine').setup({
		options = {
			theme = 'monokai-pro',
			section_separators = { left = '', right = '' },
			disabled_filetypes = { -- Recommended filetypes to disable winbar
				winbar = { 'gitcommit', 'neo-tree', 'toggleterm', 'fugitive' },
			},
		},
		winbar = winbar,
		inactive_winbar = winbar,
	})

	-- Setup File Explorer
	require("neo-tree").setup({
		close_if_last_window = true,
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
	
	-- Setup Autocomplete
	local lspkind = require('lspkind')
	local cmp = require("cmp")
	cmp.setup({
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		
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
	
	local capabilities = require('cmp_nvim_lsp').default_capabilities()
	
	-- Python
	require("lspconfig")["pyright"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}
	
	-- Javascript
	require("lspconfig")["tsserver"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}
	
	-- Rust
	require("lspconfig")["rust_analyzer"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}
	
	-- C/C++
	require("lspconfig")["clangd"].setup {
		capabilities = capabilities,
		on_attach = on_attach
	}
	
	-- Lua
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
	
	-- Close Pairs
	require("nvim-autopairs").setup({})
	local cmp_autopairs = require('nvim-autopairs.completion.cmp')
	cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
EOF
