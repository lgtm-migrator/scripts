# 2021-08-21
# Injabie3
#
# Description:
# PowerShell OpenVPN .ovpn profile generator

$clientName = $args[0]

# Fetch settings
."$PSScriptRoot\generate-ovpn-settings.ps1"

if ($clientName -eq $null) {
    echo "Please type in a client name and try again."
    exit
}


########################################
# Copy common files across all clients #
########################################
echo "Generating .ovpn profile for client $clientName"
echo "Copying template..."
cat $template > $outputFile

echo "Copying common TLS auth key..."
echo "<tls-auth>" >> $outputFile
cat $commonTaFile >> $outputFile
echo "</tls-auth>" >> $outputFile

echo "Copying common CA..."
echo "<ca>" >> $outputFile
cat $commonCAFile >> $outputFile
echo "</ca>" >> $outputFile

##############################
# Copy client-specific files #
##############################
echo "Copying client certificate..."
echo "<cert>" >> $outputFile
cat $($clientName + ".crt") >> $outputFile
echo "</cert>" >> $outputFile

echo "Meshing client private key..."
echo "<key>" >> $outputFile
cat $($clientName + ".key") >> $outputFile
echo "</key>" >> $outputFile

echo "Adding remote server..."
echo "remote $($serverAddress) $($serverPort)" >> $outputFile

# Rewrite with UTF-8 to fix issues on Unix-based systems
[IO.File]::WriteAllLines($outputFile, $(cat $outputFile))

echo "Generated $outputFile!"
