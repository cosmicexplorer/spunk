spunk
=====

If we wish to perform the NFA->DFA optimization, then we'll need to specify parsers in a less imperative and more declarative way. This also has the added benefit of being more declarative, which reduces the burden on the user to write intense logic loops themselves. However, specifying things declaratively and possibly performing the NFA->DFA optimization would remove the ability (unless there's something clever I'm missing) to modify the parser being used while the parser is running, which is a super niche and advanced feature anyway, but is also kind of cool.
