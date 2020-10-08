# Příklady pro kit OMDAZZ (Cyclone IV)

## Počítadlo stisknutí tlačítka s výstupem na displej LED

Používá:

- komponenty [Seg7](../../seg7/seg7.vhd) a [SegMuxNum](../../seg7/segmuxnum.vhd) pro zobrazování čísel 0000-9999 na LED displeji
- komponentu [freqdiv](../../frequency-divider/freqdiv.vhd) pro získání kmitočtu 1 kHz pro buzení displeje
- komponentu [counter4bcd](../../counter/counter4bcd.vhd) pro samotnou funkci čítání
- komponentu [debouncer](../../debouncer/debouncer.vhd) pro ošetření zákmitů tlačítek

Je možné vybrat z více variant, použijte menu `Assignments->Settings->General->Top-level entity`.

Základní varianta je `BCD_counter_button`. Ta ukazuje propojení jednotlivých komponent dohromady. Při každém stisku tlačítka 0 (levé) by měla zvýšit hodnotu počítadla o 1, ale vlivem zákmitů často "přeskočí" několik hodnot najednou.

Druhá varianta je `BCD_counter_button_debouncer_`. Přidává komponentu [debouncer](../../debouncer/debouncer.vhd), která ošetří zákmity a čítač tak počítá vždy reálná stisknutí tlačítka.
