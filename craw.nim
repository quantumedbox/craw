# Small utility for creating binary C constants from files
import std/[os, strutils]

proc process(target: string, output_ident: string, output_path: string) =
  var file: File
  if not open(file, target):
    echo "can't open file"
    return
  let data = file.readAll()
  file.close()
  var data_in_hex = newStringOfCap(data.len * 3)
  for idx, ch in data[0..data.high]:
    data_in_hex &= "0x" & toHex(ch.byte) & ','
  data_in_hex &= "0x" & toHex(data[data.high].byte)
  var output: File
  if open(output, output_path, fmWrite):
    let final = "const char " & output_ident & "[] = {" & data_in_hex & "};"
    output.write(final)
    output.close()
  else:
    echo "can't write output"

when isMainModule:
  if paramCount() > 1:
    if paramCount() > 2:
      process(paramStr(1), paramStr(2), paramStr(3))
    else:
      process(paramStr(1), paramStr(2), paramStr(2) & ".h")
  else:
    echo "no target specified"
