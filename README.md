# elm-networking
An example elm project that talks to a socket.io server.

To run:
* Compile Elm code: `elm make Counters.elm --yes`
* Install Node dependencies: `npm install`
* Run node server: `server.js`
* Navigate to `http://localhost:3000` in a browser
* Open a new tab also pointing to `http://localhost:3000` to witness the interaction

Some notes:
* It does some stuff that might be a little unsafe because it's a demo.
* It only takes 2 clients, ever.
