# initilaztion
kubectl exec -it vault-0 -- /bin/sh

vault status

vault operator init

vault operator unseal <token 1>
vault operator unseal <token 2>
vault operator unseal <token 3>

vault login <Initial Root Token>

# secrets
vault secrets enable -path=crds kv-v2
vault kv put crds/mysql username=root password=12345 apikey=adsaiojB78VIHGIhdas
vault kv metadata  get crds/mysql
vault kv get crds/mysql

# authorization
cat <<EOF > /home/vault/app-policy.hcl
path "crds/data/mongodb" { 
   capabilities = ["create", "update", "read"]
} 

path "crds/data/mysql" { 
   capabilities = ["read"]
}
EOF

vault policy write app /home/vault/app-policy.hcl
vault policy list
export VAULT_TOKEN="$(vault token create -field token -policy=app)"
vault kv put crds/mysql username=siddharth


# authentication
vault auth enable kubernetes

vault write auth/kubernetes/config \
   token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
   kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/phpapp \
   bound_service_account_names=app \
   bound_service_account_namespaces=demo \
   policies=app \
   ttl=1h

# app-deploy
kubectl create ns demo 
kubectl apply -f php-vault.yaml -n demo
kubectl patch deploy php -p "$(cat patch-annotations.yaml)" -n demo
kubectl patch deploy php -p "$(cat patch-annotations-template.yaml)" -n demo
