module csvenc

import takkyuuplayer.bufwriter
import io

// A Writer writes records using CSV encoding.
pub struct Writer {
	delimiter    rune
	use_crlf     bool
	always_quote bool
mut:
	bw bufwriter.Writer
}

// Config are options that can be given to a writer
pub struct Config {
	writer       io.Writer
	delimiter    rune = `,`
	use_crlf     bool
	always_quote bool
}

pub fn new_writer(c Config) ?&Writer {
	if !valid_delim(c.delimiter) {
		return error('invalid delimiter: $c.delimiter')
	}

	return &Writer{
		bw: bufwriter.new(writer: c.writer)
		delimiter: c.delimiter
		use_crlf: c.use_crlf
		always_quote: c.always_quote
	}
}

pub fn (mut w Writer) write(fields []string) ? {
	le := if w.use_crlf { '\r\n' } else { '\n' }
	for n, field_ in fields {
		mut field := field_
		if n > 0 {
			w.bw.write(w.delimiter.str().bytes()) ?
		}
		if !w.field_needs_quotes(field) {
			_ = w.bw.write(field.bytes()) ?
			continue
		}
		w.bw.write('"'.bytes()) ?
		for field.len > 0 {
			mut i := field.index_any('"\r\n')
			if i < 0 {
				i = field.len
			}
			w.bw.write(field[..i].bytes()) ?
			field = field[i..]
			if field.len > 0 {
				z := field[0]
				match z {
					`"` {
						w.bw.write('""'.bytes()) ?
					}
					`\r` {
						if !w.use_crlf {
							w.bw.write('\r'.bytes()) ?
						}
					}
					`\n` {
						w.bw.write(le.bytes()) ?
					}
					else {}
				}
				field = field[1..]
			}
		}
		w.bw.write('"'.bytes()) ?
	}
	w.bw.write(le.bytes()) ?
}

pub fn (mut w Writer) flush() ? {
	w.bw.flush() ?
}

pub fn (mut w Writer) write_all(records [][]string) ? {
	for _, record in records {
		w.write(record) ?
	}
	w.flush() ?
}

fn (w &Writer) field_needs_quotes(field string) bool {
	if w.always_quote {
		return true
	}
	if field == '' {
		return false
	}
	if field == '\\.' {
		return true
	}
	if field.contains(w.delimiter.str()) || (field.index_any('"\r\n') != -1) {
		return true
	}
	return false
}

fn valid_delim(b rune) bool {
	return b != 0 && b != `"` && b != `\r` && b != `\n` && b < 255
}
