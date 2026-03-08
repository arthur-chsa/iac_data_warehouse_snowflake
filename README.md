# iac_data_warehouse_snowflake


## Snowflake setup to allow authentication with pair of keys

### Generate private key
```
openssl genrsa 2048 | openssl pkcs8 -topk8 -v2 des3 -inform PEM -out rsa_key.p8
```

### Generate public key
```
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```

### Grant privilege to assign a public key to a user
```
GRANT MODIFY PROGRAMMATIC AUTHENTICATION METHODS ON USER TERRAFORM_SA
TO ROLE ACCOUNTADMIN;
```

### Assign the public key to the user, removing the delimiters (first and last lines)
```
ALTER USER TERRAFORM_SA SET RSA_PUBLIC_KEY='';
```