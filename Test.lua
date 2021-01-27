f = {"Zee","Slit","mpf"}

local index={}
for k,v in pairs(f) do
   index[v]=k
end
tostring(index["Zee"])