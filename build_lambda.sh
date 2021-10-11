if [ -fe 'package.zip' ]
then 
    rm 'package.zip'
fi 

CURRENT_DIR=$(pwd)
python3 -m venv venv
source venv/bin/activate && \
pip3 install -r requirements.txt && \
deactivate
cd venv/lib/python3.8/site-packages
zip -r $CURRENT_DIR/temp/package.zip .
cd $CURRENT_DIR/lambda-code
zip -g $CURRENT_DIR/temp/package.zip main.py