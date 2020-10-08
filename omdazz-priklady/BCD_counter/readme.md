# Příklady pro kit OMDAZZ (Cyclone IV)

## Jednoduché počítadlo s výstupem na displej LED

Používá:

- komponenty [Seg7](../../seg7/seg7.vhd) a [SegMuxNum](../../seg7/segmuxnum.vhd) pro zobrazování čísel 0000-9999 na LED displeji
- komponentu [freqdiv](../../frequency-divider/freqdiv.vhd) pro získání kmitočtu 1 kHz pro buzení displeje
- komponentu [freqdiv](../../frequency-divider/freqdiv.vhd) pro získání pomalého kmitočtu (1 Hz) pro počítání
- komponentu [counter4bcd](../../counter/counter4bcd.vhd) pro samotnou funkci čítání

Je možné vybrat z více variant, použijte menu `Assignments->Settings->General->Top-level entity`.

Základní varianta je `BCD_counter`. Ta ukazuje propojení jednotlivých komponent dohromady. Čítá od 0 do 9, při přechodu 9->1 zobrazí na místě desítek symbol "1".

Druhá varianta je `BCD_counter16`. Používá čtyři BCD čítače v zapojení _ripple_carry_, takže výstup přenosu z jednotek je zapojen jako hodinový vstup desítek atd. Vytvoří se tak 16bitový BCD čítač, který čítá hodnoty 0000 až 9999.

Doplňková varianta je `Binary_counter16`. Používá komponentu `counter16b` a počítá, podobně jako předchozí varianta, šestnáctibitově, ale nikoli v BCD, ale binárně. Hodnoty jsou tedy 0000 až FFFF.
