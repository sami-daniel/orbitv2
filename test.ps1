Write-Output "Prefer run this with act tool"

docker build --target test -t orbit:test .
docker run --rm orbit:test
