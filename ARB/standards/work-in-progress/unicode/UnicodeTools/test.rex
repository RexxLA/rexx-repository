  --Say "--- "~copies(5)--Say "--- "~copies(5)
  
  Options  DefaultString  NONE
  
  Call  Test  '01100001'B
  Say  result
  Exit
  
  Test:
  Use  Strict  Arg  a  =  'b'
  Return  Arg(1)

::Requires 'Unicode.cls'
