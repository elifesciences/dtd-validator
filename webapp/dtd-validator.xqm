module namespace e = 'http://elifesciences.org/modules/validate';
import module namespace rest = "http://exquery.org/ns/restxq";

declare
  %rest:path("/dtd")
  %rest:POST("{$xml}")
  %input:text("xml","encoding=UTF-8")
  %output:method("json")
function e:validate-dtd($xml)
{
  let $dtd-folder := (file:base-dir()||'dtd/')
  let $dtd := ($dtd-folder||
              file:list($dtd-folder)[ends-with(.,'.dtd') and contains(lower-case(.),'jats')])
  let $report :=  validate:dtd-report($xml,$dtd)
  
  return e:dtd2json($report)
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