# UUID Identifiers

Hyacinth switched to using UUID (v4) identifiers in version 2.5, previously using Fedora 3 PIDs (e.g. abc:123).

## Why?

- UUIDs (v4) are quick to create, unlike DOIs (which are created by a request to an external service). UUID values are stored in a database with a unique column, so in the *extremely* rare case of a collision during random minting, we'll identify the collision and simply mint another UUID.
- UUIDs (v4) are sufficiently random and there are effectively an unlimited number of them.
- We want to stop using PIDs as primary identifiers in order to decouple Hyacinth from its potential publish targets (in this case, Fedora 3, but eventually Fedora 4 or other systems).
- UUIDs are made up of a simple set of alphanumeric characters, which translate well to file names across different systems (unlike PIDs, which contain a colon character).
