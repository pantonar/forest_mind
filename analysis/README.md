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



# For Windows users
### First time user
Download PuTTY and WinSCP.

Convert private SSH key using PuTTYgen: 
1. Save private SSH key on notepad.  
2. Open Puttygen. Press Load. Browse, select the private SSH key you want to convert. Save private key. Specify name of private key. 
3. Now have a private key saved under the .ppk extension.

### Instructions to open jupyter notebook on another terminal on the server. 
1. Open Putty. Type ubuntu@ec2-15-188-135-192.eu-west-3.compute.amazonaws.com in host name. Port value is 22. Connection type is SSH. Press Open. Easier to save this session to load it later.   
2. Go to Connection (left pane), choose Auth, Browse, look for your .ppk private key file, Open. Can no longer use this Putty window. 
3. Open another Putty window. Load the right saved session or type the IP address from above. Go to SSH, Tunnels. Enter 8881 in source port and localhost:8888 in Destination. Then Open. 
4. In the new window, type jupyter notebook list. Copy the token. Use it to enter localhost:8881 on your browser. 

### Moving files between local and server using WinSCP
1. Open WinSCP. Type ubuntu@ec2-15-188-135-192.eu-west-3.compute.amazonaws.com in host name. Port value is 22. SFTP. Username is ubunto. Do not type password. Go to Advanced Settings, SSH, Authentication. Browse and select the private SSH key. 
2. Should arrive in /home. Need to go up one level to get to /mnt/uksa-storage. 




