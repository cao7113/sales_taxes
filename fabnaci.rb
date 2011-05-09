def fab(n)
  return 0 if n<0
  return 1 if n==0
  return 1 if n==1
  fab(n-1)+fab(n-2)
end


a,b,y=0,6,0
(a..b).each do |x|
  puts fab(x)
end