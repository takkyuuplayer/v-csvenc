import os
import examples.csvenc

fn main() {
	mut output := os.stdout()
	mut buf := csvenc.new_writer(writer: output)?
	buf.write(['a', 'b', 'c'])?
	buf.flush()? // Output: a,b,c
}
