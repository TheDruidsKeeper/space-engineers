set folder="C:\World\"
set dedicated="C:\ProgramData\SpaceEngineersDedicated\"
if !exist %folder% (
  mkdir %folder%
)
if exist %dedicated% (
  rmdir %dedicated%
)
mklink /J %dedicated% %folder%
