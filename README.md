# nvim-config

Konfiguracja Neovima do pracy na serwerach Ubuntu 24.04 — edycja skryptów bash, YAML, docker-compose, Pythona i Lua. Jeden skrypt stawia edytor, wtyczki i serwery LSP na czystej maszynie.

## Wymagania

- Ubuntu 24.04 (na innych dystrybucjach zadziała po ręcznym zainstalowaniu zależności)
- Terminal z fontem Nerd Font — bez niego ikony w Neo-tree i lualine będą wyświetlane jako puste kwadraty
- Dostęp do `sudo` (skrypt instaluje pakiety i snapa)

Skrypt sam instaluje: Neovim 0.12 (snap), `git`, `curl`, `unzip`, `build-essential` (kompilacja parserów Treesitter), `npm` (serwery LSP), `ripgrep` (Telescope live_grep).

## Instalacja

Na nowym serwerze:

```bash
curl -fsSL https://raw.githubusercontent.com/FranciszekRyszka/neovim-config/refs/heads/main/install.sh | bash
```

Skrypt sklonuje repo do `~/.config/nvim` (istniejąca konfiguracja trafia do `~/.config/nvim.bak.<timestamp>`) i zainstaluje wtyczki w wersjach z `lazy-lock.json`. Serwery LSP dociągnie Mason przy pierwszym uruchomieniu `nvim` — postęp widać w `:Mason`.

Ręcznie:

```bash
git clone https://github.com/FranciszekRyszka/nvim-config.git ~/.config/nvim
bash ~/.config/nvim/install.sh
```

## Aktualizacja

Na serwerze, który już ma konfigurację:

```bash
bash ~/.config/nvim/install.sh
```

Skrypt jest idempotentny: zrobi `git pull` i `:Lazy restore`, pomijając to, co już jest zainstalowane.

Aktualizacja wtyczek do nowszych wersji — na jednej maszynie `:Lazy update`, potem commit `lazy-lock.json`. Pozostałe serwery dostaną te same wersje przy następnym uruchomieniu skryptu.

## Edycja plików systemowych

`sudo nvim` nie użyje tej konfiguracji, bo sudo podmienia `HOME` na `/root`. Zamiast tego:

```bash
echo 'export SUDO_EDITOR=nvim' >> ~/.bashrc
sudoedit /etc/plik
```

Edytor działa jako zwykły użytkownik z pełną konfiguracją, a plik jest zapisywany z uprawnieniami roota.

## Struktura

```
init.lua          opcje edytora, bootstrap lazy.nvim, lista wtyczek
lua/keymaps.lua   klawisz Leader i wszystkie skróty
lazy-lock.json    przypięte wersje wtyczek
install.sh        bootstrap / aktualizacja
```

## Wtyczki

| Wtyczka | Rola |
|---|---|
| lazy.nvim | menedżer wtyczek |
| catppuccin | motyw (wariant `mocha`) |
| which-key | podpowiedzi skrótów po naciśnięciu Leader |
| lualine | pasek statusu |
| telescope | wyszukiwanie plików, tekstu, buforów, symboli |
| neo-tree | drzewo plików (`<leader>e`) |
| nvim-treesitter | podświetlanie składni i wcięcia |
| gitsigns | znaczniki zmian git w marginesie |
| indent-blankline | pionowe linie wcięć |
| nvim-surround | zmiana nawiasów/cudzysłowów wokół tekstu |
| nvim-autopairs | domykanie nawiasów |
| blink.cmp | uzupełnianie kodu |
| nvim-lspconfig + mason | LSP: `bashls`, `yamlls`, `lua_ls`, `pyright` |

## Najważniejsze skróty

Leader to `Spacja`. Pełna lista pojawia się po naciśnięciu `Spacji` (which-key) lub w `lua/keymaps.lua`.

| Skrót | Działanie |
|---|---|
| `jk` (insert) | wyjście do trybu Normal |
| `<leader>w` / `<leader>q` / `<leader>d` | zapisz / zapisz i zamknij / zamknij |
| `<leader>e` | drzewo plików |
| `<leader>ff` / `fg` / `fb` / `fr` | pliki / tekst / bufory / ostatnie pliki |
| `Ctrl+h/j/k/l` | nawigacja między oknami |
| `Shift+h` / `Shift+l` | poprzedni / następny bufor |
| `J` / `K` (visual) | przesuń zaznaczone linie |
| `gd` / `K` | definicja / dokumentacja (LSP) |
| `<leader>ld` / `lf` / `lr` / `la` | diagnostyka / formatuj / zmień nazwę / akcja kodu |
| `]c` / `[c` / `<leader>gp` / `gb` | następna / poprzednia zmiana git, podgląd, blame |
| `<leader>tn` / `tw` | przełącz relatywne numery / zawijanie linii |
