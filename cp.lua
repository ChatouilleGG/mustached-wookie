
--[[ IMPORTANT NOTES

before enabling this CGI script on an Apache server,
an empty folder named 'cp' should be created in the same folder as this script.

in order to correctly locate the files queried in URLs,
the .htaccess file in the script folder must contain this:
RewriteEngine on
RewriteRule cp[/]([a-zA-Z0-9]+)$ cp.lua?$1 [L]
--]]

local old_tostring = tostring;

-- tostring for tables, used for debugging only
local function tostring(D, indent)
	indent = indent or 0;
	local str = "";
	if ( type(D) == "table" ) then
		local str = "{\n";
		for i=1,indent do
			str = str.."\t";
		end
		for k,v in pairs(D) do
			str = str .. "\t"..tostring(k).." : "..tostring(v,indent+1).."\n";
			for i=1,indent do
				str = str.."\t";
			end
		end
		return str.."}";
	end
	return old_tostring(D);
end

--================================================================
-- Processing GET/POST
--================================================================

local fchar = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
fchar_len = 62;

--================ GET ================
-- grab the target file name if queried in URL
local fname = os.getenv("QUERY_STRING");
if ( string.len(fname) == 0 ) then
	fname = nil;
end

--================ POST ================
if ( os.getenv("REQUEST_METHOD") == "POST" ) then
	local data = io.read(tonumber(os.getenv("CONTENT_LENGTH")));
	local text,button = string.match(data, "^pastebin=(.*)&([^=]*).*$");
	if ( button == "send" ) then

		-- special characters replacement
		text = string.gsub(text, "+", " ");
		text = string.gsub(text, "%%(..)", function(hex) return string.char(tonumber(hex,16)) end);

		if ( fname ~= nil ) then
			local cp = io.open("cp/"..fname..".txt", "w");
			cp:write(text);
			io.close(cp);

		else
			-- create new file for this paste
			fnew = "";
			math.randomseed(os.time()); math.random(); math.random(); math.random();
			for i=1,6 do
				local r = math.random(1, fchar_len);
				fnew = fnew .. string.sub(fchar, r,r);
			end
			local cp = io.open("cp/"..fnew..".txt", "w");
			cp:write(text);
			io.close(cp);
			print("Location: http://82.229.28.10:56002/scripts/cp/"..fnew.."\n\n");
			exit();
		end
	end
end

--================================================================
-- HTML Generation
--================================================================

--================ HTML Head ================
print("Content-type: text/html; charset=iso-8859-1\n\n");
print("<html>");
print("<head>");
print("<title>- Paste Bin -</title>");
print("</head>");
print("<body>");
print("<br>");

--================ Form, Text, Button ================
if ( fname ~= nil ) then
	print("<form method=POST action=\""..fname.."\">");
else
	print("<form method=POST action=\"cp.lua\">");
end

print("<center>");
print("<textarea name=\"pastebin\" cols=\"110\" rows=\"32\"/>");

if ( fname ~= nil ) then
	local f = io.open("cp/"..fname..".txt", "r");
	if ( f ~= nil ) then
		for line in f:lines() do
			io.write(line);
		end
		io.close(f);
	end
end

print("</textarea>");

print("<br>");
print("<p><input type=submit name=\"refresh\" value=\"  Refresh  \">    <input type=submit name=\"send\" value=\"    Send    \">");
print("</center>");

print("</form>");

--================ HTML Tail ================
print("</body>");
print("</html>");
