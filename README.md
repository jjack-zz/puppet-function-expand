puppet-function-expander
=
Take a string and auto-magic it into an array

the old way
-
    $servers = ["server1.domain.com", ... ,"server10.domain.com"]
    $servers = ["server01.domain.com", ... ,"server10.domain.com"]
    $servers = ["server01.domain.com", ... ,"server17.domain.com", "server18.domain.com", ..., "server20.domain.com"]
    $servers = ["serverA.domain.com", ..., "serverF.domain.com"]

the new, expander way
-
    $servers = expander("server[1..10].domain.com")

    # preserves your space padding
    $servers = expander("server[01..10].domain.com")

    # supports broken lists
    $servers = expander("server[01..17,18..20].domain.com")

    # iterates over letters (alphabetically) as well as numbers
    $servers = expander("server[A..F].domain.com")

    # can iterate over both types at once
    $servers = expander("server[01..06,7..10,a..b,A..C].domain.com")
