param(
    [int]$Numerator = 1,
    [int]$Denominator = 4,
    [int]$Base = 5,
    [int]$NumDigits = 20
)

# --- Validation ---
# The p-adic expansion is for p-adic *integers* when p does not divide the denominator.
# This algorithm assumes we're finding the p-adic integer representation.
if ($Denominator % $Base -eq 0) {
    Write-Error "The base (p=$Base) divides the denominator ($Denominator)."
    Write-Error "This fraction does not have a p-adic integer representation."
    Write-Error "Its p-adic representation would have negative powers of $Base (a 'decimal point')."
    return
}

# --- Algorithm ---
# We want to find x = A/B, such that B*x = A.
# Let x = d_0 + d_1*p + d_2*p^2 + ...
#
# Step 0:
# B * d_0 === A (mod p)
# Find d_0. Let A_1 = (A - B*d_0) / p
#
# Step 1:
# B * (d_1 + d_2*p + ...) = A_1
# B * d_1 === A_1 (mod p)
# Find d_1. Let A_2 = (A_1 - B*d_1) / p
#
# Repeat this process.
# We use $current_a to store A, A_1, A_2, ...

Write-Host "Calculating $Numerator / $Denominator in base $Base (...d_n ... d_1 d_0):"

# Use [int64] to avoid potential overflow with intermediate calculations
[int64]$current_a = $Numerator
[int64]$b = $Denominator
[int64]$p = $Base

# Array to store the digits d_0, d_1, d_2, ...
$digits = @()

try {
    for ($i = 0; $i -lt $NumDigits; $i++) {
        
        $found_d = -1
        
        # Find the digit $d (0 <= d < p) that satisfies (B * d) === A_i (mod p)
        # This is equivalent to (B*d - A_i) being divisible by p.
        for ($d = 0; $d -lt $p; $d++) {
            if ( ($b * $d - $current_a) % $p -eq 0 ) {
                $found_d = $d
                break
            }
        }

        if ($found_d -eq -1) {
            # This should not happen if the validation check passed
            throw "Failed to find a digit. Check inputs."
        }

        # Add the digit to our list
        $digits += $found_d
        
        # Calculate the next 'A' value: A_{i+1} = (A_i - B*d_i) / p
        # This division is guaranteed to be an integer.
        $current_a = ($current_a - $b * $found_d) / $p
    }
}
catch {
    Write-Error $_
    return
}

# --- Format Output ---
# The $digits array currently holds [d_0, d_1, d_2, ... d_n]
# Standard p-adic notation is ...d_n ... d_2 d_1 d_0
# So, we need to reverse the array and join it.

# Clone the array so we don't modify the original (good practice)
$reversed_digits = $digits.Clone()
[array]::Reverse($reversed_digits)

# Join the reversed array of digits into a single string
$representation = $reversed_digits -join ""

# Prepend "..." to indicate it's an infinite expansion to the left
Write-Host "..." -NoNewline
Write-Host $representation