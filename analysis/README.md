# Run in separate local terminals to connect to server
```bash
ssh -i path_to_creds.pem ubuntu@ec2-15-188-135-192.eu-west-3.compute.amazonaws.com   
```
ssh -i /Users/pablo/vivid_new/aws/ec2_acc.pem ubuntu@ec2-15-188-135-192.eu-west-3.compute.amazonaws.com   

### Start jupyter notebook inside the analysis server
log to your user name
```
cd /home/pablo/forest_mind/analysis/static_dri 
jupyter notebook
```
# On another terminal on the server
```
jupyter notebook list # get token
```
get token returned
# Listen to jupyter on local port 8881 - run locally
```
ssh -i path_to_ec2_acc.pem -f -N -L 8881:localhost:8888 ubuntu@ec2-15-188-135-192.eu-west-3.compute.amazonaws.com  
```
Open localhost:8881 on the browser and enter the token 

# Build DRI
The DRI is build using 3 jupyter notebooks:
* data_formatting.ipynb: shapes all features and processes raw EWS
* model_selection.ipynb: trains dozens of different models fine tuning the hyper-parameter on the test set
* dri_outputs.ipynb: runs the predict dataset through the selected models and rasterise the outputs
