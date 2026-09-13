-- Ustawienie Spacji jako klawisza Leader (musi być zrobione przed wtyczkami)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

-- Zapisywanie i zamykanie
keymap('n', '<leader>w', '<cmd>w<CR>', { desc = 'Zapisz plik' })
keymap('n', '<leader>q', '<cmd>wq<CR>', { desc = 'Zapisz i zamknij okno' })
keymap('n', '<leader>d', '<cmd>q<CR>', { desc = 'Zamknij okno' }) -- :q odmówi przy niezapisanych zmianach; :q! zostaje jako świadome polecenie

-- Odznaczenie podświetlenia wyszukiwania
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Usuń podświetlenie szukania' })

-- Szybkie wyjście z trybu Insert
keymap('i', 'jk', '<Esc>', { desc = 'Wyjdź do trybu Normal' })

-- Nawigacja między podzielonymi oknami
keymap('n', '<C-h>', '<C-w>h', { desc = 'Okno po lewej' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Okno na dole' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Okno na górze' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Okno po prawej' })

-- Zmiana rozmiaru okien
keymap('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Wyższe okno' })
keymap('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Niższe okno' })
keymap('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Węższe okno' })
keymap('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Szersze okno' })

-- Bufory
keymap('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Poprzedni bufor' })
keymap('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Następny bufor' })
keymap('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Zamknij bufor' })

-- Przesuwanie zaznaczonych linii w trybie Visual
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Przesuń zaznaczenie w dół' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Przesuń zaznaczenie w górę' })

-- Przewijanie o pół ekranu z kursorem na środku
keymap('n', '<C-d>', '<C-d>zz')
keymap('n', '<C-u>', '<C-u>zz')
keymap('n', 'n', 'nzzzv', { desc = 'Następny wynik (wyśrodkowany)' })
keymap('n', 'N', 'Nzzzv', { desc = 'Poprzedni wynik (wyśrodkowany)' })

-- Łączenie linii bez przesuwania kursora
keymap('n', 'J', 'mzJ`z')

-- Wklejanie na zaznaczenie bez nadpisywania rejestru
keymap('x', '<leader>p', '"_dP', { desc = 'Wklej bez nadpisania schowka' })

-- Wcięcia w Visual bez utraty zaznaczenia
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')

-- Przełączniki
keymap('n', '<leader>tn', function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = 'Relatywne numery linii' })
keymap('n', '<leader>tw', function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = 'Zawijanie linii' })

-- Drzewo plików
keymap('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Drzewo plików' })

-- Usuwanie całej zawartości pliku
keymap('n', '<leader>ca', ':%d<CR>', { desc = 'Wyczyść całą zawartość pliku' })

-- Git (gitsigns) – require w funkcji, bo wtyczka ładuje się później
keymap('n', ']c', function() require('gitsigns').nav_hunk('next') end, { desc = 'Następna zmiana' })
keymap('n', '[c', function() require('gitsigns').nav_hunk('prev') end, { desc = 'Poprzednia zmiana' })
keymap('n', '<leader>gp', function() require('gitsigns').preview_hunk() end, { desc = 'Podgląd zmiany' })
keymap('n', '<leader>gr', function() require('gitsigns').reset_hunk() end, { desc = 'Cofnij zmianę' })
keymap('n', '<leader>gs', function() require('gitsigns').stage_hunk() end, { desc = 'Stage zmiany' })
keymap('n', '<leader>gb', function() require('gitsigns').blame_line({ full = true }) end, { desc = 'Blame linii' })

-- LSP – tylko dla buforów z podłączonym serwerem
-- Neovim 0.11 ma już wbudowane: grn (rename), gra (code action), grr (referencje),
-- gri (implementacja), gO (symbole), K (dokumentacja), [d / ]d (diagnostyka)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local map = function(mode, lhs, rhs, desc)
      keymap(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end
    map('n', 'gd', vim.lsp.buf.definition, 'Idź do definicji')
    map('n', '<leader>ld', vim.diagnostic.open_float, 'Pokaż diagnostykę')
    map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Formatuj plik')
    map('n', '<leader>lr', vim.lsp.buf.rename, 'Zmień nazwę')
    map('n', '<leader>la', vim.lsp.buf.code_action, 'Akcja kodu')
  end,
})

-- 'i' na ostatnim znaku linii wstawia za nim (jak 'a')
keymap('n', 'i', function()
  return vim.fn.col('.') == vim.fn.col('$') - 1 and 'a' or 'i'
end, { expr = true, desc = 'Insert (na końcu linii: append)' })
