module Puppet::Parser::Functions
    newfunction(:expand, :type => :rvalue) do |args|

        items = Array.new
        args.each { |arg|
            items.push( expand( arg ) )
        }

        return items

    end
end

# take an item with a bracketed list and expands the list
def expand(item)

    # strip out any spaces
    item = item.gsub(/\s+/,'')

    # swap [...] with %s for output formatting
    new_format = item.sub(/\[[a-zA-Z0-9\.\,]+\]/,'%s')

    # was anything swapped out?
    if new_format != item
        # grab the values from the [...] group and process them
        values = Array.new
        process( item.scan(/\[([a-zA-Z0-9\.\,]+)\]/).flatten[0] ).each { |value|
            values.push( sprintf new_format, value )
        }

        return values
    else
        # there was nothing to swap out
        return item
    end
end

# take a comma-separated list of values and iterates over them
def process(ranges)

    processed = Array.new

    # split the list into individual ranges to traverse
    ranges.split(',').each{ |range|

        if range.match(/^[a-zA-Z0-9]+$/)
            # a single number in the list can just be added to the results
            processed.push(range)

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
                    processed.push(sprintf "%0#{leading_zeroes}i", number)
                }
            else
                # iterating over letters doesn't require anything special
                # just count on up to m[2]
                m[1].upto( m[2] ) { |number|
                    processed.push(number)
                }
            end
        else
            raise Puppet::ParseError, "Range #{range} is in an invalid or unsupported format"
        end
    }
    return processed
end
