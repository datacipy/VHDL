# Příklady pro kit OMDAZZ (Cyclone IV)

## Čtení teploty z čidla LM75 s výstupem na displej LED

Používá:

- komponenty [Seg7](../../seg7/seg7.vhd) a [SegMuxNum](../../seg7/segmuxnum.vhd) pro zobrazování čísel 0000-9999 na LED displeji
- komponentu [freqdiv](../../frequency-divider/freqdiv.vhd) pro získání kmitočtu 1 kHz pro buzení displeje
- komponentu [lm75](../../lm75/pmod_temp_sensor_tcn75a.vhd) pro komunikaci s čidlem LM75
- komponentu [i2c Master](../../i2c_m/i2cm.vhd) pro řízení sběrnice I2C

Zapojení používá komponentu [lm75](../../lm75/pmod_temp_sensor_tcn75a.vhd) pro komunikaci s čidlem po sběrnici I2C. Čte teplotu s přesností 9 bitů (8 bitů celá část, jeden bit desetinná) a zobrazuje ji na displeji. Pro jednoduchost ji zobrazuje hexadecimálně a bez desetinné tečky, tedy např. `01A0` znamená teplotu 26 °C (1Ah = 26).

Námět pro rozšíření: dekodér binárního čísla na desítkovou reprezentaci (BCD).
