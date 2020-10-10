# [Data, čipy, procesory](https://datacipy.cz/)

Příklady ke knize a další konstrukce s doporučenými kity. Vše pod otevřenými licencemi MIT, pokud není uvedeno jinak (např. CC nebo GPL). Software třetí strany (adresář 3rd) může mít vlastní licenční podmínky.

**Po klonování proveďte `git submodule update --init --recursive`, aby byly stažené i knihovny třetích stran.**

## Doporučené nástroje

- [GHDL](https://github.com/ghdl/ghdl)
- [GTKWave]()
  (Pro MacOS využijte [tento návod](https://ughe.github.io/2018/11/06/gtkwave-osx) na spouštění gtkwave z příkazové řádky.)

## Komponenty abecedně

#### [Adder](./adder)

_kapitola 2.4 a další_

- sčítačka
- 4bitová sčítačka
- 16b sčítačka
- full adder

#### [Alpha-decoder](./alpha-decoder)

_kapitola 2.7_

- jednoduchý kombinační obvod

#### [ALU](./alu)

_kapitola 14.2_

- aritmeticko-logická jednotka (16bit)

#### [Analog](./analog)

_kapitola 4.1_

- PWM převodník
- Sigma-delta převodník

#### [Barrel](./barrel)

_kapitola 14.2_

- Rychlý shifter (16bit) až o 16 pozic

#### [BCD](./bcd)

- Převodník 8bitových binárních čísel na desítkovou BCD reprezentaci (10 bitů)

#### [Counter](./counter)

_kapitola 6.1_

- Čítač 4bit
- Čítač 16bit
- Desítkový čítač 4bit

#### [Debouncer](./debouncer)

_kapitola 13.5_

- odstraňovač zákmitů

#### [FF](./ff)

_kapitola 2.12_

- klopné obvody D, D+R+S
- registry 8bit, 16bit7

#### [Frequency divider](./frequency-divider)

- generická dělička frekvence

#### [Hello: blink](./hello-blink)

- Blikání LEDkou (kompletní projekt pro Quartus)

#### [I2C_m](./i2c_m) , [I2C_s](./i2c_s)

_kapitola 13.7_

- Master a slave pro I2C

#### [MHRD](./MHRD)

_kapitola 14_

- Implementace mikroprocesoru MHRD

#### [MUX](./mux)

- Multiplexor

#### [Resolved](./resolved)

_kapitola 2.9_

- Rozdíl mezi resolved a unresolved signály

#### [Seg7](./seg7)

- Komponenta pro ovládání sedmisegmentového displeje:
  - dekodér BCD-na-7seg
  - multiplexor (pro buzení použít frekvence okolo 1 kHz)

#### [Sirena](./sirena)

_kapitola 4.2_

- Generujeme zvuk

#### [SPI](./spi)

_kapitola 13.6_

- SPI master

#### [Start-Blink](./start-blink)

- První příklad s blikáním LEDkou

#### [UART Tx](./uart-tx)

_kapitola 7.2_

- Sériový vysílač (UART)

#### [UART Rx](./uart-rx)

_kapitola 8.2_

- Sériový přijímač (UART)

#### [Utility](./utility)

- Užitečné funkce pro VHDL

## Komponenty podle kapitol

#### kapitola 2.4 a další

[Adder](./adder)

- sčítačka
- 4bitová sčítačka
- 16b sčítačka
- full adder

####kapitola 2.7
[Alpha-decoder](./alpha-decoder)

- jednoduchý kombinační obvod

#### kapitola 2.9

[Resolved](./resolved)

- Rozdíl mezi resolved a unresolved signály

#### kapitola 2.12

[FF](./ff)

- klopné obvody D, D+R+S
- registry 8bit, 16bit7

#### kapitola 4.1

[Analog](./analog)

- PWM převodník
- Sigma-delta převodník

#### kapitola 4.2

[Siréna](./sirena)

- Generujeme zvuk

#### kapitola 6.1

[Counter](./counter)

- Čítač 4bit
- Čítač 16bit
- Desítkový čítač 4bit (BCD)

#### kapitola 7.2

[UART Tx](./uart-tx)

- Sériový vysílač (UART)

#### kapitola 8.2

[UART Rx](./uart-rx)

- Sériový přijímač (UART)

#### kapitola 13.5

[Debouncer](./debouncer)

- odstraňovač zákmitů

#### kapitola 13.6

[SPI](./spi)

- SPI master

#### kapitola 13.7

[I2C_m](./i2c_m)
[I2C_s](./i2c_s)

- Master a slave pro I2C

#### kapitola 14

[MHRD](./MHRD)

- Implementace mikroprocesoru MHRD

#### kapitola 14.2

[Barrel](./barrel)

- Rychlý shifter (16bit) až o 16 pozic

#### kapitola 14.2

[ALU](./alu)

- aritmeticko-logická jednotka (16bit)

## Knihovny

**Po klonování proveďte `git submodule update --init --recursive`, aby byly stažené i knihovny třetích stran.**

- [3rd/light8080](./3rd/light8080) - VHDL procesor 8080
- [3rd/T80](./3rd/T80) - VHDL procesor Z80
- [3rd/uart16450](./3rd/uart16450) - VHDL sériové rozhraní 16450
- [3rd/zxgate](./3rd/zxgate) - ZX Spectrum ve VHDL
- [acia6850](./acia6850) - VHDL sériový interface 6850
- [pia8255](./pia8255) - VHDL verze paralelního obvodu 8255
- [3rd/GrantSearle](./3rd/GrantSearle) - VHDL konstrukce [Granta Searla](https://searle.wales)

## Konstrukce

- [Alpha](./alpha) - OMEN Alpha ve VHDL pro EP2C5 (_kapitola 11_)
- [OMDAZZ Alpha](./omdazz-alpha) - OMEN Alpha s procesorem Z80 a pamětí SDRAM pro kit OMDAZZ
- [OMDAZZ Zeta](./omdazz-zeta) - OMEN Zeta s procesorem Z80, pamětí SDRAM a grafickým rozhraním pro kit OMDAZZ

## Příklady

- [OMDAZZ](./omdazz-priklady) - Příklady pro kit OMDAZZ (Cyclone IV)
  - [Počítadlo BCD](./omdazz-priklady/BCD_counter) - jednoduché počítadlo (7segmentový displej LED, komponenty counter4BCD, 7seg, divider)
  - [Počítadlo stisknutí tlačítka](./omdazz-priklady/BCD_counter_button) - rozšíření příkladu výše. Ukazuje zapojení tlačítka a rozdíl mezi ošetřenými a neošetřenými zákmity
