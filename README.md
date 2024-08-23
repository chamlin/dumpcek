# dumpcek

## purpose

On the tin it says:  dumpček

## setup

Set up an app server with the modules pointing to the src directory on disk.

## data

### parse

'Standard' parsed dump files, Olav's or https://github.com/chamlin/dumparse .  

### load

Load the files, use a collection

~/mlcp/mlcp-10.0.6.2/bin/mlcp.sh  import -host localhost -port 8000 -username admin -password admin -input_file_path ./Support-Dump/ -mode local -output_collections timestamp-check -database dumpcek

## use

Go to /dumpcek.xqy on the app server.

Select your collection and submit.  This will be remembered but can be reset.

Select your report and submit.
