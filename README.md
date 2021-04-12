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

JATS DTDs are included in `webapp/dtds`.
To add (or replace) DTDs, add the files in the correct folder depending on its version and flavour, and update `webapp/dtds/catalogue.xml` with the version/filename (ensuring to include `.dtd`).

dtd version is derived from the `article/@dtd-version` attribute value in the xml file supplied. If there is no such attribute, then `1.2` is the default version.

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

The flavour of JATS can be optionally specified in a type parameter in the post:

```
curl -F xml=@file.xml -F "type=publishing" http://localhost:8984/dtd
```

If no type parameter is supplied, then archiving is used by default.