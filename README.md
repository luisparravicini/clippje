clippje
=======

*Warning: this is an unfinished project! It works but it doesn't generate good texts.*

Clippje generates text using a Markov chain and some heuristics.

It can work interactively like a predictive keyboard or generate sentences without user intervention.

It needs some texts to process. It was designed to work on project Gutenberg's books. There's a [downloader.rb](bin/downloader.rb) script to download all books within a bookshelf (bookshelf url has to be changed in the script).

You can also copy some html files on `texts/corpus_name`. Each file should have a "Language: English" within a \<pre\> tag. Everything inside \<p\> tags is processed.

Then you run `./bin/clippje.rb` 

All the available options are:

```
maui:clippje xrm0$ ./clippje.rb -h
Usage: ./gen_text.rb [-i] <-c corpus>
    -i, --interactive                Interactive
    -c, --corpus NAME                Corpus
    -r, --recreate-cache             Recreate cache
    -l, --list                       List available corpuses
```


How it works
------------

Each paragraph of all the corpus' files is used to creates markov chains of order 2, 3 and 4.

When it has generate a word, it selects the probabilities for the current text for all the available chains, randomly chooses one and from that list, a random word.
