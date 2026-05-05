vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- Plugins
require("lazy").setup({

-- Syntax highlighting
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", 
		config = function()
			require("nvim-treesitter.configs").setup({
				-- ADDED: python, solidity, and r for your research
				ensure_installed = { "svelte", "typescript", "javascript", "html", "css", "bash", "yaml", "python", "solidity", "r" }, 
				highlight = { enable = true }
			})
		end
	},

-- Fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } }, 

--Catppuccin theme to match kitty
	{ 
		"catppuccin/nvim", 
		name = "catppuccin", 
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = {
					treesitter = true,
					telescope = { enabled = true },
					bufferline = true,      -- Makes your tabs match the theme
					native_lsp = { enabled = true },
					vimtex = true,          -- Highlights LaTeX math/environments beautifully
				}
			})
			vim.cmd.colorscheme "catppuccin" -- This actually turns the theme ON
		end
	},

-- Tabs in the same terminal window
	{ 
		"akinsho/bufferline.nvim", 
		version = "*", 
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({})
		end
	},

-- Markdown Preview
{
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = { "markdown" },
  commit = "a923f5fc5ba36a3b17e289dc35dc17f66d0548ee",
  config = function()
    vim.g.mkdp_auto_start = 0       -- don't auto-open browser
    vim.g.mkdp_auto_close = 1       -- close preview when buffer is closed
    vim.g.mkdp_refresh_slow = 0     -- auto-refresh on edit
    vim.g.mkdp_browser = ""         -- leave empty to use system default
    vim.g.mkdp_theme = "light"
  end,
},

-- Latex Preview
{
  "lervag/vimtex",
  lazy = false,
  init = function()
    -- Use Skim on macOS
    vim.g.vimtex_view_method = "skim"

    -- Use latexmk (comes with MacTeX)
    vim.g.vimtex_compiler_method = "latexmk"

    -- Optional: don't auto-open quickfix on warnings
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_compiler_latexmk = {
      out_dir = '.build',
			options = {
				'-xelatex',
				'-shell-escape',
				'-synctex=1',
				'-interaction=nonstopmode',
				'-file-line-error',
			},
    }
  end,
}

})

-- Set keymaps

-- Fuzzy Finder
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)

-- Tabs/Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>")

-- MarkdownPreview
-- 
-- Normal preview (light)
vim.keymap.set("n", "<leader>mp", function()
  vim.g.mkdp_theme = "light"
  vim.cmd("MarkdownPreviewToggle")
end, { desc = "Markdown Preview (light)" })

-- Dark preview
vim.keymap.set("n", "<leader>mpd", function()
  vim.g.mkdp_theme = "dark"
  vim.cmd("MarkdownPreviewToggle")
end, { desc = "Markdown Preview (dark)" })


-- Set line numbers
vim.opt.number = true

-- Enable spellcheck globally
vim.opt.spell = true
vim.opt.spelllang = { "en_us" } 


-- Use the system clipboard for all yank, delete, change, and put operations
vim.opt.clipboard = "unnamedplus"


-- Autosaves when entering normal mode
local function save()
  local buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! write")
  end)
end

vim.api.nvim_create_augroup("AutoSave", {
  clear = true,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    save()
  end,
  pattern = "*",
  group = "AutoSave",
})

if vim.env.TERM:match("kitty") or vim.env.TERM:match("tmux") then
    vim.cmd([[let &t_EI = "\e[2 q"]])  -- Normal: block
    vim.cmd([[let &t_SI = "\e[6 q"]])  -- Insert: steady beam
    vim.cmd([[let &t_SR = "\e[4 q"]])  -- Replace: underline
end

vim.opt.mouse = "a"  -- Enable mouse in all modes

-- Use 2 spaces for tabs and indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2 
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.smarttab = true

vim.o.inccommand = ""
vim.keymap.set("n", "/", "/", { noremap = true })
vim.keymap.set("n", "?", "?", { noremap = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true })

vim.filetype.add({
  extension = {
    svx = 'markdown',
  },
})
