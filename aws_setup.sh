#!/bin/bash
sudo pip install boto3

echo Please enter a valid IP address. Type carefully:
read ip_address
echo IP address:$ip_address
echo Please wait...
#sudo pip install --upgrade awscli
bucket=$(aws s3api list-buckets --query "Buckets[].Name" | grep s3bucket | tr -d ',' | sed -e 's/"//g' | xargs)
#apigateway=$(aws apigateway get-rest-apis | grep id | cut -f2- -d: | tr -d ',' | xargs)
apigateway=$(aws apigateway get-rest-apis | jq  '.items[0].id' |xargs)
echo $apigateway
FILE_PATH="/home/ec2-user/environment/resources/public_policy.json"
FILE_PATH_2="/home/ec2-user/environment/resources/permissions.py"
FILE_PATH_3="/home/ec2-user/environment/resources/setup.sh"
FILE_PATH_4="/home/ec2-user/environment/resources/website/config.js"


##addging from lab 9
FILE_PATH_5="/home/ec2-user/environment/resources/global_waf_acl.json"
FILE_PATH_6="/home/ec2-user/environment/resources/regional_waf_acl.json"


oai_id=$(aws cloudfront list-cloud-front-origin-access-identities --query CloudFrontOriginAccessIdentityList.Items[?Comment==\`access-identity-cafe-website\`].Id --output text)
sed -i "s/<FMI_3>/$oai_id/g" $FILE_PATH
#####

sed -i "s/<FMI_1>/$bucket/g" $FILE_PATH
sed -i "s/<FMI_2>/$ip_address/g" $FILE_PATH
sed -i "s/<FMI>/$bucket/g" $FILE_PATH_2

sed -i "s/API_GW_BASE_URL_STR: null,/API_GW_BASE_URL_STR: \"https:\/\/${apigateway}.execute-api.us-east-1.amazonaws.com\/prod\",/g" $FILE_PATH_4

aws s3 cp ./resources/website s3://$bucket/ --recursive --cache-control "max-age=0"

python3 /home/ec2-user/environment/resources/permissions.py
python3 /home/ec2-user/environment/resources/seed.py


cd /home/ec2-user/environment/resources/codebase_partner

touch Dockerfile

echo 'FROM node:11-alpine
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "run", "start"]
' > Dockerfile


account_id=$(aws sts get-caller-identity --query "Account" --output "text")

docker build --tag cafe/node-web-app .

docker tag cafe/node-web-app:latest "${account_id}.dkr.ecr.us-east-1.amazonaws.com/cafe/node-web-app:latest"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.us-east-1.amazonaws.com"


docker push "${account_id}.dkr.ecr.us-east-1.amazonaws.com/cafe/node-web-app"

cd /home/ec2-user/environment

echo "setting up RDS"
MYPASS='coffee_beans_for_all'
# MYDB=`aws rds  describe-db-cluster-endpoints --query DBClusterEndpoints[0].Endpoint --output text`
MYDB=$(aws rds  describe-db-cluster-endpoints --query DBClusterEndpoints[?DBClusterIdentifier==\`supplierdb\`].Endpoint --output text)
echo $MYDB
mysql -h $MYDB -P 3306 -u admin -p$MYPASS -e "CREATE USER 'nodeapp' IDENTIFIED WITH mysql_native_password BY 'coffee';GRANT all privileges on COFFEE.* to 'nodeapp'@'%'; CREATE DATABASE COFFEE; USE COFFEE; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO 'nodeapp'@'%' WITH GRANT OPTION;"
mysql -h $MYDB -P 3306 -u admin -p$MYPASS -e "source ./resources/coffee_db_dump.sql"
echo "seeded rds"


echo "swap out beanstalk code"

mkdir bean
cd bean
touch Dockerrun.aws.json

echo '{
    "AWSEBDockerrunVersion": "1",
    "Image": {
       "Name": "'${account_id}'.dkr.ecr.us-east-1.amazonaws.com/cafe/node-web-app",
     "Update": "true"
    },
    "Ports": [ { "ContainerPort" : 3000 } ]
}' > Dockerrun.aws.json


aws s3 cp Dockerrun.aws.json s3://$bucket/ --cache-control "max-age=0"

echo "try spawn beanstalk"
# result = `aws elasticbeanstalk update-applicatiion --source"./bean/Dockerrun.aws.json"`
result=$(aws elasticbeanstalk create-application-version --application-name MyNodeApp --version-label v2 --description MyAppv2 --source-bundle S3Bucket="${bucket}",S3Key="Dockerrun.aws.json" --auto-create-application)

echo $result

result2=$(aws elasticbeanstalk update-environment --environment-name MyEnv --version-label v2)

echo $result2



#API GW stuff


#rest_api=`aws apigateway get-rest-apis --query items[0].id --output text`
# rest_api=`aws apigateway get-rest-apis --query items[?name==\`ProductsApi\`].id --output text`
rest_api=$(aws apigateway get-rest-apis --query items[?name==\`ProductsApi\`].id --output text)
parent_id=$(aws apigateway get-resources --rest-api-id ${rest_api} --query items[?path==\`/\`][id] --output text)

echo "rest_api"
echo $rest_api
echo "parent_id"
echo $parent_id

create_resource=$(aws apigateway create-resource --rest-api-id ${rest_api} --path-part 'bean_products' --parent-id ${parent_id})
echo $create_resource


bean_id=$(aws apigateway get-resources --rest-api-id ${rest_api} --query items[?path==\`/bean_products\`][id] --output text)
echo $bean_id


put_bean_result=$(aws apigateway put-method --rest-api-id ${rest_api} --resource-id ${bean_id} --http-method GET --authorization-type 'NONE' --no-api-key-required)

echo $put_bean_result


bs_url=http://$(aws elasticbeanstalk describe-environments --environment-names MyEnv --query Environments[0].CNAME --output text)/beans.json
echo $bs_url

put_bean_integration=$(aws apigateway put-integration --rest-api-id ${rest_api} --resource-id ${bean_id} --http-method GET --type HTTP_PROXY --integration-http-method GET --uri ${bs_url})

echo $put_bean_integration


# deploying=$(aws apigateway update-stage --rest-api-id ${rest_api} --stage-name prod --patch-operations op=update,path=\`/\`,value=string)
deploying=$(aws apigateway create-deployment --rest-api-id ${rest_api} --stage-name prod)
echo $deploying

###lab 9 stuff
#global waf stuff
global_ip_set=$(aws wafv2 create-ip-set --name office --scope CLOUDFRONT --ip-address-version IPV4  --addresses ${ip_address}/32)
echo $global_ip_set

#get ip set arn
global_ip_set_arn=$(aws wafv2 list-ip-sets --scope CLOUDFRONT --query 'IPSets[?Name==`office`].ARN'  --output text)
echo $global_ip_set_arn
#formatting with back slashes to use in command
global_ip_set_arn_sub=${global_ip_set_arn//\//\\/}

#update global_waf_acl.json with ip set arn
sed -i "s/<FMI_4>/$global_ip_set_arn_sub/g" $FILE_PATH_5

#create global waf acl
global_waf_acl=$(aws wafv2 create-web-acl --cli-input-json file://~/environment/resources/global_waf_acl.json)
echo $global_waf_acl

#get global acl arn
global_acl_arn=$(aws wafv2 list-web-acls --scope CLOUDFRONT --query 'WebACLs[?Name==`cafe-website-office-only-during-dev`].ARN'  --output text)
echo $global_acl_arn
#get cfront distro id
cfront_id=$(aws cloudfront list-distributions --query DistributionList.Items[0].Id --output text)
echo $cfront_id

echo "Associating WAF ACL with CloudFront"
python3 ~/environment/resources/associate_cfront_acl.py $cfront_id $global_acl_arn

#regional waf stuff
regional_ip_set=$(aws wafv2 create-ip-set --name office_regional --scope REGIONAL --ip-address-version IPV4  --addresses ${ip_address}/32)
echo $regional_ip_set

#get regional ip set arn
regional_ip_set_arn=$(aws wafv2 list-ip-sets --scope REGIONAL --query 'IPSets[?Name==`office_regional`].ARN'  --output text)
echo $regional_ip_set_arn
#formatting with back slashes to use in command
regional_ip_set_arn_sub=${regional_ip_set_arn//\//\\/}

#update global_waf_acl.json with ip set arn
sed -i "s/<FMI_5>/$regional_ip_set_arn_sub/g" $FILE_PATH_6

#create regional waf acl
regional_waf_acl=$(aws wafv2 create-web-acl --cli-input-json file://~/environment/resources/regional_waf_acl.json)
echo $regional_waf_acl

#get regional acl arn
regional_acl_arn=$(aws wafv2 list-web-acls --scope REGIONAL --query 'WebACLs[?Name==`website-api-gw-office-only-during-dev`].ARN'  --output text)
echo $regional_acl_arn
echo "Associating WAF ACL with API Gateway prod stage"
python3 ~/environment/resources/associate_apigateway_acl.py $regional_acl_arn $apigateway prod

#new for lab 12
#
sns_email_topic=$(aws sns list-topics --output text --query 'Topics[?ends_with(TopicArn, `:email`)]'[TopicArn])
echo "Asking for an SNS subscription"
echo Please enter a valid email address. Type carefully:
read student_email_address
echo Email Address:$student_email_address
student_email_subscription=$(aws sns subscribe --topic-arn ${sns_email_topic} --protocol email --notification-endpoint ${student_email_address})
echo $student_email_subscription
echo Please check your email inbox and your spam folder and use the confirmation link.
echo "done"

