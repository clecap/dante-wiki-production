

# Debugging

## Container introspection

We can enter the containers for introspection by shell commands via

`docker exec -it my-lap-container /bin/ash`
`docker exec -it my-mysql /bin/ash`


## Connectivity Test

For a first test of the connectivity try to access the webserver at 

http://localhost:8080/wiki-dir/FAQ via `browser`, `wget` or `curl`.
