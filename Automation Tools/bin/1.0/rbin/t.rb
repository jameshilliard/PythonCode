require 'rubygems'
require 'json/pure'

some_data = {'foo' =>1, 'bar'=> 20,"cow"=>[1, 2, 3, 4], "moo"=>{"cat"=>"meow", "dog"=>"woof"}, "foo"=>1, "bar"=>20}
JSON.pretty_generate(some_data)
