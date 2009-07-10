HashBuilder.define(:foobar) do |b|
  b.build_hash do
    b.hash[:first_name] = "Dave"
    b.hash[:last_name] = "Brady"
  end 
end
 
