# Current plan with src/

Create three groupings of directories, each that have data structures and parsing for each unique JSON dataset from MTGJSON:

- ``AllPrices/AllPricesToday.json`` - Price data by 90 day period or 1 day
- ``AtomicCards.json`` - Card data
- ``AllIdentifiers.json`` - Mapping of uuid to atomic card data
