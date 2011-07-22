## expander - take a string and auto-magic it into an array
##
## the old way:
## $servers = ["server1.domain.com","server2.domain.com",...]
## $servers = ["server01.domain.com","server02.domain.com",...]
##
## the expander way:
## $servers = expander("server[1..20].domain.com")
## $servers = expander("server[01..20].domain.com")
## $servers = expander("server[01..17,18..20].domain.com")
## $servers = expander("server[a..f].domain.com")
## $servers = expander("server[01..06,7..10,a..b,A..C].domain.com")
##
module Puppet::Parser::Functions
    newfunction(:expander, :type => :rvalue) do |args|

        items = Array.new
        args.each { |arg|
            items.push( process( arg ) )
        }

        return items

    end
end

# process - handles the input and output of expand
# takes a string with a bracketed list and expands the list
def process(item)

    # strip any spaces
    item = item.gsub(/s+/,'')

    # swap [...] with %s for output formatting
    new_format = item.sub(/\[[a-zA-Z0-9\.\,]+\]/,'%s')

    # grab the values from the [...] group and process them
    values = Array.new
    expand( item.scan(/\[([a-zA-Z0-9\.\,]+)\]/).flatten[0] ).each { |value|
        values.push( sprintf new_format, value )
    }

    return values

end

# expand - the meat
# it takes a comma-separated list of values and iterates over them
# 00..02,3..6,7,8..10,a..c
def expand(ranges)

    # split up the list into individual ranges to traverse
    numbers = Array.new
    ranges.split(',').each{ |range|

        if range.match(/^[a-zA-Z0-9]+$/)
            # a single number in the list can just be added to the results
            numbers.push(range)

        elsif m = range.match(/^([a-zA-Z0-9]+)\.\.([a-zA-Z0-9]+)$/)
            # if this matched, the elements of the range will be in m[1] and m[2]

            if m[1].match(/[0-9]/)
                # play nice and preserve leading zeroes
                leading_zeroes = 0
                if m[1].match(/^0\d+/)
                    leading_zeroes = m[1].to_s.length
                elsif m[2].match(/^0\d+/)
                    leading_zeroes = m[2].to_s.length
                end

                # iterate through this range
                m[1].to_i.upto( m[2].to_i ) { |number|
                    numbers.push(sprintf "%0#{leading_zeroes}i", number)
                }
            else
                # iterating over letters doesn't require anything special
                # just count on up to m[2]
                m[1].upto( m[2] ) { |number|
                    numbers.push(number)
                }
            end
        else
            raise Puppet::ParseError, "Range #{range} is in an invalid or unsupported format"
        end
    }
    
    return numbers
end
