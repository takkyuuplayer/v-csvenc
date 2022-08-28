module csvenc

import takkyuuplayer.bytebuf

fn test_new_writer() ? {
	w := bytebuf.Buffer{}
	{
		writer := new_writer(writer: w)?

		assert writer.delimiter == `,`
		assert writer.use_crlf == false
	}
	{
		// with config
		writer := new_writer(writer: w, delimiter: `\t`, use_crlf: true)?

		assert writer.delimiter == `\t`
		assert writer.use_crlf == true
	}
	{
		// with invalid delimiter
		if writer := new_writer(writer: w, delimiter: `あ`) {
			assert false
		} else {
			assert err.str() == 'invalid delimiter: あ'
		}
	}
}

struct WriteTestCase {
	input        []string
	output       string
	use_crlf     bool
	delimiter    rune = `,`
	always_quote bool
}

fn test_write() ? {
	cases := [
		WriteTestCase{
			input: ['abc']
			output: 'abc\n'
		},
		WriteTestCase{
			input: ['abc']
			output: 'abc\r\n'
			use_crlf: true
		},
		WriteTestCase{
			input: ['"abc"']
			output: '"""abc"""\n'
		},
		WriteTestCase{
			input: ['a"b']
			output: '"a""b"\n'
		},
		WriteTestCase{
			input: [' abc']
			output: ' abc\n'
		},
		WriteTestCase{
			input: ['abc,def']
			output: '"abc,def"\n'
		},
		WriteTestCase{
			input: ['abc\ndef']
			output: '"abc\ndef"\n'
		},
		WriteTestCase{
			input: ['abc\ndef']
			output: '"abc\r\ndef"\r\n'
			use_crlf: true
		},
		WriteTestCase{
			input: ['abc\rdef']
			output: '"abc\rdef"\n'
		},
		WriteTestCase{
			input: ['abc\rdef']
			output: '"abcdef"\r\n'
			use_crlf: true
		},
		WriteTestCase{
			input: ['']
			output: '\n'
		},
		WriteTestCase{
			input: ['', '']
			output: ',\n'
		},
		WriteTestCase{
			input: ['', '', '']
			output: ',,\n'
		},
		WriteTestCase{
			input: ['', '', 'a']
			output: ',,a\n'
		},
		WriteTestCase{
			input: ['', 'a', '']
			output: ',a,\n'
		},
		WriteTestCase{
			input: ['', 'a', 'a']
			output: ',a,a\n'
		},
		WriteTestCase{
			input: ['a', '', '']
			output: 'a,,\n'
		},
		WriteTestCase{
			input: ['a', '', 'a']
			output: 'a,,a\n'
		},
		WriteTestCase{
			input: ['a', 'a', '']
			output: 'a,a,\n'
		},
		WriteTestCase{
			input: ['a', 'a', 'a']
			output: 'a,a,a\n'
		},
		WriteTestCase{
			input: ['\\.']
			output: '"\\."\n'
		},
		WriteTestCase{
			input: ['x09\x41\xb4\x1c', 'aktau']
			output: 'x09\x41\xb4\x1c,aktau\n'
		},
		WriteTestCase{
			input: [',x09\x41\xb4\x1c', 'aktau']
			output: '",x09\x41\xb4\x1c",aktau\n'
		},
		WriteTestCase{
			input: ['a', 'a', '']
			output: 'a|a|\n'
			delimiter: `|`
		},
		WriteTestCase{
			input: [',', ',', '']
			output: ',|,|\n'
			delimiter: `|`
		},
		WriteTestCase{
			input: ['a', 'a', '']
			output: '"a","a",""\n'
			always_quote: true
		},
	]

	for _, tt in cases {
		w := bytebuf.Buffer{}
		mut writer := new_writer(
			writer: w
			use_crlf: tt.use_crlf
			delimiter: tt.delimiter
			always_quote: tt.always_quote
		)?
		writer.write(tt.input)?
		writer.flush()?
		assert w.bytes().bytestr() == tt.output
	}
}

fn test_write_all() ? {
	w := bytebuf.Buffer{}
	mut writer := new_writer(writer: w)?
	writer.write_all([['a', 'b', 'c'], ['d', 'e', 'f']])?

	assert w.bytes().bytestr() == 'a,b,c\nd,e,f\n'
}
