module namespace e = 'http://elifesciences.org/modules/validate';
import module namespace rest = "http://exquery.org/ns/restxq";

declare
  %rest:path("/dtd")
  %rest:POST("{$data}")
  %output:method("json")
function e:validate-dtd($data as item()+)
{
  let $param-count := count($data)
  return
    if ($param-count gt 2) then  error (
                                        xs:QName("basex:error"),
                                        (count($data)||' is too many parameters for this request')
                                      )
    else if (empty(for $param in $data where $param instance of document-node() return $param)) then error (
                                        xs:QName("basex:error"),
                                        ('An xml file must be supplied to validate')
                                      )
    else if ($param-count=2) then (
      let $xml := for $param in $data where $param instance of document-node() return $param
      let $type := for $param in $data where $param instance of xs:string return $param
      let $version := e:get-version($xml)
      let $dtd := e:get-dtd($version,$type)
      let $report :=  validate:dtd-report($xml,$dtd)
  
      return e:dtd2json($report)
    )
    (: default is archiving if no type is provided :)
    else (
      let $xml := for $param in $data where $param instance of document-node() return $param
      let $type := "archiving"
      let $version := e:get-version($xml)
      let $dtd := e:get-dtd($version,$type)
      let $report :=  validate:dtd-report($xml,$dtd)
  
      return e:dtd2json($report)
    )
};

(: get dtd version from dtd-version attribute on root.
   if the attribute is missing the default version is 1.2:)
declare function e:get-version($xml){
  if ($xml//*:article/@dtd-version) then $xml//*:article/@dtd-version
  else '1.2'
};

declare function e:get-dtd($version,$type){
  let $cat := doc(file:base-dir()||'dtds/catalogue.xml')
  let $dtd-folder := file:base-dir()||'dtds/'||$type||'/'
  return
  switch ($type)
      case "publishing" return let $dtd-file := $cat//*:publishing/*:dtd[@version=$version]/@uri
                               return ($dtd-folder||$version||'/'||$dtd-file)
      case "authoring" return let $dtd-file := $cat//*:authoring/*:dtd[@version=$version]/@uri
                               return ($dtd-folder||$version||'/'||$dtd-file)
      (: default is archiving :)
      default return let $dtd-file := $cat//*:archiving/*:dtd[@version=$version]/@uri
                     return ($dtd-folder||$version||'/'||$dtd-file)
};

declare function e:dtd2json($report){
   if ($report//*:status/text() = 'valid') then json:parse('{"status": "valid"}')
   else json:parse(concat(
       '{"status": "invalid",',
       '"errors": [', 
       string-join(for $error in $report//*:message
                     return ('{'||
                            ('"line": "'||$error/@line/string()||'",')||
                            ('"column": "'||$error/@column/string()||'",')||
                            ('"message": "'||replace($error/data(),'"',"'")||'"')||
                            '}')
                   ,','),
       ']}'))
};