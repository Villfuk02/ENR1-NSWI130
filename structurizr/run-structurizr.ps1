$workspace = (Resolve-Path .).Path
docker run -it --rm -p 8080:8080 -v "${workspace}:/usr/local/structurizr" structurizr/lite
