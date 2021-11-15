/*
MIT License

Copyright (c) 2019 Waqar Ahmed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

module progressbar

import time
import term { erase_line, get_terminal_size }

fn difftime(b time.Time) int {
	temp := time.now()
	offset := ((temp.minute - b.minute) * 60 ) + (temp.second - b.second)
	return offset
}

fn get_screen_width() int {
	cols, _ := get_terminal_size()
	return cols
}

fn printchar(s byte) {
	if isnil(s) {
		panic('printchar(NIL)')
	}
	print('${s.ascii_str()}')
	return
}

const (
	default_screen_width = 80
	min_bar_width = 10
	whitespace_length = 2
	bar_border_width = 2
	eta_format_length = 13
)

pub struct Progressbar {
mut:
	max u64
	value u64

	start time.Time
	label string

	begin byte
	fill byte
	end byte
}

struct ProgressbarTime {
	hours int
	min int
	sec int
}

pub fn (mut p Progressbar) new_with_format (label string, max u64, format []rune) {
	p.max = max
	p.value = 0
	p.label = label
	p.start = time.now()

	p.begin = format[0]
	p.fill = format[1]
	p.end = format[2]
}

pub fn (mut p Progressbar) new (label string, max u64) {
	p.new_with_format(label, max, [rune(`|`), rune(`=`), rune(`|`)])
}

fn (mut p Progressbar) update(value u64) {
	p.value = value
	p.draw()
}

fn (mut p Progressbar) update_label(label string) {
	p.label = label
}

pub fn (mut p Progressbar) increment() {
	p.update(p.value + u64(1))
}

fn (p Progressbar) write_char(ch byte, times int) {
	for i := 0; i < times; i++ {
        printchar(ch)
	}
}

fn max (a int , b int) int {
	if a > b {
		return a
	} else {
		return b
	}
}

fn progressbar_width(screen_width int, label_len int) int {
	return max(min_bar_width, screen_width - label_len - eta_format_length - whitespace_length)
}

fn progressbar_label_width (screen_width int, label_len int, bar_width int) int {
	if label_len + 1 + bar_width + eta_format_length > screen_width {
		return max(0, screen_width - bar_width - eta_format_length - whitespace_length)
	}
	else {
		return label_len
	}
}



fn (p Progressbar) remaining_seconds() int {

	offset := difftime(p.start)
	if (p.value > 0) && (offset > 0) {
		return int ( (f64(offset) / f64(p.value)) * (int(p.max) - int(p.value)) )
	} else {
		return 0
	}
}

fn calc_time_components (secs int) ProgressbarTime {
	mut seconds := secs
	hours := seconds / 3600
	seconds -= hours * 3600
	mins := seconds / 60
	seconds -= mins * 60

	components := ProgressbarTime{hours, mins, seconds}
	return components
}

fn (p Progressbar) draw() {
	printchar(`\r`)
	// type: 0 -> current cursor position to end of the line
	// type: 1 -> current cursor position to beginning of the line
	// type: 2 -> clears entire line
	erase_line('2')
	screen_width := get_screen_width()
	label_len := p.label.len
	mut bar_width := progressbar_width(screen_width, label_len)
	label_width := progressbar_label_width(screen_width, label_len, bar_width)

	completed := if p.value >= p.max {
		true
	} else {
		false
	}

	x := f64(p.value) / f64(p.max)
	bar_piece_count := bar_width - bar_border_width
	bar_piece_current := if completed {
		bar_piece_count
	} else {
		int(f64(bar_piece_count) * x)
	}

	offset := difftime(p.start)
	eta := if completed {
		calc_time_components(offset)
	} else {
		calc_time_components(p.remaining_seconds())
	}

	if label_width == 0 {
		bar_width += 1
	} else {
        print(p.label)
		printchar(` `)
	}

	printchar(p.begin)
	p.write_char(p.fill, bar_piece_current)
	p.write_char(` `, bar_piece_count - bar_piece_current)
	printchar(p.end)

	printchar(` `)
	eta_format := 'ETA:${eta.hours}h/${eta.min}m/${eta.sec}s'//.substr(0, eta_format_length)
	print(eta_format)
}

pub fn (p Progressbar) finish() {
	p.draw()
	println('')
}
