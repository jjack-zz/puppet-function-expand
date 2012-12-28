puppet-function-expand
=
Take a string and auto-magic it into an array

the old way
-
    $servers = ["server1.domain.com", ... ,"server10.domain.com"]
    $servers = ["server01.domain.com", ... ,"server10.domain.com"]
    $servers = ["server01.domain.com", ... ,"server17.domain.com", "server18.domain.com", ..., "server20.domain.com"]
    $servers = ["serverA.domain.com", ..., "serverF.domain.com"]

the new, expand way
-
    $servers = expand("server[1..10].domain.com")

    # preserves your space padding
    $servers = expand("server[01..10].domain.com")

    # supports broken lists
    $servers = expand("server[01..17,18..20].domain.com")

    # iterates over letters (alphabetically) as well as numbers
    $servers = expand("server[A..F].domain.com")

    # can iterate over both types at once
    $servers = expand("server[01..06,7..10,a..b,A..C].domain.com")
