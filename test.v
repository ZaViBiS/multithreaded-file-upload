import os
fn main() {
	//embedded_file := $embed_file('v.png')
    mut f := os.create('test.txt') or {
        println(err)
        return
    }
    f.write('test'.bytes()) or { println(err) }
    f.close()
	// os.open_file('exported.txt', 'wb').write('test'.bytes()) ?
}