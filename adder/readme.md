# Sčítačky

### [adder](./adder.vhd)

Neúplná jednobitová sčítačka

### [fulladder](./fulladder.vhd)

Úplná jednobitová sčítačka

### [adder4b](./adder4b.vhd)

Úplná čtyřbitová sčítačka

### [adder16b](./adder16b.vhd)

Úplná 16bitová sčítačka

## Testy

- vyžadují nainstalovaný nástroj [ghdl](https://github.com/ghdl/ghdl/releases). _(Použijte verzi mingw32-mcode, macos-mcode nebo odpovídající linuxovou distribuci)_
- spusťte pomocí `test název-entity`
- entita `xyz` musí být v souboru `xyz.vhd`
- musí existovat testbench `xyz_tb` v souboru `xyz_tb.vhd`
- skript neřeší závislosti; při testování entity fulladder musíte nejprve otestovat entitu adder, která se v ní používá. Po jejím překladu už půjde přeložit fulladder.
