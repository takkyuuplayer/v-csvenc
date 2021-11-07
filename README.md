# v-csvenc

![CI](https://github.com/takkyuuplayer/v-csvenc/workflows/CI/badge.svg)

Port of Go's encoding/csv

```v
import takkyuuplayer.csvenc

fn main() {
	mut output := os.stdout()
	mut buf := csvenc.new_writer(writer: output)
	buf.write(['a', 'b', 'c']) ?
	buf.flush() ?               // Output: a,b,c
}
```
