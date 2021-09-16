# not really meant for automatic execution, but as a reference
. construct_nwchem_inputs.sh ../0000-structs/*

nwchem_batch.sh LiH.nw

cd LiH
cat LiH.log | python ../export_chem_library_yaml.py > Lih.yaml
cd -

