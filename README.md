# UITestKit

A framework for automating server side of UI testing and mocking API responses for feature development.

_This framework is currently under development and until completion I'll not be helping with any issues you might have. You are still welcome to contribute with suggestions, improvements, ideas ..._

### Usage

As simple as

```
let kit = UITestKit(port: 4321, fixtureDirectory: "<path to fixtures>")
try! kit.listen()
```

### File naming

File names are important when it comes to defining the behaviour of the server.

Filenames can either be:

1. `METHOD_aparam-value1&bparam-value2.json` (query get parameters ordered alphabetically. Can be arbi)
2. `METHOD_default.json` (eg. `GET_default.json`, `POST_default.json`)
3. `default.json`

Files will be tried in the order listed above. If a file cannot be found an error will be returned.

### Folder structure

Response files are looked up in the same manner as the URL path. `/` index starts at the root folder and goes in for each request subpath. Once the end is reached UITestKit expects the folder to contain folders that represent the corresponding HTTP response code. At the very least a folder named `200` should be present that contains successful responses. For each status code you'd like to see returned you must create a separate folder. The files in each folder can be arbitrary but have to follow the rules specified under _File naming_.

For example a request `http://localhost:1234/users/active` will begin in the root fixture directory (as specified in the constructor). It will then change directory to `users` and then `active` then because the end of the path has been reached it will change to folder `200`. From there it will return a file based on the rules defined in _File naming_.

#### Wildcard paths

Some URL requests have a unique path component in the request that can change. For example `http://localhost:1234/users/location/{CITY_NAME}`. You could create folders for some concrete examples (eg. `London`, `New York City`, `Ljubljana`) but if you wish to have a default folder that will be used for fixtures if no matches are found you can name the folder `*`. If no folders are found with the speficied path component UITestKit will attempt to change directory to `*` or return an error if there isn't one present.

### Modifying requests

By default all response files will be looked up in the 200 status code folder. To change this behaviour use TBD.
