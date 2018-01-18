RSwift
=========

RSwift is a low-level library that provides [signal/slot] and [functional reactive programming]-like primitives. It can serve as the basis for a user
interface toolkit, or any other library that has a model on which clients will
listen and to which they will react.

RSwift is a port of [React](http://github.com/threerings/react), a Java
library that was originally created by Three Rings Design, and which has nothing to do with the JavaScript UI toolkit of the same name. 

(RSwift omits the "Futures" and "Promises" components of the original React library; [PromiseKit](https://github.com/mxcl/PromiseKit) is the defacto Promises implementation in Swift.)

Distribution
------------

RSwift is released under the MIT License. The most recent version of the
library is available at http://github.com/tconkling/rswift

Contact
-------

Feel free to open issues on the project's Github home.

Twitter: [@timconkling](http://twitter.com/timconkling)

[signal/slot]: http://en.wikipedia.org/wiki/Signals_and_slots
[functional reactive programming]: http://en.wikipedia.org/wiki/Functional_reactive_programming
