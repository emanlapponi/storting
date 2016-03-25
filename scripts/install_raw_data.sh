echo 'downloading...'
wget http://emanuel.at.ifi.uio.no:/storting_raw.tar;
echo 'unpacking...'
tar xf storting_raw.tar;
mv stortinget.no/ data/
echo 'deleting tarball...'
rm storting_raw.tar
echo 'done!'
