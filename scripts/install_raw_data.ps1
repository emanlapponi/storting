#### Relies on 7Zip4Powershell ####
# Install-Package 7Zip4Powershell

echo "Downloading data..."
wget http://emanuel.at.ifi.uio.no:/storting_raw.tar -OutFile storting_raw.tar

echo "Unpacking..."
Expand-7Zip -ArchiveFileName storting_raw.tar -TargetPath .\data

echo "Deleting tarball"
Remove-Item .\storting_raw.tar

echo "Done"