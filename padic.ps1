param(
    [int64]$Numerator = 1,
    [int64]$Denominator = 4,
    [int64]$Base = 5,
    [int64]$NumDigits = 20
)

for ($i = 0; $i -lt $NumDigits; $i++) {
    
    $found_d = -1

    for ($d = 0; $d -lt $Base; $d++) {
        if ( ($Denominator * $d - $Numerator) % $Base -eq 0 ) {
            $found_d = $d
            break
        }
    }
    write-host $found_d -NoNewline
    $Numerator = ($Numerator - $Denominator * $found_d) / $Base
}
