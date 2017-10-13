local tpl = [[
<!DOCTYPE html>
<html>

<head>
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8"/>
<title>PedF UK v Praze - novinky</title>
<link href="http://www.pedf.cuni.cz/css/css.css" rel="stylesheet" type="text/css" media="screen">

</head>

<body> 

<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
   <td width="25%" valign="top" >
    <iframe name="hlavni" src="{{konspekt}}" width="100%" height="660"  frameborder="0" align="baseline">
     </iframe>
   </td>

   <td width="75%" valign="top">
    <iframe name="jin" src="{{body}}" width="100%" height="660" frameborder="0" align="baseline">
    </iframe> 
   </td>
 </tr>
</table>
  </body>
</html>
]]

local body = arg[1]
local konspekt = arg[2]
local out = tpl:gsub("{{body}}",body):gsub("{{konspekt}}",konspekt)
print(out)
