s = <<-END
This is an example.
    a = 1
Of what I mean.
    b = 2
And it can go on
like this.

    c = 3
For ever and ever.

    d = 4
END

a = s.scan(/(.*?(\s+)\s+[^\n]+?\n(?=\2\S|\z))/m)

p a
#p a.map{ |x| x[0] }
