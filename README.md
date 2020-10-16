# dtd-validator
Post xml and receive dtd validation in json format.

Valid
```json
{
  "status":"valid"
}
```

Invalid
```json
{
  "status":"invalid",
  "errors":[
    {
      "line":"15",
      "column":"20",
      "message":"Element type 'sarticle-meta' must be declared."
    },
    {
      "line":"369",
      "column":"11",
      "message":"The content of element type 'front' must match '(journal-meta?,article-meta,(def-list|list|ack|bio|fn-group|glossary|notes)*)'."
    }
  ]
}
```

Replace the contents of `webapp/dtd` with the DTD of your choice.
The `.dtd` file with 'jats' in the filename [will be determined](https://github.com/elifesciences/dtd-validator/blob/eb3eeaaad1c0648f490e046b2764d8f037a6f56f/webapp/dtd-validator.xqm#L11-L13) as the DTD to use.


# Docker
Build a container (based on `basexhttp`)
```
docker build . --tag elife-dtd:test
docker run --rm --memory="512Mi" -p 1984:1984 -p 8984:8984 elife-dtd:test
```
Interact with the service on port 8984
```
curl -F xml=@file.xml http://localhost:8984/dtd
```
