$infile = ".\bimboIds_2013-06-12_1.txt"
$outfile = "bimboids_si_2013-06-18_2.txt"

Get-Content $infile | %{ $("{0}`t{1}" -f $_, $("{0:X}" -f $si).PadLeft(5, '0')); $si--;} > $outfile