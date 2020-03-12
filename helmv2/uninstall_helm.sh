# Helm - Cleanup files
echo "### ### cleanup files ### ###"
rm $(helm home) -rf
rm ca.* tiller.* helm.*
