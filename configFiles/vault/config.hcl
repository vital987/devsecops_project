api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"
ui = false
disable_mlock = true

storage "raft" { 
    path = "/opt/vault/data"
    node_id = "node1"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = true
}
