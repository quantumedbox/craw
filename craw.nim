# Small utility for creating binary C constants from files such as png images and shader code
import std/[os, strutils]
import nimPNG

func bytes_to_c_array_init(data: string): string =
  result = newStringOfCap(data.len * 3)
  for idx, ch in data[0..data.high]:
    result &= "0x" & toHex(ch.byte) & ','
  result &= "0x" & toHex(data[data.high].byte)

proc process_png*(data: string, c_name: string): string =
  let image = decodePNG32(data)
  result = "const char " & c_name & "[] = {" & bytes_to_c_array_init(image.data) & "};\n"
  result &= "const size_t " & c_name & "_width = " & $image.width & ";\n"
  result &= "const size_t " & c_name & "_height = " & $image.height & ";"

func process_binary*(data: string, c_name: string): string =
  "const char " & c_name & "[] = {" & bytes_to_c_array_init(data) & "};"

proc process*(target: string, c_name: string, output_path: string) =
  var file: File
  if not open(file, target):
    echo "can't open file"
    return
  let data = file.readAll()
  file.close()

  let final =
    if target.endswith(".png"):
      process_png(data, c_name)
    else:
      process_binary(data, c_name)

  var output: File
  if open(output, output_path, fmWrite):
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
